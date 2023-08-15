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
//defining variables
uint32_t approm_start = &__approm_start__;
uint32_t approm_size = &__approm_size__;
uint32_t bootrom_start = &__bootrom_start__;
uint32_t bootrom_size = &__bootrom_size__;
uint32_t shared_start = &__shared_start__;
uint32_t shared_size = &__shared_size__;


// tells the source is app
*LED_SOURCE = 1;

static void branch_to_app(uint32_t pc, uint32_t sp) {
    __asm("           \n\
          msr msp, r1 /* load r1 into MSP */\n\
          bx r0       /* branch to the address at r0 */\n\
    ");
}

void start_bootloader(void){
    uint32_t *bootloader_code = (uint32_t *) 0x00000;
    uint32_t bootloader_sp = bootloader_code[0];
    uint32_t bootloader_start = bootloader_code[1];

    uint32_t *led_vector_table = (uint32_t *) 0x00000;
    //specifying the vtor location
    uint32_t *vtor = (uint32_t *)0xE000ED08;
    //writing offset to vtor. the bitwise & is to allign it to 1024 bytes as there are 134 interupts. last 10 bits are reserved.
    *vtor = ((uint32_t) led_vector_table & 0xFFFFFC00);

    branch_to_app(bootloader_start, bootloader_sp);
}

void start_led(){
    uint32_t *led_code = (uint32_t *) 0x15000;
    uint32_t led_sp = led_code[0];
    uint32_t led_start = led_code[1];

    //VTOR can only be accessed from privileged mode
    //specifying the start of the approm to be the offset for vector table
    uint32_t *led_vector_table = (uint32_t *) 0x15000;
    //specifying the vtor location
    uint32_t *vtor = (uint32_t *)0xE000ED08;
    //writing offset to vtor. the bitwise & is to allign it to 1024 bytes as there are 134 interupts. last 10 bits are reserved.
    *vtor = ((uint32_t) led_vector_table & 0xFFFFFC00);

    branch_to_app(led_start, led_sp);
}

void start_app(void){
    uint32_t *app_code = (uint32_t *) 0x20000;
    uint32_t app_sp = app_code[0];
    uint32_t app_start = app_code[1];

    //VTOR can only be accessed from privileged mode
    //specifying the start of the approm to be the offset for vector table
    uint32_t *app_vector_table = (uint32_t *) 0x20000;
    //specifying the vtor location
    uint32_t *vtor = (uint32_t *)0xE000ED08;
    //writing offset to vtor. the bitwise & is to allign it to 1024 bytes as there are 134 interupts. last 10 bits are reserved.
    *vtor = ((uint32_t) app_vector_table & 0xFFFFFC00);

    branch_to_app(app_start, app_sp);
}


void led_on(uint8_t pin){
    if (pin == GPIO_PIN_1)pin = 0;
    if (pin == GPIO_PIN_2)pin = 1;
    if (pin == GPIO_PIN_3)pin = 2;

    *LED_POINTER_COLOUR = pin; 
    *LED_MODE = 1;
    *LED_TYPE = 0;
    *LED_BLINK_NUMBER = 0;

    start_led();
}

void led_off(uint8_t pin){
    if (pin == GPIO_PIN_1)pin = 0;
    if (pin == GPIO_PIN_2)pin = 1;
    if (pin == GPIO_PIN_3)pin = 2;

    *LED_POINTER_COLOUR = pin; 
    *LED_MODE = 0;
    *LED_TYPE = 0;
    *LED_BLINK_NUMBER = 0;

    start_led();
    GPIOPinWrite(GPIO_PORTF_BASE, pin, 0x0);
    start_bootloader();
}

void blink(uint8_t pin, int n){
    *LED_POINTER_COLOUR = pin; 
    *LED_MODE = 2;
    *LED_TYPE = 1;
    *LED_BLINK_NUMBER = n;
    start_bootloader();
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
		blink(GPIO_PIN_2, 1, 400000);                  //Delay almost 1 sec
	}
	// start_bootloader();

    return 0;
}
