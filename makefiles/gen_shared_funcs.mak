#defining directories and constants
linker_file = linkers/shared_linker.ld
boot_folder = src/boot


compiler = arm-none-eabi-g++
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy
python = python3

AWK_PATH=/usr/bin/

dependancy_path:= .

#defining sharedlib src files and obj files
rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

sharedlib_src_dir = shared_libraries
sharedlib_src = $(call rwildcard, ./$(sharedlib_src_dir), *.c *.cpp)

sharedlib_obj_dir = build/obj_temp/shared_libraries_obj_temp
# sharedlib_obj := $(patsubst ./$(sharedlib_src_dir)/%.c, ./$(sharedlib_obj_dir)/%.o, $(sharedlib_src))
sharedlib_obj = $(patsubst ./$(sharedlib_src_dir)/%.cpp, ./$(sharedlib_obj_dir)/%.o, $(patsubst ./$(sharedlib_src_dir)/%.c, ./$(sharedlib_obj_dir)/%.o, $(sharedlib_src)))

#defining bootfiles recursively
boot_files = $(call rwildcard, ./$(boot_folder), *.c *.cpp) 

.PHONY: all 

all:  compile_bootloader get_dependancies

defines = TARGET_IS_TM4C123_RB1 \
		PART_TM4C123GH6PM \
		gcc \

includes = ${dependancy_path}/shared_libraries \

#to create .elf directly from c files
CFLAGS = -nostdlib \
		--specs=nosys.specs \
		-mcpu=cortex-m4 \
		-fpermissive \
		-fno-exceptions \
		-mfloat-abi=hard \
		-g3 

CFLAGS += $(foreach i,$(includes),-I$(i))
CFLAGS += $(foreach d,$(defines),-D $(d))

CFLAGS +=  -T ${linker_file}

#to compile the .c files to .o files.
SHAREDLIB_COMPILE_FLAGS = -nostdlib \
						-mcpu=cortex-m4 \
						-mfloat-abi=hard \
						-ffunction-sections \
						-fpermissive \
						-fno-exceptions \
						-fdata-sections \
						-c -Wall\
						-g3

SHAREDLIB_COMPILE_FLAGS += $(foreach i,$(includes),-I$(i))
SHAREDLIB_COMPILE_FLAGS += $(foreach d,$(defines),-D $(d))

compile_bootloader: create_json compile_bootloader_stage1 compile_bootloader_stage2 link_bootloader

sharedlib_json = build/helper_files_temp/shared_files/sharedlib_syms.json 
opt_shared_json = build/helper_files_temp/shared_files/opt_shared_syms.json  
create_json: 
	touch $(sharedlib_json)
	touch $(opt_shared_json) 

compile_bootloader_stage1: $(sharedlib_obj) 
	@echo compiling shared_libraries for bootloader

#generate symbols while making .o files for all the sharedlib
$(sharedlib_obj_dir)/%.o : $(sharedlib_src_dir)/%.cpp
	mkdir -p $(dir $@)
	$(compiler) $(SHAREDLIB_COMPILE_FLAGS) $< -o $@
	$(python) -u "scripts/gen_syms.py" $@ $(sharedlib_json)

$(sharedlib_obj_dir)/%.o : $(sharedlib_src_dir)/%.c
	mkdir -p $(dir $@)
	$(compiler) $(SHAREDLIB_COMPILE_FLAGS) $< -o $@
	$(python) -u "scripts/gen_syms.py" $@ $(sharedlib_json)


boot_obj_dir = build/obj_temp/boot_obj_temp
boot_folder_escaped = src\/boot
boot_obj_dir_escaped = build\/obj_temp\/boot_obj_temp
boot_obj = $(foreach i,$(boot_files), $(shell echo $(i) | sed 's/$(boot_folder_escaped)/$(boot_obj_dir_escaped)/1; s/\.cpp/\.o/; s/\.c/\.o/'))

#compile the bootloader files
compile_bootloader_stage2: $(boot_obj)
	@echo compiling boot objects 
	mkdir -p $(boot_obj_dir)

$(boot_obj_dir)/%.o : $(boot_folder)/%.cpp
	mkdir -p $(dir $@)	
	$(compiler) $(SHAREDLIB_COMPILE_FLAGS) $^ -o $@

$(boot_obj_dir)/%.o : $(boot_folder)/%.c
	mkdir -p $(dir $@)	
	$(compiler) $(SHAREDLIB_COMPILE_FLAGS) $^ -o $@

bootloader_linker = linkers/boot_linker.ld
LFAGS = -T ${bootloader_linker}
LFAGS += --gc-sections

#link it with gc sections to make unopt_bootloader
link_bootloader: $(boot_obj) $(sharedlib_obj) 
	@echo linking bootloader
	$(linker) $(LFAGS) $^ -o build/outputs_temp/unopt_bootloader.elf 

LIB_NAME_DIR=$(dependancy_path)/build/outputs_temp

#get the unopt bootloader syms and make linker using the syms obtained
get_dependancies:
	@echo generating helper files
	arm-none-eabi-nm --format=posix ${LIB_NAME_DIR}/unopt_bootloader.elf > build/helper_files_temp/shared_files/unopt_bootloader_syms.txt
	$(python) -u "scripts/shared_make_linker.py"
