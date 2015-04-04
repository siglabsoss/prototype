function live_xxcorrelator( block )
Setup(block);
end



% called for every input port
function SetInputPortSampleTime(block, portNumber, time)

% first set our sample time to what the engine requested
block.InputPort(1).SampleTime = time;

end

function SetOutputPortSampleTime(block, portNumber, time)
end

function PostPropagationSetup(block)
    % http://www.mathworks.com/matlabcentral/answers/98799-what-are-the-valid-datatypeid-values-for-matlab-file-s-functions-in-simulink
%     -1 for 'inherited',
%     0 for 'double',
%     1 for 'single',
%     2 for 'int8',
%     3 for 'uint8',
%     4 for 'int16',
%     5 for 'uint16',
%     6 for 'int32',
%     7 for 'uint32',
%     8 for 'boolean'

global udp_handle

udp_handle = dsp.UDPReceiver('LocalIPPort', 1235, 'MaximumMessageLength', 8*4*1000, 'ReceiveBufferSize', 8192*8);


    % Setup Dwork 

%     fs = eval(get_param(gcb,'samps_per_second'));
%     
     block.NumDworks                = 2;
%     
%     
%     
    block.Dwork(1).Name            = 'byteBuffer'; 
    block.Dwork(1).Dimensions      = 2048;
    block.Dwork(1).DatatypeID      = 3; % int8 aka byte
    block.Dwork(1).Complexity      = 'Real';
    block.Dwork(1).UsedAsDiscState = true;
%     
    block.Dwork(2).Name            = 'bufferIndex'; 
    block.Dwork(2).Dimensions      = 1;
    block.Dwork(2).DatatypeID      = 0; % double
    block.Dwork(2).Complexity      = 'Real';
    block.Dwork(2).UsedAsDiscState = true;

%     
%     block.Dwork(3).Name            = 'totalSamples'; 
%     block.Dwork(3).Dimensions      = 1;
%     block.Dwork(3).DatatypeID      = 0; % double
%     block.Dwork(3).Complexity      = 'Real';
%     block.Dwork(3).UsedAsDiscState = true;
    
%     close all;



    
end



function Setup(block)

% WTF is gcb?
% this is how we get values from mask parameters
% samplesPerSymbol = eval(get_param(gcb,'SampsPerSym'));
% rotationsPerSymbol = eval(get_param(gcb,'RotationsPerSym'));
% clockFrequency = eval(get_param(gcb,'ClockUpDownFrequency'));
% dinFilterLength = eval(get_param(gcb,'FilterBufferLength'));

sampleTime = eval(get_param(gcb,'sample_time'));

block.NumInputPorts = 0;
block.NumOutputPorts = 1;

% block.InputPort(1).Complexity = 'Complex';
% block.InputPort(1).DataTypeID = 0; % 8 for boolean, 0 for double
% block.InputPort(1).SampleTime = [-1 0];
% block.InputPort(1).Dimensions = [(0.2 * fs) 1];


block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Complex';
block.OutputPort(1).SamplingMode = 'Sample';

block.OutputPort(1).SampleTime = [sampleTime 0];
% block.OutputPort(1).Dimensions = [(0.8 * fs) 1];


block.RegBlockMethod('Outputs', @Outputs);
block.RegBlockMethod('SetInputPortSampleTime', @SetInputPortSampleTime);
block.RegBlockMethod('SetOutputPortSampleTime', @SetOutputPortSampleTime);
block.RegBlockMethod('PostPropagationSetup', @PostPropagationSetup);
end

function Outputs(block)

    global udp_handle
    sampleTime = eval(get_param(gcb,'sample_time'));
    bufferIndex = block.Dwork(2).Data;
    buff = block.Dwork(1).Data;
    
    % bytesReceived = 0;

    chunk = 8;
    lowWaterMark = 16;

    if( bufferIndex < lowWaterMark )
        
        bytesReceivedLen = 0;
        while (bytesReceivedLen == 0)
            dataReceived = step(udp_handle);
            bytesReceivedLen = length(dataReceived);
        end
        
%         disp(sprintf('just got %d bytes', bytesReceivedLen));

        % if we got any bytes put them on buffer
        if( bytesReceivedLen ~= 0 )
%             disp(dataReceived);

            block.Dwork(1).Data(bufferIndex+1:bufferIndex+bytesReceivedLen) = dataReceived;

%             disp(dataReceived);

            bufferIndex = bufferIndex + bytesReceivedLen;

        end
    end
    
    if( bufferIndex > chunk )
        poppedBytes = block.Dwork(1).Data(1:chunk);
        
        % shift buffer down
        block.Dwork(1).Data(1:bufferIndex-chunk) = block.Dwork(1).Data(1+chunk:bufferIndex);
        
        % zero out what we just shifted
        block.Dwork(1).Data(bufferIndex+1-chunk:bufferIndex) = zeros(1,chunk);
        
        % update buffer pointer
        bufferIndex = bufferIndex - chunk;
        
        f1 = typecast(uint8(poppedBytes(1:4)),'single');
        f2 = typecast(uint8(poppedBytes(5:8)),'single');
        
%         disp(poppedBytes);
%         disp(f1);
%         disp(f2);
        
        block.OutputPort(1).Data = complex(double(f1),double(f2));
        
    else
        block.OutputPort(1).Data = complex(0,0);
    end

    
    % update bufferIndex dwork
    block.Dwork(2).Data = bufferIndex;
    
    

end

