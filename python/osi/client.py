import time
import zmq
import struct
import collections # http://stackoverflow.com/questions/4151320/efficient-circular-buffer
import pickle
from sigmath import *
import numpy as np
# from numpy import *
import oct2py
import logging
from switch import *
from sigsource import *
from sigsink import *
from enum import Enum
import sigproto


class FSM(Enum):
    boot = 1
    connecting = 2
    connected = 3




class Client(object):
    def __init__(self, port):
        self.port = port

        self.tx = SigSink(self.port)
        self.rx = SigSource()
        self.state = FSM.boot
        self.message = None


        logging.basicConfig(level=logging.DEBUG)
        # use one or the other
        # self.octave = oct2py.Oct2Py(logger=logging.getLogger())
        self.octave = oct2py.Oct2Py()
        self.octave.addpath('../../simulink')

    def send(self, bits):
        signal = self.octave.o_cpm_mod(bits, 1/125E1, 1/125E3, 100, 1, sigproto.pattern_vec, 1)
        return signal
        # data = o_cpm_mod(ideal_bits, 1/1000, 1/125E3, 100, 1, patternvec, 1);

    def demod(self, data):
        bits = self.octave.o_cpm_demod(data, 1/125E3, 100, sigproto.pattern_vec, 1)
        return bits


    def tick(self):

        print ('tick')

        if( self.rx.waiting() ):
            raw = self.rx.get_pyobj()


        if( self.state == FSM.boot ):
            self.state = FSM.connecting

    def get_state(self):
        return self.state




if __name__ == '__main__':
    c = Client(4000)
    bits = np.array([1, -1, -1, 1, 1, -1, -1, 1])
    data = c.send(bits[:,np.newaxis])
    demod_bits = c.demod(data)
    print demod_bits

    # print c.get_state()
    # c.tick()
    # print c.get_state()