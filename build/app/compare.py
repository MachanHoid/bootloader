import numpy as np

app_dir = 'build/app/'
shared_dir = 'build/shared/'

#swapping shared ad app_raw because our logic is flipped
shared = open(f'{app_dir}app_raw_funcs.txt')
shared_funcs = set()

shared_element = shared.readline()
while (shared_element):
    shared_funcs.add(shared_element.split()[0])
    shared_element = shared.readline()

app = open(f'{app_dir}shared_funcs.txt')
app_funcs = set()

app_element = app.readline()
while (app_element):
    # print(bootloader_element)
    app_funcs.add(app_element.split()[0])
    app_element = app.readline()

sharedanddriverlib = open(f'{shared_dir}driverlib_funcs.txt')
sharedanddriverlib_funcs = set()

sharedanddriverlib_element = sharedanddriverlib.readline()
while (sharedanddriverlib_element):
    # print(bootloader_element)
    sharedanddriverlib_funcs.add(sharedanddriverlib_element.split()[0])
    sharedanddriverlib_element = sharedanddriverlib.readline()


includes = shared_funcs.difference(app_funcs)
discards = sharedanddriverlib_funcs.difference(includes)
shared.close()
app.close()

difference = open(f'{app_dir}app_difference_shared.txt','w')

difference.write('\n'.join(includes))

difference.close()


intersection = open(f'{app_dir}sharedanddriverlib_difference_includes.txt','w')
intersection.write('\n'.join(discards))
intersection.close()