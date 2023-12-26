#include <cstdint>

// Replace these placeholders with your actual GPIO definitions
#define SYSCTL_RCGCGPIO_R  (*((volatile uint32_t *)0x400FE608))
#define GPIO_PORTF_DEN_R   (*((volatile uint32_t *)0x4002551C))
#define GPIO_PORTF_DIR_R   (*((volatile uint32_t *)0x40025400))
#define GPIO_PORTF_DATA_R  (*((volatile uint32_t *)0x40025038))


#define GPIO_PORTF_CLK_EN  0x20
#define GPIO_PORTF_PIN1_EN 0x02
#define LED_ON1            0x02
#define DELAY_VALUE        400000

class GPIO {
public:
    GPIO(volatile uint32_t* denReg, volatile uint32_t* dirReg, volatile uint32_t* dataReg, uint8_t pinMask)
        : denRegister(denReg), dirRegister(dirReg), dataRegister(dataReg), pinMask(pinMask) {}

    void enable() { *denRegister |= pinMask; }
    void setDirectionOutput() { *dirRegister |= pinMask; }
    void write(uint8_t value) { *dataRegister = value << (pinMask >> 1); }

private:
    volatile uint32_t* denRegister;
    volatile uint32_t* dirRegister;
    volatile uint32_t* dataRegister;
    uint8_t pinMask;
};

class Blinky {
public:
    Blinky(GPIO& gpio, uint32_t delayValue) : gpio(gpio), delayValue(delayValue) {}

    void run() {
        while (true) {
            gpio.write(LED_ON1);
            delay();
            gpio.write(0x00);
            delay();
        }
    }

private:
    void delay() {
        volatile unsigned long i;
        for (i = 0; i < delayValue; i++);
    }

    GPIO& gpio;
    uint32_t delayValue;
};

int main() {
    GPIO portF(&GPIO_PORTF_DEN_R, &GPIO_PORTF_DIR_R, &GPIO_PORTF_DATA_R, GPIO_PORTF_PIN1_EN);
    portF.enable();
    portF.setDirectionOutput();

    Blinky blinky(portF, DELAY_VALUE);
    blinky.run();

    return 0;
}
