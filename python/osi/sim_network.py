import time
import zmq
import struct
import collections # http://stackoverflow.com/questions/4151320/efficient-circular-buffer
import pickle
from sigmath import *
from numpy import *
import oct2py
import logging
from client import Client
from basestation import Basestation






if __name__ == '__main__':
    # print "making octave"
    #
    # octave = oct2py.Oct2Py()
    # octave.addpath('../../simulink')

    # logging.basicConfig(level=logging.DEBUG)
    # use one or the other
    # self.octave = oct2py.Oct2Py(logger=logging.getLogger())



    print "making objects"


    c = Client(4000, 1)
    print "connecting network"
    b = Basestation(4001, 1)

    c.rx.connect(b.tx)
    b.rx.connect(c.tx)

    tick_max = 250*1000

    for i in range(1,tick_max):
        c.tick()
        b.tick()
        time.sleep(0.002)

    # print c.get_state()
    # c.tick()
    # print c.get_state()