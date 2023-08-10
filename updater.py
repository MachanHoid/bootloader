import serial
# from time import delay
ser = serial.Serial('/dev/tty.usbmodem0E239D471', 9600, timeout=1)
while True:
    ser.write(b'\xff')
    ack = ser.read(1)
    print(ack)
    if ack == b'\xff':
        print('love you')
        break
ser.close()

# ser2 = serial.Serial('/dev/tty.usbmodem0E239D471', 9600)
# print('hello')
# with open('appb.bin', 'rb') as app:
#     data = app.read()
#     i = 0
#     for byte in data:
#         print(i)
#         ser2.write(byte)
#         i+=1
#         # delay(10)
#     # ser2.write(b'\x00')
# print('hello again')
# ser2.close()

ser2 = serial.Serial('/dev/tty.usbmodem0E239D471', 9600)
print('hello')
with open('appb.bin', 'rb') as app:
    data = [b'\x34', b'\xff', b'\x00', b'\x78']
    i = 0
    for byte in data:
        print(i)
        ser2.write(byte)
        i+=1
        # delay(10)
    # ser2.write(b'\x00')
print('hello again')
ser2.close()