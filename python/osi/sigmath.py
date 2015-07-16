import struct
import numpy
import sigproto

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

def cpm_mod(bits, octave):
    signal = octave.o_cpm_mod(bits, 1/125E1, 1/125E3, 100, 1, sigproto.pattern_vec, 1)
    return signal

def cpm_demod(data, octave):
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