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
#include "memory_map.h"
#include <stdint.h>
#include <stdbool.h>
#include "inc/hw_memmap.h"
#include "inc/hw_types.h"
#include "inc/tm4c123gh6pm.h"
#include "driverlib/sysctl.h"
#include "driverlib/gpio.h"
#include "driverlib/interrupt.h"

void led_on(uint8_t pin){
    GPIOPinWrite(GPIO_PORTF_BASE, pin, pin);
    if (*LED_SOURCE == 0)start_bootloader();
    if (*LED_SOURCE == 1)start_app();
}

void led_off(uint8_t pin){
    GPIOPinWrite(GPIO_PORTF_BASE, pin, 0x0);
    if (*LED_SOURCE == 0)start_bootloader();
    if (*LED_SOURCE == 1)start_app();
}


void blink(uint8_t pin, int n,int delay){
    for(int i = 0; i<n; i++){
        GPIOPinWrite(GPIO_PORTF_BASE, pin, pin);
        delay(delay);
        GPIOPinWrite(GPIO_PORTF_BASE, pin, 0x0);
        delay(delay);
    }
    *LED_BLINK_NUMBER = 0;

    if (*LED_SOURCE == 0)start_bootloader();
    if (*LED_SOURCE == 1)start_app();
}

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

int main(){
    uint32_t pin;
    if (*LED_POINTER_COLOUR == 0)pin = GPIO_PIN_1;
    if (*LED_POINTER_COLOUR == 1)pin = GPIO_PIN_2;
    if (*LED_POINTER_COLOUR == 2)pin = GPIO_PIN_3;

    if (*LED_MODE == 0){
        led_off(pin);
    }
    if (*LED_MODE == 1){
        led_on(pin);
    }
    if (*LED_MODE == 2){
        blink(pin, *LED_BLINK_NUMBER, *LED_DELAY);
    }
}