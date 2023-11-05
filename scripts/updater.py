import time
import serial
import json

config = json.load(open('config.json', 'r'))

port = config['mcu_port']

app_file = 'outputs/app.bin'
#Initialising handshake
ser = serial.Serial(port, 9600, timeout=1, stopbits=2)
while True:
    ser.write(b'\xff')
    ack = ser.read(1)
    print(ack)
    if ack == b'\xff':
        print('First ACK Received')
        break
ser.close()
#sending app
ser2 = serial.Serial(port, 9600, stopbits=2)
print('Sending File length')
with open(app_file, 'rb') as app:
    filebytes = app.read()
    filelength = len(filebytes)
    #send file length
    print(f'file length: {filelength}')
    b1 = filelength & 0xFF
    b2 = (filelength >> 8) & 0xFF 
    b3 = (filelength >> 16) & 0xFF 
    b4 = (filelength >> 24) & 0xFF 
    b1 = bytearray([b1])
    b2 = bytearray([b2])
    b3 = bytearray([b3])
    b4 = bytearray([b4])
     
    ser2.write(b1)
    ser2.write(b2)
    ser2.write(b3)
    ser2.write(b4)
    print('File length sent')   
    #ack 
    ack = ser2.read(1)
    if ack == b'\xff':
        print('File Length ACK Received')

def crc32_update(seed, val, poly): #updates with every byte
    seed <<= 8
    seed += val
    poly <<= 8
    for _ in range(8):
        if (seed & (0x80000000 << 8) != 0):
            seed <<= 1
            seed ^= poly
        else:
            seed <<=1
    return ((seed >> 8) & (0xFFFFFFFF))

def parity_check(value):
    result = 0
    while (value):
        result ^= value & 1
        value >>= 1
    return result

#sending app contents
print('Sending App')
crc_seed = 0x0
crc_poly = 0x04c11db7
byte0 = 0xa5
byte5 = 0x5a
with open(app_file, 'rb') as app:
    i = 0
    word = 0
    byte = app.read(1)
    while (byte):
        byte = int.from_bytes(byte, byteorder = 'little')
        if i%4==0:
            ser2.write(bytearray([byte0]))
            word = 0
        crc_seed = crc32_update(crc_seed, byte, crc_poly)
        word <<= 8
        word += byte
        byte = bytearray([byte])
        ser2.write(byte)
        i+=1
        #receiving ack every 4 bytes
        if i%4 == 0:
            parity = parity_check(word)
            ser2.write(bytearray([parity]))
            ser2.write(bytearray([byte5]))
            ack = ser2.read(1)
            if ack == b'\xff':
                print(f'{i} Bytes Sent')
            elif ack == b'\x55':
                print('NACK')
                app.seek(-4, 1)
                i -= 4
        byte = app.read(1)
        time.sleep(0.0001)
        

#padding as bootloader expects 4 byte bursts
num_padding = (4 - filelength%4) % 4
for i in range(num_padding):
    ser2.write(b'\xff')
    word <<= 8
    word += 0xFF
    crc_seed = crc32_update(crc_seed, 0xff, crc_poly)

if not(num_padding==0):
    parity = parity_check(word)
    ser2.write(bytearray([parity]))
    ser2.write(bytearray([byte5]))
    ack = ser2.read(1)
    if ack == b'\xff': 
        print(f'{num_padding} byte padding sent')
    elif ack == b'\x55':
        print('NACK')
print('App Sent Completed')
#send 4 extra bytes to crc
crc_seed = crc32_update(crc_seed, 0x0, crc_poly)
crc_seed = crc32_update(crc_seed, 0x0, crc_poly)
crc_seed = crc32_update(crc_seed, 0x0, crc_poly)
crc_seed = crc32_update(crc_seed, 0x0, crc_poly)
#send crc
crc_bytes = crc_seed.to_bytes(4, 'little')
for b in crc_bytes:
    ser2.write(bytearray([b]))
ack = ser2.read(1)
if ack == b'\xff': 
    print(f'crc_checksum sent: {hex(crc_seed)}')
ser2.close()