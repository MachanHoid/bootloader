dependancy_path:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
updater_file = updater.py

all : prepare_shared shared bootloader app upload_bootloader upload_shared transmit_app

prepare_shared:
	make -f gen_shared_funcs.mak

shared:
	make -f shared.mak

bootloader:
	make -f boot.mak 

# this part needs change
app:
	make -f app.mak

upload_bootloader:
	openocd -f board/ti_ek-tm4c123gxl.cfg -c "program build/bootloader/boot.elf verify reset exit"

upload_shared:
	openocd -f board/ti_ek-tm4c123gxl.cfg -c "program build/sharedMemory/shared.elf verify reset exit"
	
transmit_app:
	python3 -u "${dependancy_path}/${updater_file}" 