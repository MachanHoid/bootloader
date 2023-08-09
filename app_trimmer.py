#strips the first 'n' unwanted bytes

# unwanted_byte_count = 128*1024

wanted_byte_count = 128*1024

# with open('app.bin', 'rb') as f:
#     kuppai = f.read(unwanted_byte_count)
#     print(len(kuppai))
#     data = f.read()
#     print(len(data))
#     with open('app_trimmed.bin', 'wb') as f2:
#         f2.write(data)

with open('app.bin', 'rb') as f:
    data = f.read(wanted_byte_count)
    with open('app_trimmed.bin', 'wb') as f2:
        f2.write(data)