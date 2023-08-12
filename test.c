/*
 * This is an example that shows the use of asynchronous interruptions requested from the General Purpose Inputs/Outputs (GPIO) peripheral
 * using the Tiva C launchpad and the Tivaware library.
 * In this example, the internal LEDs in PF1, PF2 and PF3 are used in addition to pins PB0, PB1, PB2 and PB3.
 * When the pins on B port are connected to ground the interrupt is attended and the LEDs are activated or desactivated.
 * Author: Eduardo Muralles
*/

//Libraries
#include <stdint.h>
#include <stdbool.h>
#include "inc/hw_memmap.h"
#include "inc/hw_types.h"
#include "inc/tm4c123gh6pm.h"
#include "driverlib/sysctl.h"
#include "driverlib/gpio.h"
#include "driverlib/interrupt.h"

//Definitions
#define LEDS GPIO_PIN_1 | GPIO_PIN_2 | GPIO_PIN_3
#define PINS GPIO_PIN_0

//Declarations
void initClock(void);
void initGPIO(void);
void GPIOIntHandler(void);

void delay( int n){
    for(volatile int i = 0; i<n; i++);
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

void blink(uint8_t pin, int n){
    for(int i = 0; i<n; i++){
        led_on(pin);
        delay(400000);
        led_off(pin);
        delay(400000);
    }
}

//Main routine
int main(void) {
	// initClock();
    // blink(GPIO_PIN_1, 2);
	initGPIO();
    blink(GPIO_PIN_2, 2);
    while(1){
        if(GPIOPinRead(GPIO_PORTB_BASE, GPIO_PIN_0)==0){
            blink(GPIO_PIN_3, 1);
        }
    }
    
	return 0;
}

//Clock initialization
void initClock(void){
	SysCtlClockSet(SYSCTL_OSC_MAIN | SYSCTL_XTAL_16MHZ | SYSCTL_USE_PLL | SYSCTL_SYSDIV_5);
}

void initGPIO(void){
	SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOB);
	GPIOPinTypeGPIOInput(GPIO_PORTB_BASE, PINS);
	GPIOPadConfigSet(GPIO_PORTB_BASE, GPIO_PIN_0, GPIO_STRENGTH_2MA, GPIO_PIN_TYPE_STD_WPU);
	GPIOIntEnable(GPIO_PORTB_BASE, GPIO_INT_PIN_0);
	GPIOIntTypeSet(GPIO_PORTB_BASE, GPIO_PIN_0, GPIO_FALLING_EDGE);
	IntPrioritySet(INT_GPIOB, 0);
	IntRegister(INT_GPIOB, GPIOIntHandler);
	IntEnable(INT_GPIOB);
	IntMasterEnable();
}

//Interrupt service routine
void GPIOIntHandler(void){
	GPIOIntClear(GPIO_PORTB_BASE, GPIO_INT_PIN_0);
	blink(GPIO_PIN_1, 1);
}