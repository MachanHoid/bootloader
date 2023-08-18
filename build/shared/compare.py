import numpy as np

driverlib = open('driverlib_funcs.txt')
driverlib_funcs = set()

driverlib_element = driverlib.readline()
while (driverlib_element):
    # print(bootloader_element)
    driverlib_funcs.add(driverlib_element.split()[0])
    driverlib_element = driverlib.readline()

bootloader = open('bootloader_raw_funcs.txt')
bootloader_funcs = set()

bootloader_element = bootloader.readline()
while (bootloader_element):
    # print(bootloader_element)
    bootloader_funcs.add(bootloader_element.split()[0])
    bootloader_element = bootloader.readline()

bootloader_intersection_driverlib = bootloader_funcs.intersection(driverlib_funcs)
bootloader_difference_driverlib = driverlib_funcs.difference(bootloader_funcs)

np.savetxt(np.array('intersection.txt',bootloader_intersection_driverlib))
np.savetxt(np.array('difference.txt',bootloader_difference_driverlib))
