#defining constants and directories
compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy
python = python3

app_folder = src/app

# defining app files in app dir
rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))
app_files = $(call rwildcard, ./$(app_folder), *.c) 

dependancy_path = .

#defining shared files in sharedlib dir
sharedlib_src_dir = shared_libraries
sharedlib_src = $(call rwildcard, ./$(sharedlib_src_dir), *.c)

sharedlib_obj_dir = build/obj_temp/shared_libraries_obj_temp
sharedlib_obj = $(patsubst ./$(sharedlib_src_dir)/%.c, ./$(sharedlib_obj_dir)/%.o, $(sharedlib_src))

defines = TARGET_IS_TM4C123_RB1 \
		PART_TM4C123GH6PM \
		gcc \

includes = ${dependancy_path}/shared_libraries 

#to compile .o from .c files
SHAREDLIB_COMPILE_FLAGS = -nostdlib \
						-mcpu=cortex-m4 \
						-mfloat-abi=hard \
						-ffunction-sections \
						-fdata-sections \
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
all: create_json gen_app_files link_unopt_app  optimise_dependancies build_final
#------------------------------------------------------------------------
# generate app + sharedlib
app_obj_dir = build/obj_temp/app_obj_temp
app_folder_escaped = src\/app
app_obj_dir_escaped = build\/obj_temp\/app_obj_temp
app_obj = $(foreach i,$(app_files), $(shell echo $(i) | sed 's/$(app_folder_escaped)/$(app_obj_dir_escaped)/1; s/\.c/\.o/'))

applib_json = build/helper_files_temp/app_files/applib_syms.json 

create_json:
	touch $(applib_json)

gen_app_files: $(app_obj) create_json
	@echo compiling app  
	mkdir -p $(app_obj_dir)
	
#create each app obj file and update its syms
$(app_obj_dir)/%.o : $(app_folder)/%.c
	mkdir -p $(dir $@)	
	$(compiler) $(SHAREDLIB_COMPILE_FLAGS) $^ -o $@
	$(python) -u "scripts/gen_syms.py" $@ $(applib_json)



# kill dead code in this
#linking unopt app from sharedlib and app objects
link_unopt_app: $(app_obj)  $(sharedlib_obj)
	$(linker) $(LFAGS) $^ -o build/outputs_temp/unopt_app.elf
	
# compare with shared.elf syms and make new linker 
optimise_dependancies:
	arm-none-eabi-nm --format=posix build/outputs_temp/unopt_app.elf > build/helper_files_temp/app_files/unopt_app_syms.txt
	$(python) -u "scripts/app_make_linker.py"

#build the final file with links to shared.elf funcs and create binary output.
build_final: $(app_obj)  $(sharedlib_obj)
	$(linker) $(CFLAGS) $^ -o $(elf_file)
	${ocpy} -O binary outputs/app.elf outputs/app.bin