1;

% quick wrappers around fwrite to handle error conditions


% pipe_type = 'uint8';

function [] = o_pipe_write(fid, data)
    
    pipe_type = 'uint8';

    wrcount = fwrite(fid, data, pipe_type);
    
    [sz,~] = size(data);
    
    if( sz ~= wrcount )
        disp(sprintf('o_pipe_write was given %d samples but wrote %d', sz, wrcount));
    end
    
    if( ~iscolumn(data) )
        disp('data must be columnar in o_pipe_write');
    end
end


function [data] = o_pipe_read(fid, count)
    
    pipe_type = 'uint8';
    
    [data, rdcount] = fread(fid, count, pipe_type);
    
    if( rdcount == 0 )
        data = [];
    end
    
    [sz,~] = size(data);
    
    if( sz ~= rdcount || sz ~= count )
        disp(sprintf('in o_fifo_read %d %d %d should all be the same', sz, rdcount, count));
    end
end
 
function fid = o_pipe_open(filename)
    fid = fopen(filename, 'a+'); % http://man7.org/linux/man-pages/man3/fopen.3.html
    
    % avoid hangs when trying to overfill fifo
    % also avoids hangs when reading empty pipe
    fcntl(fid, F_SETFL, O_NONBLOCK);  
end

