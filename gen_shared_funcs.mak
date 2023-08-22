linker_file = linker.ld
project_file = main.c
startup_file = startup_gcc.c
shared_file = shared.c

compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy
python = python3

AWK_PATH=/usr/bin/

dependancy_path:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

driverlib_src_dir = driverlib
driverlib_src = $(wildcard $(driverlib_src_dir)/*.c)

driverlib_obj_dir = driverlib_obj_temp
driverlib_obj = $(patsubst $(driverlib_src_dir)/%.c, $(driverlib_obj_dir)/%.o, $(driverlib_src))

.PHONY: all clean upload soft_clean

all:makeBuildDir compile_driverlib compile_bootloader get_dependancies

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

DRIVERLIB_COMPILE_FLAGS = -nostdlib \
						-mcpu=cortex-m4 \
						-mfloat-abi=hard \
						-ffunction-sections \
						-c -Wall\

DRIVERLIB_COMPILE_FLAGS += $(foreach i,$(includes),-I$(i))
DRIVERLIB_COMPILE_FLAGS += $(foreach d,$(defines),-D $(d))

makeBuildDir: 
	mkdir -p build/shared

compile_driverlib: $(driverlib_src) ${shared_file}
	@echo compiling
	${compiler} ${CFLAGS}  $^ -o build/shared/driverlib.elf

compile_bootloader: compile_bootloader_stage1 compile_bootloader_stage2 link_bootloader

$(driverlib_obj_dir)/%.o : $(driverlib_src_dir)/%.c
	$(compiler) $(DRIVERLIB_COMPILE_FLAGS) $< -o $@

compile_bootloader_stage1: $(driverlib_obj_dir) $(driverlib_obj)

$(driverlib_obj_dir):
	mkdir -p $(driverlib_obj_dir)

compile_bootloader_stage2: $(project_file) $(startup_file) $(shared_file)
	@echo compiling main, startup and shared
	$(compiler) $(DRIVERLIB_COMPILE_FLAGS) $^



LFAGS = -T ${linker_file}
LFAGS += --gc-sections
# 	change this wildcard to a seperate variable like driverlib_obj and put all .o files in a seperate file IMPORTANT
# this variable is to be changed to be not hardcoded
all_project_obj_files = main.o shared.o startup_gcc.o
link_bootloader: 
	$(linker) $(LFAGS) $(all_project_obj_files) $(driverlib_obj) -o build/shared/bootloader_raw.elf 
	
soft_clean:
	@rm -f *.o
	@echo done

LIB_NAME_DIR=$(dependancy_path)/build/shared/

get_dependancies:
	arm-none-eabi-nm --format=posix ${LIB_NAME_DIR}bootloader_raw.elf > ${LIB_NAME_DIR}bootloader_raw_funcs.txt
	arm-none-eabi-nm --format=posix ${LIB_NAME_DIR}driverlib.elf > ${LIB_NAME_DIR}driverlib_funcs.txt
	$(python) -u "$(LIB_NAME_DIR)compare.py"
	$(python) -u "$(LIB_NAME_DIR)make_linker.py"


clean:
	@rm -f build/bootloader/boot.bin build/bootloader/boot.elf *.o *.s
