import time
import zmq
import struct
import collections # http://stackoverflow.com/questions/4151320/efficient-circular-buffer
import pickle
from sigmath import *
from numpy import *
from oct2py import octave
from switch import *
from sigsource import *
from sigsink import *
from enum import Enum
import sigproto


class BFSM(Enum):
    boot = 1
    connecting = 2
    connected = 3




class Basestation(object):
    def __init__(self, port):
        self.port = port

        self.tx = SigSink(self.port)
        self.rx = SigSource()
        self.state = BFSM.boot

    state = BFSM.boot

    def tick(self):

        print ('tick')

        if( self.rx.waiting() ):
            raw = self.rx.get_pyobj()
            print raw

        if( self.state == BFSM.boot ):
            self.state = BFSM.connecting

    def get_state(self):
        return self.state




# if __name__ == '__main__':
#     c = Client()
#     print c.get_state()
#     c.tick()
#     print c.get_state()