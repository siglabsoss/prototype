% Prevent Octave from thinkign that this is a function file:
1;

pkg load sockets; 


% This is how we include our fifo package
o_include_fifo;

% just a few helper functions for pipes
o_include_pipes;

% utility functions including type conversions
o_util;

radio = 2;

% if( exist('radio') == 0)
%     disp('Please set radio = {0,1} to continue');
%     return
% end


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
    global payload_size payload_size_floats tx_pipe rx_pipe txfifo rxfifo rx_total tx_total txrxcountdelta theta_rotate;

    if( o_fifo_avail(txfifo) > payload_size_floats )
        if( (tx_total + txrxcountdelta) <= rx_total )
            fifo_tx_data = o_fifo_read(txfifo, payload_size_floats);
            
            %rotate
            fifo_tx_data = fifo_tx_data * exp(1i*theta_rotate);
            
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


tx_pipe_path = sprintf('r%d_tx_pipe',radio)
rx_pipe_path = sprintf('r%d_rx_pipe',radio)
tx_pipe = o_pipe_open(tx_pipe_path);
rx_pipe = o_pipe_open(rx_pipe_path);
% ------------------------ NAMED PIPES ------------------------



load('clock_comb195k.mat','clock_comb195k','idealdata','patternvec');
clock_comb = clock_comb195k;

srate = 512/1E8;
fs = 1/srate;

% these are used for measuring the rope
shift_ammount = 10E3;
clock_comb_shift = freq_shift(clock_comb, fs, shift_ammount);

% this is what we reply with
clock_comb_reply = freq_shift(clock_comb, fs, 20E3);

detect_threshold = 3;



schunk = floor(fs*0.8);

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


% raw
global raw_data;
raw_data = [];

% grab delta seconds
tx_timer = clock;


figure(1);
figure(2);
figure(3);
figure(4);




% prime tx named pipe
disp('block');
txdata = zero_zero_samples(1.5*fifoMaxBytes/8);
o_pipe_write(tx_pipe, complex_to_raw(txdata));
disp('unblock');
% o_pipe_write(tx_pipe, complex_to_raw(txdata));
% disp('unblock');
% o_pipe_write(tx_pipe, complex_to_raw(txdata));
% disp('unblock');

% prime tx fifo
% txdata = sin_out_cont(ones(1000000,1));  % debug sin wave
o_fifo_write(txfifo, txdata);
o_fifo_write(txfifo, txdata);
o_fifo_write(txfifo, txdata);



% o_fifo_write(txfifo, clock_comb_reply);
% o_fifo_write(txfifo, clock_comb_reply);

% o_fifo_write(txfifo, txdata);
% o_fifo_write(txfifo, txdata);

% start radio in rx mode
magic_rx = magic_rx_samples(10);
magic_rx_bytes = complex_to_raw(magic_rx);
o_pipe_write(tx_pipe, magic_rx_bytes);


% flags
measure_rope = 0;
global theta_rotate;
theta_rotate = 0;
output_enable = 1;
output_interval = 6-0.6;

output_timer = clock;
chunk_detect = 0;
chunk_samples = [];
fignum = 0;
log_dump = 1;

if( log_dump )
    logfilename = sprintf('%s-log-client%d.dat', mat2str(round(time)), radio)
    logfid = fopen(logfilename, 'w'); % http://man7.org/linux/man-pages/man3/fopen.3.html
end


i = 0;
while 1

    sleep(0.001);
    
    chars = kbhit (1);    
    if( size(chars) ~= [0 0] )
        disp('');
        switch(chars)
            % --- rx dump
            case 'A'
                disp('dump 1k rx buffer');
                o_fifo_read(rxfifo, 1000);
            case 'S'
                disp('dump 100 rx buffer');
                o_fifo_read(rxfifo, 100);
            case 'D'
                
                disp('dump 10 rx buffer');
                o_fifo_read(rxfifo, 10);
            case 'F'
                disp('dump 1 rx buffer');
                o_fifo_read(rxfifo, 1);
                
            % --- tx insert
            case 'q'
                disp('inserting 100k into tx buffer');
                o_fifo_write(txfifo,complex_to_raw(zero_zero_samples(100E3)));
                
            % --- tx dump
            case 'a'
                disp('dump 1k tx buffer');
                o_fifo_read(txfifo, 1000);
            case 's'
                disp('dump 100 tx buffer');
                o_fifo_read(txfifo, 100);
            case 'd'
                disp('dump 10 tx buffer');
                o_fifo_read(txfifo, 10);
            case 'f'
                disp('dump 1 tx buffer');
                o_fifo_read(txfifo, 1);

            % --- theta rotate
            case 'r'
                disp('theta -= pi/8');
                theta_rotate = theta_rotate - pi/8;
                disp(theta_rotate);
            case 't'
                disp('theta -= pi/4');
                theta_rotate = theta_rotate - pi/4;
                disp(theta_rotate);
            case 'y'
                disp('theta += pi/4');
                theta_rotate = theta_rotate + pi/4;
                disp(theta_rotate);
            case 'u'
                disp('theta += pi/8');
                theta_rotate = theta_rotate + pi/8;
                disp(theta_rotate);
                
            case ','
                output_interval = output_interval - 0.5;
                disp(sprintf('sending signal every %g seconds', output_interval));
                
            case '.'
                output_interval = output_interval + 0.5;
                disp(sprintf('sending signal every %g seconds', output_interval));
                

            % --- Toggle output
            case 'p'
                
                output_enable = bitxor(output_enable, 1);
                if( output_enable )
                    disp('Enabling output');
                else
                    disp('Disabling output');
                end
                
            case 'm'
                
                disp('starting measure (make sure output is enabled)');
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
                
