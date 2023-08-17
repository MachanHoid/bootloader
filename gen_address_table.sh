#!/bin/bash

AWK_PATH='/usr/bin/'

echo "inside gen_address_table"

LIB_NAME='build/sharedMemory/shared'

LIB_SYMS=${LIB_NAME}_syms

# arm-none-eabi-nm --format=posix ${LIB_NAME}.elf | ${AWK_PATH}awk '/ T / {print ".equ " $1 ", 0x0" $3 }' > ${LIB_SYMS}.s

arm-none-eabi-nm --format=posix ${LIB_NAME}.elf | ${AWK_PATH}awk '/ T / {print $1 " = 0x0" $3 ";"}' > ${LIB_SYMS}.ld