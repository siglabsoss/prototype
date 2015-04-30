pkg load sockets; 

rcv_port = 1235;
send_ip = '127.0.0.1';
send_port = 1236;

disp('0 here');
% UDP Socket for reception 
rcv_sck=socket(AF_INET, SOCK_DGRAM, 0); 
disp('1 here');
bind(rcv_sck,rcv_port); 
disp('2 here');

dout = [];

for i=[1:99999]

    [data, count] = recv(rcv_sck, 1024, 'MSG_DONTWAIT');
    if( count ~= 0 )
%         disp(data);
%         disp(count);
%         fflush(stdout);
        dout = [dout data];
    end

    [~,sz] = size(dout);
    
    if( sz > 10000 )
        break
    end
    
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