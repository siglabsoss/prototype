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
from sigproto import *
from channel import Channel
import json
from cpm import *
from sigmath import *





class Radio(object):
    def __init__(self, port, octave=None):
        self.port = port

        self.tx = SigSink(self.port)
        self.rx = SigSource()

        if( octave ):
            self.octave = octave
        else:
            self.octave = oct2py.Oct2Py()
            self.octave.addpath('../../simulink')

    def pack_send(self, str, ch=None):
        obj = {}
        if ch == None:
            obj['hz'] = self.hz
        else:
            obj['hz'] = ch.hz


        # build a varint with the size of the following message
        sizestr = encode_varint(len(str))

        # slap it on the beginning
        str = sizestr + str

        bits = str_to_bits(str)  # convert to list of 0,1
        bits = [(b*2)-1 for b in bits] # convert to -1,1

        # modulate into cpm
        obj['data'] = cpm_mod(bits)

        # send over the "air"
        self.tx.send_pyobj(obj)

    def unpack_data(self, data):
        bits = cpm_demod(data)
        bits = [int((b+1)/2) for b in bits]  # convert to ints with range of 0,1
        str = bits_to_str(bits)     # convert to string

        # calc out the length of the message to follow
        length = decode_varint(str)

        # calc the number of bytes that it took to represent 'length' as a varing
        varint_length = size_varint(str)

        # print_hex(str[varint_length:length+varint_length])
        return str[varint_length:length+varint_length]



if __name__ == '__main__':
    r = Radio(4000)