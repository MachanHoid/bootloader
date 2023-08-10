import time
import serial
# from time import delay
ser = serial.Serial('/dev/tty.usbmodem0E239D471', 9600, timeout=1)
while True:
    ser.write(b'\xff')
    ack = ser.read(1)
    print(ack)
    if ack == b'\xff':
        print('First ACK Received')
        break
ser.close()

ser2 = serial.Serial('/dev/tty.usbmodem0E239D471', 9600)
print('Sending File length')
with open('app.bin', 'rb') as app:
    filebytes = app.read()
    filelength = len(filebytes)
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
    ack = ser2.read(1)
    if ack == b'\xff':
        print('File Length ACK Received')


print('Sending App')
with open('app.bin', 'rb') as app:
    data = app.read()
    i = 0
    for byte in data:
        byte = bytearray([byte])
        ser2.write(byte)
        i+=1
        if i%4 == 0:
            ack = ser2.read(1)
            if ack == b'\xff':
                print(f'{i} Bytes Sent')
        time.sleep(0.0001)

print('App Sent Completed')
ser2.close()

# ser2 = serial.Serial('/dev/tty.usbmodem0E239D471', 9600)
# print('hello')
# with open('app.bin', 'rb') as app:
#     data = [b'\x34', b'\xff', b'\x00', b'\x78']
#     i = 0
#     for byte in data:
#         print(i)
#         ser2.write(byte)
#         i+=1
#         # delay(10)
#     # ser2.write(b'\x00')
# print('hello again')
# ser2.close()