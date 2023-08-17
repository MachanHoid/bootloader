linker_file = shared_linker.ld
project_file = shared.c

compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy

addressTable = gen_address_table.sh

dependancy_path:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))


all_files =${project_file} ${startup_file}
driverlib_dependancies = $(wildcard driverlib/*.c)
obj_files = $(project_file:%.c=%.o) $(startup_file:boot_loader/%.S:%.o)  $(boot_dependancies:boot_loader/%.c=%.o)

.PHONY: all clean upload soft_clean

all:makeBuildDir compile soft_clean update_syms

everything: clean compile soft_clean update_syms upload

defines = TARGET_IS_TM4C123_RB1 \
		PART_TM4C123GH6PM \
		gcc \

includes = ${dependancy_path}/ 

CFLAGS = -nostdlib \
		--specs=nosys.specs \
		-mcpu=cortex-m4 \
		-mfloat-abi=hard 

CFLAGS += $(foreach i,$(includes),-I$(i))
CFLAGS += $(foreach d,$(defines),-D $(d))

CFLAGS +=  -T ${linker_file}

makeBuildDir: 
	echo ${dependancy_path}
	mkdir -p build/sharedMemory

compile: ${project_file} ${driverlib_dependancies}
	@echo compiling
	${compiler} ${CFLAGS}  $^ -o build/sharedMemory/shared.elf
	${ocpy} -O binary build/sharedMemory/shared.elf build/sharedMemory/shared.bin
	
soft_clean:
	@rm -f *.o
	@rm -f shared_syms.ld
	@echo done

update_syms:
	@ ./${addressTable}

upload:
	openocd -f board/ti_ek-tm4c123gxl.cfg -c "program build/sharedMemory/shared.elf verify reset exit"

clean:
	@rm -f build/sharedMemory/shared.bin build/sharedMemory/shared.elf *.o *.s