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
    contacted = 2
    connected = 3



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

        self.poll_time = 0.6 # low number for simulation

        self.state = FSM.boot
        self.message = None
        self.sequence = 42
        self.first_contact = None
        self.last_contact = None
        self.last_poll = datetime.now() - timedelta(seconds=self.poll_time)  # start off with our most recent poll in the past
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
        # self.waiting_ack_fsm = FSM.connecting
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

    def debounce_hello(self):
        if (datetime.now() - self.last_poll).total_seconds() > self.poll_time:
            self.last_poll = datetime.now()
            self.send_hello()

    def debounce_poll(self):
        if (datetime.now() - self.last_poll).total_seconds() > self.poll_time:
            self.last_poll = datetime.now()
            self.send_poll()

    # check if the packet is good do a few bookkeeping stuffs
    def _parse_check_packet(self, raw):
        if raw and 'data' in raw and 'hz' in raw:
            p = Packet()
            p.ParseFromString(self.unpack_data(raw['data']))
            if raw['hz'] == self.hz:
                self.log.info('rx: ' + p.__str__())
                self.last_contact = datetime.now()
                return p
            else:
                self.log.warning('packet on wrong hz %s' % p.type)
                return None
        else:
            self.log.warning('warning client got malformed packet')
            return None
        return None

    def tick(self):

        # print ('c tick')
        ack_good = 0

        nextstate = self.state

        if self.rx.waiting():
            # theres an incomming packet
            p = self._parse_check_packet(self.rx.get_pyobj())
            if p is not None:
                if p.type == Packet.BACK:
                    if p.radio == self.id and p.ack == self.waiting_ack:
                        ack_good = 1
                        # self.log.info('ack good')

                for case in switch(self.state):
                    if case(FSM.boot):
                        if ack_good:
                            nextstate = FSM.contacted
                    if case(FSM.contacted):
                        self.log.info('contacted')
        else:
            # there's no packet, we are just ticking
            if self.state == FSM.boot:
                self.debounce_hello()

            if self.state == FSM.contacted or self.state == FSM.connected:
                self.debounce_poll()


        self.state = nextstate # always set the state after each tick



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