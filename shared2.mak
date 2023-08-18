compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy

driverlib_src_dir = driverlib
driverlib_src = $(wildcard $(driverlib_src_dir)/*.c)

driverlib_obj_dir = driverlib_obj
driverlib_obj = $(patsubst $(driverlib_src_dir)/%.c, $(driverlib_obj_dir)/%.o, $(driverlib_src))

defines = TARGET_IS_TM4C123_RB1 \
		PART_TM4C123GH6PM \
		gcc \
		
dependancy_path = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST)))) 
includes = ${dependancy_path} 

DRIVERLIB_COMPILE_FLAGS = -nostdlib \
						-mcpu=cortex-m4 \
						-mfloat-abi=hard \
						-ffunction-sections \
						-c -Wall\

DRIVERLIB_COMPILE_FLAGS += $(foreach i,$(includes),-I$(i))
DRIVERLIB_COMPILE_FLAGS += $(foreach d,$(defines),-D $(d))

all: stage1 stage2 stage3

$(driverlib_obj_dir)/%.o : $(driverlib_src_dir)/%.c
	$(compiler) $(DRIVERLIB_COMPILE_FLAGS) $< -o $@

stage1: $(driverlib_obj_dir) $(driverlib_obj)

$(driverlib_obj_dir):
	mkdir -p $(driverlib_obj_dir)




project_file = shared.c
project_obj_file = shared_temp.o

$(project_obj_file): $(project_file)
	$(compiler) $(DRIVERLIB_COMPILE_FLAGS) $< -o $@

stage2: $(project_obj_file)



# CFLAGS = -nostdlib \
# 		--specs=nosys.specs \
# 		-ffunction-sections \
# 		-mcpu=cortex-m4 \
# 		-mfloat-abi=hard \
# 		--gc-sections 

# CFLAGS += $(foreach i,$(includes),-I$(i))
# CFLAGS += $(foreach d,$(defines),-D $(d))

# CFLAGS +=  -T $(linker_file)

CFLAGS =  -T $(linker_file)

linker_file = shared_linker_temp.ld
elf_file = shared_temp.elf

stage3: $(project_obj_file) $(linker_file) 
	$(linker) $(CFLAGS) $< -o $(elf_file)

# Once this is done remove unnecessary sections using 
# arm-none-eabi-objcopy --remove-sections <section name> <file name>
#
# Or else you can also remove the unnecessary sections using /DISCARD/ section
# https://stackoverflow.com/questions/41511317/why-does-ld-include-sections-in-the-output-file-that-are-not-specified-in-the-li
# https://stackoverflow.com/questions/53584666/why-does-gnu-ld-include-a-section-that-does-not-appear-in-the-linker-script

