from siglabs_pb2 import *
import sigmath as sm

bringup = 909E6
channel1 = 908.25E6
pattern_vec = [1,1,0,2,1,0,2,2,1,0,0,1,1,1,0,2,2,0,2,2]
defaultCpmSettings = {'fs': 125E3, 'samplesPerSymbol': 100, 'rotationsPerSymbol': 1, 'patternVector': [1,1,0,2,1,0,2,2,1,0,0,1,1,1,0,2,2,0,2,2]}

# frequency stuff
unlicensed_min = 902E6
unlicensed_max = 928E6
channel_size = 25E3
channel_spacing = 2


def encode_varint(val):
    v = VarIntPacker()
    v.val = val
    str = v.SerializeToString()
    str = str[1:] # chop field type

    return str

def size_varint(str):
    # loop looking for msbit set in each char
    for valid in range(0,len(str)):
        if not ord(str[valid]) & 0x80:
            break

    return valid+1

def decode_varint(str):

    valid = size_varint(str)

    # truncate string so ProtoBuf keeps it's cool
    str = str[0:valid]

    # field type is 0x08 for VarIntPacker.  This is covered by the test incase it changes
    str = chr(0x08) + str

    v = VarIntPacker()
    v.ParseFromString(str)

    return v.val