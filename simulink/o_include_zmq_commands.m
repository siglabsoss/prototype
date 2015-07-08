1;

% wrapper around some common zmq commands we wend




function [] = zmq_octave_hello(zsock, radio)
    command = complex(10000,radio);
    msg = complex_to_raw(command);
    zmq('send',zsock,msg);
end

function [] = zmq_octave_packet_rx(zsock, radio, aligned_data, samplesoffset)
    command = complex(10001,radio);
    msg = complex_to_raw([command,samplesoffset].'); % ZOMG use .'
    
    data = complex_to_raw(aligned_data);
    
    zmq('send',zsock,[msg;data]);
end



