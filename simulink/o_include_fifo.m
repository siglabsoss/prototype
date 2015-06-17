1;

% in memory fifo, mostily inefficient when reading


% ------------------------ fifo ------------------------ 
global fifoSampleLifetimeWritten fifoSampleLifetimeRead fifoTotalSamples fifoBuffer fifoCount

fifoSampleLifetimeRead{1} = 0;
fifoSampleLifetimeWritten{1} = 0;
fifoTotalSamples{1} = 0;
fifoBuffer{1} = single([]);
fifoCount = 0;


function [] = o_fifo_write(index, data)
    global fifoCount fifoTotalSamples fifoBuffer fifoSampleLifetimeWritten fifoSampleLifetimeRead
    
    [sz,~] = size(data);
    
    % locals
    overwriteStart = fifoTotalSamples{index} + 1;
    overwriteEnd = fifoTotalSamples{index} + sz;
    
    fifoBuffer{index}(overwriteStart:overwriteEnd,1) = data;
    
    fifoTotalSamples{index} = fifoTotalSamples{index} + sz;
    fifoSampleLifetimeWritten{index} = fifoSampleLifetimeWritten{index} + sz;

    if( ~iscolumn(data) )
        if( data ~= [] )
            disp('data must be columnar in o_fifo_write');
        end
    end
end

function [data] = o_fifo_read(index, count)
    global fifoCount fifoTotalSamples fifoBuffer fifoSampleLifetimeWritten fifoSampleLifetimeRead

    % locals
    readStart = 1;
    readEnd = count;

    if( readEnd == 0 )
        data = [];
        return;
    end
    
    data = fifoBuffer{index}(readStart:readEnd,1);
    
    fifoBuffer{index}(readStart:readEnd,:) = [];
    
    fifoTotalSamples{index} = fifoTotalSamples{index} - count;
    fifoSampleLifetimeRead{index} = fifoSampleLifetimeRead{index} + count;
    
end

function [avail] = o_fifo_avail(index)
    global fifoCount fifoTotalSamples fifoBuffer fifoSampleLifetimeWritten fifoSampleLifetimeRead
    
    avail = fifoTotalSamples{index};
end

function [count] = o_fifo_read_lifetime(index)
    global fifoCount fifoTotalSamples fifoBuffer fifoSampleLifetimeWritten fifoSampleLifetimeRead 
    count = fifoSampleLifetimeRead{index};
end

function [count] = o_fifo_written_lifetime(index)
    global fifoCount fifoTotalSamples fifoBuffer fifoSampleLifetimeWritten fifoSampleLifetimeRead 
    count = fifoSampleLifetimeWritten{index};
end

function index = o_fifo_new()
    global fifoCount fifoTotalSamples fifoBuffer fifoSampleLifetimeWritten fifoSampleLifetimeRead

    fifoCount = fifoCount + 1;
    index = fifoCount;
    
    fifoTotalSamples{index} = 0;
    fifoSampleLifetimeWritten{index} = 0;
    fifoSampleLifetimeRead{index} = 0;
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