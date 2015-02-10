% 

function mycpm(block)

Setup(block);
% we no longer call InitVars here, now it's done in InitializeConditions

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

global outSampleTime inSampleTime samplesPerSymbol clockFrequency rotationsPerSymbol dinFilterLength patternVectorDialog patternVectorRepeatDialog;


% WTF is gcb?
% this is how we get values from mask parameters
samplesPerSymbol = eval(get_param(gcb,'SampsPerSym'));
rotationsPerSymbol = eval(get_param(gcb,'RotationsPerSym'));
clockFrequency = eval(get_param(gcb,'ClockUpDownFrequency'));
dinFilterLength = eval(get_param(gcb,'FilterBufferLength'));
patternVectorDialog = eval(get_param(gcb,'PatternVectorDialog'));
patternVectorRepeatDialog = eval(get_param(gcb,'PatternVectorRepeatDialog'));

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
block.RegBlockMethod('PostPropagationSetup', @PostPropagationSetup);
block.RegBlockMethod('InitializeConditions', @InitializeConditions);
%end

function PostPropagationSetup(block)
    % http://www.mathworks.com/matlabcentral/answers/98799-what-are-the-valid-datatypeid-values-for-matlab-file-s-functions-in-simulink
    % Setup Dwork
    
    patternVectorDialog = eval(get_param(gcb,'PatternVectorDialog'));
    patternVectorRepeatDialog = eval(get_param(gcb,'PatternVectorRepeatDialog'));

    [~,sizeTemp1] = size(patternVectorDialog);

    block.NumDworks                = 1;
    
    
    
    
    block.Dwork(1).Name            = 'patternVector'; 
    block.Dwork(1).Dimensions      = sizeTemp1 * patternVectorRepeatDialog;
    block.Dwork(1).DatatypeID      = 2; % uint8
    block.Dwork(1).Complexity      = 'Real';
    block.Dwork(1).UsedAsDiscState = true;

    
%end

function InitializeConditions(block)
    InitVars(block);
%end

% called by InitializeConditions
function InitVars(block)
    global outSampleTime samplesPerSymbol totalSamples dataInt clockUpInt clockDownInt pvSize dinFilterr dinFilterLength packetLength;

    patternVectorDialog = eval(get_param(gcb,'PatternVectorDialog'));
    patternVectorRepeatDialog = eval(get_param(gcb,'PatternVectorRepeatDialog'));
    
    totalSamples = 0;
    dataInt = 0;
    clockUpInt = 0;
    clockDownInt = 0; 
    
    
    
    % repeat the pattern vector as specificed by the dialog
    patternVector = zeros(0);
    for j = 1:patternVectorRepeatDialog
        patternVector = [patternVector patternVectorDialog];
    end

    % save the full size
    [~,pvSize] = size(patternVector);
    
    
    block.Dwork(1).Data = int8(patternVector);
    

    % prepare buffer "filter"
    dinFilterr = zeros(dinFilterLength,1);
    
    % fixed packet length in seconds
    packetLength = 0.4;

    %end


function Start(block)

%end


% imaginary is up and down, is Quadrature
% real is left and right, is In-phase
  
function Outputs(block)
global outSampleTime inSampleTime samplesPerSymbol totalSamples sampleIndex dataInt clockUpInt clockDownInt patternVector pvSize dinFilterr dinFilterLength clockFrequency rotationsPerSymbol packetLength;

patternVector = block.Dwork(1).Data;

din = sum(dinFilterr)/dinFilterLength;

filterIndex = mod(totalSamples, dinFilterLength) + 1;
dinFilterr(filterIndex) = block.InputPort(1).Data; % fill into filter



currentTime = block.CurrentTime;

scaledTimeIndex = floor((currentTime / packetLength) * pvSize);

% tt = round(currentTime*10000);

% gives us a ms index
tms = floor(currentTime*10000);

% 0 1 2
modee = patternVector(mod(scaledTimeIndex,pvSize)+1);

% if( mod(tt, 1000) == 999 )
%     set_param(gcs, 'SimulationCommand', 'pause');
% end

% disp(sprintf('tms %f modee %f', tms, modee));

% mod(tt, 10000)

% 1/rotations per bit.
% each bit is 10 data points (when samplesPerSymbol is 10)
% so a clock with 1000 points for rotation would be 1/100
df = rotationsPerSymbol;
% cdf = 1/100;

cdf = outSampleTime * clockFrequency * samplesPerSymbol;


% always run clock "movies"
clockUpInt   = clockUpInt   + 1 / samplesPerSymbol;
clockDownInt = clockDownInt - 1 / samplesPerSymbol;
ddt = din / samplesPerSymbol;
dataInt = dataInt + ddt;

% Clock output port
% Switch between movies (even if discontinuous)
% Output 0 when in data mode
switch modee
    case 0
        crout = 0;
        ciout = 0;
    case 1
        crout = cos(cdf * 2 * pi * clockUpInt);
        ciout = sin(cdf * 2 * pi * clockUpInt);
    case 2
        crout = cos(cdf * 2 * pi * clockDownInt);
        ciout = sin(cdf * 2 * pi * clockDownInt);
end

% Data only output port (mostly useless)
rout = cos(df * 2 * pi * dataInt);
iout = sin(df * 2 * pi * dataInt);

% modulation output port ('t' stands for 3rd)
trout = crout;
tiout = ciout;

% 0 is data, 1 is clock up, 2 is clock down 
if( modee == 0 )
    % mode 0 so put in data
    trout = rout;
    tiout = iout;
end

if( currentTime > packetLength )
    trout = 0; % end packet
    tiout = 0;
    crout = 0;
    ciout = 0;
end



% write to block
block.OutputPort(1).Data = complex(rout,iout);
block.OutputPort(2).Data = complex(crout,ciout);
block.OutputPort(3).Data = complex(trout,tiout);


totalSamples = totalSamples + 1;

%end