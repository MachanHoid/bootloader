#!/bin/bash

# we should pass the path of the file as an argument
# first arg = filename
# second arg = destination file name

AWK_PATH='/usr/bin/'

echo "inside gen_address_table"

LIB_NAME=$1

LIB_SYMS=$2

#generating the local and Global text symbols for a elf file
arm-none-eabi-nm --format=posix ${LIB_NAME} | ${AWK_PATH}awk '/ T / {print $1 " = 0x0" $3 ";"}' > ${LIB_SYMS}
arm-none-eabi-nm --format=posix ${LIB_NAME} | ${AWK_PATH}awk '/ t / {print $1 " = 0x0" $3 ";"}' >> ${LIB_SYMS}