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
fifoDataTypeSize = 4;
fifoMaxBytes = 1048576; % this is operating system enforced, changing here will not help

global fifoSampleIndex fifoTotalSamples fifoBuffer
fifoSampleIndex = 0;
fifoTotalSamples = 0;
fifoBuffer = [];


function [] = o_fifo_write(index, data)
    global fifoCount fifoSamples fifoFiles fifoFids fifoDataType fifoSampleIndex fifoTotalSamples fifoBuffer
    
    [sz,~] = size(data);
    
    % locals
    overwriteStart = fifoTotalSamples + 1;
    overwriteEnd = fifoTotalSamples + sz;
    
    fifoBuffer(overwriteStart:overwriteEnd,1) = data;
    
    fifoTotalSamples = fifoTotalSamples + sz;

    if( ~iscolumn(data) )
        disp('data must be columnar in o_fifo_write');
    end
end

function [data] = o_fifo_read(index, count)
    global fifoCount fifoSamples fifoFiles fifoFids fifoDataType fifoSampleIndex fifoTotalSamples fifoBuffer

    % always
    fifoSampleIndex = 0;

    % locals
    readStart = fifoSampleIndex + 1;
    readEnd = fifoSampleIndex + count;

    data = fifoBuffer(readStart:readEnd,1);
    
    fifoBuffer(readStart:readEnd,:) = [];
    
    fifoTotalSamples = fifoTotalSamples - count;
end

function [avail] = o_fifo_avail(index)
    global fifoCount fifoSamples fifoFiles fifoFids fifoDataType fifoSampleIndex fifoTotalSamples fifoBuffer
    
    avail = fifoTotalSamples;
end

function index = o_fifo_new()
%     global fifoCount fifoSamples fifoFiles fifoFids fifoDataType
% 
%     fifoCount = fifoCount + 1;
%     index = fifoCount;
%     
%     fifoSamples(index) = 0;
%     fifoFiles{index} = tempname;
%     [ERR, MSG] = mkfifo(fifoFiles{index}, base2dec('744',8));
%     fifoFids(index)  = fopen(fifoFiles{index}, 'a+');
% %     fcntl(fifoFids(index), F_SETFL, O_NONBLOCK);  % uncomment to avoid hangs when trying to overfill fifo
end
% ------------------------ fifo ------------------------ 

fifoBuffer
disp(sprintf('%d avail', o_fifo_avail(1)))
o_fifo_write(1, [1 2]')
fifoBuffer
o_fifo_write(1, [3 4 5 6 7]')
disp(sprintf('%d avail', o_fifo_avail(1)))
fifoBuffer
o_fifo_read(1, 4)
disp(sprintf('%d avail', o_fifo_avail(1)))
fifoBuffer
o_fifo_read(1, 1)
disp(sprintf('%d avail', o_fifo_avail(1)))
o_fifo_read(1, 1)
disp(sprintf('%d avail', o_fifo_avail(1)))
o_fifo_write(1, [10 11 12]')
disp(sprintf('%d avail', o_fifo_avail(1)))
o_fifo_read(1, 4)
disp(sprintf('%d avail', o_fifo_avail(1)))



return;















function [floats] = raw_to_float(raw)

    [~,sz] = size(raw);
    
    floats = [];

    for i = [1:8:sz]
        f1 = typecast(uint8(raw(i:i+3)),'single');
        f2 = typecast(uint8(raw(i+4:i+7)),'single');
        floats = [floats;f1;f2];
    end

end

more off;  % ffs Octave


rcv_port = 1235;          % radio RX port (will be udp rx)
send_ip = '127.0.0.1';    % ip where gnuradio is running
send_port = 1236;         % radio TX port (will be udp tx)
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

rxfifo = o_fifo_new();
% txfifo = o_fifo_new();


i = 0;
while 1
%     disp(i);
    [data, count] = recv(rcv_sck, payload_size, 'MSG_DONTWAIT');
    if( count ~= 0 )

%            disp(data);

%            disp();
           disp('pre');
           o_fifo_write(rxfifo, raw_to_float(data));
           disp('post');
           disp(o_fifo_avail(rxfifo));
         
%         if( mod(i,2) == 0 )
%             send(send_sck,data); 
%         else
%             send(send_sck,uint8(zeros(1,payload_size)));
%         end
          
%         dout = [dout data];
    end
    
%     disp(o_fifo_avail(rxfifo));
%     
%     chunk = 1000;
%     
%     if( o_fifo_avail(rxfifo) > 1000)
%         rrrr = o_fifo_read(rxfifo, 1000);
%         cxs = [];
%         for j = 1:2:1000
%             c1 = complex(rrrr(j),rrrr(j+1));
%             cxs = [cxs;c1];
%         end
%         plot(imag(cxs));
%         return;
%     end

%     [~,sz] = size(dout);
    
%     if( sz > 10000 )
%         break
%     end
    i = i + 1;
end

% [~,sz] = size(dout);
% 
% cout = [];
% for i = [1:8:sz]
%     f1 = typecast(uint8(dout(i:i+3)),'single');
%     f2 = typecast(uint8(dout(i+4:i+7)),'single');
%     cout = [cout complex(f2,f1)];
% end
% 



% UDP socket for sending 
% send_sck=socket(AF_INET, SOCK_DGRAM, 0); 
% client_info = struct("addr", send_ip, "port", send_port); 
% connect(send_sck, client_info); 
% %Receive requests 
% [args_serial,len_s]=recv(rcv_sck,1000); 
% %Send results 
% send(send_sck,results_ser); 