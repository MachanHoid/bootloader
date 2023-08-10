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

extern int __approm_start__;

void delay( int n){
    for(int i = 0; i<n; i++);
}

void led_setup(void){
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

void led_on(uint8_t pin){
    
    GPIOPinWrite(GPIO_PORTF_BASE, pin, pin);

}

void led_off(uint8_t pin){
    
    GPIOPinWrite(GPIO_PORTF_BASE, pin, 0x0);

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

static void start_app(uint32_t pc, uint32_t sp) {
    __asm("           \n\
          msr msp, r1 /* load r1 into MSP */\n\
          bx r0       /* branch to the address at r0 */\n\
    ");
}

int main(void){
    led_setup();
    // led_on(GPIO_PIN_1);
    // delay(100000);
    // led_off(GPIO_PIN_1);
    //configure serial communication
    uart_init();
    // led_on(GPIO_PIN_3);
    //listen for commands - polling method
    uint32_t msg;
    int flash_buffer_limit = 4; 
    int flash_buffer_pointer = 0;
    int flash_pointer = 0;
    int flash_write_flag = 0;
    uint32_t flash_buffer[flash_buffer_limit];

    if (__approm_start__ ==0x20000) led_on(GPIO_PIN_1);
    else{
        led_on(GPIO_PIN_3);
    }
    //initial command
    while (true){
        msg = UARTCharGet(UART0_BASE);
        if(msg == 0xff){

            //initialise write
            flash_write_flag = 1;
            //acknowledgement
            UARTCharPut(UART0_BASE, 0b11111111);
    
            break;
        }
    }

    while (true)
    {
        msg = UARTCharGet(UART0_BASE);
        if(flash_write_flag){
            flash_buffer[flash_buffer_pointer] = msg;
            flash_buffer_pointer += 1;
            if (flash_buffer_pointer == flash_buffer_limit-1){
                flash_buffer_pointer = 0;
                int flashflag = FlashProgram(flash_buffer, 0x20000 + flash_pointer, flash_buffer_limit);
                // if(flashflag==0)led_on(GPIO_PIN_3);
                // if(flashflag==-1)led_on(GPIO_PIN_1);
                flash_pointer += flash_buffer_limit;
            }
        } 
    }
    // should never be reached
    while (1);

}