linker_file = app_linker.ld
startup_file = startup_gcc.c
project_file = blinky.c

compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy

	
dependancy_path:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))


all_files =${project_file} ${startup_file}
driverlib_dependancies = $(wildcard driverlib/*.c)
obj_files = $(project_file:%.c=%.o) $(startup_file:boot_loader/%.S:%.o)  $(boot_dependancies:boot_loader/%.c=%.o)

.PHONY: all clean upload soft_clean

all:makeBuildDir compile soft_clean

everything: clean compile soft_clean

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
	mkdir -p build/app

compile: ${project_file} ${startup_file}
	@echo compiling
	${compiler} ${CFLAGS}  $^ -o build/app/app.elf
	${ocpy} -O binary build/app/app.elf build/app/app.bin
	
soft_clean:
	@rm -f *.o
	@echo done

clean:
	@rm -f build/app/app.bin build/app/app.elf *.o *.s
