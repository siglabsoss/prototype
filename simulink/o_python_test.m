1;

more off;

% utility functions including type conversions
o_util;

% wrap zmq command set
o_include_zmq_commands;



radio = 1;



zmq_to_python = zmq('publish_connect','tcp','127.0.0.1',4000);
sleep(1) % if we don't sleep the first few zmq message may be dropped

i = 0;
% 
% while 1
%     zmq('send',zmq_to_python,single([10000, i, -0.4, 0.5, -0.9]))
%     sleep(5)
%     i = i + 1
% end

zmq_octave_hello(zmq_to_python, radio);

