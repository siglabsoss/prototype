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
from copy import *


# our best idea of where the radio is
class RadioClient(Channel):
    def __init__(self, radio):
        super(RadioClient, self).__init__(radio)           # this is the constructor for Channel
        self.first_contact = None
        self.last_contact = None
        self.sequence = 0     # the sequence # that the client is using.  this is auto overwritten with every packet
        self.state = FSM.boot
        self.bs_sequence = 7  # the sequence # that the basestation is using to talk to the radio
        self.modulation = deepcopy(sigproto.defaultCpmSettings)
    def bseq(self):
        ret = self.bs_sequence
        self.bs_sequence += 1
        return ret




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
            self.log.info('rx: ' + '(' + str(raw['hz']/1E6) + 'M):\n' + p.__str__() + '--\n')
            return p
        else:
            self.log.warning('warning bs got malformed packet')
            return None
        return None

    def _find_or_create_radio(self, p, raw):
        if p.radio in self.radios:
            # self.log.info('there')
            r = self.radios[p.radio]
        else:
            # self.log.info('not there')
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
        ack.sequence = r.bseq()   # we are using our own sequence number here
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
                        self.pack_send(ack.SerializeToString(), r)
                        r.state = FSM.contacted
                    break
                if case(FSM.contacted):
                    if r.hz == sigproto.bringup:
                        # here is where we pick a smart channel
                        out = Packet()
                        out.type = Packet.CHANGE
                        out.radio = r.id
                        out.sequence = r.bseq()      # the packet is originating from the bs, so we use our sequence number specifically for that radio
                        out.change_param = Packet.CHANNEL
                        out.change_val = int(sigproto.channel1)
                        self.pack_send(out.SerializeToString(), r)
                        r.state = FSM.connected
                        r.changehz(sigproto.channel1) # update our records so we expect radio on new channel
                    break
                if case(FSM.connected):
                    if r.hz != raw['hz']:
                        self.log.warn('Radio %d on wrong channel %g, expected %g', r.id, raw['hz']/1E6, r.hz/1E6)

                    if r.modulation['samplesPerSymbol'] == 100: # bang bang way of ramping up modulation
                        self.log.info('telling radio to switch to fast rate')
                        # request fukin fast bits per symbol
                        bitsPerSample = 4

                        out = Packet()
                        out.type = Packet.CHANGE
                        out.radio = r.id
                        out.sequence = r.bseq()
                        out.change_param = Packet.BPS
                        out.change_val = bitsPerSample  # pretty fuckin fast
                        self.pack_send(out.SerializeToString(), r)
                        r.modulation['samplesPerSymbol'] = bitsPerSample # update our record so we will demodulate correctly


            # if r.state == FSM.connected:
            #     if p.type == Packet.POLL:
            #         self.log.info('got poll from client on new %d' % raw['hz'])
            #


        # if( self.state == BFSM.boot ):
        #     self.state = BFSM.connecting

    def get_state(self):
        return self.state




# if __name__ == '__main__':
#     c = Client()
#     print c.get_state()
#     c.tick()
#     print c.get_state()