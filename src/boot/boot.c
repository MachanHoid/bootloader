#include <inttypes.h>
#include "memory_map.h"

#include <stdbool.h>
#include <stdint.h>
#include "inc/hw_ints.h"
#include "inc/hw_memmap.h"
#include "inc/hw_types.h"
#include "driverlib/gpio.h"
#include "driverlib/interrupt.h"
#include "driverlib/pin_map.h"
#include "driverlib/sysctl.h"
#include "driverlib/uart.h"
#include "utils/uartstdio.h"
#include "driverlib/flash.h"

//defining memory map variables
uint32_t approm_start = &__approm_start__;
uint32_t approm_size = &__approm_size__;
uint32_t bootrom_start = &__bootrom_start__;
uint32_t bootrom_size = &__bootrom_size__;
uint32_t appheader_start = &__appheader_start__;
uint32_t appheader_size = &__appheader_size__;

#define ACK 0xff
#define NACK 0x55

#define BLOCK_SIZE 1024

/*
    extern int check_if_sharedram_working[];
*/

/**
 * Setting up UART
*/
static void uart_init(){
    //no need sysctlclockset?
    // Tiva Ports configuration
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOA);

    // Tiva UART starts
    SysCtlPeripheralEnable(SYSCTL_PERIPH_UART0);

    // Configuring MUX of the two switches for UART1
    GPIOPinConfigure(GPIO_PA0_U0RX);
    GPIOPinConfigure(GPIO_PA1_U0TX);
    
    // Setting up UART in PC4 and PC5
    GPIOPinTypeUART(GPIO_PORTA_BASE, GPIO_PIN_0 | GPIO_PIN_1);

    // UART setup, keeping 9600 baud rate
    UARTConfigSetExpClk(UART0_BASE, SysCtlClockGet(), 9600,
                                (UART_CONFIG_WLEN_8 | UART_CONFIG_STOP_TWO |
                                UART_CONFIG_PAR_NONE));
}

/**
 * Deinitialize UART
*/
// void uart_deinit(){
//     UARTDisable(UART0_BASE);
//     SysCtlPeripheralDisable(SYSCTL_PERIPH_GPIOA);
//     SysCtlPeripheralDisable(SYSCTL_PERIPH_UART0);

//     led_off(GPIO_PIN_1);
//     led_on(GPIO_PIN_2);
//     led_on(GPIO_PIN_3);
//     delay(400000);
//     led_off(GPIO_PIN_1);
//     led_off(GPIO_PIN_2);
//     led_off(GPIO_PIN_3);
// }


/**
 * CRC Update
*/
uint32_t crc32_update(uint32_t seed, uint32_t val, uint32_t poly){
    uint64_t seed64 = (uint64_t) seed;
    uint64_t poly64 = (uint64_t) poly;

    seed64 <<= 8;
    seed64 += val;
    poly64 <<= 8;

    for(int i = 0; i<8; i++){
        if((seed64 & (0x8000000000)) != 0){
            seed64 <<= 1;
            seed64 ^= poly64;
        }
        else{
            seed64 <<= 1;
        }
    }
    return (uint32_t)((seed64 >> 8) & (0xFFFFFFFF));
}

uint32_t parity_check(uint32_t value){
    uint32_t result = 0;
    while (value) {
        result ^= value & 1;
        value >>= 1;
    }
    return result;
}

