dependancy_path:= .
updater_file = scripts/updater.py

all : create_build_dir prepare_shared shared bootloader app  upload_bootloader upload_shared 

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
	@echo making prepare_shared
	make -f makefiles/gen_shared_funcs.mak

shared:
	@echo making shared
	make -f makefiles/shared.mak

bootloader:
	@echo making bootloader
	make -f makefiles/boot.mak 

app:
	@echo making app
	make -f makefiles/app.mak

mass_erase:
	openocd -s "/share/openocd/scripts" -f "board/ti_ek-tm4c123gxl.cfg" -c "init; halt; sleep 100; flash erase_address 0 0x40000; reset; exit"

upload_bootloader:
	openocd -s "/share/openocd/scripts" -f "board/ti_ek-tm4c123gxl.cfg" -c "program outputs/boot.elf verify reset exit"

upload_shared:
	openocd -s "/share/openocd/scripts" -f "board/ti_ek-tm4c123gxl.cfg" -c "program outputs/shared.elf verify reset exit"
	
transmit_app:
	python3 -u "${dependancy_path}/${updater_file}" 
	
clean:
	rm -r build
	rm -r outputs

# debug:
# 	openocd -s "/share/openocd/scripts" -f "board/ti_ek-tm4c123gxl.cfg" -c "program outputs/boot.elf verify reset exit"
# 	openocd -s "/share/openocd/scripts" -f "board/ti_ek-tm4c123gxl.cfg" -c "program outputs/shared.elf verify reset exit"
# 	python3 -u "${dependancy_path}/${updater_file}" 
# 	open -a Terminal.app "openocd -s "/opt/homebrew/bin/openocd" -f /opt/homebrew/share/openocd/scripts/board/ti_ek-tm4c123gxl.cfg"
# 	sleep 1
# 	open -a Terminal.app "arm-none-eabi-gdb outputs/boot.elf"
	