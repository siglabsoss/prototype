import time
import subprocess
import zmq
import socket
import struct
import collections # http://stackoverflow.com/questions/4151320/efficient-circular-buffer


def setup_zmq():
    global zmq_context, zmq_poller, octave_socket

    # setup zmq
    zmq_context = zmq.Context()


    octave_socket = zmq_context.socket(zmq.SUB)
    octave_socket.setsockopt(zmq.SUBSCRIBE, '') # empty string here subscribes to all channels
    octave_socket.connect('tcp://127.0.0.1:4000')
    # octave_socket.bind('tcp://*:4000')

    zmq_poller = zmq.Poller()
    zmq_poller.register(octave_socket, zmq.POLLIN)



def poll_zmq():
    global zmq_context, zmq_poller, octave_socket, rx_fifo


    socks = dict(zmq_poller.poll(0))
    print socks
    if octave_socket in socks and socks[octave_socket] == zmq.POLLIN:
        obj = octave_socket.recv()
        print obj
        for b in obj:
            rx_fifo.append(ord(b))
        # obj = zmq_subscriber.recv_pyobj()
        # print 'zmq got', obj
        # obj['zmq'] = True # just in-case we need to distinguish this later
        # q.append(obj)

def parse_rx_fifo():
    global rx_fifo

    bytes = range(0,8)

    if(len(rx_fifo) > 8):
        for i in range(0,8):
            # print i
            bytes[i] = rx_fifo.popleft()

        print bytes

        str = ''
        for n in bytes[0:4]:
            str = str + chr(n)
        f1 = struct.unpack('%df' % 1, str)

        str = ''
        for n in bytes[4:8]:
            str = str + chr(n)
        f2 = struct.unpack('%df' % 1, str)

        print f1
        print f2



# pop x.popleft()
# push x.append(3);
# Peek x[0]
# get length len(x)

def setup_fifo():
    global rx_fifo

    rx_fifo = collections.deque()

    # rx_fifo.append(3)
    # rx_fifo.append(4)

    print rx_fifo

if __name__ == '__main__':
    global zmq_context, zmq_poller, octave_socket, rx_fifo

    setup_zmq()
    setup_fifo()

    while 1:
        # octave_socket.send('hello')
        poll_zmq()
        time.sleep(1)
        # print 'rx_fifo', rx_fifo
        # parse_rx_fifo()

    # zmq_context = zmq.Context()