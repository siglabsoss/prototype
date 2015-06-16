#!/bin/bash
rm r0_rx_pipe
rm r0_tx_pipe
rm r1_rx_pipe
rm r1_tx_pipe

mkfifo r0_rx_pipe
mkfifo r0_tx_pipe
mkfifo r1_rx_pipe
mkfifo r1_tx_pipe
