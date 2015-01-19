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

global outSampleTime inSampleTime samplesPerSymbol pattern patternCount;


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


LoadPattern();




function LoadPattern()

global outSampleTime inSampleTime samplesPerSymbol pattern patternCount;

% pattern taken from http://bmx-pointtool.meteor.com/ with min/max of 200
% pattern = [[-198,-197],[-7,-197],[197,-200],[201,-3],[199,195],[0,195],[-197,197],[-203,-1],[-198,-197],[0,-1],[200,194],[199,-4],[196,-200]];

% pattern = [[-198,-197],[197,-200],[199,195],[-197,197],[-198,-197],[200,194],[196,-200]];

% unrolled optimized
% pattern = [[-199,-199],[-199,-199],[199,-199],[199,-198],[199,199],[197,199],[-199,199],[-200,198],[198,198],[199,-199],[-200,-200],[198,197],[-201,-199],[-200,195],[198,-197],[-200,197]];

% unrolled optimized with correct bit position
pattern = [[199,-199],[-199,-199],[-199,-199],[-199,199],[-199,199],[199,199],[199,199],[-199,199],[-199,-199],[199,-199],[-199,199],[199,-199],[199,199],[-199,-199],[199,199]];



% reshape because matlab doesn't understand copy pasta from json 
elements = size(pattern);
elements = elements(2)/2;
pattern = reshape(pattern, [2,elements]);
pattern = pattern';

% remap to sqrt(2)/2
pattern = pattern / 200 * (sqrt(2)/2);


[patternCount ~] = size(pattern);


%end

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
global v1 v2 MPSK outSampleTime inSampleTime samplesPerSymbol totalSamples outputHold outputHoldPrev sampleIndex pattern patternCount;
din = block.InputPort(1).Data;

LoadPattern();

sampleIndex = mod(totalSamples, patternCount);

rreal = pattern(sampleIndex+1,1);
iimag = pattern(sampleIndex+1,2);

% flip y axis
dout = rreal + iimag * -1i;

% write to block
block.OutputPort(1).Data = dout;


totalSamples = totalSamples + 1;

%end