compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy
python = python3

app_folder = src/app
startup_folder = startup

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))
app_files = $(call rwildcard, ./$(app_folder), *.c) 
startup_files = $(call rwildcard, ./$(startup_folder), *.c) 

dependancy_path = .

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


#-----------------------------------------------------------------------
linker_file = linkers/app_linker.ld
new_linker_file = build/linkers_temp/app_linker_new.ld
elf_file =  outputs/app.elf #final output
#-------
LFAGS = -T ${linker_file}
LFAGS += --gc-sections

CFLAGS =  -T $(new_linker_file) --gc-sections
#------------------------------------------------------------------------
all: compile_sharedlib gen_app_files link_app_raw  optimise_dependancies build_final
#------------------------------------------------------------------------
# generate app + driverlib + shared
# generate driver lib obj files

compile_sharedlib: $(sharedlib_obj)
	@echo compiling sharedlib

$(sharedlib_obj_dir)/%.o : $(sharedlib_src_dir)/%.c
	mkdir -p $(dir $@)
	$(compiler) $(SHAREDLIB_COMPILE_FLAGS) $< -o $@

app_obj_dir = build/obj_temp/app_obj_temp
app_folder_escaped = src\/app
app_obj_dir_escaped = build\/obj_temp\/app_obj_temp
app_obj = $(foreach i,$(app_files), $(shell echo $(i) | sed 's/$(app_folder_escaped)/$(app_obj_dir_escaped)/1; s/\.c/\.o/'))

startup_obj_dir = build/obj_temp/app_obj_temp
startup_folder_escaped = startup
startup_obj_dir_escaped = build\/obj_temp\/app_obj_temp
startup_obj = $(foreach i,$(startup_files), $(shell echo $(i) | sed 's/$(startup_folder_escaped)/$(startup_obj_dir_escaped)/1; s/\.c/\.o/'))

gen_app_files: $(app_obj) $(startup_obj)
	@echo compiling app and startup
	mkdir -p $(app_obj_dir)

$(app_obj_dir)/%.o : $(app_folder)/%.c
	mkdir -p $(dir $@)	
	$(compiler) $(SHAREDLIB_COMPILE_FLAGS) $^ -o $@

$(startup_obj_dir)/%.o : $(startup_folder)/%.c
	mkdir -p $(dir $@)	
	$(compiler) $(SHAREDLIB_COMPILE_FLAGS) $^ -o $@


# kill dead code in this
#linking
link_app_raw: $(app_obj) $(startup_obj) $(sharedlib_obj)
	$(linker) $(LFAGS) $^ -o build/outputs_temp/unopt_app.elf
	
# compare with shared.elf funcs
optimise_dependancies:
	arm-none-eabi-nm --format=posix build/outputs_temp/unopt_app.elf > build/helper_files_temp/app_files/unopt_app_funcs.txt
	arm-none-eabi-nm --format=posix outputs/shared.elf > build/helper_files_temp/app_files/shared_funcs.txt
	$(python) -u "scripts/app_compare.py"
	$(python) -u "scripts/app_make_linker.py"

#build the final file
build_final: $(app_obj) $(startup_obj) $(sharedlib_obj)
	$(linker) $(CFLAGS) $^ -o $(elf_file)
	${ocpy} -O binary outputs/app.elf outputs/app.bin