/**
 * Verify Firmware image
*/
bool verify_firmware()
{
    uint32_t *applen_loc = (uint32_t *)appheader_start;
    uint32_t applen = *applen_loc;

    uint32_t *checksum_loc = (uint32_t *)(appheader_start + 0x500);
    uint32_t checksum = *checksum_loc;

    uint32_t crc_seed = 0x0;
    uint32_t crc_poly = 0x04c11db7;

    uint32_t *app_code = (uint32_t *) approm_start;

    uint32_t msg;
    uint32_t b1;
    uint32_t b2;
    uint32_t b3;
    uint32_t b4;

    for (uint32_t i = 0; i < (uint32_t)(applen/4); i++)
    {
        msg = app_code[i];
        b1 = (msg >> 0) & 0xFF;
        b2 = (msg >> 8) & 0xFF;
        b3 = (msg >> 16) & 0xFF;
        b4 = (msg >> 24) & 0xFF;

        crc_seed = crc32_update(crc_seed, b1, crc_poly);
        crc_seed = crc32_update(crc_seed, b2, crc_poly);
        crc_seed = crc32_update(crc_seed, b3, crc_poly);
        crc_seed = crc32_update(crc_seed, b4, crc_poly);
    }

    msg = checksum;
    b1 = (msg >> 0) & 0xFF;
    b2 = (msg >> 8) & 0xFF;
    b3 = (msg >> 16) & 0xFF;
    b4 = (msg >> 24) & 0xFF;

    crc_seed = crc32_update(crc_seed, b4, crc_poly);
    crc_seed = crc32_update(crc_seed, b3, crc_poly);
    crc_seed = crc32_update(crc_seed, b2, crc_poly);
    crc_seed = crc32_update(crc_seed, b1, crc_poly);

    return (crc_seed == 0x0);
}

static void branch_to_app(uint32_t pc, uint32_t sp) {
    __asm volatile(
        "msr msp, %[sp]\n\t" // Load sp into MSP
        "bx %[pc]\n\t"      // Branch to the address at pc
        :
        : [sp] "r" (sp), [pc] "r" (pc)
    );
}

void start_app(void){

    if (!verify_firmware())
    {

        led_on(GPIO_PIN_1);
        led_off(GPIO_PIN_2);
        led_off(GPIO_PIN_3);
        blink(GPIO_PIN_1, 4, 400000);
        // while (true);
    }
    else{
        led_on(GPIO_PIN_1);
        led_on(GPIO_PIN_2);
        led_on(GPIO_PIN_3);
        delay(400000);
        led_off(GPIO_PIN_1);
        led_off(GPIO_PIN_2);
        led_off(GPIO_PIN_3);
        // while (true);
    }

    uint32_t *app_code = (uint32_t *) approm_start;
    uint32_t app_sp = app_code[0];
    uint32_t app_start = app_code[1];

    //VTOR can only be accessed from privileged mode?
    //specifying the start of the approm to be the offset for vector table
    uint32_t *app_vector_table = (uint32_t *) approm_start;
    //specifying the vtor location
    uint32_t *vtor = (uint32_t *)0xE000ED08;
    //writing offset to vtor. the bitwise & is to allign it to 1024 bytes as there are 134 interupts. last 10 bits are reserved.
    *vtor = ((uint32_t) app_vector_table & 0xFFFFFC00);

    branch_to_app(app_start, app_sp);
}



/**
 * Erase Flash
*/
void erase_app()
{ 
    
    for(int i = 0; i < (approm_size / BLOCK_SIZE) + 1; i++)
    {
        FlashErase(approm_start + i * BLOCK_SIZE);
    }
    for(int i = 0; i < (appheader_size / BLOCK_SIZE) + 1; i++)
    {
        FlashErase(appheader_start + i * BLOCK_SIZE);
    }
}


