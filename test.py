import json

f = open('build/helper_files_temp/shared_files/sharedlib_syms.json', 'r')
d = json.load(f)

req_sym = ['g_pui32GPIOBaseAddrs',
           'g_pui32Xtals',
           'g_ui32GPIOIntMapSnowflakeRows',
           'g_sXTALtoMEMTIM',
           'g_pppui32XTALtoVCO',
           'g_ppui32GPIOIntMapBlizzard',
           'g_ppui32GPIOIntMapSnowflake',
           'g_pui32VCOFrequencies',
           'g_ui32GPIOIntMapBlizzardRows']

for file in d.keys():
    for sym in d[file]['R']+d[file]['r']:
        if sym in req_sym:
            print(f'{sym} in {file}')