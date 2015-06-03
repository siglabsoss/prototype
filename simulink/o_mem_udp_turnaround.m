% Prevent Octave from thinkign that this is a function file:
1;

pkg load sockets; 



% ------------------------ fifo ------------------------ 
global fifoSampleIndex fifoTotalSamples fifoBuffer fifoCount

fifoTotalSamples{1} = 0;
fifoBuffer{1} = single([]);
fifoCount = 0;


function [] = o_fifo_write(index, data)
    global fifoCount fifoTotalSamples fifoBuffer
    
    [sz,~] = size(data);
    
    % locals
    overwriteStart = fifoTotalSamples{index} + 1;
    overwriteEnd = fifoTotalSamples{index} + sz;
    
    fifoBuffer{index}(overwriteStart:overwriteEnd,1) = data;
    
    fifoTotalSamples{index} = fifoTotalSamples{index} + sz;

    if( ~iscolumn(data) )
        disp('data must be columnar in o_fifo_write');
    end
end

function [data] = o_fifo_read(index, count)
    global fifoCount fifoTotalSamples fifoBuffer

    % locals
    readStart = 1;
    readEnd = count;

    data = fifoBuffer{index}(readStart:readEnd,1);
    
    fifoBuffer{index}(readStart:readEnd,:) = [];
    
    fifoTotalSamples{index} = fifoTotalSamples{index} - count;
end

function [avail] = o_fifo_avail(index)
    global fifoCount fifoTotalSamples fifoBuffer
    
    avail = fifoTotalSamples{index};
end

function index = o_fifo_new()
    global fifoCount fifoTotalSamples fifoBuffer

    fifoCount = fifoCount + 1;
    index = fifoCount;
    
    fifoTotalSamples{index} = 0;
    fifoBuffer{index} = single([]);
end
% ------------------------ fifo ------------------------ 

