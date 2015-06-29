import time
import subprocess
import zmq
import socket
import struct



# def service_tcp():


# def setup_tcp():


if __name__ == '__main__':
    # global zmq_context




    TCP_IP = '127.0.0.1'
    TCP_PORT = 4000
    BUFFER_SIZE = 8*2  # Normally 1024, but we want fast response

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((TCP_IP, TCP_PORT))
    s.listen(1)

    conn, addr = s.accept()
    print 'Connection address:', addr
    while 1:
        data = conn.recv(BUFFER_SIZE)
        if not data: break
        print "received data:", data

        if True:
            for b in data:
                print '%02x' % ord(b),

        break

        conn.send(data)  # echo
    conn.close()

    unpacked = struct.unpack('%df' % 4, data)

    print unpacked


