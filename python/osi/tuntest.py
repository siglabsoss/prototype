from pytun import TunTapDevice, IFF_TAP
from sigmath import *



# run ifconfig -a after this
def ttap():
    tap = TunTapDevice(flags=IFF_TAP)
    print tap.name
    tap.hwaddr = '\x00\x11\x22\x33\x44\x55'
    print_hex(tap.hwaddr)

    tap.mtu = 200

    tap.up()
    while(1):
        buf = tap.read(tap.mtu)
        print "read"
        print_hex(buf)
        # tun.write(buf)

# this one doesn't work so well
def ttun():
    tun = TunTapDevice(name='mytun')
    print tun.name
    tun.addr = '10.0.2.16'
    tun.dstaddr = '10.8.0.2'
    tun.netmask = '255.255.255.0'
    tun.mtu = 1500
    tun.up()

#


if __name__ == '__main__':
    ttap()
    #
    # while(1):
    #     pass
