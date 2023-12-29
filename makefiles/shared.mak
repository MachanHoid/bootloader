#defining constants and directories
compiler = arm-none-eabi-g++
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy
python = python3

dependancy_path:= .

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

sharedlib_src_dir = shared_libraries
sharedlib_src = $(call rwildcard, ./$(sharedlib_src_dir), *.c *.cpp)

sharedlib_obj_dir = build/obj_temp/shared_libraries_obj_temp
sharedlib_obj = $(patsubst ./$(sharedlib_src_dir)/%.cpp, ./$(sharedlib_obj_dir)/%.o, $(patsubst ./$(sharedlib_src_dir)/%.c, ./$(sharedlib_obj_dir)/%.o, $(sharedlib_src)))

defines = TARGET_IS_TM4C123_RB1 \
		PART_TM4C123GH6PM \
		gcc \
		
includes = ${dependancy_path}/shared_libraries 

#to compile .c files to .o files
SHAREDLIB_COMPILE_FLAGS = -nostdlib \
						-mcpu=cortex-m4 \
						-mfloat-abi=hard \
						-ffunction-sections \
						-fno-exceptions \
						-fpermissive \
						-c -Wall\
						-g3

SHAREDLIB_COMPILE_FLAGS += $(foreach i,$(includes),-I$(i))
SHAREDLIB_COMPILE_FLAGS += $(foreach d,$(defines),-D $(d))

addressTable = gen_address_table.sh

all: link update_syms

linker_file = build/linkers_temp/shared_linker_new.ld
elf_file = outputs/shared.elf

#linker flags
LFLAGS =  -T $(linker_file)


#linking the shared lib objects with new linker to get only the functions that are common with bootloader.
link: $(sharedlib_obj)
	@echo linking shared.elf
	$(linker) $(LFLAGS) $^ -o $(elf_file)

#makes a new linker used to give the shared addresses to boot_new_linker and app_new_linker
update_syms:
	@echo syms file created with shared files
	$(python) -u "scripts/make_shared_syms_linker.py"

# Once this is done remove unnecessary sections using 
# arm-none-eabi-objcopy --remove-sections <section name> <file name>
#
# Or else you can also remove the unnecessary sections using /DISCARD/ section
# https://stackoverflow.com/questions/41511317/why-does-ld-include-sections-in-the-output-file-that-are-not-specified-in-the-li
# https://stackoverflow.com/questions/53584666/why-does-gnu-ld-include-a-section-that-does-not-appear-in-the-linker-script

