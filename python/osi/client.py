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
from radio import Radio
import json
from sigmath import *
from siglabs_pb2 import *
from datetime import *
import logging

class FSM(Enum):
    boot = 1
    connecting = 2
    contacted = 3
    connected = 4



class Client(Channel, Radio):
    def __init__(self, port, octave=None):
        self.port = port

        # this is annoying
        super(Client, self).__init__(1)           # this is the constructor for Channel
        super(Channel, self).__init__(port, octave) # this is the constructor for Radio

        self.log = logging.getLogger('client')
        self.log.setLevel(logging.INFO)
        # create console handler and set level to debug
        lch = logging.StreamHandler()
        lch.setLevel(logging.INFO)
        lfmt = logging.Formatter('Client: %(message)s')
        # add formatter to channel
        lch.setFormatter(lfmt)
        # add ch to logger
        self.log.addHandler(lch)

        self.state = FSM.boot
        self.message = None
        self.sequence = 0
        self.first_contact = None
        self.last_contact = None
        self.waiting_ack = -1
        self.waiting_ack_fsm = -1

        self.changehz(sigproto.bringup)

    def seq(self):
        ret = self.sequence
        self.sequence += 1
        return ret

    def send_hello(self):
        p = Packet()
        p.sequence = self.seq()
        self.waiting_ack = p.sequence
        self.waiting_ack_fsm = FSM.connecting
        p.radio = self.id
        p.type = Packet.HELLO
        # message = {}
        # message['m'] = 'hi'
        # message['p'] = self.id
        self.pack_send(p.SerializeToString())

    def send_poll(self):
        p = Packet()
        p.sequence = self.seq()
        p.radio = self.id
        p.type = Packet.POLL

        self.waiting_ack = p.sequence

        self.pack_send(p.SerializeToString())


    def tick(self):

        # print ('c tick')
        ack_good = 0

        if self.rx.waiting():
            raw = self.rx.get_pyobj()
            if raw and 'data' in raw:
                str = self.unpack_data(raw['data'])
                p = Packet()
                p.ParseFromString(str)
                self.log.info('rx: ' + p.__str__())
                self.last_contact = datetime.now()

                if p.sequence == self.waiting_ack and p.radio == self.id:
                    self.log.info('got correct ack %d' % self.waiting_ack)
                    self.waiting_ack = -1
                    ack_good = 1

                if self.state == FSM.connecting:
                    if self.waiting_ack_fsm == FSM.connecting and ack_good:
                        self.state = FSM.contacted
                        self.log.info('first contact with bs')
                        self.first_contact = datetime.now()
                        self.send_poll() # poll right now

                if self.state == FSM.contacted:
                    if p.type == Packet.CHANGE and self.hz == sigproto.bringup:
                        self.state == FSM.connected

                if p.type == Packet.CHANGE:
                    if p.change_param == Packet.CHANNEL:
                        self.log.info('switching to channel %d as instructed' % p.change_val)
                        self.changehz(p.change_val)

            else:
                self.log.warning('warning client got malformed packet')


        if self.state == FSM.boot:
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