% fifoBuffer
% disp(sprintf('%d avail', o_fifo_avail(1)))
% o_fifo_write(1, [complex(1) complex(0,2)]')
% fifoBuffer
% o_fifo_write(1, [complex(3) complex(4) complex(5) complex(6) 7]')
%  disp(sprintf('%d avail', o_fifo_avail(1)))
% fifoBuffer
% o_fifo_read(1, 4)
% disp(sprintf('%d avail', o_fifo_avail(1)))
% fifoBuffer
% o_fifo_read(1, 1)
% disp(sprintf('%d avail', o_fifo_avail(1)))
% o_fifo_read(1, 1)
% disp(sprintf('%d avail', o_fifo_avail(1)))
% o_fifo_write(1, [10 11 12]')
% disp(sprintf('%d avail', o_fifo_avail(1)))
% o_fifo_read(1, 4)
% % disp(sprintf('%d avail', o_fifo_avail(1)))
% return


% fifoBuffer
% fifoA = o_fifo_new()
% fifoB = o_fifo_new()
% o_fifo_write(fifoA, [complex(1) complex(0,2)]')
% o_fifo_write(fifoB, [complex(101) complex(0,102)]')
% o_fifo_write(fifoA, [complex(3) complex(4) complex(5) complex(6) 7]')
% fifoBuffer
% o_fifo_read(fifoA, 4)
% o_fifo_read(fifoB, 1)
% o_fifo_read(fifoB, 1)
% fifoBuffer
% return




function [floats] = raw_to_float(raw)
    [~,sz] = size(raw);
    
    floats = [];

    for i = [1:8:sz]
        f1 = typecast(uint8(raw(i:i+3)),'single');
        f2 = typecast(uint8(raw(i+4:i+7)),'single');
        floats = [floats;f1;f2];
    end
end

function [floats] = raw_to_complex(raw)

    
    list = typecast(uint8(raw),'single');

    [~,sz] = size(list);
    
    floats = complex(list(1:2:sz),list(2:2:sz)).'; % zomg uze .'
    
end

function [raw] = complex_to_raw(floats)

    sing = single(floats);

    % conj(x)*1i is the same as swapping real and imaginary
    % conj(sing)*1i
    list = typecast(sing,'uint8');
    
    raw = list;
end


function [ retro_out ] = replace_zero_ones( retro_single )
    [sz,~] = size(retro_single);
    dataStart = 0;
    dataEnd = 0;

%     Scan for the first non 0/0 signal
    for i = [1:sz]
        if( retro_single(i) ~= 0 )
            dataStart = i;
            break;
        end
    end

    % for now we assume signal is 50K samples
    dataEnd = dataStart + 50000;

    leadOnes = dataStart-1;
    trailOnes = sz - dataEnd;

    % rebuild the same packet with 1,1 for the zero portions
    retro_out = [complex(ones(leadOnes,1),ones(leadOnes,1)); retro_single(dataStart:dataEnd); complex(ones(trailOnes,1),ones(trailOnes,1))];
end



global sin_out_t;
sin_out_t = 0;

function [ output ] = sin_out_cont( retro_single )
    global sin_out_t

    f = 25.1;
    fs = 1/f * 2 * pi; % probably wrong

    [sz,~] = size(retro_single);

    ts = [0:sz-1]*fs + sin_out_t;
    ts = ts.';

    sin_out_t = sin_out_t + sz*fs;

    output = sin(ts);
end


global sps_then sps_count;
sps_count = 0;
sps_then = clock;

% this only works if you call it more often than 1ce per minute
function [output] = samples_per_second(count)
    global sps_then sps_count;

    rate_ave = 2; % how many seconds to average over
    
    % grab delta seconds
    seconds = etime(clock,sps_then);
    
    sps_count = sps_count + count;
    
    if( seconds < rate_ave )
        return
    end
    
    disp(sprintf('sps: %d', sps_count/seconds));
    
    sps_count = 0;
    sps_then = clock;
    
end



more off;  % ffs Octave

% ------------------------ UDP ------------------------
rcv_port = 1235;          % radio RX port (will be udp rx)
send_ip = '127.0.0.1';    % ip where gnuradio is running
send_port = 1236;         % radio TX port (will be udp tx)
payload_size = 1024*8;    % MTU this large works for localhost only
payload_size_floats = payload_size / 8;


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
% ------------------------ UDP ------------------------



load('thursday.mat','clock_comb125k','idealdata','patternvec')
clock_comb = clock_comb125k;

srate = 512/1E8;
srate = 1/125000;
detect_threshold = 4;

schunk = 1/srate*0.8;

aligned_data = [];
retro_data = [];



% schunk_bytes = schunk * 10;


rxfifo = o_fifo_new();
txfifo = o_fifo_new();


samples_per_second(0);

rxcount = 0; % in samples
txcount = 0;
txrxcountdelta = 195E3*3;

% grab delta seconds
tx_timer = clock;

% prime tx fifo
txdata = sin_out_cont(ones(1000000,1));  % debug sin wave
o_fifo_write(txfifo, single(complex(txdata,0.5)));

then = now;
i = 0;
while 1
%     disp(i);
    [data, count] = recv(rcv_sck, payload_size, 'MSG_DONTWAIT');
    if( count ~= 0 )

         cplx = raw_to_complex(data);
        
         o_fifo_write(rxfifo, cplx);

%          [~,szin] = size(data);
            [szin,~] = size(cplx);
%          samples_per_second(szin/8);
         
         rxcount = rxcount + szin;
    end
    
%     
    if( o_fifo_avail(rxfifo) > schunk )
        samples = o_fifo_read(rxfifo, schunk);
%         samples = raw_to_complex(o_fifo_read(rxfifo, floor(schunk/8)*8));
%         return;
        
%         [aligned_data_single retro_single] = retrocorrelator_octave(double(samples),srate,clock_comb,detect_threshold);
          aligned_data_single = [];
%         [sz,~] = size(retro_single);
    
%         size(retro_single);
%         plot(sin_out_cont(retro_single));
%         figure;
        if ~(sum(aligned_data_single)==0)
%               txdata = replace_zero_ones(retro_single);

%             figure;
%             plot(real(aligned_data_single));
%             disp('valid data');
        else
            
          
%             txdata = complex(ones(sz,1),ones(sz,1));
            
%             disp('empty');
%             return;
        end
        
%         size(txdata)
%         txdata = sin_out_cont(samples);  % debug sin wave
        txdata = single(complex(ones(schunk,1),0.5));
         o_fifo_write(txfifo, txdata);
%         return;
        
%         disp('rx');
%         delta = datestr(now-then,'HH:MM:SS.FFF')
        then = now;
    end
    
%     disp(o_fifo_avail(txfifo) - o_fifo_avail(rxfifo));
    
%     if( o_fifo_avail(txfifo) > payload_size_floats )
%         if( txcount + txrxcountdelta <= rxcount )
%             tx_floats = o_fifo_read(txfifo, payload_size_floats);
%             send(send_sck,complex_to_raw(tx_floats));
%             
%             txcount = txcount + payload_size_floats;
%             
%             samples_per_second(payload_size_floats);
% %             disp('tx');
%         end
%     end
    
    deltat = etime(clock,tx_timer) + 0.5;
    chaseTheDragon = deltat * (1E8/512);
    if( chaseTheDragon - txcount > payload_size )
        vec2 = complex(sin_out_cont(ones(payload_size/8,1)), 0.5);
        vec2_bytes = complex_to_raw(vec2);
        
%         vec3 = complex(o_fifo_read(txfifo, payload_size/8, 0.5));
%         vec3_bytes = complex_to_raw(vec3);
        
        send(send_sck,vec2_bytes);
        txcount = txcount + payload_size/8;
        
        
%         disp(sprintf('burn %d', payload_size/8));
        o_fifo_read(txfifo, payload_size/8); % burn
    end

%     if( totalRxSamples > schunk*8 )
% %         disp(sprintf('ok rx %d', totalRxSamples));
%         delta = datestr(now-then,'HH:MM:SS.FFF')
%         then = now;
% %         datestr(JD,'HH:MM:SS.FFF') 
%         totalRxSamples = totalRxSamples - schunk*8;
%         
%         
%     end
    
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