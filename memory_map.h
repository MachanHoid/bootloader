#pragma once

extern char __bootrom_start__;
extern char __bootrom_size__;
extern char __approm_start__;
extern char __approm_size__;
extern char __shared_start__;
extern char __shared_size__;

// pin value tells what colour the LED should blink
uint32_t* LED_POINTER_COLOUR = (uint32_t *)0x19000;

// tells delay of blink(if needed) else 0
uint32_t* LED_DELAY = (uint32_t *)0x19004;

// tells you if it is on or off
// off : 0
// on : 1
// blink : 2
uint32_t* LED_MODE = (uint32_t *)0x19008;

// tells the source is bootloader
// 0 : bootloader
// 1 : app
uint32_t* LED_SOURCE = (uint32_t *)0x19012;

uint32_t* LED_BLINK_NUMBER = (uint32_t *)0x19016;