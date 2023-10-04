import numpy as np

#TODO: change the variable names properly


driverlib = open(f'build/helper_files_temp/shared_files/sharedlib_funcs.txt')
driverlib_funcs = set()

driverlib_element = driverlib.readline()
while (driverlib_element):
    driverlib_funcs.add(driverlib_element.split()[0])
    driverlib_element = driverlib.readline()

bootloader = open(f'build/helper_files_temp/shared_files/unopt_bootloader_funcs.txt')
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

intersection = open(f'build/helper_files_temp/shared_files/bootloader_intersection_sharedlib.txt','w')
difference = open(f'build/helper_files_temp/shared_files/bootloader_difference_sharedlib.txt','w')

intersection.write('\n'.join(bootloader_intersection_driverlib))
difference.write('\n'.join(bootloader_difference_driverlib))

intersection.close()
difference.close()


shared_ro = open(f'build/helper_files_temp/shared_files/sharedlib_syms/local_readonly.txt')
shared_ro_data = set()

shared_ro_element = shared_ro.readline()
while (shared_ro_element):
    shared_ro_data.add(shared_ro_element.split()[0])
    shared_ro_element = shared_ro.readline()

unopt_bootloader_all = open(f'build/helper_files_temp/shared_files/unopt_bootloader_funcs.txt')
unopt_bootloader_all_data = set()

bootloader_element = unopt_bootloader_all.readline()
while (bootloader_element):
    # print(bootloader_element)
    unopt_bootloader_all_data.add(bootloader_element.split()[0])
    bootloader_element = unopt_bootloader_all.readline()

intersection_data = unopt_bootloader_all_data.intersection(shared_ro_data)
difference_data = unopt_bootloader_all_data.difference(shared_ro_data)

shared_ro.close()
unopt_bootloader_all.close()

intersection = open(f'intersection_rodata.txt','w')
difference = open(f'difference_rodata.txt','w')

intersection.write('\n'.join(intersection_data))
difference.write('\n'.join(difference_data))

intersection.close()
difference.close()