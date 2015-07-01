#!/bin/bash

while true; do

cd ../gnuradio
cp drive_test_200.raw drive_test_200_previous.raw
cp drive_test_202.raw drive_test_202_previous.raw
echo "file copied"
./dual_drive_test.py &
GR_PID=$!
cd ../simulink
octave --eval 'o_dual_drive_test' &
O_PID=$!

echo $GR_PID
echo $O_PID

wait $GR_PID
echo "Gnuradio is finished"

wait $O_PID
echo "octave is finished"

done
