compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy

dependancy_path:= .

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

sharedlib_src_dir = shared_libraries
sharedlib_src = $(call rwildcard, ./$(sharedlib_src_dir), *.c)

sharedlib_obj_dir = build/obj_temp/shared_libraries_obj_temp
sharedlib_obj = $(patsubst ./$(sharedlib_src_dir)/%.c, ./$(sharedlib_obj_dir)/%.o, $(sharedlib_src))

defines = TARGET_IS_TM4C123_RB1 \
		PART_TM4C123GH6PM \
		gcc \
		
includes = ${dependancy_path}/shared_libraries 

SHAREDLIB_COMPILE_FLAGS = -nostdlib \
						-mcpu=cortex-m4 \
						-mfloat-abi=hard \
						-ffunction-sections \
						-c -Wall\

SHAREDLIB_COMPILE_FLAGS += $(foreach i,$(includes),-I$(i))
SHAREDLIB_COMPILE_FLAGS += $(foreach d,$(defines),-D $(d))

addressTable = gen_address_table.sh

all: compile_sharedlib link update_syms

$(sharedlib_obj_dir)/%.o : $(sharedlib_src_dir)/%.c
	$(compiler) $(SHAREDLIB_COMPILE_FLAGS) $< -o $@

#TODO: Change here also
sharedlib_driverlib_dir = $(sharedlib_obj_dir)/driverlib

compile_sharedlib: $(sharedlib_obj_dir) $(sharedlib_driverlib_dir) $(sharedlib_obj)
	@echo compiling sharedlib

$(sharedlib_obj_dir): 
	mkdir -p $(sharedlib_obj_dir)

$(sharedlib_driverlib_dir): 
	mkdir -p $@

linker_file = build/linkers_temp/shared_linker_new.ld
elf_file = outputs/shared.elf

CFLAGS =  -T $(linker_file)


link: $(sharedlib_obj)
	@echo linking shared.elf
	$(linker) $(CFLAGS) $^ -o $(elf_file)

# TODO: do it only for functions. It does for all symbols? 
update_syms:
	@echo syms file created with shared files
	@ scripts/${addressTable} outputs/shared.elf build/linkers_temp/shared_syms.ld

# Once this is done remove unnecessary sections using 
# arm-none-eabi-objcopy --remove-sections <section name> <file name>
#
# Or else you can also remove the unnecessary sections using /DISCARD/ section
# https://stackoverflow.com/questions/41511317/why-does-ld-include-sections-in-the-output-file-that-are-not-specified-in-the-li
# https://stackoverflow.com/questions/53584666/why-does-gnu-ld-include-a-section-that-does-not-appear-in-the-linker-script

