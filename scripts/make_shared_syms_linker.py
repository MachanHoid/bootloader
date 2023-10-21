import json
import os

#defining paths and constants
shared_elf = 'outputs/shared.elf'
shared_linker = 'build/linkers_temp/shared_syms.ld'
shared_syms_linker = 'build/linkers_temp/shared_syms.ld'

AWK_PATH='/usr/bin/'

req_types = ['T', 't', 'b', 'B', 'd', 'D', 'a', 'A']
types = ['T', 't', 'U', 'r', 'R', 'l', 'L', 'f', 'd', 'D', 'b', 'B', 'a', 'A']

#getting all opt_shared syms
opt_shared = json.load(open('build/helper_files_temp/shared_files/opt_shared_syms.json'))

def check_type(lib_syms, sym, types): #check type is different for opt_shared_syms
    for type in types:
        if sym in lib_syms[type]:
            return type
    return None

#getting all symbols from the elf file
shared_elf_syms = []
for type in req_types:
    shared_elf_syms += os.popen(f"arm-none-eabi-nm --format=posix {shared_elf} | {AWK_PATH}awk '/ {type} / " + "{print $1 \" = 0x0\" $3 \";\"}'").readlines()

#checking and writing to the linker file
shared_syms_linker_file = open(shared_syms_linker, 'w')
for sym in shared_elf_syms:
    sym_name = sym.split()[0]
    # if check_type(opt_shared, sym_name, types):
    #     shared_syms_linker_file.write(sym)
    shared_syms_linker_file.write(sym)