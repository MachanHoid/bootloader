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
#include "inc/tm4c123gh6pm.h"
#include "driverlib/interrupt.h"

//defining variables
uint32_t approm_start = &__approm_start__;
uint32_t approm_size = &__approm_size__;
uint32_t bootrom_start = &__bootrom_start__;
uint32_t bootrom_size = &__bootrom_size__;

// void delay( int n){
//     for(volatile int i = 0; i<n; i++);
// }

void led_init(void){
    //
    // Enable the GPIO port that is used for the on-board LED.
    //
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOF);

    //
    // Check if the peripheral access is enabled.
    //
    while(!SysCtlPeripheralReady(SYSCTL_PERIPH_GPIOF))
    {
    }

    //
    // Enable the GPIO pin for the LED (PF3).  Set the direction as output, and
    // enable the GPIO pin for digital function.
    //
    GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_3);
    GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_2);
    GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_1);


}

void led_deinit(void){
   SysCtlPeripheralDisable(SYSCTL_PERIPH_GPIOF); 
}

void led_on(uint8_t pin){
    
    GPIOPinWrite(GPIO_PORTF_BASE, pin, pin);

}

void led_off(uint8_t pin){
    
    GPIOPinWrite(GPIO_PORTF_BASE, pin, 0x0);

}

void blink(uint8_t pin, int n){
    for(int i = 0; i<n; i++){
        led_on(pin);
        delay(400000);
        led_off(pin);
        delay(400000);
    }
}

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

//Interrupt service routine
void GPIOIntHandler(void){
	GPIOIntClear(GPIO_PORTB_BASE, GPIO_INT_PIN_0);
	blink(GPIO_PIN_3, 1);
}

void GPIO_int_init(void){
	SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOB);
	GPIOPinTypeGPIOInput(GPIO_PORTB_BASE, GPIO_PIN_0);
	GPIOPadConfigSet(GPIO_PORTB_BASE, GPIO_PIN_0, GPIO_STRENGTH_2MA, GPIO_PIN_TYPE_STD_WPU);
	GPIOIntEnable(GPIO_PORTB_BASE, GPIO_INT_PIN_0);
	GPIOIntTypeSet(GPIO_PORTB_BASE, GPIO_PIN_0, GPIO_FALLING_EDGE);
	IntPrioritySet(INT_GPIOB, 0);
	// IntRegister(INT_GPIOB, GPIOIntHandler);
	IntEnable(INT_GPIOB);
	IntMasterEnable();
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

    //VTOR can only be accessed from privileged mode
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

int main(void){
    led_init();
    // led_on(GPIO_PIN_1);
    // delay(100000);
    // led_off(GPIO_PIN_1);
    //configure serial communication
    uart_init();
    // led_on(GPIO_PIN_3);
    GPIO_int_init();

    //ack
    int32_t ack;
    int ack_limit = 100;
    int app_update_flag = 0;
    for (int num_ack_tries = 0; num_ack_tries < ack_limit; num_ack_tries++){
        if(UARTCharsAvail){
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
    if(!app_update_flag) {
        start_app();
        led_on(GPIO_PIN_2);
    }
    
    uint32_t msg;
    uint32_t b1;
    uint32_t b2;
    uint32_t b3;
    uint32_t b4;
    
    //send file length
    b1 = UARTCharGet(UART0_BASE);
    b2 = UARTCharGet(UART0_BASE);
    b3 = UARTCharGet(UART0_BASE);
    b4 = UARTCharGet(UART0_BASE); 
    uint32_t applen = (b4<<24)| (b3<<16) | (b2<<8) | b1;
    UARTCharPut(UART0_BASE, 0xff);
    
    uint32_t bytes_received = 0;
    uint32_t flash_buffer[1];

    erase_approm(1024);

    while (bytes_received < applen)
    {
        b1 = UARTCharGet(UART0_BASE);
        b2 = UARTCharGet(UART0_BASE);
        b3 = UARTCharGet(UART0_BASE);
        b4 = UARTCharGet(UART0_BASE);
        msg = (b4<<24)| (b3<<16) | (b2<<8) | b1;
        flash_buffer[0] = msg;    
        // led_on(GPIO_PIN_2);
        int flashflag = FlashProgram(&msg, approm_start + bytes_received, 4);
        bytes_received += 4; 
        if(flashflag==0)led_on(GPIO_PIN_3);
        if(flashflag==-1)led_on(GPIO_PIN_1);
        UARTCharPut(UART0_BASE, 0xff);
    }
    led_off(GPIO_PIN_1);
    led_off(GPIO_PIN_3);
    uart_deinit();
    led_deinit();
    start_app();

    // should never be reached
    while (1);
}