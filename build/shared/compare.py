import numpy as np

shared_dir = 'build/shared/'

driverlib = open(f'{shared_dir}driverlib_funcs.txt')
driverlib_funcs = set()

driverlib_element = driverlib.readline()
while (driverlib_element):
    driverlib_funcs.add(driverlib_element.split()[0])
    driverlib_element = driverlib.readline()

bootloader = open(f'{shared_dir}bootloader_raw_funcs.txt')
bootloader_funcs = set()

bootloader_element = bootloader.readline()
while (bootloader_element):
    # print(bootloader_element)
    bootloader_funcs.add(bootloader_element.split()[0])
    bootloader_element = bootloader.readline()

bootloader_intersection_driverlib = bootloader_funcs.intersection(driverlib_funcs)
bootloader_difference_driverlib = driverlib_funcs.difference(bootloader_funcs)

driverlib.close()
bootloader.close()

intersection = open(f'{shared_dir}bootloader_intersection_driverlib.txt','w')
difference = open(f'{shared_dir}bootloader_difference_driverlib.txt','w')

intersection.write('\n'.join(bootloader_intersection_driverlib))
difference.write('\n'.join(bootloader_difference_driverlib))

intersection.close()
difference.close()