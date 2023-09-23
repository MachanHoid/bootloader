compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy
python = python3

dependancy_path = .

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


#-----------------------------------------------------------------------
app_file = $(dependancy_path)/src/app.c
startup_file = $(dependancy_path)/startup/startup_gcc.c
all_files = $(app_file) $(startup_file)
#HARDCODING THIS, CHANGE LATER
all_files_obj = build/obj_temp/app_obj_temp/app.o build/obj_temp/app_obj_temp/startup_gcc.o 
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

# generate shared and app
# gen_all_files : $(all_files_obj) 
# 	@echo all obj files are : $(all_files_obj)
#NOT WORKING 
# $(all_files_obj) : %.o : %.c
# 	@echo all_files_obj compiling
# 	$(compiler) $(DRIVERLIB_COMPILE_FLAGS) $< -o $@
#FIX (this also not working goppa mavane):
# $(app_file: %.c=%.o) : $(app_file)
# 	$(compiler) $(DRIVERLIB_COMPILE_FLAGS) $< -o $@
# $(shared_file: %.c=%.o) : $(shared_file)
# 	$(compiler) $(DRIVERLIB_COMPILE_FLAGS) $< -o $@
gen_app_files: $(all_files_obj)
#HARDCODING FOR NOW CHANGE LATER
appfile_obj_dir = build/obj_temp/app_obj_temp/app.o
startup_obj_dir = build/obj_temp/app_obj_temp/startup_gcc.o
$(appfile_obj_dir) : src/app.c
	$(compiler) $(SHAREDLIB_COMPILE_FLAGS) $^ -o $@	

$(startup_obj_dir) : startup/startup_gcc.c
	$(compiler) $(SHAREDLIB_COMPILE_FLAGS) $^ -o $@	


# kill dead code in this
#linking
link_app_raw: $(all_files_obj) $(sharedlib_obj)
	$(linker) $(LFAGS) $^ -o build/outputs_temp/unopt_app.elf
	
# compare with shared.elf funcs
optimise_dependancies:
	arm-none-eabi-nm --format=posix build/outputs_temp/unopt_app.elf > build/helper_files_temp/app_files/unopt_app_funcs.txt
	arm-none-eabi-nm --format=posix outputs/shared.elf > build/helper_files_temp/app_files/shared_funcs.txt
	$(python) -u "scripts/app_compare.py"
	$(python) -u "scripts/app_make_linker.py"

#build the final file
build_final: $(all_files_obj) $(sharedlib_obj) 
	$(linker) $(CFLAGS) $^ -o $(elf_file)
	${ocpy} -O binary outputs/app.elf outputs/app.bin