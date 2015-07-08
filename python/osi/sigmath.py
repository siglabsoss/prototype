import struct
import numpy

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
