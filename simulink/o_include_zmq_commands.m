1;

% wrapper around some common zmq commands we wend



% global fifoSampleLifetimeWritten fifoSampleLifetimeRead fifoTotalSamples fifoBuffer fifoCount
% 
% fifoSampleLifetimeRead{1} = 0;
% fifoSampleLifetimeWritten{1} = 0;
% fifoTotalSamples{1} = 0;
% fifoBuffer{1} = single([]);
% fifoCount = 0;


function [] = zmq_octave_hello(zsock, radio)
    command = complex(10000,radio);
    msg = complex_to_raw(command);
    zmq('send',zsock,msg);
end

function [] = zmq_octave_packet_rx(zsock, radio)
    zmq('send',zsock,single([10000, radio]))
end

% function [data] = o_fifo_read(index, count)
%     global fifoCount fifoTotalSamples fifoBuffer fifoSampleLifetimeWritten fifoSampleLifetimeRead
% 
%     % locals
%     readStart = 1;
%     readEnd = count;
% 
%     if( readEnd == 0 )
%         data = [];
%         return;
%     end
%     
%     data = fifoBuffer{index}(readStart:readEnd,1);
%     
%     fifoBuffer{index}(readStart:readEnd,:) = [];
%     
%     fifoTotalSamples{index} = fifoTotalSamples{index} - count;
%     fifoSampleLifetimeRead{index} = fifoSampleLifetimeRead{index} + count;
%     
% end
% 
% function [avail] = o_fifo_avail(index)
%     global fifoCount fifoTotalSamples fifoBuffer fifoSampleLifetimeWritten fifoSampleLifetimeRead
%     
%     avail = fifoTotalSamples{index};
% end
% 
% function [count] = o_fifo_read_lifetime(index)
%     global fifoCount fifoTotalSamples fifoBuffer fifoSampleLifetimeWritten fifoSampleLifetimeRead 
%     count = fifoSampleLifetimeRead{index};
% end
% 
% function [count] = o_fifo_written_lifetime(index)
%     global fifoCount fifoTotalSamples fifoBuffer fifoSampleLifetimeWritten fifoSampleLifetimeRead 
%     count = fifoSampleLifetimeWritten{index};
% end
% 
% function index = o_fifo_new()
%     global fifoCount fifoTotalSamples fifoBuffer fifoSampleLifetimeWritten fifoSampleLifetimeRead
% 
%     fifoCount = fifoCount + 1;
%     index = fifoCount;
%     
%     fifoTotalSamples{index} = 0;
%     fifoSampleLifetimeWritten{index} = 0;
%     fifoSampleLifetimeRead{index} = 0;
%     fifoBuffer{index} = single([]);
% end




