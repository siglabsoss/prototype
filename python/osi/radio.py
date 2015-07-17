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
from cpm import *





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

    def pack_send(self, message):
        obj = {}
        obj['hz'] = self.hz

        str = json.dumps(message, separators=(',',':'))  # pack json
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
        obj = json.loads(str)       # load from json (but all keys and values are in unicode)
        obj = all_to_ascii(obj)     # strip unicode
        return obj



if __name__ == '__main__':
    r = Radio(4000)