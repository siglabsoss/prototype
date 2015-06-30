#!/usr/bin/env python
##################################################
# Gnuradio Python Flow Graph
# Title: Top Block
# Generated: Mon Jun 29 20:26:12 2015
##################################################

from gnuradio import analog
from gnuradio import blocks
from gnuradio import eng_notation
from gnuradio import filter
from gnuradio import gr
from gnuradio import uhd
from gnuradio.eng_option import eng_option
from gnuradio.filter import firdes
from grc_gnuradio import wxgui as grc_wxgui
from optparse import OptionParser
import time
import wx

class top_block(grc_wxgui.top_block_gui):

    def __init__(self):
        grc_wxgui.top_block_gui.__init__(self, title="Top Block")
        _icon_path = "/usr/share/icons/hicolor/32x32/apps/gnuradio-grc.png"
        self.SetIcon(wx.Icon(_icon_path, wx.BITMAP_TYPE_ANY))

        ##################################################
        # Variables
        ##################################################
        self.udp_payload_size = udp_payload_size = 1024*30
        self.samp_rate = samp_rate = 1E8/512
        self.samp_freq = samp_freq = 910e6
        self.r01_feedback_port = r01_feedback_port = 1300
        self.operator_ip = operator_ip = "127.0.0.1"
        self.all_tx_gain = all_tx_gain = 0
        self.all_rx_gain = all_rx_gain = 10

        ##################################################
        # Blocks
        ##################################################
        self.uhd_usrp_source_0_0 = uhd.usrp_source(
        	device_addr="addr=192.168.1.202",
        	stream_args=uhd.stream_args(
        		cpu_format="fc32",
        		channels=range(1),
        	),
        )
        self.uhd_usrp_source_0_0.set_clock_source("external", 0)
        self.uhd_usrp_source_0_0.set_samp_rate(samp_rate)
        self.uhd_usrp_source_0_0.set_center_freq(samp_freq, 0)
        self.uhd_usrp_source_0_0.set_gain(all_rx_gain, 0)
        self.uhd_usrp_source_0_0.set_antenna("TX/RX", 0)
        self.blocks_multiply_xx_0 = blocks.multiply_vcc(1)
        self.blocks_file_sink_1 = blocks.file_sink(gr.sizeof_gr_complex*1, "drive_test.raw", False)
        self.blocks_file_sink_1.set_unbuffered(False)
        self.band_pass_filter_0_1 = filter.fir_filter_ccc(1, firdes.complex_band_pass(
        	1, samp_rate, 18E3, 22E3, 1e3, firdes.WIN_HAMMING, 6.76))
        self.band_pass_filter_0 = filter.fir_filter_ccc(1, firdes.complex_band_pass(
        	1, samp_rate, 18E3, 22E3, 1e3, firdes.WIN_HAMMING, 6.76))
        self.analog_sig_source_x_1 = analog.sig_source_c(samp_rate, analog.GR_COS_WAVE, -20000, 1, 0)

        ##################################################
        # Connections
        ##################################################
        self.connect((self.uhd_usrp_source_0_0, 0), (self.band_pass_filter_0, 0))
        self.connect((self.band_pass_filter_0, 0), (self.band_pass_filter_0_1, 0))
        self.connect((self.analog_sig_source_x_1, 0), (self.blocks_multiply_xx_0, 1))
        self.connect((self.band_pass_filter_0_1, 0), (self.blocks_multiply_xx_0, 0))
        self.connect((self.blocks_multiply_xx_0, 0), (self.blocks_file_sink_1, 0))


# QT sink close method reimplementation

    def get_udp_payload_size(self):
        return self.udp_payload_size

    def set_udp_payload_size(self, udp_payload_size):
        self.udp_payload_size = udp_payload_size

    def get_samp_rate(self):
        return self.samp_rate

    def set_samp_rate(self, samp_rate):
        self.samp_rate = samp_rate
        self.uhd_usrp_source_0_0.set_samp_rate(self.samp_rate)
        self.band_pass_filter_0.set_taps(firdes.complex_band_pass(1, self.samp_rate, 18E3, 22E3, 1e3, firdes.WIN_HAMMING, 6.76))
        self.analog_sig_source_x_1.set_sampling_freq(self.samp_rate)
        self.band_pass_filter_0_1.set_taps(firdes.complex_band_pass(1, self.samp_rate, 18E3, 22E3, 1e3, firdes.WIN_HAMMING, 6.76))

    def get_samp_freq(self):
        return self.samp_freq

    def set_samp_freq(self, samp_freq):
        self.samp_freq = samp_freq
        self.uhd_usrp_source_0_0.set_center_freq(self.samp_freq, 0)

    def get_r01_feedback_port(self):
        return self.r01_feedback_port

    def set_r01_feedback_port(self, r01_feedback_port):
        self.r01_feedback_port = r01_feedback_port

    def get_operator_ip(self):
        return self.operator_ip

    def set_operator_ip(self, operator_ip):
        self.operator_ip = operator_ip

    def get_all_tx_gain(self):
        return self.all_tx_gain

    def set_all_tx_gain(self, all_tx_gain):
        self.all_tx_gain = all_tx_gain

    def get_all_rx_gain(self):
        return self.all_rx_gain

    def set_all_rx_gain(self, all_rx_gain):
        self.all_rx_gain = all_rx_gain
        self.uhd_usrp_source_0_0.set_gain(self.all_rx_gain, 0)
import time
import thread
if __name__ == '__main__':
    import ctypes
    import os
    if os.name == 'posix':
        try:
            x11 = ctypes.cdll.LoadLibrary('libX11.so')
            x11.XInitThreads()
        except:
            print "Warning: failed to XInitThreads()"
    parser = OptionParser(option_class=eng_option, usage="%prog: [options]")
    (options, args) = parser.parse_args()
    tb = top_block()
    tb.start(True)
    time.sleep(60)
    tb.stop()
    tb.wait()
