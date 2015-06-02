pkg load sockets; 

global sin_out_t;
sin_out_t = 0;

function [ output ] = sin_out_cont( retro_single )
    global sin_out_t

    f = 5000;
    fs = 1/f * 2 * pi; % probably wrong

    [sz,~] = size(retro_single);

    ts = [0:sz-1]*fs + sin_out_t;
    ts = ts.';

    sin_out_t = sin_out_t + sz*fs;

    output = sin(ts);
end

function [raw] = complex_to_raw(floats)

    sing = single(floats);

    % conj(x)*1i is the same as swapping real and imaginary
    % conj(sing)*1i
    list = typecast(sing,'uint8');
    
    raw = list;
end



more off;

rcv_port = 1235;
send_ip = '192.168.1.24';
send_ip = '127.0.0.1'
% send_ip = '192.168.1.16';
send_port = 1236;
% payload_size = 180*8;
payload_size = 1024*8;
fs = 1E8/512;

fs = fs;

disp('0 here');
% UDP Socket for reception 
% rcv_sck=socket(AF_INET, SOCK_DGRAM, 0); 
% disp('1 here');
% bind(rcv_sck,rcv_port); 
% disp('2 here');

dout = [];


send_sck=socket(AF_INET, SOCK_DGRAM, 0); 
client_info = struct('addr', send_ip, 'port', send_port); 
connect(send_sck, client_info); 
disp('3 here');


% for i=[1:5000]
% %     realt = time();
% %     disp(gmtime (realt))
% %     disp(gmtime(time()).usec)
%     us = gmtime(time()).usec; ms = floor(us/1000);
%     disp(ms)
% end

% us = gmtime(time()).usec; ms = floor(us/1000);
% start = ms;
tic;

sentSamples = 0;

while 1
    deltat = toc + 0.1;
    
    chaseTheDragon = (deltat)*fs;
%     disp(mat2str(samps));
    
    if( chaseTheDragon - sentSamples > payload_size )
        
%          fi = typecast(0.5, 'single');
%         bytesI = typecast(single(sin(i/1000)),'uint8');
%         bytesQ = typecast(single(0.1),'uint8');
        
%         vec = [bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ bytesI bytesQ]';
        
        vec2 = complex(sin_out_cont( ones(payload_size/8,1)),0.5);
        vec2_bytes = complex_to_raw(vec2);
        
        send(send_sck,vec2_bytes);
%         send(send_sck,vec);
%         return;
        
%          send(send_sck,uint8(ones(1,payload_size)*i));
        
         
         sentSamples += payload_size/8;
%          disp(sentSamples);
%          deltat
%         disp('tx');
    end
    sleep(0.001) % this prevents CPU from slamming
end


[~,sz] = size(dout);

cout = [];
for i = [1:8:sz]
    f1 = typecast(uint8(dout(i:i+3)),'single');
    f2 = typecast(uint8(dout(i+4:i+7)),'single');
    cout = [cout complex(f2,f1)];
end
% 



% UDP socket for sending 
% send_sck=socket(AF_INET, SOCK_DGRAM, 0); 
% client_info = struct("addr", send_ip, "port", send_port); 
% connect(send_sck, client_info); 
% %Receive requests 
% [args_serial,len_s]=recv(rcv_sck,1000); 
% %Send results 
% send(send_sck,results_ser); 