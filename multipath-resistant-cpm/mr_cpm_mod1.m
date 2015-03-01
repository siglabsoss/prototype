% 

function mr_cpm_mod1(block)

Setup(block);
% we no longer call InitVars here, now it's now called InitializeConditions

%end

% called for every input port
function SetInputPortSampleTime(block, portNumber, time)


% first set our sample time to what the engine requested
block.InputPort(1).SampleTime = time;

block.OutputPort(1).SampleTime = [time(1), 0];




%end

function SetInputPortSamplingMode(block, port, mode)
% When a Level-2 MATLAB S-function with multiple output ports has dynamic sampling mode setting for any of its ports, it is necessary to register a 'SetInputPortSamplingMode' method
block.InputPort(1).SamplingMode = 0; % 0 = sample 1 = frame
%end

function SetOutputPortSampleTime(block, portNumber, time)
%end


function Setup(block)


% aa = block.DialogPrm(1).Data;
% bb = block.DialogPrm(2).Data;
% cc = block.DialogPrm(3).Data;

block.NumInputPorts = 1;
block.NumOutputPorts = 1;

block.InputPort(1).Complexity = 'Real';
block.InputPort(1).DataTypeID = 0; % 8 for boolean, 0 for double
% block.InputPort(1).SampleTime = [.1 .1/2];
block.InputPort(1).SampleTime = [-1 0];


block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Complex';
block.OutputPort(1).SamplingMode = 'Sample';





block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);
block.RegBlockMethod('SetInputPortSampleTime', @SetInputPortSampleTime);
block.RegBlockMethod('SetOutputPortSampleTime', @SetOutputPortSampleTime);
block.RegBlockMethod('SetInputPortSamplingMode', @SetInputPortSamplingMode);
block.RegBlockMethod('PostPropagationSetup', @PostPropagationSetup);
block.RegBlockMethod('InitializeConditions', @InitializeConditions);
%end

function PostPropagationSetup(block)
 

    
%end

% called by InitializeConditions
function InitializeConditions(block)
    

    %end


function Start(block)

%end


% imaginary is up and down, is Quadrature
% real is left and right, is In-phase
  
function Outputs(block)
global outSampleTime inSampleTime samplesPerSymbol totalSamples sampleIndex dataInt clockUpInt clockDownInt patternVector pvSize dinFilterr dinFilterLength clockFrequency rotationsPerSymbol packetLength;


a = block.InputPort(1).Data; % fill into filter

% scale to full rotation
a = a * 10 * 2 * pi;


% write to block
block.OutputPort(1).Data = i * sin(a) + cos(a);



%end