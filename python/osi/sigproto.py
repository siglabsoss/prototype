from siglabs_pb2 import *
# from sigmath import *

bringup = 909E6
pattern_vec = [1,1,0,2,1,0,2,2,1,0,0,1,1,1,0,2,2,0,2,2]



def encode_varint(val):
    v = VarIntPacker()
    v.val = val
    str = v.SerializeToString()
    str = str[1:] # chop field type

    return str

def decode_varint(str):
    # field type is 0x08 for VarIntPacker.  This is covered by the test incase it changes
    str = chr(0x08) + str

    v = VarIntPacker()
    v.ParseFromString(str)

    return v.val