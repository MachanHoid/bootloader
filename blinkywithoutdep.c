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

#include <stdint.h>
#include <stdbool.h>
#include "inc/hw_memmap.h"
#include "inc/hw_types.h"
#include "inc/tm4c123gh6pm.h"
#include "driverlib/sysctl.h"
#include "driverlib/gpio.h"
#include "driverlib/interrupt.h"
#include "memory_map.h"

//defining variables
uint32_t approm_start = 0x20000;
uint32_t approm_size =0x20000;
uint32_t bootrom_start = 0x0000;
uint32_t bootrom_size = 0x20000;


// void delay( int n){
//     for(volatile int i = 0; i<n; i++);
// }

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

//Interrupt service routine
void GPIOIntHandler(void){
	GPIOIntClear(GPIO_PORTB_BASE, GPIO_INT_PIN_0);
	blink(GPIO_PIN_1, 1);
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

void start_bootloader(void){
    uint32_t *bootloader_code = (uint32_t *) bootrom_start;
    uint32_t bootloader_sp = bootloader_code[0];
    uint32_t bootloader_start = bootloader_code[1];
    branch_to_app(bootloader_start, bootloader_sp);
}

int main(void)
{
	led_setup();
	GPIO_int_init();
	SYSCTL_RCGCGPIO_R |= GPIO_PORTF_CLK_EN;     //enable clock for PORTF
	GPIO_PORTF_DEN_R  |= GPIO_PORTF_PIN1_EN;    //enable pins 1 on PORTF
	GPIO_PORTF_DIR_R  |= GPIO_PORTF_PIN1_EN;    //make pins 1 as output pins
	GPIO_PORTF_DEN_R  |= GPIO_PORTF_PIN2_EN;    //enable pins 2 on PORTF
	GPIO_PORTF_DIR_R  |= GPIO_PORTF_PIN2_EN;    //make pins 2 as output pins
	GPIO_PORTF_DEN_R  |= GPIO_PORTF_PIN3_EN;    //enable pins 3 on PORTF
	GPIO_PORTF_DIR_R  |= GPIO_PORTF_PIN3_EN;    //make pins 3 as output pins
	
	for(int i = 0; i<20; i++)
	{
		blink(GPIO_PIN_2, 1);                  //Delay almost 1 sec
	}
	// start_bootloader();

    return 0;
}
