# Program Flow
`Makefile` runs the entire program flow. It builds the required directories and runs `makefiles/gen_shared_funcs.mak`, `makefiles/shared.mak`, `makefiles/boot.mak`, `makefiles/app.mak` in that order. Then it uploads `outputs/boot.bin` to tiva, and then uploads `outputs/shared.bin`. We can optionally run:
```bash
make transmit_app
```
to upload the app to bootloader in update mode.

## gen_shared_funcs.mak
Creates buid directory
Creates the sharedlib json
compiles each shared lib .c file
compiles the boot files
links it with the standard linker to give `build/outputs_temp/unopt_bootloader`
Gets all the syms in unopt_bootloader
Generates new linker file for the shared.elf 

## shared.mak
