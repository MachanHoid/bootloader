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

//defining variables
uint32_t approm_start = &__approm_start__;
uint32_t approm_size = &__approm_size__;
uint32_t bootrom_start = &__bootrom_start__;
uint32_t bootrom_size = &__bootrom_size__;

extern int check_if_sharedram_working[];

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
                                (UART_CONFIG_WLEN_8 | UART_CONFIG_STOP_ONE |
                                UART_CONFIG_PAR_NONE));
}

void uart_deinit(){
    UARTDisable(UART0_BASE);
    SysCtlPeripheralDisable(SYSCTL_PERIPH_GPIOA);
    SysCtlPeripheralDisable(SYSCTL_PERIPH_UART0);
}

static void branch_to_app(uint32_t pc, uint32_t sp) {
    __asm("           \n\
          msr msp, r1 /* load r1 into MSP */\n\
          bx r0       /* branch to the address at r0 */\n\
    ");
}

void start_app(void){
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

void erase_approm(int block_size){ //block size in bytes
    for(int i = 0; i< (approm_size/block_size); i++){
        FlashErase(approm_start+ i*block_size);
    }
}

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

int main(void){
    led_setup();
    //configure serial communication
    uart_init();

    //ack
    int32_t ack;
    int ack_limit = 100;
    int app_update_flag = 0;
    for (int num_ack_tries = 0; num_ack_tries < ack_limit; num_ack_tries++){
        if(UARTCharsAvail(UART0_BASE)){
            ack = UARTCharGetNonBlocking(UART0_BASE);
        }
        led_on(GPIO_PIN_2);
        delay(40000);
        led_off(GPIO_PIN_2);
        delay(40000);

        if(ack == 0xff){
            UARTCharPut(UART0_BASE, 0xff);
            app_update_flag = 1;
            break;
        }
    }

    // if(check_if_sharedram_working == 10){
    //     led_on(GPIO_PIN_1);
    //     delay(40000);
    //     led_off(GPIO_PIN_1);
    // }

    if(!app_update_flag) {
        start_app();
        led_on(GPIO_PIN_2);
    }
    
    uint32_t crc_seed = 0x0;
    uint32_t crc_poly = 0x04c11db7;

    uint32_t msg;
    uint32_t b1;
    uint32_t b2;
    uint32_t b3;
    uint32_t b4;
    
    //receive file length
    b1 = UARTCharGet(UART0_BASE);
    b2 = UARTCharGet(UART0_BASE);
    b3 = UARTCharGet(UART0_BASE);
    b4 = UARTCharGet(UART0_BASE); 
    uint32_t applen = (b4<<24)| (b3<<16) | (b2<<8) | b1;
    UARTCharPut(UART0_BASE, 0xff);
    
    uint32_t bytes_received = 0;

    erase_approm(1024);
    uint32_t parity = 0;
    while (bytes_received < applen)
    {
        b1 = UARTCharGet(UART0_BASE);
        b2 = UARTCharGet(UART0_BASE);
        b3 = UARTCharGet(UART0_BASE);
        b4 = UARTCharGet(UART0_BASE);
        msg = (b4<<24)| (b3<<16) | (b2<<8) | b1;
        crc_seed = crc32_update(crc_seed, b1, crc_poly);
        crc_seed = crc32_update(crc_seed, b2, crc_poly);
        crc_seed = crc32_update(crc_seed, b3, crc_poly);
        crc_seed = crc32_update(crc_seed, b4, crc_poly);

        int flashflag = FlashProgram(&msg, approm_start + bytes_received, 4);
        bytes_received += 4; 
        if(flashflag==0)led_on(GPIO_PIN_3);
        if(flashflag==-1)led_on(GPIO_PIN_1);
        UARTCharPut(UART0_BASE, 0xff);
    }
    led_off(GPIO_PIN_1);
    led_off(GPIO_PIN_3);
    // receive crc_checksum
    b1 = UARTCharGet(UART0_BASE);
    b2 = UARTCharGet(UART0_BASE);
    b3 = UARTCharGet(UART0_BASE);
    b4 = UARTCharGet(UART0_BASE);
    crc_seed = crc32_update(crc_seed, b1, crc_poly);
    crc_seed = crc32_update(crc_seed, b2, crc_poly);
    crc_seed = crc32_update(crc_seed, b3, crc_poly);
    crc_seed = crc32_update(crc_seed, b4, crc_poly);
    UARTCharPut(UART0_BASE, 0xff);
    if (crc_seed == 0x0){
        for(int i = 0;i< 3; i++){
            led_on(GPIO_PIN_3);
            delay(400000);
            led_off(GPIO_PIN_3);
            delay(400000);
        }
    }
    else{
        for(int i = 0;i< 3; i++){
            led_on(GPIO_PIN_1);
            delay(400000);
            led_off(GPIO_PIN_1);
            delay(400000);
        } 
    }

    uart_deinit();
    start_app();

    // should never be reached
    while (1);
}