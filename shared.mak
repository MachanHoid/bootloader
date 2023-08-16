linker_file = shared_linker.ld
project_file = shared.c

compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy

	
dependancy_path = /Users/niting/Nitin/IITM/Abhiyaan/Bootloader/bootloader_nalikkuday1/

all_files =${project_file} ${startup_file}
driverlib_dependancies = $(wildcard driverlib/*.c)
obj_files = $(project_file:%.c=%.o) $(startup_file:boot_loader/%.S:%.o)  $(boot_dependancies:boot_loader/%.c=%.o)

.PHONY: all clean upload soft_clean

all: compile soft_clean update_syms

everything: clean compile soft_clean update_syms upload

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

compile: ${project_file} ${driverlib_dependancies}
	@echo compiling
	${compiler} ${CFLAGS}  $^ -o shared.elf
	${ocpy} -O binary shared.elf shared.bin
	
soft_clean:
	@rm -f *.o
	@rm -f shared_syms.ld
	@echo done

update_syms:
	./gen_address_table.sh

upload:
	openocd -f board/ti_ek-tm4c123gxl.cfg -c "program shared.elf verify reset exit"

clean:
	@rm -f shared.bin shared.elf *.o *.s