linker = open("linkers/shared_linker.ld",'r')
function = open(f"build/helper_files_temp/shared_files/bootloader_intersection_sharedlib.txt",'r')
notFunction = open(f"build/helper_files_temp/shared_files/bootloader_difference_sharedlib.txt",'r')
newLinker = open("build/linkers_temp/shared_linker_new.ld",'w')

new_linker = ''
functions = [i.split()[0] for i in function.readlines()]
functions = ['*(.text.' + i + ')' for i in functions]
functions = '\n\t\t'.join(functions)

noFunctions = [i.split()[0] for i in notFunction.readlines()]
noFunctions = ['*(.text.' + i + ')' for i in noFunctions]
noFunctions = '\n\t\t'.join(noFunctions)

checkerDiscard = 0
checkerFunction = 0
linker_lines = linker.readlines()

for i in linker_lines:
    if i.strip() == '*(.text*)' and checkerFunction == 0:
        new_linker += '\n\t\t'
        new_linker += functions
        new_linker += '\n'
        checkerFunction = 1
    elif i.strip() == '} > SHARED' and checkerDiscard == 0:
        new_linker += i
        new_linker += '\n/DISCARD/ :{'
        new_linker += '\n\t\t'
        new_linker += noFunctions
        new_linker += '\n\t}\n'
        checkerDiscard = 1
    else:
        new_linker += i
newLinker.write(new_linker)

linker.close()
newLinker.close()
function.close()
notFunction.close()