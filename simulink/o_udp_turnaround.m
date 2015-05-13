% Prevent Octave from thinkign that this is a function file:
1;

pkg load sockets; 



% ------------------------ fifo ------------------------ 
global fifoCount fifoSamples fifoFiles fifoFids fifoDataType
fifoSamples = zeros(0);
fifoCount = 0;
fifoFiles = cell(1);
fifoFids  = zeros(0);
fifoDataType = 'single';

function [] = o_fifo_write(index, data)
    global fifoCount fifoSamples fifoFiles fifoFids fifoDataType
    
    wrcount = fwrite(fifoFids(index), data, fifoDataType);
    
    [sz,~] = size(data);
    
    fifoSamples(index) = fifoSamples(index) + sz;
    
    if( sz ~= wrcount )
        disp(sprintf('o_fifo_write was given %d samples but wrote %d', sz, wrcount));
    end
    
    if( ~iscolumn(data) )
        disp('data must be columnar in o_fifo_write');
    end
end

function [data] = o_fifo_read(index, count)
    global fifoCount fifoSamples fifoFiles fifoFids fifoDataType
    
    [data, rdcount] = fread(fifoFids(index), count, fifoDataType);
    
    [sz,~] = size(data);
    
    fifoSamples(index) = fifoSamples(index) - sz;
    
    if( sz ~= rdcount || sz ~= count )
        disp(sprintf('in o_fifo_read %d %d %d should all be the same', sz, rdcount, count));
    end
end

function [avail] = o_fifo_avail(index)
    global fifoCount fifoSamples fifoFiles fifoFids fifoDataType
    
    avail = fifoSamples(index);
end

function index = o_fifo_new()
    global fifoCount fifoSamples fifoFiles fifoFids fifoDataType

    fifoCount = fifoCount + 1;
    index = fifoCount;
    
    fifoSamples(index) = 0;
    fifoFiles{index} = tempname;
    [ERR, MSG] = mkfifo(fifoFiles{index}, base2dec('744',8));
    fifoFids(index)  = fopen(fifoFiles{index}, 'a+');
end
% ------------------------ fifo ------------------------ 


txfifo = o_fifo_new();
disp(o_fifo_avail(txfifo));
o_fifo_write(txfifo, [1.243 pi 2*pi 4/3*pi]');
disp(o_fifo_avail(txfifo));
disp(o_fifo_read(txfifo, 4));
disp(o_fifo_avail(txfifo));








return



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