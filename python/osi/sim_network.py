import time
import zmq
import struct
import collections # http://stackoverflow.com/questions/4151320/efficient-circular-buffer
import pickle
from sigmath import *
from numpy import *
from oct2py import octave
from client import Client
from basestation import Basestation






if __name__ == '__main__':
    print "making objects"
    c = Client(4000)
    print "connecting network"
    b = Basestation(4001)

    c.rx.connect(b.tx)
    b.rx.connect(c.tx)

    print c.get_state()
    c.tick()
    print c.get_state()