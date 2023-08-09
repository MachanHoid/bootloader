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

    int flash_buffer_pointer = 0;
    uint32_t flash_buffer[0x20000];

    // uint32_t b1 = UARTCharGet(UART0_BASE);
    // uint32_t b2 = UARTCharGet(UART0_BASE);
    // uint32_t b3 = UARTCharGet(UART0_BASE);
    // uint32_t b4 = UARTCharGet(UART0_BASE);

    // uint32_t applength = (b4 << 24) | (b3 << 16) | (b2 << 8) | b1;
    UARTCharPut(UART0_BASE, 0b11111111);

    uint32_t applength = applength > 0x20000 ? 0x20000: applength;

    for (flash_buffer_pointer = 0; flash_buffer_pointer < applength; flash_buffer_pointer++)
    {
        msg = UARTCharGet(UART0_BASE);
        flash_buffer[flash_buffer_pointer] = msg;                
    }

    FlashProgram(flash_buffer, __approm_start__, applength);

    uint32_t *app_code = (uint32_t *)__approm_start__;
    uint32_t app_sp = app_code[0];
    uint32_t app_start = app_code[1];
    uart_deinit();
    start_app(app_start, app_sp);

    while (1);

}