%     service_rx_fifo();
    service_all();
    
%     o_fifo_avail(txfifo) - o_fifo_avail(rxfifo)     

    if( o_fifo_avail(rxfifo) > schunk )
        
        samples = o_fifo_read(rxfifo, schunk);
        
        fsearchcenter = -10E3;
       
        if( log_dump )
            fwrite(logfid, complex_to_raw(samples), 'uint8');
        end
        
        fsearchwindow_low = -200 + fsearchcenter; %frequency search window low, in Hz
        fsearchwindow_hi = 200 + fsearchcenter;   %frequency search window high, in Hz

        numdatasets = 0;
%         [~, ~, numdatasets, retrostart, retroend, samplesoffset] = retrocorrelator_octave(double(samples), srate,clock_comb, clock_comb_reply, detect_threshold, fsearchwindow_low, fsearchwindow_hi);
         
        
%         clear samples;
         
%         retro_single = single(retro_single);

        deltat = etime(clock,output_timer);
        
        if( deltat > output_interval && output_enable == 1)
            
            o_fifo_write(txfifo, magic_tx_samples(10));
            o_fifo_write(txfifo, clock_comb_reply);
            o_fifo_write(txfifo, magic_rx_samples(10));
            
            [sz,~] = size(clock_comb_reply);
            o_fifo_read(txfifo, sz+20); % burn the same ammount we just inserted
            
            output_timer = clock;
            
            disp('transmitting');
        end

         if( chunk_detect == 1 )
                chunk_samples = [chunk_samples;samples];
                
                fignum = mod(fignum+1,4);
                fignum+1
                figure(fignum+1);
                
                
                plot(real(chunk_samples));
                
                absdata = abs(chunk_samples).^2;
                power_result = sum(absdata)*1000;
                disp(sprintf('sum of abs of data is %g', power_result));
                
                title(power_result);
                chunk_detect = 2;
          end
        
        if (numdatasets > 0)
            

%             [sz,~] = size(clock_comb);
%             
%             if( (schunk - samplesoffset) > (sz*1.05) && samplesoffset > 0 )
% %                 figure;
% %                 plot(real(samples));
%                 
%                 absdata = abs(samples).^2;
%                 disp(sprintf('sum of abs of data is %g', sum(absdata)*1000));
%             end
            
              if( chunk_detect == 0 )
                  chunk_samples = samples;
                  chunk_detect = 1;
              end
              
              if( chunk_detect == 2 )
                  chunk_detect = 0;
              end
           

%             [sz,~] = size(retro_single);
            
            % unsure if this works on clinet
            if( measure_rope == 1 )
                rope_end = o_fifo_read_lifetime(rxfifo) - schunk + samplesoffset;
                disp(sprintf('measured rope to be %d samples', rope_end - rope_start));
                rope_end = 0;
                rope_start = 0;
                measure_rope = 0;
            end
            
%             figure;
%             plot(real(samples));
            
            clear retro_single;
            
            disp('valid data');

        else
            clear retro_single;
            
%             disp('empty');
        end
        
        txdata = zero_zero_samples(schunk);
        
%         size(txdata)
%         txdata = sin_out_cont(samples);  % debug sin wave

%        txdata = single(complex(ones(schunk,1),0.5));
         o_fifo_write(txfifo, txdata);
         clear txdata;

%         o_fifo_write(txfifo, samples);


%         return;
        
%         disp('rx');
%         delta = datestr(now-then,'HH:MM:SS.FFF')
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














