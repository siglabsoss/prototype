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


function Setup(block)

fs = 125000;

% WTF is gcb?
% this is how we get values from mask parameters
% samplesPerSymbol = eval(get_param(gcb,'SampsPerSym'));
% rotationsPerSymbol = eval(get_param(gcb,'RotationsPerSym'));
% clockFrequency = eval(get_param(gcb,'ClockUpDownFrequency'));
% dinFilterLength = eval(get_param(gcb,'FilterBufferLength'));

block.NumInputPorts = 1;
block.NumOutputPorts = 1;

block.InputPort(1).Complexity = 'Complex';
block.InputPort(1).DataTypeID = 0; % 8 for boolean, 0 for double
block.InputPort(1).SampleTime = [-1 0];
block.InputPort(1).Dimensions = [(0.3 * fs) 1];


block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Complex';
block.OutputPort(1).SamplingMode = 'Sample';

block.OutputPort(1).SampleTime = [(0.8 * fs) 0];
block.OutputPort(1).Dimensions = [(0.8 * fs) 1];



% block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);
block.RegBlockMethod('SetInputPortSampleTime', @SetInputPortSampleTime);
block.RegBlockMethod('SetOutputPortSampleTime', @SetOutputPortSampleTime);
% block.RegBlockMethod('SetInputPortSamplingMode', @SetInputPortSamplingMode);
% block.RegBlockMethod('PostPropagationSetup', @PostPropagationSetup);
% block.RegBlockMethod('InitializeConditions', @InitializeConditions);
end

function Outputs(block)

fs = 125000;

block.OutputPort(1).Data = zeros((0.8 * fs),1);
end

