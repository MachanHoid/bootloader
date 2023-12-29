extern struct checkStruct name_of_struct;
struct checkStruct
{
    int length;
};

void delay(int n);
void led_setup(void);
void led_on(uint8_t pin);
void led_off(uint8_t pin);
void blink(uint8_t pin, int n, int delay_num);
