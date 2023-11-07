#defining directories and constants
linker_file = linkers/boot_linker.ld
new_linker_file = build/linkers_temp/boot_linker_new.ld
boot_folder = src/boot

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))
boot_files = $(call rwildcard, ./$(boot_folder), *.c) 

compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy

dependancy_path:= .

all_files =${project_file} 

.PHONY: all clean upload soft_clean

all:make_new_linker link_bootloader 

#makes new linker with links to the syms in shared.elf
make_new_linker:
	@cp $(linker_file) $(new_linker_file)
	@echo 'INCLUDE build/linkers_temp/shared_syms.ld' >> $(new_linker_file)

boot_obj_dir = build/obj_temp/boot_obj_temp
boot_folder_escaped = src\/boot
boot_obj_dir_escaped = build\/obj_temp\/boot_obj_temp
boot_obj = $(foreach i,$(boot_files), $(shell echo $(i) | sed 's/$(boot_folder_escaped)/$(boot_obj_dir_escaped)/1; s/\.c/\.o/'))

LFAGS = -T ${new_linker_file}
LFAGS += --gc-sections

link_bootloader: $(boot_obj)
	@echo linking bootloader
	$(linker) $(LFAGS) $^ -o outputs/boot.elf
