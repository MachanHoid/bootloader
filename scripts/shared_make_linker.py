linker = open("linkers/shared_linker.ld",'r')
function = open(f"build/helper_files_temp/shared_files/bootloader_intersection_sharedlib.txt",'r')
notFunction = open(f"build/helper_files_temp/shared_files/bootloader_difference_sharedlib.txt",'r')
roData_intersection = open(f"intersection_rodata.txt",'r')
roData_difference = open(f"difference_rodata.txt",'r')
newLinker = open("build/linkers_temp/shared_linker_new.ld",'w')

new_linker = ''
functions = [i.split()[0] for i in function.readlines()]
functions = ['*(.text.' + i + ')' for i in functions]
functions = '\n\t\t'.join(functions)

noFunctions = [i.split()[0] for i in notFunction.readlines()]
noFunctions = ['*(.text.' + i + ')' for i in noFunctions]
noFunctions = '\n\t\t'.join(noFunctions)

roData_intersections = [i.split()[0] for i in roData_intersection.readlines()]
roData_intersections = ['*(.rodata.' + i + ')' for i in roData_intersections]
roData_intersections = '\n\t\t'.join(roData_intersections)

roData_differences = [i.split()[0] for i in roData_difference.readlines()]
roData_differences = ['*(.rodata.' + i + ')' for i in roData_differences]
roData_differences = '\n\t\t'.join(roData_differences)

checkerDiscard = 0
checkerFunction = 0
checkerRO = 0
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
        new_linker += roData_differences
        new_linker += '\n\t}\n'
        checkerDiscard = 1
    elif i.strip() == '*(.rodata*)' and checkerRO == 0:
        new_linker += '\n\t\t'
        new_linker += roData_intersections
        new_linker += '\n'
        checkerRO = 1
    else:
        new_linker += i
newLinker.write(new_linker)

linker.close()
newLinker.close()
function.close()
notFunction.close()