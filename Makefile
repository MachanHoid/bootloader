dependancy_path:= .
updater_file = scripts/updater.py

all : create_build_dir prepare_shared shared bootloader app upload_bootloader upload_shared 

create_build_dir:
	@mkdir -p build/linkers_temp
	@mkdir -p build/outputs_temp
	@mkdir -p build/obj_temp
	@mkdir -p build/obj_temp/shared_libraries_obj_temp
	@mkdir -p build/obj_temp/shared_libraries_obj_temp/driverlib
	@mkdir -p build/obj_temp/boot_obj_temp
	@mkdir -p build/obj_temp/app_obj_temp
	@mkdir -p build/helper_files_temp
	@mkdir -p build/helper_files_temp/shared_files
	@mkdir -p build/helper_files_temp/app_files

	@mkdir -p outputs


prepare_shared:
	make -f makefiles/gen_shared_funcs.mak

shared:
	make -f makefiles/shared.mak

bootloader:
	make -f makefiles/boot.mak 

app:
	make -f makefiles/app.mak

upload_bootloader:
	openocd -f board/ti_ek-tm4c123gxl.cfg -c "program outputs/boot.elf verify reset exit"
	echo uploaded_bootloader

upload_shared:
	openocd -f board/ti_ek-tm4c123gxl.cfg -c "program outputs/shared.elf verify reset exit"
	echo uploaded_bootloader
	
transmit_app:
	python3 -u "${dependancy_path}/${updater_file}" 
	
clean:
	rm -r build
	rm -r outputs