#!/bin/bash
rm r2_rx_pipe
rm r2_tx_pipe


mkfifo r2_rx_pipe
mkfifo r2_tx_pipe

