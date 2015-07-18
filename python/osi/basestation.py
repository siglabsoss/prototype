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
from channel import Channel
from radio import Radio
from datetime import datetime
from siglabs_pb2 import *


class BFSM(Enum):
    connecting = 1
    connected = 2


# our best idea of where the radio is
class RadioClient(Channel):
    def __init__(self, radio):
        super(RadioClient, self).__init__(radio)           # this is the constructor for Channel
        self.first_contact = None
        self.last_contact = None
        self.sequence = 0




class Basestation(Radio):
    def __init__(self, port, octave=None):
        self.port = port

        # this is annoying
        # super(Basestation, self).__init__('basestation1')           # this is the constructor for Channel
        super(Basestation, self).__init__(port, octave) # this is the constructor for Radio

        # self.state = BFSM.boot
        self.message = None

        self.radios = {}




    def tick(self):

        print ('tick')

        if( self.rx.waiting() ):
            raw = self.rx.get_pyobj()
            if( raw and 'data' in raw ):
                str = self.unpack_data(raw['data'])
                p = Packet()
                p.ParseFromString(str)
                print p.__str__()

            else:
                print 'warning bs got malformed packet'

            if p.radio in self.radios:
                print 'there'
            else:
                print 'not there'
                self.radios[p.radio] = RadioClient(p.radio)
                r = self.radios[p.radio]  # this is a reference to the array elements
                # print self.radios[str(p.radio)]
                r.sequence = p.sequence

            # make ack
            ack = Packet()
            ack.type = Packet.ACK
            ack.radio = r.id
            ack.sequence = r.sequence
            self.pack_send(ack.SerializeToString(), r)

            print ack.__str__()

        # if( self.state == BFSM.boot ):
        #     self.state = BFSM.connecting

    def get_state(self):
        return self.state




# if __name__ == '__main__':
#     c = Client()
#     print c.get_state()
#     c.tick()
#     print c.get_state()