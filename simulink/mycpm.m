% 

function mycpm(block)

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
block.OutputPort(2).SampleTime = [outSampleTime 0];
block.OutputPort(3).SampleTime = [outSampleTime 0];



%end

function SetInputPortSamplingMode(block, port, mode)
% When a Level-2 MATLAB S-function with multiple output ports has dynamic sampling mode setting for any of its ports, it is necessary to register a 'SetInputPortSamplingMode' method
block.InputPort(1).SamplingMode = 0; % 0 = sample 1 = frame
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
block.NumOutputPorts = 3;

block.InputPort(1).Complexity = 'Real';
block.InputPort(1).DataTypeID = 0; % 8 for boolean, 0 for double
% block.InputPort(1).SampleTime = [.1 .1/2];
block.InputPort(1).SampleTime = [-1 0];


block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Complex';
block.OutputPort(1).SamplingMode = 'Sample';

block.OutputPort(2).DatatypeID  = 0; % double
block.OutputPort(2).Complexity  = 'Complex';
block.OutputPort(2).SamplingMode = 'Sample';

block.OutputPort(3).DatatypeID  = 0; % double
block.OutputPort(3).Complexity  = 'Complex';
block.OutputPort(3).SamplingMode = 'Sample';




block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);
block.RegBlockMethod('SetInputPortSampleTime', @SetInputPortSampleTime);
block.RegBlockMethod('SetOutputPortSampleTime', @SetOutputPortSampleTime);
block.RegBlockMethod('SetInputPortSamplingMode', @SetInputPortSamplingMode);
%end

function InitVars()
    global v1 v2 MPSK outSampleTime samplesPerSymbol totalSamples outputHold outputHoldPrev dataInt clockUpInt clcokDownInt df patternVector;
    v1 = 0;
    v2 = 42;
    MPSK = 4;
    totalSamples = 0;
    dataInt = 0;
    clockUpInt = 0;
    clcokDownInt = 0; 
    
    % 0 is data, 1 is clock up, 2 is clock down
    pv = [ones(1,300)*1 ones(1,300)*2 ones(1,400)*0 ones(1,500)*2 ones(1,500)*1];
    
    patternVector = [pv pv];

%end

    df = 100;


function Start(block)

%end


% imaginary is up and down, is Quadrature
% real is left and right, is In-phase
  
function Outputs(block)
global v1 v2 MPSK outSampleTime inSampleTime samplesPerSymbol totalSamples outputHold outputHoldPrev sampleIndex dataInt clockUpInt clcokDownInt df patternVector;
din = block.InputPort(1).Data;

currentTime = block.CurrentTime;

tt = round(currentTime*10000);

% gives us a ms index
tms = floor(currentTime*10000);

% 0 1 2
modee = patternVector(mod(tms,4000)+1);

% if( mod(tt, 1000) == 999 )
%     set_param(gcs, 'SimulationCommand', 'pause');
% end

% disp(sprintf('tms %f modee %f', tms, modee));

% mod(tt, 10000)

% 1/rotations per bit.
% each bit is 10 data points (when samplesPerSymbol is 10)
% so a clock with 1000 points for rotation would be 1/100
df = 1;
cdf = 1/100;


switch modee
    case 0
        cdin = 0;
    case 1
        cdin = 1;
    case 2
        cdin = -1;
end

cdt = cdin / samplesPerSymbol;
clockUpInt = clockUpInt + cdt;
ddt = din / samplesPerSymbol;
dataInt = dataInt + ddt;

crout = cos(cdf * 2 * pi * clockUpInt);
ciout = sin(cdf * 2 * pi * clockUpInt);

rout = cos(df * 2 * pi * dataInt);
iout = sin(df * 2 * pi * dataInt);

trout = crout;
tiout = ciout;

if( modee == 0 )
    trout = rout;
    tiout = iout;
end


sampleIndex = mod(totalSamples, samplesPerSymbol);

% how much of the first and second samples we are blending
% alpha = (samplesPerSymbol-sampleIndex) / (samplesPerSymbol);
% beta = 1 - alpha;

% % blend samples
% dout = alpha * outputHoldPrev + beta * outputHold;

% write to block
block.OutputPort(1).Data = complex(rout,iout);
block.OutputPort(2).Data = complex(crout,ciout);
block.OutputPort(3).Data = complex(trout,tiout);


totalSamples = totalSamples + 1;

%end