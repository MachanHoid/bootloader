linker_file = linkers/shared_linker.ld
project_file = src/boot.c
startup_file = startup/startup_gcc.c


compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy
python = python3

AWK_PATH=/usr/bin/

dependancy_path:= .

# We should also have a JSON file where we can give the include paths 
rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

sharedlib_src_dir = shared_libraries
sharedlib_src = $(call rwildcard, ./$(sharedlib_src_dir), *.c)

sharedlib_obj_dir = build/obj_temp/shared_libraries_obj_temp
sharedlib_obj = $(patsubst ./$(sharedlib_src_dir)/%.c, ./$(sharedlib_obj_dir)/%.o, $(sharedlib_src))

.PHONY: all  

all:makeBuildDir compile_sharedlib compile_bootloader get_dependancies

defines = TARGET_IS_TM4C123_RB1 \
		PART_TM4C123GH6PM \
		gcc \

# Why are we doing this? Automate it??s
includes = ${dependancy_path}/shared_libraries \
			${dependancy_path}/shared_libraries/inc \
			${dependancy_path}/shared_libraries/driverlib \
			${dependancy_path}/shared_libraries/utils

CFLAGS = -nostdlib \
		--specs=nosys.specs \
		-mcpu=cortex-m4 \
		-mfloat-abi=hard 

CFLAGS += $(foreach i,$(includes),-I$(i))
CFLAGS += $(foreach d,$(defines),-D $(d))

CFLAGS +=  -T ${linker_file}

SHAREDLIB_COMPILE_FLAGS = -nostdlib \
						-mcpu=cortex-m4 \
						-mfloat-abi=hard \
						-ffunction-sections \
						-c -Wall\

SHAREDLIB_COMPILE_FLAGS += $(foreach i,$(includes),-I$(i))
SHAREDLIB_COMPILE_FLAGS += $(foreach d,$(defines),-D $(d))

makeBuildDir: 
	mkdir -p build/obj_temp/shared_libraries_obj_temp

compile_sharedlib: $(sharedlib_src)
	@echo compiling shared_libraries
	${compiler} ${CFLAGS}  $^ -o build/outputs_temp/unopt_shared.elf

compile_bootloader: compile_bootloader_stage1 compile_bootloader_stage2 link_bootloader

# What's this ? Why are we doing separately
sharedlib_driverlib_dir = $(sharedlib_obj_dir)/driverlib

compile_bootloader_stage1: $(sharedlib_obj_dir) $(sharedlib_driverlib_dir) $(sharedlib_obj) 
	@echo compiling shared_libraries for bootloader

$(sharedlib_obj_dir): 
	mkdir -p $(sharedlib_obj_dir)

$(sharedlib_driverlib_dir): 
	mkdir -p $@

$(sharedlib_obj_dir)/%.o : $(sharedlib_src_dir)/%.c
	$(compiler) $(SHAREDLIB_COMPILE_FLAGS) $< -o $@

boot_files = $(project_file) $(startup_file)
# NOT WORKING PLS CHECK - doing some jugaad for now
# boot_obj = $(patsubst %/%.c, build/obj_temp/boot_obj_temp/%.o, $(boot_files))

# Should not do this manually. Bootloader might be made up of several files on its own. 
# Including them manually is wrong
boot_obj = build/obj_temp/boot_obj_temp/boot.o build/obj_temp/boot_obj_temp/startup_gcc.o 
boot_obj_dir = build/obj_temp/boot_obj_temp 

compile_bootloader_stage2: $(boot_obj) $(boot_obj_dir)
	@echo compiling main and startup
	@echo $(boot_obj)

$(boot_obj_dir):
	mkdir -p $(boot_obj_dir)
	
#hardcoding for 2 files right now
bootfile_obj_dir = build/obj_temp/boot_obj_temp/boot.o
startup_obj_dir = build/obj_temp/boot_obj_temp/startup_gcc.o
$(bootfile_obj_dir) : src/boot.c
	$(compiler) $(SHAREDLIB_COMPILE_FLAGS) $^ -o $@	

$(startup_obj_dir) : startup/startup_gcc.c
	$(compiler) $(SHAREDLIB_COMPILE_FLAGS) $^ -o $@	

LFAGS = -T ${linker_file}
LFAGS += --gc-sections

link_bootloader: 
	@echo linking bootloader
	$(linker) $(LFAGS) $(boot_obj) $(sharedlib_obj) -o build/outputs_temp/unopt_bootloader.elf 

LIB_NAME_DIR=$(dependancy_path)/build/outputs_temp

get_dependancies:
	@echo generating helper files
	arm-none-eabi-nm --format=posix ${LIB_NAME_DIR}/unopt_bootloader.elf > build/helper_files_temp/shared_files/unopt_bootloader_funcs.txt
	arm-none-eabi-nm --format=posix ${LIB_NAME_DIR}/unopt_shared.elf > build/helper_files_temp/shared_files/sharedlib_funcs.txt
	$(python) -u "scripts/shared_compare.py"
	$(python) -u "scripts/shared_make_linker.py"
