import time
import zmq
import struct
import collections # http://stackoverflow.com/questions/4151320/efficient-circular-buffer
import pickle
from sigmath import *
from numpy import *



# http://code.activestate.com/recipes/410692/
# This class provides the functionality we want. You only need to look at
# this if you want to know how this works. It only needs to be defined
# once, no need to muck around with its internals.
class switch(object):
    def __init__(self, value):
        self.value = value
        self.fall = False

    def __iter__(self):
        """Return the match method once, then stop"""
        yield self.match
        raise StopIteration

    def match(self, *args):
        """Indicate whether or not to enter a case suite"""
        if self.fall or not args:
            return True
        elif self.value in args: # changed for v1.5, see below
            self.fall = True
            return True
        else:
            return False


def setup_zmq():
    global zmq_context, zmq_poller, octave_socket

    # setup zmq
    zmq_context = zmq.Context()


    octave_socket = zmq_context.socket(zmq.SUB)
    octave_socket.setsockopt(zmq.SUBSCRIBE, '') # empty string here subscribes to all channels
    # octave_socket.connect('tcp://127.0.0.1:4000')
    octave_socket.bind('tcp://*:4000')

    zmq_poller = zmq.Poller()
    zmq_poller.register(octave_socket, zmq.POLLIN)



def switch_zmq_message(m):
    # print m

    # print ord(m[0])

    print 'switch message with len', len(m)
    print ''
    # print pickle.dumps(m)
    print ''
    print ''

    cplx = raw_to_complex(m)

    print 'first complex number', cplx

    command = real(cplx)
    data = imag(cplx)

    # command 10000
    if( command == 10000 ):
        print "radio id", data, "booted"

    if( command == 10001 ):
        print "got packet"



def poll_zmq():
    global zmq_context, zmq_poller, octave_socket, rx_fifo


    socks = dict(zmq_poller.poll(0))
    # print socks
    if octave_socket in socks and socks[octave_socket] == zmq.POLLIN:
        obj = octave_socket.recv()
        # print obj
        # for b in obj:
        #     rx_fifo.append(ord(b))
        #     print ord(b)
        # print ''
        # print ''
        switch_zmq_message(obj)
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
    # setup_fifo()

    while 1:
        # octave_socket.send('hello')
        poll_zmq()
        time.sleep(0.1)
        # print 'rx_fifo', rx_fifo
        # parse_rx_fifo()

    # zmq_context = zmq.Context()