import serial
ser = serial.Serial('portname', 9600, timeout=1)
while True:
    ser.write(b'\xff')
    ack = ser.read(1)
    if ack == b'\xff':
        break
ser.close()

ser2 = serial.Serial('portname', 9600)

with open('app.bin', 'rb') as app:
    bit = app.read(1)
    while bit!='':
        ser2.write(bit)
        bit = app.read(1)
    ser2.write(b'\x00')