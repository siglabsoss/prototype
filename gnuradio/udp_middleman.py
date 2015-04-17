#!/usr/bin/env python

from gnuradio import gr, blocks
from gnuradio import audio, analog

class my_top_block(gr.top_block):
    def __init__(self):
        gr.top_block.__init__(self)

        sample_rate = 36000
        ampl = 1



        self.packet_source = blocks.udp_source(gr.sizeof_float, "0.0.0.0", 1234, 180*8)


        src0 = analog.sig_source_f(sample_rate, analog.GR_SIN_WAVE, 350, ampl)
        src1 = analog.sig_source_f(sample_rate, analog.GR_SIN_WAVE, 440, ampl)
        dst = audio.sink(sample_rate, "", True)

        self.connect(self.packet_source, (dst,0))
        self.connect(src0, (dst, 1))
        self.connect(src1, (dst, 2))

if __name__ == '__main__':
    try:
        my_top_block().run()
    except [[KeyboardInterrupt]]:
        pass

