import struct
import numpy as np
import sigproto
import collections

# converts string types to complex
def raw_to_complex(str):
    f1 = struct.unpack('%df' % 1, str[0:4])
    f2 = struct.unpack('%df' % 1, str[4:8])

    f1 = f1[0]
    f2 = f2[0]
    return f1 + f2*1j

def complex_to_raw(n):

    s1 = struct.pack('%df' % 1, numpy.real(n))
    s2 = struct.pack('%df' % 1, numpy.imag(n))

    return s1 + s2

def print_hex(str):
    print 'hex:'
    for b in str:
        print ' ', format(ord(b), '02x')

def print_dec(str):
    print 'hex:'
    for b in str:
        print ' ', ord(b)

def o_cpm_mod(bits, octave):
    signal = octave.o_cpm_mod(bits, 1/125E1, 1/125E3, 100, 1, sigproto.pattern_vec, 1)
    return signal

def o_cpm_demod(data, octave):
    bits = octave.o_cpm_demod(data, 1/125E3, 100, sigproto.pattern_vec, 1)
    return bits


# http://stackoverflow.com/questions/10237926/convert-string-to-list-of-bits-and-viceversa
def str_to_bits(s):
    result = []
    for c in s:
        bits = bin(ord(c))[2:]
        bits = '00000000'[len(bits):] + bits
        result.extend([int(b) for b in bits])
    return result

def bits_to_str(bits):
    chars = []
    for b in range(len(bits) / 8):
        byte = bits[b*8:(b+1)*8]
        chars.append(chr(int(''.join([str(bit) for bit in byte]), 2)))
    return ''.join(chars)

def all_to_ascii(data):
    if isinstance(data, basestring):
        return str(data)
    elif isinstance(data, collections.Mapping):
        return dict(map(all_to_ascii, data.iteritems()))
    elif isinstance(data, collections.Iterable):
        return type(data)(map(all_to_ascii, data))
    else:
        return data

def drange(start, stop, step):
    r = start
    while r < stop:
        yield r
        r += step


def unroll_angle(input):
    thresh = np.pi

    adjust = 0

    sz = len(input)

    output = [None]*sz

    output[0] = input[0]

    for index in range(1,sz):
        samp = input[index]
        prev = input[index-1]

        if(abs(samp-prev) > thresh):
            direction = 1
            if( samp > prev ):
                direction = -1
            adjust = adjust + 2*np.pi*direction

        output[index] = input[index] + adjust

    return output