int main(void){

    // setup LED
    led_setup();
    
    //configure serial communication
    uart_init();

    //Set if app is getting updated
    bool app_update_flag = false; 

    //check wether malloc works
    int* ptr;
    ptr = (int*)malloc(2 * sizeof(int));
    ptr[0] = 10;
    ptr[1] = 20;
    if ((ptr[0] == 10) && (ptr[1] == 20)){
        blink(GPIO_PIN_3, 4, 40000);
    }

    //Check whether bootloader is receiving any update
    uint16_t ack_limit = 100;

    for (uint16_t num_ack_tries = 0; num_ack_tries < ack_limit; num_ack_tries++)
    {

        int32_t ack_receive_byte;

        if(UARTCharsAvail(UART0_BASE)){
            ack_receive_byte = UARTCharGetNonBlocking(UART0_BASE);
        }
        
        led_on(GPIO_PIN_2);
        delay(40000);
        led_off(GPIO_PIN_2);
        delay(40000);

        if(ack_receive_byte == ACK){
            UARTCharPut(UART0_BASE, ACK);
            app_update_flag = true;
            break;
        }
    }


/*
    if(check_if_sharedram_working == 10){
        led_on(GPIO_PIN_1);
        delay(40000);
        led_off(GPIO_PIN_1);
    }
*/

    // if not getting updated, start the app
    if(!app_update_flag)
        start_app();
    
    // variables to store received bytes
    uint32_t msg;
    uint32_t b0;
    uint32_t b1;
    uint32_t b2;
    uint32_t b3;
    uint32_t b4;
    uint32_t parity;
    uint32_t b5;

    // variable that stores whether flash is programmed properly or not
    int32_t flashflag;

    //Erase APP Flash
    erase_app();

    // receive app length
    b1 = (uint32_t)UARTCharGet(UART0_BASE);
    b2 = (uint32_t)UARTCharGet(UART0_BASE);
    b3 = (uint32_t)UARTCharGet(UART0_BASE);
    b4 = (uint32_t)UARTCharGet(UART0_BASE); 
    msg = (b4<<24)| (b3<<16) | (b2<<8) | b1;
    uint32_t applen = msg;

    // Store the app length in Flash
    // If Flash program fails, blink red color
    flashflag = FlashProgram(&applen, appheader_start, 4);
    if(flashflag == 0)      {    led_on(GPIO_PIN_3); led_off(GPIO_PIN_1);}
    else if(flashflag ==-1) {    led_on(GPIO_PIN_1); led_off(GPIO_PIN_3); delay(400000); }

    // Respond ACK for receiving flash length
    UARTCharPut(UART0_BASE, ACK);

    // variable to check number of bytes received
    uint32_t bytes_received = 0;

    // Receive app
    while (bytes_received < applen)
    {
        b0 = (uint32_t)UARTCharGet(UART0_BASE);
        b1 = (uint32_t)UARTCharGet(UART0_BASE);
        b2 = (uint32_t)UARTCharGet(UART0_BASE);
        b3 = (uint32_t)UARTCharGet(UART0_BASE);
        b4 = (uint32_t)UARTCharGet(UART0_BASE);
        parity = (uint32_t)UARTCharGet(UART0_BASE);
        b5 = (uint32_t)UARTCharGet(UART0_BASE);
        msg = (b4<<24)| (b3<<16) | (b2<<8) | b1;

        if((b0 == 0xa5) & (b5 == 0x5a) & (parity == parity_check(msg))){
            // Store app in Flash
            // If Flash program fails, blink red color
            flashflag = FlashProgram(&msg, approm_start + bytes_received, 4);
            if(flashflag == 0)      {    led_on(GPIO_PIN_3); led_off(GPIO_PIN_1);}
            else if(flashflag ==-1) {    led_on(GPIO_PIN_1); led_off(GPIO_PIN_3); delay(400000); }

            // Respond ACK for receiving bytes
            UARTCharPut(UART0_BASE, ACK);
            bytes_received += 4; 
        }
        else{
            UARTCharPut(UART0_BASE, NACK); 
        }
    }

    led_off(GPIO_PIN_1);  led_off(GPIO_PIN_3);
    delay(400000);

    // receive crc_checksum
    b1 = (uint32_t)UARTCharGet(UART0_BASE);
    b2 = (uint32_t)UARTCharGet(UART0_BASE);
    b3 = (uint32_t)UARTCharGet(UART0_BASE);
    b4 = (uint32_t)UARTCharGet(UART0_BASE);
    msg = (b4<<24)| (b3<<16) | (b2<<8) | b1;
    uint32_t checksum = msg;

    // Store checksum in Flash
    // If Flash program fails, blink red color
    flashflag = FlashProgram(&checksum, (appheader_start + 0x500), 4);
    if(flashflag == 0)      {    led_on(GPIO_PIN_3); led_off(GPIO_PIN_1);}
    else if(flashflag ==-1) {    led_on(GPIO_PIN_1); led_off(GPIO_PIN_3); delay(400000); }

    // Respond ACK for receiving checksum
    UARTCharPut(UART0_BASE, 0xff);

    led_off(GPIO_PIN_1);  led_off(GPIO_PIN_3);
    delay(400000);

    // Deinitialize UART and start APP
    // uart_deinit();
    start_app();

    // should never be reached
    while (1);

}