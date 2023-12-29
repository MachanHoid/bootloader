import numpy as np
import json

#load sharedlib syms
json_path = 'build/helper_files_temp/shared_files/sharedlib_syms.json' 
json_file = open(json_path, 'r')
sharedlib_syms = json.load(json_file)

#load unopt bootloader syms
bootloader = open(f'build/helper_files_temp/shared_files/unopt_bootloader_syms.txt')
bootloader_syms = set()

bootloader_element = bootloader.readline()
while (bootloader_element):
    bootloader_syms.add(bootloader_element.split()[0])
    bootloader_element = bootloader.readline()

types = ['T', 't', 'U', 'r', 'R', 'l', 'L', 'f', 'd', 'D', 'b', 'B', 'a', 'A']
def check_type(lib_syms, sym, types):
    for file in lib_syms.keys():
        for type in types:
            if sym in lib_syms[file][type]:
                return type
    return None

    

includes = {}
discards = {}
for type in types:
    includes[type] = []
    discards[type] = []

#looks very ineffective, try to change

#include every symbol in bootloader and shared lib
for sym in bootloader_syms:
    a = check_type(sharedlib_syms, sym, types)
    if a:
        includes[a].append(sym)

#discard every symbol in sharedlib but not in bootloader.
for type in types:
    for file in sharedlib_syms.keys():
        for sym in sharedlib_syms[file][type]:
            if sym not in includes[type]:
                discards[type].append(sym)

#write these includes to opt_shared.json
opt_shared_json_file = open('build/helper_files_temp/shared_files/opt_shared_syms.json', 'w')
json.dump(includes, opt_shared_json_file, indent=4)

#write new linker
linker = open("linkers/shared_linker.ld",'r')
newLinker = open("build/linkers_temp/shared_linker_new.ld",'w')

new_linker = ''

checkerDiscard = 0
checkerText = 0
checkerRodata = 0
checkerExceptions = 0
linker_lines = linker.readlines()

# readelf -a your_binary.elf
# This contains a line about .ARM.extab or extensions. Since we are compiling with -fno-exceptions, it is not coming up.
# This list can be then added to making a shared_syms_exceptions. We can use both the elfs to get intersections and unions and do the same

exceptions_list = []

for i in linker_lines:
    if i.strip() == '*(.text*)' and checkerText == 0:
        #writing everything other than r and R to data
        new_linker += '\n\t\t'
        new_linker += '\n\t\t'.join([f'*(.text.{sym})' for sym in includes['T']+includes['t']])
        new_linker += '\n'
        checkerText = 1
    elif i.strip() == '*(.rodata*)' and checkerRodata == 0:
        new_linker += '\n\t\t'
        new_linker += '\n\t\t'.join([f'*(.rodata.{sym})' for sym in includes['R']+includes['r']]) 
        new_linker += '\n'
        checkerRodata = 1

    elif '.ARM.extab*' in i.strip().split() and checkerExceptions == 1:
        new_linker += '\n\t\t'
        new_linker += '\n\t\t'.join([f'*(.ARM.extab.{sym})' for sym in exceptions_list]) 
        new_linker += '\n'
        checkerRodata = 1
    elif i.strip() == '} > SHARED' and checkerDiscard == 0:
        new_linker += i
        new_linker += '\n/DISCARD/ :{'
        new_linker += '\n\t\t'
        new_linker += '\n\t\t'.join([f'*(.text.{sym})' for sym in discards['T']+discards['t']])
        new_linker += '\n\t\t'
        new_linker += '\n\t\t'.join([f'*(.rodata.{sym})' for sym in discards['R']+discards['r']])
        new_linker += '\n\t}\n'
        checkerDiscard = 1
    else:
        new_linker += i
newLinker.write(new_linker)

linker.close()
newLinker.close()
     