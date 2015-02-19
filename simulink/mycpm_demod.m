% 

function mycpm_demod(block)

Setup(block);
% we no longer call InitVars here, now it's now called InitializeConditions

%end

% called for every input port
function SetInputPortSampleTime(block, portNumber, time)

global demodOutSampleTime demodInSampleTime demodSamplesPerSymbol;

% first set our sample time to what the engine requested
block.InputPort(1).SampleTime = time;

% then set the output
demodInSampleTime = time(1);
demodOutSampleTime = demodInSampleTime * demodSamplesPerSymbol;

% block.OutputPort(1).SampleTime = [0.05 0.05];
block.OutputPort(1).SampleTime = [demodOutSampleTime 0];
block.OutputPort(2).SampleTime = [demodOutSampleTime 0];
% block.OutputPort(3).SampleTime = [demodOutSampleTime 0];



%end

function SetInputPortSamplingMode(block, port, mode)
% When a Level-2 MATLAB S-function with multiple output ports has dynamic sampling mode setting for any of its ports, it is necessary to register a 'SetInputPortSamplingMode' method
block.InputPort(port).SamplingMode = 0; % 0 = sample 1 = frame
%end

function SetOutputPortSampleTime(block, portNumber, time)
%end


function Setup(block)

global demodOutSampleTime demodInSampleTime demodSamplesPerSymbol demodRotationsPerSymbol;


% WTF is gcb?
% this is how we get values from mask parameters
demodSamplesPerSymbol = eval(get_param(gcb,'SampsPerSym'));
demodRotationsPerSymbol = eval(get_param(gcb,'RotationsPerSym'));


% aa = block.DialogPrm(1).Data;
% bb = block.DialogPrm(2).Data;
% cc = block.DialogPrm(3).Data;

block.NumInputPorts = 1;
block.NumOutputPorts = 2;

block.InputPort(1).DataTypeID = 0; % 8 for boolean, 0 for double
block.InputPort(1).Complexity = 'Complex';
% block.InputPort(1).SampleTime = [.1 .1/2];
block.InputPort(1).SampleTime = [-1 0];


block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';
block.OutputPort(1).SamplingMode = 'Sample';

block.OutputPort(2).DatatypeID  = 0; % double
block.OutputPort(2).Complexity  = 'Real';
block.OutputPort(2).SamplingMode = 'Sample';

% block.OutputPort(3).DatatypeID  = 0; % double
% block.OutputPort(3).Complexity  = 'Complex';
% block.OutputPort(3).SamplingMode = 'Sample';




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
    global demodOutSampleTime demodSamplesPerSymbol demodTotalSamples dataInt clockUpInt clcokDownInt demodPreviousSample demodAngleAdjust demodPreviousSampleAngle demodPreviousBuffer demodPvSize demodPacketLength;
    
    patternVectorDialog = eval(get_param(gcb,'PatternVectorDialog'));
    patternVectorRepeatDialog = eval(get_param(gcb,'PatternVectorRepeatDialog'));
    
    
    demodTotalSamples = 0;
    dataInt = 0;
    clockUpInt = 0;
    clcokDownInt = 0;
    demodAngleAdjust = 0;

    % repeat the pattern vector as specificed by the dialog
    patternVector = zeros(0);
    for j = 1:patternVectorRepeatDialog
        patternVector = [patternVector patternVectorDialog];
    end

    % save the full size
    [~,demodPvSize] = size(patternVector);


    block.Dwork(1).Data = int8(patternVector);

    demodPreviousSample = 0;
    demodPreviousSampleAngle = 0;

    demodPreviousBuffer = zeros(0);
    
    % fixed packet length in seconds
    demodPacketLength = 0.4;

%end


function Start(block)

%end


% imaginary is up and down, is Quadrature
% real is left and right, is In-phase
  
function Outputs(block)
global demodSamplesPerSymbol demodTotalSamples demodPreviousSample demodAngleAdjust demodPreviousSampleAngle demodPreviousBuffer demodPvSize demodPacketLength;


%%% Pattern vector stuff
currentTime = block.CurrentTime;

scaledTimeIndex = floor((currentTime / demodPacketLength) * demodPvSize);

patternVector = block.Dwork(1).Data;
% 0 1 2
modee = patternVector(mod(scaledTimeIndex,demodPvSize)+1);
%%%


sample = block.InputPort(1).Data;

sampleAngle = angle(sample);

if( demodTotalSamples == 0 )
    demodPreviousSample = sampleAngle;
    demodPreviousSampleAngle = sampleAngle;
end

thresh = pi;

if(abs(sampleAngle-demodPreviousSample) > thresh)
    direction = 1;
    if( sampleAngle > demodPreviousSample )
        direction = -1;
    end
    demodAngleAdjust = demodAngleAdjust + 2*pi*direction;
end

% unrolled angle
sampleAngle = sampleAngle + demodAngleAdjust;

% diff(unrolled angle)
sampleDiff = sampleAngle - demodPreviousSampleAngle;

bufferIndex = mod(demodTotalSamples, demodSamplesPerSymbol) +1;

demodPreviousBuffer(bufferIndex) = sampleDiff;

if( bufferIndex == demodSamplesPerSymbol )
    
    % look at buffer and make our decision
    bit = -1;
    
    if( (sum(demodPreviousBuffer) / demodSamplesPerSymbol) > 0 )
        bit = 1;
    end
    
    % only output data if demodulating data
    if( modee == 0 )
        block.OutputPort(1).Data = bit;
    else
        % output an unrealstic number so we can remove this samples later
        block.OutputPort(1).Data = -2;
    end
end



block.OutputPort(2).Data = sampleAngle;





demodTotalSamples = demodTotalSamples + 1;

% need to save angle of previous sample without adjustments that
% have already been rolled into sampleAngle (aka dont use sampleAngle here)
demodPreviousSample = angle(sample);

demodPreviousSampleAngle = sampleAngle;

%end