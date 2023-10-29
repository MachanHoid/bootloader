import time
import serial
import json

config = json.load(open('config.json', 'r'))

port = config['mcu_port']

app_file = 'outputs/app.bin'
#Initialising handshake
ser = serial.Serial(port, 9600, timeout=1)
while True:
    ser.write(b'\xff')
    ack = ser.read(1)
    print(ack)
    if ack == b'\xff':
        print('First ACK Received')
        break
ser.close()
#sending app
ser2 = serial.Serial(port, 9600)
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

#sending app contents
print('Sending App')
parity = 0

def parity_check(value):
    result = 0
    while (value):
        result ^= value & 1
        value >>= 1
    return result

with open(app_file, 'rb') as app:
    data = app.read()
    i = 0
    for byte in data:
        parity ^= parity_check(byte)
        byte = bytearray([byte])
        ser2.write(byte)
        i+=1
        #receiving ack every 4 bytes
        if i%4 == 0:
            ack = ser2.read(1)
            if ack == b'\xff':
                print(f'{i} Bytes Sent')
        time.sleep(0.0001)

#padding as bootloader expects 4 byte bursts
num_padding = (4 - filelength%4) % 4
for i in range(num_padding):
    ser2.write(b'\xff')
if not(num_padding==0):
    ack = ser2.read(1)
    if ack == b'\xff': 
        print(f'{num_padding} byte padding sent')
print('App Sent Completed')
# parity ^= 1
ser2.write(bytearray([parity & 0xFF]))
ack = ser2.read(1)
if ack == b'\xff': 
    print(f'parity sent: {parity}')
ser2.close()