import numpy as np

app_dir = 'build/app/'

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

app_intersection_shared = app_funcs.intersection(shared_funcs)
app_difference_shared = shared_funcs.difference(app_funcs)

shared.close()
app.close()

intersection = open(f'{app_dir}app_intersection_shared.txt','w')
difference = open(f'{app_dir}app_difference_shared.txt','w')

intersection.write('\n'.join(app_intersection_shared))
difference.write('\n'.join(app_difference_shared))

intersection.close()
difference.close()