linker_file = bootloader_linker.ld
startup_file = startup_gcc.c
project_file = main.c

compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy

	
# dependancy_path := $(abspath $(lastword $(MAKEFILE_LIST)))
dependancy_path = /home/adi/Abhiyaan/CAN_BootLoader/bootloader_nitin/bootloader_nalikkuday1/

all_files =${project_file} ${startup_file}
driverlib_dependancies = $(wildcard driverlib/*.c)
obj_files = $(project_file:%.c=%.o) $(startup_file:boot_loader/%.S:%.o)  $(boot_dependancies:boot_loader/%.c=%.o)

.PHONY: all clean upload soft_clean

all:makeBuildDir compile soft_clean

everything: clean compile soft_clean upload

defines = TARGET_IS_TM4C123_RB1 \
		PART_TM4C123GH6PM \
		gcc \

includes = ${dependancy_path} 

CFLAGS = -nostdlib \
		--specs=nosys.specs \
		-mcpu=cortex-m4 \
		-mfloat-abi=hard 

CFLAGS += $(foreach i,$(includes),-I$(i))
CFLAGS += $(foreach d,$(defines),-D $(d))

CFLAGS +=  -T ${linker_file}

makeBuildDir: 
	mkdir -p build/bootloader

compile: ${project_file} ${startup_file}
	@echo compiling
	${compiler} ${CFLAGS}  $^ -o build/bootloader/boot.elf
	${ocpy} -O binary build/bootloader/boot.elf build/bootloader/boot.bin
	
soft_clean:
	@rm -f *.o
	@echo done

upload:
	openocd -f board/ti_ek-tm4c123gxl.cfg -c "program build/bootloader/boot.elf verify reset exit"

clean:
	@rm -f build/bootloader/boot.bin build/bootloader/boot.elf *.o *.s
