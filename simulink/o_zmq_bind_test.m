1;

more off

% socket is bound here
zsock = zmq('publish','tcp',4000);
disp('run python now');
while 1
    zmq('send',zsock,'hello world')
    sleep(1)
end