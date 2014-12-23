% 

function mypsk(block)

Setup(block);
InitVars();

%end

% called for every input port
function SetInputPortSampleTime(block, portNumber, time)

global outSampleTime inSampleTime samplesPerSymbol;

% first set our sample time to what the engine requested
block.InputPort(1).SampleTime = time;

% then set the output
inSampleTime = time(1);
outSampleTime = inSampleTime / samplesPerSymbol;

% block.OutputPort(1).SampleTime = [0.05 0.05];
block.OutputPort(1).SampleTime = [outSampleTime 0];

disp(1);

%end

function SetOutputPortSampleTime(block, portNumber, time)
%end


function Setup(block)

global outSampleTime inSampleTime samplesPerSymbol;


% WTF is gcb?
% this is how we get values from mask parameters
samplesPerSymbol = eval(get_param(gcb,'SampsPerSym'));


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





block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);
block.RegBlockMethod('SetInputPortSampleTime', @SetInputPortSampleTime);
block.RegBlockMethod('SetOutputPortSampleTime', @SetOutputPortSampleTime);
%end

function InitVars()
    global v1 v2 MPSK outSampleTime samplesPerSymbol totalSamples outputHold outputHoldPrev;
    v1 = 0;
    v2 = 42;
    MPSK = 4;
    totalSamples = 0;
%     outputHold = 0;
%     outputHoldPrev = 0;
%end


function Start(block)

%end

  
function Outputs(block)
global v1 v2 MPSK outSampleTime inSampleTime samplesPerSymbol totalSamples outputHold outputHoldPrev sampleIndex;
din = block.InputPort(1).Data;

currentTime = block.CurrentTime;

switch din
    case 0
        dinMapped = [0.707106781186548 + 0.707106781186548i];
    case 1
        dinMapped = [-0.707106781186548 + 0.707106781186548i];  % first
    case 2
        dinMapped = [-0.707106781186548 - 0.707106781186548i];  % second
    case 3
        dinMapped = [0.707106781186547 - 0.707106781186548i];
    otherwise
        dinMapped = [0.707106781186547 - 0.707106781186548i];
end

% run once
if totalSamples == 0
    outputHoldPrev = dinMapped;
    outputHold = dinMapped;
end

if sampleIndex == (samplesPerSymbol-1)
    outputHoldPrev = outputHold;
    outputHold = dinMapped;
end


sampleIndex = mod(totalSamples, samplesPerSymbol);


% how much of the first and second samples we are blending
alpha = (samplesPerSymbol-sampleIndex) / (samplesPerSymbol);
beta = 1 - alpha;

% blend samples
dout = alpha * outputHoldPrev + beta * outputHold;

% write to block
block.OutputPort(1).Data = dout;


totalSamples = totalSamples + 1;

%end