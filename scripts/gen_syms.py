import sys
import json
import os

#filename and json path passed as arguments
filename = sys.argv[1]
json_path = sys.argv[2]

new_syms = {filename: {}}
types = ['T', 't', 'U', 'r', 'R', 'l', 'L', 'f', 'd', 'D', 'b', 'B', 'a', 'A']
#write each type's syms to json
for type in types:
    l = os.popen(f"arm-none-eabi-nm {filename} | /usr/bin/awk '/ {type} /" + r" {print $3}'  ").read().split()
    new_syms[filename][type] = l 

#read from json
json_file = open(json_path, 'r')
#update
try:
    syms = json.load(json_file)
    syms.update(new_syms)
except:
    syms = new_syms
json_file.close()

#dump back to json
json_file = open(json_path, 'w')
json.dump(syms, json_file, indent=4)