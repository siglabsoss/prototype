1;

o_include_pipes;






global sin_out_t;
sin_out_t = 0;

function [ output ] = sin_out_cont( retro_single )
    global sin_out_t

    f = 55.1;
    fs = 1/f * 2 * pi; % probably wrong

    [sz,~] = size(retro_single);

    ts = [0:sz-1]*fs + sin_out_t;
    ts = ts.';

    sin_out_t = sin_out_t + sz*fs;

    output = sin(ts);
end

global cos_out_t;
cos_out_t = 0;

function [ output ] = cos_out_cont( retro_single )
    global cos_out_t

    f = 55.1;
    fs = 1/f * 2 * pi; % probably wrong

    [sz,~] = size(retro_single);

    ts = [0:sz-1]*fs + cos_out_t;
    ts = ts.';

    cos_out_t = cos_out_t + sz*fs;

    output = cos(ts);
end


function [raw] = complex_to_raw(floats)

    sing = single(floats);

    % conj(x)*1i is the same as swapping real and imaginary
    % conj(sing)*1i
    list = typecast(sing,'uint8');
    
    raw = list;
end

more off;





% all paths are relative to the simulink directory
tx_pipe_path = 'r0_tx_pipe';
rx_pipe_path = 'r0_rx_pipe';


tx_pipe = o_pipe_open(tx_pipe_path);


payload_size = 1024*8;
fs = 1E8/512;



tx_timer = clock;

sentSamples = 0;

while 1
%     deltat = toc + 0.1;
    deltat = etime(clock,tx_timer) + 0.1;
    chaseTheDragon = (deltat)*fs;
    if( chaseTheDragon - sentSamples > payload_size )
        
        sin_samples = sin_out_cont(ones(payload_size/8,1))  .* 0.8;
        cos_samples = cos_out_cont(ones(payload_size/8,1))  .* 0.8;
        
        vec2 = complex(cos_samples, sin_samples);
        vec2_bytes = complex_to_raw(vec2);
        
        o_pipe_write(tx_pipe, vec2_bytes);
         
         sentSamples += payload_size/8;
    end
    sleep(0.0001) % this prevents CPU from slamming
end



















