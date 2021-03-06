% Prevent Octave from thinkign that this is a function file:
1;

pkg load sockets; 


% This is how we include our fifo package
o_include_fifo;

% just a few helper functions for pipes
o_include_pipes;

% utility functions including type conversions
o_util;


if( exist('radio') == 0)
    disp('Please set radio = {0,1} to continue');
    return
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



function [] = service_rx_fifo()
    global payload_size payload_size_floats tx_pipe rx_pipe txfifo rxfifo rx_total tx_total txrxcountdelta raw_data;

    [data, count] = o_pipe_read(rx_pipe, payload_size);
    if( count ~= 0 )
        cplx = raw_to_complex(data');

        o_fifo_write(rxfifo, cplx);

        [szin,~] = size(cplx);

        
%         raw_data = [raw_data;cplx];
                
                
        clear cplx;
        clear data;
%         samples_per_second(szin);



        rx_total = rx_total + szin;
    end
end

function [] = service_tx_fifo()
    global payload_size payload_size_floats tx_pipe rx_pipe txfifo rxfifo rx_total tx_total txrxcountdelta;

    if( o_fifo_avail(txfifo) > payload_size_floats )
        if( (tx_total + txrxcountdelta) <= rx_total )
            fifo_tx_data = o_fifo_read(txfifo, payload_size_floats);
            o_pipe_write(tx_pipe, complex_to_raw(fifo_tx_data));
            
            tx_total = tx_total + payload_size_floats;
        end
    else
        disp('tx fifo near bottom');
    end
end

function [] = service_all()
    service_rx_fifo();
    service_tx_fifo();
    service_rx_fifo();
    service_tx_fifo();
end

more off;  % ffs Octave




% ------------------------ NAMED PIPES ------------------------
global payload_size payload_size_floats tx_pipe rx_pipe;
payload_size = 1024*40;
payload_size_floats = payload_size / 8;


tx_pipe_path = sprintf('r%d_tx_pipe',radio);
rx_pipe_path = sprintf('r%d_rx_pipe',radio);
tx_pipe = o_pipe_open(tx_pipe_path);
rx_pipe = o_pipe_open(rx_pipe_path);
% ------------------------ NAMED PIPES ------------------------



load('clock_comb195k.mat','clock_comb195k','idealdata','patternvec');
clock_comb = clock_comb195k;

srate = 512/1E8;
fs = 1/srate;

shift_ammount = 10E3;

clock_comb_shift = freq_shift(clock_comb, fs, shift_ammount);

detect_threshold = 3;



schunk = 1/srate*0.8;

global txfifo rxfifo;
rxfifo = o_fifo_new();
txfifo = o_fifo_new();

fifoMaxBytes = 1048576; % this is operating system enforced, changing here will not help
% 
samples_per_second(0);

global rx_total tx_total txrxcountdelta;
rx_total = 0; % in samples
tx_total = 0;
txrxcountdelta = 195E3*0.5;


% drop samples in the future
future_drop = 0;

% raw
global raw_data;
raw_data = [];

% grab delta seconds
tx_timer = clock;



% prime tx named pipe
disp('block');
txdata = zero_zero_samples(1.5*fifoMaxBytes/8);
o_pipe_write(tx_pipe, complex_to_raw(txdata));
disp('unblock');
o_pipe_write(tx_pipe, complex_to_raw(txdata));
disp('unblock');
o_pipe_write(tx_pipe, complex_to_raw(txdata));
disp('unblock');



% start radio in a mode
magic_samps = magic_rx_samples(10);
o_pipe_write(tx_pipe, complex_to_raw(magic_samps));

% prime tx fifo
% txdata = sin_out_cont(ones(1000000,1));  % debug sin wave
o_fifo_write(txfifo, txdata);


% o_fifo_write(txfifo, clock_comb_shift);
% o_fifo_write(txfifo, clock_comb_shift);
% o_fifo_write(txfifo, clock_comb_shift);
% o_fifo_write(txfifo, clock_comb_shift);
% o_fifo_write(txfifo, clock_comb_shift);
% o_fifo_write(txfifo, clock_comb_shift);
% o_fifo_write(txfifo, txdata);
% o_fifo_write(txfifo, txdata);


% flags
measure_rope = 0;


then = now;
i = 0;
while 1

    
    chars = kbhit (1);    
    if( size(chars) ~= [0 0] )
        switch(chars)
            case 'a'
                disp('');
                disp('dump 1k tx buffer');
                o_fifo_read(txfifo, 1000);
            case 's'
                disp('');
                disp('dump 100 tx buffer');
                o_fifo_read(txfifo, 100);
            case 'd'
                disp('');
                disp('dump 10 tx buffer');
                o_fifo_read(txfifo, 10);
            case 'f'
                disp('');
                disp('dump 1 tx buffer');
                o_fifo_read(txfifo, 1);
            case 'm'
                disp('');
                disp('starting measure');
                measure_rope = 1;
                rope_start = o_fifo_written_lifetime(txfifo);
                o_fifo_write(txfifo, clock_comb_shift);                
        end
    end


    % set these so we can view in octave gui
    a0_tx_lifetime = o_fifo_written_lifetime(txfifo);
    a0_rx_lifetime = o_fifo_read_lifetime(rxfifo);
	a1_rx_level = o_fifo_avail(rxfifo);
    a2_tx_level = o_fifo_avail(txfifo);
    a1_future_drop = future_drop;
                
%     service_rx_fifo();
    service_all();
    
%     o_fifo_avail(txfifo) - o_fifo_avail(rxfifo)     

    if( o_fifo_avail(rxfifo) > schunk )
        
        samples = o_fifo_read(rxfifo, schunk);

        [~, retro_single, numdatasets, retrostart, retroend, samplesoffset] = retrocorrelator_octave(double(samples),srate,clock_comb,detect_threshold);
         
%         clear samples;
         
        retro_single = single(retro_single);


        if (numdatasets > 0 && future_drop == 0)
            
            [sz,~] = size(retro_single);
            
            if( measure_rope == 1 )
                rope_end = o_fifo_read_lifetime(rxfifo) - schunk + samplesoffset;
                disp(sprintf('measured rope to be %d samples', rope_end - rope_start));
                rope_end = 0;
                rope_start = 0;
                measure_rope = 0;
            end
           
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
    


%     service_tx_fifo();
    





%     deltat = etime(clock,tx_timer);
%     chaseTheDragon = deltat * fs;
%     if( chaseTheDragon - tx_total > payload_size )
% 
%         % always bump this
%         tx_total = tx_total + payload_size_floats;
%         
%         tx_now_count = payload_size_floats;
%         if( o_fifo_avail(txfifo) < payload_size_floats )
%             tx_now_count = o_fifo_avail(txfifo);
%             disp(sprintf('tx underflow, only sending %d', tx_now_count));
%         end
% 
%         fifo_tx_data = o_fifo_read(txfifo, tx_now_count);
%         o_pipe_write(tx_pipe, complex_to_raw(fifo_tx_data));
%         
%         clear fifo_tx_data;      
%     end

    
    
    
    
    
    i = i + 1;
end














