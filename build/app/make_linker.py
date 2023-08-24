app_dir = 'build/app/'

linker = open("app_linker.ld",'r')
# function is for the list of functions that are to be included
function = open(f"{app_dir}app_difference_shared.txt",'r')
#notFunction is for the list of functions that are to be discarded
notFunction = open(f"{app_dir}sharedanddriverlib_difference_includes.txt",'r')
newLinker = open("app_linker_new.ld",'w')

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
    elif i.strip() == '} > APPROM' and checkerDiscard == 0:
        new_linker += i
        new_linker += '\n/DISCARD/ :{'
        new_linker += '\n\t\t'
        # new_linker += noFunctions
        new_linker += '\n\t}\n'
        checkerDiscard = 1
    else:
        new_linker += i

newLinker.write(new_linker)

linker.close()
newLinker.close()
function.close()
notFunction.close()