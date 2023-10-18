import json

#dictionary of types as keys and list of syms as value
opt_shared = json.load(open('build/helper_files_temp/app_files/opt_shared_syms.json'))

#getting unopt_app_syms
app = open(f'build/helper_files_temp/app_files/unopt_app_funcs.txt')
app_syms = set()
app_element = app.readline()
while (app_element):
    app_syms.add(app_element.split()[0])
    app_element = app.readline()

#dictionary of files as keys and another dict as value - dict has types as keys and list of syms as value
sharedlib_syms = json.load(open('build/helper_files_temp/shared_files/sharedlib_syms.json'))
applib_syms = json.load(open('build/helper_files_temp/app_files/applib_syms.json'))

types = ['T', 't', 'U', 'r', 'R', 'l', 'L', 'f', 'd', 'D', 'b', 'B', 'a', 'A']
def check_type(lib_syms, sym):
    for file in lib_syms.keys():
        for type in types:
            if sym in lib_syms[file][type]:
                return type
    return None
#initialising
includes = {}
discards = {}
for type in types:
    includes[type] = []
    discards[type] = []

#creating the includes, app syms that are not in opt_shared
for sym in app_syms:
    type = check_type(applib_syms, sym)
    if type:
        if sym not in opt_shared[type]:
            includes[type].append(sym)
#creating discards as ssharedlib difference includes
for type in types:
    for file in sharedlib_syms.keys():
        for sym in sharedlib_syms[file][type]:
            if sym not in includes[type]:
                discards[type].append(sym)

linker = open("linkers/app_linker.ld",'r')
newLinker = open("build/linkers_temp/app_linker_new.ld",'w')

new_linker = ''

checkerDiscard = 0
checkerText = 0
checkerRodata = 0
linker_lines = linker.readlines()

for i in linker_lines:
    if i.strip() == '*(.text*)' and checkerText == 0:
        new_linker += '\n\t\t'
        new_linker += '\n\t\t'.join([f'*(.text.{sym})' for sym in includes['T']+includes['t']+includes['U']+includes['a']+includes['A']+includes['l']+includes['L']+includes['f']+includes['D']+includes['d']+includes['b']+includes['B']])
        new_linker += '\n'
        checkerText = 1
    elif i.strip() == '*(.rodata*)' and checkerRodata == 0:
        new_linker += '\n\t\t'
        new_linker += '\n\t\t'.join([f'*(.rodata.{sym})' for sym in includes['R']+includes['r']]) 
        new_linker += '\n'
        checkerRodata = 1
    elif i.strip() == '} > APPROM' and checkerDiscard == 0:
        new_linker += i
        new_linker += '\n/DISCARD/ :{'
        new_linker += '\n\t\t'
        new_linker += '\n\t\t'.join([f'*(.text.{sym})' for sym in discards['T']+discards['t']+includes['U']+includes['a']+includes['A']+includes['l']+includes['L']+includes['f']+includes['D']+includes['d']+includes['b']+includes['B']])
        new_linker += '\n\t\t'
        new_linker += '\n\t\t'.join([f'*(.rodata.{sym})' for sym in discards['R']+discards['r']])
        new_linker += '\n\t}\n'
        checkerDiscard = 1
    else:
        new_linker += i

new_linker += 'INCLUDE build/linkers_temp/shared_syms.ld'

newLinker.write(new_linker)

linker.close()
newLinker.close()
     

