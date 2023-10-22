# Serial Bootloader

## Building
Run make to build the output binary files.
```bash
make
```
The source files are to be placed in `src` in the respective subdirectory. All App files are to be placed in `src/app` and all the bootloader files in `src/boot`. All the shared files to be used in both app and bootloader are to be placed in the `sharedlib` folder. This includes any functions writtend by user for bootloader and app. The tiva peripheral libraries are also placed here.

Configuration settings can be modified in `config.json`. The `mcu_port` parameter must be set to the port that the mcu is connected to.

The temporary files are stored in `build` directory.

Outputs are stored in `outputs`.

## Uploading Bootloader

The code is automatically uploaded as well to the connected tiva, when `make` is run. To Upload seperately, run:
```bash
make upload_bootloader
make upload_shared
```

## Uploading app
`updater.py` takes care of uploading the `app.bin` to the tiva loaded with bootloader. Ensure the tiva is in the proper state to recieve the app.
Tp transmit the app, run:
```bash
make transmit_app
```


Contributors: Nitin G, Adithyaa RG, AMS Arun Krishna and Vamsi Krishna

