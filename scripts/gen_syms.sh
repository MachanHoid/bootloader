#!/bin/bash


# generates and classifies all symbols of $1 and puts results in the the directory $2 - this is for a .o file
AWK_PATH='/usr/bin/'
echo "inside gen_syms"

filename=$1
dir=$2

arm-none-eabi-nm ${filename} | ${AWK_PATH}awk '/ T / {print $3 " = 0x0" $1 ";"}' >> ${dir}/global_text.txt
arm-none-eabi-nm ${filename} | ${AWK_PATH}awk '/ t / {print $3 " = 0x0" $1 ";"}' >> ${dir}/local_text.txt
arm-none-eabi-nm ${filename} | ${AWK_PATH}awk '/ U / {print $3 " = 0x0" $1 ";"}' >> ${dir}/undefined.txt
arm-none-eabi-nm ${filename} | ${AWK_PATH}awk '/ r / {print $3 " = 0x0" $1 ";"}' >> ${dir}/local_readonly.txt
arm-none-eabi-nm ${filename} | ${AWK_PATH}awk '/ R / {print $3 " = 0x0" $1 ";"}' >> ${dir}/global_readonly.txt
arm-none-eabi-nm ${filename} | ${AWK_PATH}awk '/ l / {print $3 " = 0x0" $1 ";"}' >> ${dir}/static_thread_local_symbol.txt
arm-none-eabi-nm ${filename} | ${AWK_PATH}awk '/ L / {print $3 " = 0x0" $1 ";"}' >> ${dir}/global_thread_local_symbol.txt
arm-none-eabi-nm ${filename} | ${AWK_PATH}awk '/ f / {print $3 " = 0x0" $1 ";"}' >> ${dir}/source_file_name_symbol.txt
arm-none-eabi-nm ${filename} | ${AWK_PATH}awk '/ d / {print $3 " = 0x0" $1 ";"}' >> ${dir}/local_data.txt
arm-none-eabi-nm ${filename} | ${AWK_PATH}awk '/ D / {print $3 " = 0x0" $1 ";"}' >> ${dir}/global_data.txt
arm-none-eabi-nm ${filename} | ${AWK_PATH}awk '/ b / {print $3 " = 0x0" $1 ";"}' >> ${dir}/local_bss.txt
arm-none-eabi-nm ${filename} | ${AWK_PATH}awk '/ B / {print $3 " = 0x0" $1 ";"}' >> ${dir}/global_bss.txt
arm-none-eabi-nm ${filename} | ${AWK_PATH}awk '/ a / {print $3 " = 0x0" $1 ";"}' >> ${dir}/local_absolute.txt
arm-none-eabi-nm ${filename} | ${AWK_PATH}awk '/ A / {print $3 " = 0x0" $1 ";"}' >> ${dir}/global_absolute.txt