linker_file = shared.ld
startup_file = led_startup_gcc.c
project_file = led_init.c

compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy

dependancy_path = /home/adi/Abhiyaan/CAN_BootLoader/bootloader_nitin/bootloader_nalikkuday1/
all_files =${project_file} ${startup_file}
all_dependancies = $(wildcard driverlib/*.c)
obj_files = $(all_files:%.c=%.o)  $(all_dependancies:driverlib/%.c=%.o)

.PHONY: all clean upload 

all: compile link soft_clean

link: $(obj_files)
	@echo $(all_dependancies)
	${linker} -T ${linker_file} -o led.elf $^
	${ocpy} -O binary led.elf led.bin


compile: ${project_file} ${startup_file} $(wildcard driverlib/*.c)
	${compiler} -I${dependancy_path} -D TARGET_IS_TM4C123_RB1 -D gcc -nostdlib --specs=nosys.specs -mcpu=cortex-m4 -mfloat-abi=hard -c $^

soft_clean:
	@rm -f *.o 

upload:
	openocd -f board/ti_ek-tm4c123gxl.cfg -c "program app.bin verify reset exit"

clean:
	@rm -f app.bin app_trimmed.bin *.o *.s