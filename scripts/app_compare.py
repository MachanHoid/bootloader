import numpy as np

shared = open(f'build/helper_files_temp/app_files/shared_funcs.txt')
shared_funcs = set()

shared_element = shared.readline()
while (shared_element):
    shared_funcs.add(shared_element.split()[0])
    shared_element = shared.readline()

app = open(f'build/helper_files_temp/app_files/unopt_app_funcs.txt')
app_funcs = set()
app_element = app.readline()
while (app_element):
    # print(bootloader_element)
    app_funcs.add(app_element.split()[0])
    app_element = app.readline()

#TODO: Change variable names 
sharedanddriverlib = open(f'build/helper_files_temp/shared_files/sharedlib_funcs.txt')
sharedanddriverlib_funcs = set()
sharedanddriverlib_element = sharedanddriverlib.readline()
while (sharedanddriverlib_element):
    # print(bootloader_element)
    sharedanddriverlib_funcs.add(sharedanddriverlib_element.split()[0])
    sharedanddriverlib_element = sharedanddriverlib.readline()


includes = app_funcs.difference(shared_funcs)
discards = sharedanddriverlib_funcs.difference(includes)
shared.close()
app.close()

difference = open(f'build/helper_files_temp/app_files/app_difference_shared.txt','w')

difference.write('\n'.join(includes))

difference.close()


intersection = open(f'build/helper_files_temp/app_files/sharedlib_difference_includes.txt','w')
intersection.write('\n'.join(discards))
intersection.close()