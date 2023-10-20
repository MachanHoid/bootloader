# Program Flow
`Makefile` runs the entire program flow. It builds the required directories and runs `makefiles/gen_shared_funcs.mak`, `makefiles/shared.mak`, `makefiles/boot.mak`, `makefiles/app.mak` in that order. Then it uploads `outputs/boot.bin` to tiva, and then uploads `outputs/shared.bin`. We can optionally run:
```bash
make transmit_app
```
to upload the app to bootloader in update mode.

## gen_shared_funcs.mak
Creates the sharedlib json
compiles each shared lib .c file
compiles the boot files 
links it with the standard linker to give `build/outputs_temp/unopt_bootloader` (with gc sections)
Gets all the syms in unopt_bootloader
Generates new linker file for the shared.elf 

## shared.mak
Links sharedlib with new linker so only syms common to shared and bootloader are in shared.elf. Generates final output file - `shared.elf`
Creates `shared_syms.ld` that is used to identify these shared libs in the `boot_linker_new.ld` and `app_linker_new.ld`

## boot.mak
makes new linker with links to the syms in `shared.elf`
compiles with new linker to create `boot.elf` and `boot.bin`

## app.mak
creates applib_syms.json having all the symbols of the app files.
creates all the app object files
links the unoptimised app with shared lib and app files with gc sections. 
Gets the symbols from unopt app and makes new linker
Creates final output `app.elf` and `app.bin` using new linker.

# Description of Build directory and its files

## helper_files_temp
### app_files
`applib_syms.json` - has all syms of app files in json form, with keys as file names and values as dict with key of types of syms and value as list of syms
`opt_shared_syms.json` - has syms of the ouput shared.elf - dict with key of types of syms and value as list of syms
`unopt_app_syms.txt` - text file with symbol names in `unopt_shared.elf`

### shared_files
`sharedlib_syms.json` - has all the symbols of each sharedlib obj file in json form, with keys as file names and values as dict with key of types of syms and value as list of syms
`unopt_bootloader_syms.txt` - text file with symbol names in `unopt_bootloader.elf`

## linkers_temp
Contains all the generated linker files.
`shared_linker_new.ld` - linker which includes the common symbols with bootloader and discards everything else
`shared_syms.ld` - contains links to all symbols in the shared.elf file
`boot_linker_new.ld` - normal linker but also includes `shared_syms.ld`
`app_linker_new.ld` - linker which includes the uncommon symbols of (unopt_app and shared.elf) and discards (sharedlib - includes), also includes `shared_syms.ld`

## obj_temp
Contains all temporary obj files for app, boot and shared

## outputs_temp
Contains the unopt_bootloader and unopt_app. These are standalone boot and app run with gc-sections. These are used to get all the symbols needed by each standalone app/boot and further optimise.

# Outputs
boot.elf and shared.elf are uploaded by the makefile during build.
app.bin is transmitted by `scripts/updater.py` by  `make transmit_app`.