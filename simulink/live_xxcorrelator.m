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


    % Setup Dwork 

    fs = eval(get_param(gcb,'samps_per_second'));
    
    block.NumDworks                = 3;
    
    
    
    block.Dwork(1).Name            = 'sampleBuffer'; 
    block.Dwork(1).Dimensions      = int32(0.8 * fs);
    block.Dwork(1).DatatypeID      = 0; % double
    block.Dwork(1).Complexity      = 'Complex';
    block.Dwork(1).UsedAsDiscState = true;
    
    block.Dwork(2).Name            = 'sampleIndex'; 
    block.Dwork(2).Dimensions      = 1;
    block.Dwork(2).DatatypeID      = 0; % double
    block.Dwork(2).Complexity      = 'Real';
    block.Dwork(2).UsedAsDiscState = true;
    
    block.Dwork(3).Name            = 'totalSamples'; 
    block.Dwork(3).Dimensions      = 1;
    block.Dwork(3).DatatypeID      = 0; % double
    block.Dwork(3).Complexity      = 'Real';
    block.Dwork(3).UsedAsDiscState = true;
    
%     close all;

    
end



function Setup(block)

% WTF is gcb?
% this is how we get values from mask parameters
% samplesPerSymbol = eval(get_param(gcb,'SampsPerSym'));
% rotationsPerSymbol = eval(get_param(gcb,'RotationsPerSym'));
% clockFrequency = eval(get_param(gcb,'ClockUpDownFrequency'));
% dinFilterLength = eval(get_param(gcb,'FilterBufferLength'));

fs = eval(get_param(gcb,'samps_per_second'));

block.NumInputPorts = 1;
block.NumOutputPorts = 1;

block.InputPort(1).Complexity = 'Complex';
block.InputPort(1).DataTypeID = 0; % 8 for boolean, 0 for double
block.InputPort(1).SampleTime = [-1 0];
block.InputPort(1).Dimensions = [(0.2 * fs) 1];


block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Complex';
block.OutputPort(1).SamplingMode = 'Sample';

block.OutputPort(1).SampleTime = [0.2 0];
block.OutputPort(1).Dimensions = [(0.8 * fs) 1];


block.RegBlockMethod('Outputs', @Outputs);
block.RegBlockMethod('SetInputPortSampleTime', @SetInputPortSampleTime);
block.RegBlockMethod('SetOutputPortSampleTime', @SetOutputPortSampleTime);
block.RegBlockMethod('PostPropagationSetup', @PostPropagationSetup);
end

function Outputs(block)

fs = eval(get_param(gcb,'samps_per_second'));

inChunk = 0.2 * fs;


sampleIndex  = block.Dwork(2).Data;
totalSamples = block.Dwork(3).Data;

overwriteStart = sampleIndex + 1;
overwriteEnd = sampleIndex + inChunk;


if( totalSamples < 0.8 * fs )
    % input sampleBuffer
    block.Dwork(1).Data(overwriteStart:overwriteEnd) = block.InputPort(1).Data;
else
    block.Dwork(1).Data = [block.Dwork(1).Data(0.2*fs+1:0.8*fs); block.InputPort(1).Data];
end


% block.CurrentTime
% figure;
% plot(real(block.Dwork(1).Data))
% plot(real(block.InputPort(1).Data))



% -------------- At this point block.Dwork(1).Data has .8 seconds of the most recent data --------------






% total samples
block.Dwork(3).Data = block.Dwork(3).Data + inChunk;

% sample index
block.Dwork(2).Data = mod(block.Dwork(3).Data,0.8*fs);

% output entire buffer
block.OutputPort(1).Data = block.Dwork(1).Data;
end

