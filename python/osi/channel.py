# from sigproto import *
import sigproto
from sigmath import *


# returns count of channels
def channel_count():
    mmin = sigproto.unlicensed_min
    mmax = sigproto.unlicensed_max
    ssize = sigproto.channel_size
    spacing = sigproto.channel_spacing
    delta = ssize + spacing

    calc_count = int((mmax-mmin) / delta)
    #
    #
    # count = 0
    # for f in drange(mmin, mmax, delta):
    #     end = f+ssize
    #     if end > mmax:
    #         break
    #     print "from",f,"to",end
    #     count += 1
    #
    # print "count",count
    # print "calc count", calc_count
    # assert count == calc_count
    return calc_count

# returns start, end, center of channel
def channel_index(index):

    if index >= channel_count():
        raise RuntimeError('Channel index out of bounds')

    mmin = sigproto.unlicensed_min
    mmax = sigproto.unlicensed_max
    ssize = sigproto.channel_size
    spacing = sigproto.channel_spacing
    delta = ssize + spacing

    start = delta*index + mmin
    end = delta*index + ssize + mmin
    center = (end+start)/2

    return [start,end,center]


def channel_center(index):
    return channel_index(index)[2]

def channel_by_hz(hz):
    mmin = sigproto.unlicensed_min
    mmax = sigproto.unlicensed_max
    ssize = sigproto.channel_size
    spacing = sigproto.channel_spacing
    delta = ssize + spacing

    start = hz - ssize/2

    index = (start - mmin) / delta

    return int(round(index))





class Channel(object):
    """Which channel we are communicating on

    """

    def __init__(self, id):
        self.id = id
        self.hz = 910E6

        # print 'setting id to', self.id

    def changehz(self, hz):
        if hz > sigproto.unlicensed_max:
            raise RuntimeError('Frequency too high.')
        if hz < sigproto.unlicensed_min:
            raise RuntimeError('Frequency too low.')
        self.hz = hz
