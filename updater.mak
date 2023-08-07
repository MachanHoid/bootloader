linker_file = updater_linker.ld
startup_file = startup_gcc.c
project_file = updater.c

compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld

dependancy_path = /Users/niting/Nitin/IITM/Abhiyaan/Bootloader/bootloader_nalikkuday1/

all_files =${project_file} ${startup_file}
all_dependancies = $(wildcard driverlib/*.c)
obj_files = $(all_files:%.c=%.o)  $(all_dependancies:driverlib/%.c=%.o)

.PHONY: all clean upload 

all: compile link soft_clean
link: $(obj_files)
	@echo $(all_dependancies)
	${linker} -T ${linker_file} -o updater.bin $^


compile: ${project_file} ${startup_file} $(wildcard driverlib/*.c)
	${compiler} -I${dependancy_path} -D TARGET_IS_TM4C123_RB1 -D PART_TM4C123GH6PM -D gcc -nostdlib --specs=nosys.specs -mcpu=cortex-m4 -mfloat-abi=hard -c $^

soft_clean:
	@rm -f *.o 

upload:
	openocd -f board/ti_ek-tm4c123gxl.cfg -c "program output.bin verify reset exit"

clean:
	@rm -f updater.bin *.o *.s