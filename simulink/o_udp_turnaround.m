pkg load sockets; 

rcv_port = 1235;
send_ip = '192.168.1.24';
send_ip = '127.0.0.1'
% send_ip = '192.168.1.16';
send_port = 1236;
payload_size = 180*8;

disp('0 here');
% UDP Socket for reception 
rcv_sck=socket(AF_INET, SOCK_DGRAM, 0); 
disp('1 here');
bind(rcv_sck,rcv_port); 
disp('2 here');

dout = [];


send_sck=socket(AF_INET, SOCK_DGRAM, 0); 
client_info = struct('addr', send_ip, 'port', send_port); 
connect(send_sck, client_info); 





for i=[1:9999999]

%     disp(i);
    [data, count] = recv(rcv_sck, payload_size, 'MSG_DONTWAIT');
    if( count ~= 0 )
%         typeinfo(data)
%         typeinfo(data(1))
           disp(data);
%          disp(count);
%          fflush(stdout);
         
        if( mod(i,2) == 0 )
            send(send_sck,data); 
        else
            send(send_sck,uint8(zeros(1,payload_size)));
        end
          
        dout = [dout data];
    end

    [~,sz] = size(dout);
    
%     if( sz > 10000 )
%         break
%     end
    
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