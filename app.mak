compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy
python = python3

driverlib_src_dir = driverlib
driverlib_src = $(wildcard $(driverlib_src_dir)/*.c)

driverlib_obj_dir = driverlib_obj
driverlib_obj = $(patsubst $(driverlib_src_dir)/%.c, $(driverlib_obj_dir)/%.o, $(driverlib_src))

defines = TARGET_IS_TM4C123_RB1 \
		PART_TM4C123GH6PM \
		gcc \
		
dependancy_path = $(strip $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST)))))
LIB_NAME_DIR = $(dependancy_path)/build/app
SHARED_DIR = $(dependancy_path)/build/sharedMemory
includes = ${dependancy_path} 

DRIVERLIB_COMPILE_FLAGS = -nostdlib \
						-mcpu=cortex-m4 \
						-mfloat-abi=hard \
						-ffunction-sections \
						-c -Wall\

DRIVERLIB_COMPILE_FLAGS += $(foreach i,$(includes),-I$(i))
DRIVERLIB_COMPILE_FLAGS += $(foreach d,$(defines),-D $(d))

addressTable = gen_address_table.sh


#-----------------------------------------------------------------------
app_file = $(dependancy_path)/blinky.c
shared_file = $(dependancy_path)/shared.c
startup_file = $(dependancy_path)/startup_gcc.c
all_files = $(app_file) $(shared_file) $(startup_file)
all_files_obj = $(all_files:%.c=%.o)
linker_file = app_plain_linker.ld
app_linker_file = app_linker_new.ld
elf_file =  $(LIB_NAME_DIR)/app.elf #final output
#-------
LFAGS = -T ${linker_file}
LFAGS += --gc-sections
LFLAGS += --print-gc-sections

CFLAGS =  -T $(app_linker_file)
#------------------------------------------------------------------------
all: gen_driverlib_obj gen_all_files link_app_raw  optimise_dependancies build_final soft_clean
#------------------------------------------------------------------------
# generate app + driverlib + shared
# generate driver lib obj files
$(driverlib_obj_dir)/%.o : $(driverlib_src_dir)/%.c
	$(compiler) $(DRIVERLIB_COMPILE_FLAGS) $< -o $@

gen_driverlib_obj: $(driverlib_obj_dir) $(driverlib_obj)

$(driverlib_obj_dir):
	mkdir -p $(driverlib_obj_dir)

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
gen_all_files : $(all_files)
	$(compiler) $(DRIVERLIB_COMPILE_FLAGS) $^ 
	@echo all obj files are : $(all_files_obj)


# kill dead code in this
#linking
link_app_raw: $(all_files_obj) $(driverlib_obj)
	$(linker) $(LFAGS) $^ -o build/app/app_raw.elf 
	
soft_clean:
	@rm -f *.o
	@echo done

# compare with shared.elf funcs
optimise_dependancies:
	arm-none-eabi-nm --format=posix ${LIB_NAME_DIR}/app_raw.elf > ${LIB_NAME_DIR}/app_raw_funcs.txt
	arm-none-eabi-nm --format=posix ${SHARED_DIR}/shared.elf > ${LIB_NAME_DIR}/shared_funcs.txt
	$(python) -u "$(LIB_NAME_DIR)/compare.py"
	$(python) -u "$(LIB_NAME_DIR)/make_linker.py"

#build the final file
build_final: $(all_files_obj) $(driverlib_obj) 
	$(linker) $(CFLAGS) $^ -o $(elf_file)
	${ocpy} -O binary build/app/app.elf build/app/app.bin