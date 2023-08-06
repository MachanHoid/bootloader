linker_file = bootloader_linker.ld
startup_file = startup_gcc.c
project_file = main.c

compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
	
dependancy_path = /Users/niting/Nitin/IITM/Abhiyaan/Bootloader/bootloader_nalikkuday1/

all_files =${project_file} ${startup_file}
driverlib_dependancies = $(wildcard driverlib/*.c)
#boot_dependancies = $(wildcard boot_loader/*.c) 
obj_files = $(project_file:%.c=%.o) $(startup_file:boot_loader/%.S:%.o)  $(boot_dependancies:boot_loader/%.c=%.o)

.PHONY: all clean upload soft_clean

all: compile soft_clean

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

compile: ${project_file} ${startup_file} ${driverlib_dependancies} #${boot_dependancies}
	@echo compiling
	${compiler} ${CFLAGS}  $^ -o output.bin
	
soft_clean:
	@rm -f *.o
	@echo done

upload:
	openocd -f board/ti_ek-tm4c123gxl.cfg -c "program output.bin verify reset exit"

clean:
	@rm -f output.bin *.o *.s
