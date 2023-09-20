import sys
import subprocess
# import regex

sharedlib_obj = sys.argv[1:]

opt_shared_file = './outputs/shared.elf'
opt_shared_funcs = subprocess.check_output(f'''arm-none-eabi-nm --format=posix {opt_shared_file} | /usr/bin/awk '/ T / \u007b print $1 \u007d' ''', shell=True)
opt_shared_funcs = set([i.decode() for i in opt_shared_funcs.split()]) 

for obj_file in sharedlib_obj:
    #dump all the functions
    funcs = subprocess.check_output(f'''arm-none-eabi-nm --format=posix {obj_file} | /usr/bin/awk '/ T / \u007b print $1 \u007d' ''', shell=True)
    funcs = set([i.decode() for i in funcs.split()])

    #take intersection with shared
    remove_funcs = opt_shared_funcs.intersection(funcs)
    print(remove_funcs)
    
    #remove
    for f in remove_funcs:
        subprocess.check_output(f"arm-none-eabi-objcopy --remove-section .text.{f} {obj_file}", shell=True)
    