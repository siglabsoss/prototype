# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: siglabs.proto

from google.protobuf import descriptor as _descriptor
from google.protobuf import message as _message
from google.protobuf import reflection as _reflection
from google.protobuf import descriptor_pb2
# @@protoc_insertion_point(imports)




DESCRIPTOR = _descriptor.FileDescriptor(
  name='siglabs.proto',
  package='',
  serialized_pb='\n\rsiglabs.proto\"\xf0\x01\n\x06Packet\x12\x10\n\x08sequence\x18\x01 \x02(\x05\x12\x1a\n\x04type\x18\x02 \x02(\x0e\x32\x0c.Packet.Type\x12\r\n\x05radio\x18\x03 \x01(\x03\x12\x0b\n\x03\x61\x63k\x18\x04 \x01(\x05\x12$\n\x0c\x63hange_param\x18\x05 \x01(\x0e\x32\x0e.Packet.Change\x12\x12\n\nchange_val\x18\x06 \x01(\x05\"0\n\x04Type\x12\x07\n\x03\x41\x43K\x10\x00\x12\t\n\x05HELLO\x10\x01\x12\n\n\x06\x43HANGE\x10\x02\x12\x08\n\x04POLL\x10\x03\"0\n\x06\x43hange\x12\x0b\n\x07\x43HANNEL\x10\x00\x12\x0c\n\x08\x43LK_DUTY\x10\x01\x12\x0b\n\x07\x42ITRATE\x10\x02\"*\n\x07PacketB\x12\r\n\x05radio\x18\x01 \x02(\x03\x12\x10\n\x08sequence\x18\x02 \x02(\x05\"\x1b\n\x0cVarIntPacker\x12\x0b\n\x03val\x18\x01 \x01(\x03')



_PACKET_TYPE = _descriptor.EnumDescriptor(
  name='Type',
  full_name='Packet.Type',
  filename=None,
  file=DESCRIPTOR,
  values=[
    _descriptor.EnumValueDescriptor(
      name='ACK', index=0, number=0,
      options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='HELLO', index=1, number=1,
      options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='CHANGE', index=2, number=2,
      options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='POLL', index=3, number=3,
      options=None,
      type=None),
  ],
  containing_type=None,
  options=None,
  serialized_start=160,
  serialized_end=208,
)

_PACKET_CHANGE = _descriptor.EnumDescriptor(
  name='Change',
  full_name='Packet.Change',
  filename=None,
  file=DESCRIPTOR,
  values=[
    _descriptor.EnumValueDescriptor(
      name='CHANNEL', index=0, number=0,
      options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='CLK_DUTY', index=1, number=1,
      options=None,
      type=None),
    _descriptor.EnumValueDescriptor(
      name='BITRATE', index=2, number=2,
      options=None,
      type=None),
  ],
  containing_type=None,
  options=None,
  serialized_start=210,
  serialized_end=258,
)


_PACKET = _descriptor.Descriptor(
  name='Packet',
  full_name='Packet',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='sequence', full_name='Packet.sequence', index=0,
      number=1, type=5, cpp_type=1, label=2,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None),
    _descriptor.FieldDescriptor(
      name='type', full_name='Packet.type', index=1,
      number=2, type=14, cpp_type=8, label=2,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None),
    _descriptor.FieldDescriptor(
      name='radio', full_name='Packet.radio', index=2,
      number=3, type=3, cpp_type=2, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None),
    _descriptor.FieldDescriptor(
      name='ack', full_name='Packet.ack', index=3,
      number=4, type=5, cpp_type=1, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None),
    _descriptor.FieldDescriptor(
      name='change_param', full_name='Packet.change_param', index=4,
      number=5, type=14, cpp_type=8, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None),
    _descriptor.FieldDescriptor(
      name='change_val', full_name='Packet.change_val', index=5,
      number=6, type=5, cpp_type=1, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
    _PACKET_TYPE,
    _PACKET_CHANGE,
  ],
  options=None,
  is_extendable=False,
  extension_ranges=[],
  serialized_start=18,
  serialized_end=258,
)


_PACKETB = _descriptor.Descriptor(
  name='PacketB',
  full_name='PacketB',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='radio', full_name='PacketB.radio', index=0,
      number=1, type=3, cpp_type=2, label=2,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None),
    _descriptor.FieldDescriptor(
      name='sequence', full_name='PacketB.sequence', index=1,
      number=2, type=5, cpp_type=1, label=2,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  options=None,
  is_extendable=False,
  extension_ranges=[],
  serialized_start=260,
  serialized_end=302,
)


_VARINTPACKER = _descriptor.Descriptor(
  name='VarIntPacker',
  full_name='VarIntPacker',
  filename=None,
  file=DESCRIPTOR,
  containing_type=None,
  fields=[
    _descriptor.FieldDescriptor(
      name='val', full_name='VarIntPacker.val', index=0,
      number=1, type=3, cpp_type=2, label=1,
      has_default_value=False, default_value=0,
      message_type=None, enum_type=None, containing_type=None,
      is_extension=False, extension_scope=None,
      options=None),
  ],
  extensions=[
  ],
  nested_types=[],
  enum_types=[
  ],
  options=None,
  is_extendable=False,
  extension_ranges=[],
  serialized_start=304,
  serialized_end=331,
)

_PACKET.fields_by_name['type'].enum_type = _PACKET_TYPE
_PACKET.fields_by_name['change_param'].enum_type = _PACKET_CHANGE
_PACKET_TYPE.containing_type = _PACKET;
_PACKET_CHANGE.containing_type = _PACKET;
DESCRIPTOR.message_types_by_name['Packet'] = _PACKET
DESCRIPTOR.message_types_by_name['PacketB'] = _PACKETB
DESCRIPTOR.message_types_by_name['VarIntPacker'] = _VARINTPACKER

class Packet(_message.Message):
  __metaclass__ = _reflection.GeneratedProtocolMessageType
  DESCRIPTOR = _PACKET

  # @@protoc_insertion_point(class_scope:Packet)

class PacketB(_message.Message):
  __metaclass__ = _reflection.GeneratedProtocolMessageType
  DESCRIPTOR = _PACKETB

  # @@protoc_insertion_point(class_scope:PacketB)

class VarIntPacker(_message.Message):
  __metaclass__ = _reflection.GeneratedProtocolMessageType
  DESCRIPTOR = _VARINTPACKER

  # @@protoc_insertion_point(class_scope:VarIntPacker)


# @@protoc_insertion_point(module_scope)
