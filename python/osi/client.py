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
from channel import Channel
import json


class FSM(Enum):
    boot = 1
    connecting = 2
    connected = 3




class Client(Channel):
    def __init__(self, port, octave=None):
        self.port = port

        super(Client, self).__init__('1')

        self.tx = SigSink(self.port)
        self.rx = SigSource()
        self.state = FSM.boot
        self.message = None

        if( octave ):
            self.octave = octave
        else:
            self.octave = oct2py.Oct2Py()
            self.octave.addpath('../../simulink')

    def send(self, bits):
        signal = cpm_mod(bits, self.octave)
        return signal

    def demod(self, data):
        bits = cpm_demod(data, self.octave)
        return bits

    def pack_send(self, message):
        obj = {}
        obj['hz'] = self.hz

        str = json.dumps(message, separators=(',',':'))  # pack json
        bits = str_to_bits(str)  # convert to list of 0,1
        bits = np.array(bits)    # convert to numpy vec of 0,1
        bits = bits[:,np.newaxis] # convert to columnar vec
        bits = (bits * 2) - 1     # convert to -1,1

        # modulate into cpm
        obj['data'] = cpm_mod(bits, self.octave)

        # send over the "air"
        self.tx.send_pyobj(obj)


    def send_hello(self):
        message = {}
        message['m'] = 'hi'
        message['p'] = self.id
        self.pack_send(message)


    def tick(self):

        print ('tick')

        if( self.rx.waiting() ):
            raw = self.rx.get_pyobj()


        if( self.state == FSM.boot ):
            self.send_hello()
            self.state = FSM.connecting

    def get_state(self):
        return self.state




if __name__ == '__main__':
    c = Client(4000)



    # str = json.dumps(message, separators=(',',':'))
    # print str
    # bits = str_to_bits(str)
    # bits = np.array(bits)
    #
    # print bits

    # c.pack_send(message)

    if False: # test mod/demod
        bits = np.array([1, -1, -1, 1, 1, -1, -1, 1])
        bits = bits[:,np.newaxis]
        print 'mod'
        data = c.send(bits)
        print 'demod'
        demod_bits = c.demod(data)
        print 'result'
        print bits[0:8] == demod_bits[0:8]