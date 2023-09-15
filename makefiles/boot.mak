linker_file = linkers/boot_linker.ld
new_linker_file = build/linkers_temp/boot_linker_new.ld
startup_file = startup/startup_gcc.c
project_file = src/boot.c

compiler = arm-none-eabi-gcc
assembler = arm-none-eabi-as
linker = arm-none-eabi-ld
ocpy = arm-none-eabi-objcopy

dependancy_path:= .

all_files =${project_file} ${startup_file}

.PHONY: all clean upload soft_clean

all:make_new_linker compile

defines = TARGET_IS_TM4C123_RB1 \
		PART_TM4C123GH6PM \
		gcc \

includes = ${dependancy_path}/shared_libraries \
			${dependancy_path}/shared_libraries/inc \
			${dependancy_path}/shared_libraries/driverlib \
			${dependancy_path}/shared_libraries/utils

CFLAGS = -nostdlib \
		--specs=nosys.specs \
		-mcpu=cortex-m4 \
		-mfloat-abi=hard 

CFLAGS += $(foreach i,$(includes),-I$(i))
CFLAGS += $(foreach d,$(defines),-D $(d))

CFLAGS +=  -T ${new_linker_file}

make_new_linker:
	@cp $(linker_file) $(new_linker_file)
	@echo 'INCLUDE build/linkers_temp/shared_syms.ld' >> $(new_linker_file)

compile: ${project_file} ${startup_file}
	@echo compiling
	${compiler} ${CFLAGS}  $^ -o outputs/boot.elf
	${ocpy} -O binary outputs/boot.elf outputs/boot.bin
