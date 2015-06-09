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

function [floats] = raw_to_complex(raw)

    
    list = typecast(uint8(raw),'single');

    [~,sz] = size(list);
    
    floats = complex(list(1:2:sz),list(2:2:sz)).'; % zomg uze .'
    
end


more off;





% all paths are relative to the simulink directory
tx_pipe_path = 'r0_tx_pipe';
rx_pipe_path = 'r0_rx_pipe';

% tx_pipe = o_pipe_open(tx_pipe_path);
rx_pipe = o_pipe_open(rx_pipe_path);
% sleep(2);
% o_pipe_flush(rx_pipe); % dump samples
% sleep(2);

payload_size = 1024*8;
fs = 1E8/512;

rxcount = 0;

tx_timer = clock;

sentSamples = 0;

data_sum = [];

while 1
%     deltat = toc + 0.1;
%     deltat = etime(clock,tx_timer) + 0.1;
%     
%     chaseTheDragon = (deltat)*fs;
% %     disp(mat2str(samps));
%     
%     if( chaseTheDragon - sentSamples > payload_size )
%         
%         sin_samples = sin_out_cont(ones(payload_size/8,1))  .* 0.8;
%         cos_samples = cos_out_cont(ones(payload_size/8,1))  .* 0.8;
%         
%         vec2 = complex(cos_samples, sin_samples);
%         vec2_bytes = complex_to_raw(vec2);
%         
% %         send(send_sck,vec2_bytes);
%         o_pipe_write(tx_pipe, vec2_bytes);
% %         send(send_sck,vec);
% %         return;
%         
% %          send(send_sck,uint8(ones(1,payload_size)*i));
%         
%          
%          sentSamples += payload_size/8;
% %          disp(sentSamples);
% %          deltat
% %         disp('tx');
%     end

    [data, count] = o_pipe_read(rx_pipe, payload_size);
    if( count ~= 0 )
        cplx = raw_to_complex(data');

        data_sum = [data_sum; cplx];
        
%         o_fifo_write(rxfifo, cplx);

        [szin,~] = size(cplx);
%         samples_per_second(szin);

        rxcount = rxcount + szin
    end
    
    if( rxcount > payload_size*100 )
        return;
    end
    
    sleep(0.0001) % this prevents CPU from slamming
end



















