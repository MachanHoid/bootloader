#include <inttypes.h>
#include <stdint.h>
#include <stdbool.h>

extern int check_if_sharedram_working[];

void delay(int n);
void led_setup(void);
void led_on(uint8_t pin);
void led_off(uint8_t pin);
