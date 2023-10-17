import sys
import json
import os

filename = sys.argv[1]
json_path = sys.argv[2]

new_syms = {filename: {}}

l = os.popen(f"arm-none-eabi-nm {filename} | /usr/bin/awk " + r"'/ T / {print $3}'  ").read().split()
new_syms[filename]['T'] = l 

l = os.popen(f"arm-none-eabi-nm {filename} | /usr/bin/awk " + r"'/ t / {print $3}'  ").read().split()
new_syms[filename]['t'] = l 

l = os.popen(f"arm-none-eabi-nm {filename} | /usr/bin/awk " + r"'/ U / {print $3}'  ").read().split()
new_syms[filename]['U'] = l 

l = os.popen(f"arm-none-eabi-nm {filename} | /usr/bin/awk " + r"'/ r / {print $3}'  ").read().split()
new_syms[filename]['r'] = l 

l = os.popen(f"arm-none-eabi-nm {filename} | /usr/bin/awk " + r"'/ R / {print $3}'  ").read().split()
new_syms[filename]['R'] = l 

l = os.popen(f"arm-none-eabi-nm {filename} | /usr/bin/awk " + r"'/ l / {print $3}'  ").read().split()
new_syms[filename]['l'] = l 

l = os.popen(f"arm-none-eabi-nm {filename} | /usr/bin/awk " + r"'/ L / {print $3}'  ").read().split()
new_syms[filename]['L'] = l 

l = os.popen(f"arm-none-eabi-nm {filename} | /usr/bin/awk " + r"'/ f / {print $3}'  ").read().split()
new_syms[filename]['f'] = l 

l = os.popen(f"arm-none-eabi-nm {filename} | /usr/bin/awk " + r"'/ D / {print $3}'  ").read().split()
new_syms[filename]['D'] = l 

l = os.popen(f"arm-none-eabi-nm {filename} | /usr/bin/awk " + r"'/ d / {print $3}'  ").read().split()
new_syms[filename]['d'] = l 

l = os.popen(f"arm-none-eabi-nm {filename} | /usr/bin/awk " + r"'/ b / {print $3}'  ").read().split()
new_syms[filename]['b'] = l 

l = os.popen(f"arm-none-eabi-nm {filename} | /usr/bin/awk " + r"'/ B / {print $3}'  ").read().split()
new_syms[filename]['B'] = l 

l = os.popen(f"arm-none-eabi-nm {filename} | /usr/bin/awk " + r"'/ a / {print $3}'  ").read().split()
new_syms[filename]['a'] = l 

l = os.popen(f"arm-none-eabi-nm {filename} | /usr/bin/awk " + r"'/ A / {print $3}'  ").read().split()
new_syms[filename]['A'] = l 

json_file = open(json_path, 'r')
try:
    syms = json.load(json_file)
    syms.update(new_syms)
except:
    syms = new_syms
json_file.close()

json_file = open(json_path, 'w')
json.dump(syms, json_file, indent=4)