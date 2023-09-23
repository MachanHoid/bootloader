linker_file = linkers/shared_linker.ld
boot_folder = src/boot
startup_folder = startup


compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy
python = python3

AWK_PATH=/usr/bin/

dependancy_path:= .

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

sharedlib_src_dir = shared_libraries
sharedlib_src = $(call rwildcard, ./$(sharedlib_src_dir), *.c)

sharedlib_obj_dir = build/obj_temp/shared_libraries_obj_temp
sharedlib_obj = $(patsubst ./$(sharedlib_src_dir)/%.c, ./$(sharedlib_obj_dir)/%.o, $(sharedlib_src))

boot_files = $(call rwildcard, ./$(boot_folder), *.c) 
startup_files = $(call rwildcard, ./$(startup_folder), *.c) 

.PHONY: all 

all:makeBuildDir compile_sharedlib compile_bootloader get_dependancies

defines = TARGET_IS_TM4C123_RB1 \
		PART_TM4C123GH6PM \
		gcc \

includes = ${dependancy_path}/shared_libraries \

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

compile_bootloader_stage1: $(sharedlib_obj) 
	@echo compiling shared_libraries for bootloader

$(sharedlib_obj_dir)/%.o : $(sharedlib_src_dir)/%.c
	mkdir -p $(dir $@)
	$(compiler) $(SHAREDLIB_COMPILE_FLAGS) $< -o $@

boot_obj_dir = build/obj_temp/boot_obj_temp
boot_folder_escaped = src\/boot
boot_obj_dir_escaped = build\/obj_temp\/boot_obj_temp
boot_obj = $(foreach i,$(boot_files), $(shell echo $(i) | sed 's/$(boot_folder_escaped)/$(boot_obj_dir_escaped)/1; s/\.c/\.o/'))

startup_obj_dir = build/obj_temp/boot_obj_temp
startup_folder_escaped = startup
startup_obj_dir_escaped = build\/obj_temp\/boot_obj_temp
startup_obj = $(foreach i,$(startup_files), $(shell echo $(i) | sed 's/$(startup_folder_escaped)/$(startup_obj_dir_escaped)/1; s/\.c/\.o/'))

compile_bootloader_stage2: $(boot_obj) $(startup_obj)
	@echo compiling main and startup
	mkdir -p $(boot_obj_dir)

$(boot_obj_dir)/%.o : $(boot_folder)/%.c
	mkdir -p $(dir $@)	
	$(compiler) $(SHAREDLIB_COMPILE_FLAGS) $^ -o $@

$(startup_obj_dir)/%.o : $(startup_folder)/%.c
	mkdir -p $(dir $@)	
	$(compiler) $(SHAREDLIB_COMPILE_FLAGS) $^ -o $@

LFAGS = -T ${linker_file}
LFAGS += --gc-sections

link_bootloader: $(boot_obj) $(startup_obj) $(sharedlib_obj) 
	@echo linking bootloader
	$(linker) $(LFAGS) $^ -o build/outputs_temp/unopt_bootloader.elf 

LIB_NAME_DIR=$(dependancy_path)/build/outputs_temp


get_dependancies:
	@echo generating helper files
	arm-none-eabi-nm --format=posix ${LIB_NAME_DIR}/unopt_bootloader.elf > build/helper_files_temp/shared_files/unopt_bootloader_funcs.txt
	arm-none-eabi-nm --format=posix ${LIB_NAME_DIR}/unopt_shared.elf > build/helper_files_temp/shared_files/sharedlib_funcs.txt
	$(python) -u "scripts/shared_compare.py"
	$(python) -u "scripts/shared_make_linker.py"
