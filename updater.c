//gives commands to the tiva to update its firmware

#include <inttypes.h>

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

void delay(int n){
    for(int i = 0; i < n; i++){};
}

void transmit(void){
    unsigned char buffer[10];
    FILE *ptr;
    ptr = fopen("app.bin","rb");  // r for read, b for binary
    while (!feof(ptr)){
        fread(buffer,sizeof(buffer),1,ptr); // read 10 bytes to our buffer
        for(int i = 0; i< sizeof(buffer); i++){
            UARTCharPut(UART1_BASE, buffer[i]);
            delay(1000);
        }
    }
    fclose(ptr);
}

void UARTIntHandler(void){
    UARTIntClear(UART1_BASE, UART_INT_RX);
    uint32_t ack;
    ack = UARTCharGet(UART1_BASE);
    if(ack = 0xff){
        transmit();
    }
}

static void uart_init(){
    //no need sysctlclockset?
    // Tiva Ports configuration
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOC);

    // Tiva UART starts
    SysCtlPeripheralEnable(SYSCTL_PERIPH_UART1);

    // Configuring MUX of the two switches for UART1
    GPIOPinConfigure(GPIO_PC4_U1RX);
    GPIOPinConfigure(GPIO_PC5_U1TX);
    
    // Setting up UART in PC4 and PC5
    GPIOPinTypeUART(GPIO_PORTC_BASE, GPIO_PIN_4 | GPIO_PIN_5);

    // UART setup, keeping 9600 baud rate
    UARTConfigSetExpClk(UART1_BASE, SysCtlClockGet(), 9600,
                                (UART_CONFIG_WLEN_8 | UART_CONFIG_STOP_ONE |
                                UART_CONFIG_PAR_NONE));

    //interrupt initialisation
    IntMasterEnable();
    //IntEnable(INT_UART1);
    UARTIntEnable(UART1_BASE, UART_INT_RX);
    UARTIntRegister(UART1_BASE, UARTIntHandler);
}

void uart_deinit(){
    UARTDisable(UART1_BASE);
    SysCtlPeripheralDisable(SYSCTL_PERIPH_GPIOC);
    SysCtlPeripheralDisable(SYSCTL_PERIPH_UART1);
}

int main(void){
    uart_init();
    int ack = 0;
    while(ack ==0){
        UARTCharPut(UART1_BASE, 0xff);
        delay(1000);
    }
}