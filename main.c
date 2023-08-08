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
    //configure serial communication
    uart_init();
    //listen for commands - polling method
    uint32_t msg;
    int flash_buffer_limit = 4; 
    int flash_buffer_pointer = 0;
    int flash_pointer = 0;
    int flash_write_flag = 0;
    uint32_t flash_buffer[flash_buffer_limit];
    while (true)
    {
        msg = UARTCharGet(UART0_BASE);
        switch (msg){
            case 0b11111111:
                //initialise write
                flash_write_flag = 1;
                //acknowledgement
                UARTCharPut(UART0_BASE, 0b11111111);
            case 0b00000000:
                //start program
                flash_write_flag=0;
                //change pc to start of approm, and reset conditions. PUT THIS UNDER CONDITION
                uint32_t *app_code = (uint32_t *)__approm_start__;
                uint32_t app_sp = app_code[0];
                uint32_t app_start = app_code[1];
                uart_deinit();
                start_app(app_start, app_sp);
            default:
                if(flash_write_flag){
                    flash_buffer[flash_buffer_pointer] = msg;
                    flash_buffer_pointer += 1;
                    if (flash_buffer_pointer == flash_buffer_limit-1){
                        flash_buffer_pointer = 0;
                        FlashProgram(flash_buffer, __approm_start__ + flash_pointer, flash_buffer_limit);
                        flash_pointer += flash_buffer_limit;
                    }
                }
        }
        
    }
    // should never be reached
    while (1);

}