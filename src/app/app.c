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

#define SYSCTL_RCGCGPIO_R (*((volatile unsigned long *) 0x400FE608))
#define GPIO_PORTF_DEN_R  (*((volatile unsigned long *) 0x4002551C))
#define GPIO_PORTF_DIR_R  (*((volatile unsigned long *) 0x40025400))
#define GPIO_PORTF_DATA_R (*((volatile unsigned long *) 0x40025038))

	 
#define GPIO_PORTF_CLK_EN  0x20
#define GPIO_PORTF_PIN1_EN 0x02
#define GPIO_PORTF_PIN2_EN 0x04
#define GPIO_PORTF_PIN3_EN 0x08
#define LED_ON1            0x02
#define LED_ON2            0x04
#define LED_ON3            0x08

#define DELAY_VALUE        400000  

void Delay(void);
void blink(uint8_t pin, int n){
    for(int i = 0; i<n; i++){
        led_on(pin);
        delay(400000);
        led_off(pin);
        delay(400000);
    }
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
	IntRegister(INT_GPIOB, GPIOIntHandler);
	IntEnable(INT_GPIOB);
	IntMasterEnable();
}

int main(void)
{
	GPIO_int_init();
	SYSCTL_RCGCGPIO_R |= GPIO_PORTF_CLK_EN;     //enable clock for PORTF
	GPIO_PORTF_DEN_R  |= GPIO_PORTF_PIN1_EN;    //enable pins 1 on PORTF
	GPIO_PORTF_DIR_R  |= GPIO_PORTF_PIN1_EN;    //make pins 1 as output pins
	GPIO_PORTF_DEN_R  |= GPIO_PORTF_PIN2_EN;    //enable pins 2 on PORTF
	GPIO_PORTF_DIR_R  |= GPIO_PORTF_PIN2_EN;    //make pins 2 as output pins
	GPIO_PORTF_DEN_R  |= GPIO_PORTF_PIN3_EN;    //enable pins 3 on PORTF
	GPIO_PORTF_DIR_R  |= GPIO_PORTF_PIN3_EN;    //make pins 3 as output pins
	
	while(1)
	{
		GPIO_PORTF_DATA_R = 0x02;    //Turn on RED LED 	 
		Delay();	                   //Delay almost 1 sec
		GPIO_PORTF_DATA_R = 0x00;    //Turn  off LED
		Delay();                     //Delay almost 1 sec
	}

    return 0;
}

void Delay(void)
{
	volatile unsigned long i;
	for(i=0;i<DELAY_VALUE;i++);
}