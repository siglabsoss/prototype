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
from client import FSM
from datetime import datetime
from siglabs_pb2 import *
import logging


# our best idea of where the radio is
class RadioClient(Channel):
    def __init__(self, radio):
        super(RadioClient, self).__init__(radio)           # this is the constructor for Channel
        self.first_contact = None
        self.last_contact = None
        self.sequence = 0     # the sequence # that the client is using.  this is auto overwritten with every packet
        self.state = FSM.boot
        self.bs_sequence = 7  # the sequence # that the basestation is using to talk to the radio




class Basestation(Radio):
    def __init__(self, port, octave=None):
        self.port = port

        # this is annoying
        # super(Basestation, self).__init__('basestation1')           # this is the constructor for Channel
        super(Basestation, self).__init__(port, octave) # this is the constructor for Radio

        self.log = logging.getLogger('basestation')
        self.log.setLevel(logging.INFO)
        # create console handler and set level to debug
        lch = logging.StreamHandler()
        lch.setLevel(logging.INFO)
        lfmt = logging.Formatter('BStatn: %(message)s')
        # add formatter to channel
        lch.setFormatter(lfmt)
        # add ch to logger
        self.log.addHandler(lch)


        # self.state = BFSM.boot
        self.message = None

        self.radios = {}


    def _parse_check_packet(self, raw):
        if raw and 'data' in raw and 'hz' in raw:
            p = Packet()
            p.ParseFromString(self.unpack_data(raw['data']))
            self.log.info('rx: ' + p.__str__())
            return p
        else:
            self.log.warning('warning bs got malformed packet')
            return None
        return None

    def _find_or_create_radio(self, p, raw):
        if p.radio in self.radios:
            self.log.info('there')
            r = self.radios[p.radio]
        else:
            self.log.info('not there')
            self.radios[p.radio] = RadioClient(p.radio)
            r = self.radios[p.radio]  # this is a reference to the array elements
            r.changehz(raw['hz'])
            r.state = FSM.boot

        # now that r is set, update the sequence
        r.sequence = p.sequence
        return r

    def build_ack(self, r):
        ack = Packet()
        ack.type = Packet.BACK
        ack.radio = r.id
        ack.ack = r.sequence # we are acknowledging the sequence id of the packet we just received in this 'ack' field
        ack.sequence = r.bs_sequence   # we are using our own sequence number here
        return ack


    def tick(self):

        # print ('bs tick')

        if self.rx.waiting():
            raw = self.rx.get_pyobj()
            p = self._parse_check_packet(raw)
            if p is None:
                return

            # this will set the sequence # of the client
            r = self._find_or_create_radio(p, raw)

            for case in switch(r.state):
                if case(FSM.boot):
                    if p.type == Packet.HELLO:
                        ack = self.build_ack(r)
                        # self.log.info(ack.__str__())
                        self.pack_send(ack.SerializeToString(), r)
                        r.bs_sequence += 1
                        r.state = FSM.contacted


            # if r.state == FSM.connected:
            #     if p.type == Packet.POLL:
            #         self.log.info('got poll from client on new %d' % raw['hz'])
            #
            # if r.state == FSM.contacted:
            #     if r.hz == sigproto.bringup:
            #         # here is where we pick a smart channel
            #         out = Packet()
            #         out.type = Packet.CHANGE
            #         out.radio = r.id
            #         out.sequence = r.sequence
            #         out.change_param = Packet.CHANNEL
            #         out.change_val = int(sigproto.channel1)
            #         self.pack_send(out.SerializeToString(), r)
            #         r.state = FSM.connected
            #
            #
            # # make ack
            # ack = Packet()
            # ack.type = Packet.BACK
            # ack.radio = r.id
            # ack.sequence = r.sequence
            # self.pack_send(ack.SerializeToString(), r)

            # print ack.__str__()

        # if( self.state == BFSM.boot ):
        #     self.state = BFSM.connecting

    def get_state(self):
        return self.state




# if __name__ == '__main__':
#     c = Client()
#     print c.get_state()
#     c.tick()
#     print c.get_state()