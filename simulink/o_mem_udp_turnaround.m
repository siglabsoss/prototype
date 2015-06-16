% Prevent Octave from thinkign that this is a function file:
1;

pkg load sockets; 


% This is how we include our fifo package
o_include_fifo;

% just a few helper functions for pipes
o_include_pipes;

% utility functions including type conversions
o_util;



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




% ------------------------ NAMED PIPES ------------------------
payload_size = 1024*30;
payload_size_floats = payload_size / 8;


tx_pipe_path = 'r0_tx_pipe';
rx_pipe_path = 'r0_rx_pipe';
tx_pipe = o_pipe_open(tx_pipe_path);
rx_pipe = o_pipe_open(rx_pipe_path);
% ------------------------ NAMED PIPES ------------------------



load('clock_comb195k.mat','clock_comb195k','idealdata','patternvec');
clock_comb = clock_comb195k;

srate = 512/1E8;
% srate = 1/125000;
detect_threshold = 2;

fs = 1/srate;

schunk = 1/srate*0.8;


rxfifo = o_fifo_new();
txfifo = o_fifo_new();


samples_per_second(0);

rxcount = 0; % in samples
txcount = 0;
txrxcountdelta = 195E3*3;


% drop samples in the future
future_drop = 0;

% raw
raw_data = [];

% grab delta seconds
tx_timer = clock;

% prime tx fifo
% txdata = sin_out_cont(ones(1000000,1));  % debug sin wave
% o_fifo_write(txfifo, single(complex(txdata,0.5)));

% prime tx fifo
txdata = zero_zero_samples(1000000);  % debug sin wave
o_fifo_write(txfifo, txdata);

% start radio in rx mode
magic_rx = magic_rx_samples(10);
magic_rx_bytes = complex_to_raw(magic_rx);
o_pipe_write(tx_pipe, magic_rx_bytes);


then = now;
i = 0;
while 1

    
    

    % set these so we can view in octave gui
	a1_rx_level = o_fifo_avail(rxfifo);
    a2_tx_level = o_fifo_avail(txfifo);
    a1_future_drop = future_drop;
    
    
                
    
    [data, count] = o_pipe_read(rx_pipe, payload_size);
    if( count ~= 0 )
        cplx = raw_to_complex(data');

        o_fifo_write(rxfifo, cplx);

        [szin,~] = size(cplx);
        
        clear cplx;
        clear data;
%         samples_per_second(szin);

%         raw_data = [raw_data;cplx];

        rxcount = rxcount + szin;
    end
    
%     
    if( o_fifo_avail(rxfifo) > schunk )
        samples = o_fifo_read(rxfifo, schunk);

        [~, retro_single, numdatasets, retrostart, retroend] = retrocorrelator_octave(double(samples),srate,clock_comb,detect_threshold);
         
        clear samples;
         
        retro_single = single(retro_single);

%         size(retro_single);
%         plot(sin_out_cont(retro_single));
%         figure;
%         numdatasets
%         retrostart
%         retroend

%         schunk
%         size(retro_single)

        if (numdatasets > 0 && future_drop == 0)
            
            [sz,~] = size(retro_single);
           
            % snip in our magic samples
            retro_single(retrostart-10:retrostart-1) = magic_tx_samples(10);
            retro_single(retroend+1:retroend+10)     = magic_rx_samples(10);
            
            % retrocorrelator_octave() gave us too many samples (because ewin)
            % this counter keeps track of how many extra samples we have in the fifo right now
            future_drop = future_drop + (sz-schunk);
            
            
            txdata = retro_single;
            clear retro_single;
            
%               txdata = replace_zero_ones(retro_single);
%             txdata = retro_single;
%             txdata = zero_zero_samples(schunk);

%             figure;
%             plot(real(aligned_data_single));
            disp('valid data');
%             disp(sprintf('tx pipe fill level %d', o_fifo_avail(txfifo)));
%             return;
        else
            clear retro_single;
            
            zeros_to_queue = schunk;
            
            % if the 'valid data' condition put too much in our buffer
            if( future_drop > 0 )
                % subtract all of them, this will nominally be negative
                zeros_to_queue = zeros_to_queue - future_drop;
                
                % bound the ammount, if zero txdata below ends up at [] which is ok
                zeros_to_queue = max(0, zeros_to_queue);
                
                % only take away what we can from future_drop
                future_drop = future_drop - (schunk - zeros_to_queue);
%                 disp('making up for previous packet');
            end
            
            txdata = zero_zero_samples(zeros_to_queue);

            disp('empty');
        end
        
%         size(txdata)
%         txdata = sin_out_cont(samples);  % debug sin wave

%        txdata = single(complex(ones(schunk,1),0.5));
         o_fifo_write(txfifo, txdata);
         clear txdata;

%         o_fifo_write(txfifo, samples);


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
    
    deltat = etime(clock,tx_timer) + 1;
    chaseTheDragon = deltat * fs;
    if( chaseTheDragon - txcount > payload_size )

        txcount = txcount + payload_size/8;

        fifo_tx_data = o_fifo_read(txfifo, payload_size/8);
%         typeinfo(fifo_tx_data)

        
%         fifo_tx_data = zero_zero_samples(payload_size/8);
%         typeinfo(fifo_tx_data)

        
        o_pipe_write(tx_pipe, complex_to_raw(fifo_tx_data));
        
        clear fifo_tx_data;      
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