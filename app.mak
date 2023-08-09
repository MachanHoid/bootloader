linker_file = app_linker.ld
startup_file = startup_gcc.c
project_file = blinkywithoutdep.c

compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy

dependancy_path = /Users/niting/Nitin/IITM/Abhiyaan/Bootloader/bootloader_nalikkuday1/

all_files =${project_file} ${startup_file}
all_dependancies = $(wildcard driverlib/*.c)
obj_files = $(all_files:%.c=%.o)  $(all_dependancies:driverlib/%.c=%.o)

.PHONY: all clean upload 

all: compile link soft_clean trim
trim: app.bin
	python3 -u "/Users/niting/Nitin/IITM/Abhiyaan/Bootloader/bootloader_nalikkuday1/app_trimmer.py"
link: $(obj_files)
	@echo $(all_dependancies)
	${linker} -T ${linker_file} -o app.bin $^


compile: ${project_file} ${startup_file} $(wildcard driverlib/*.c)
	${compiler} -I${dependancy_path} -D TARGET_IS_TM4C123_RB1 -D gcc -nostdlib --specs=nosys.specs -mcpu=cortex-m4 -mfloat-abi=hard -c $^

soft_clean:
	@rm -f *.o 

upload:
	openocd -f board/ti_ek-tm4c123gxl.cfg -c "program app_trimmed.bin verify reset exit"

clean:
	@rm -f app.bin app_trimmed.bin *.o *.s