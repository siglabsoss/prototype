% 

function mypsk(block)

Setup(block);
InitVars();

%end

% called for every input port
function SetInputPortSampleTime(block, portNumber, time)

global OutSamTime InSamTime SampsPerSym;

% first set our sample time to what the engine requested
block.InputPort(1).SampleTime = time;

% then set the output
InSamTime = time(1);
OutSamTime = InSamTime / SampsPerSym;

block.OutputPort(1).SampleTime = [OutSamTime 0];

disp(1);

%end

function SetOutputPortSampleTime(block, portNumber, time)
%end


function Setup(block)

global OutSamTime InSamTime SampsPerSym;


% WTF is gcb?
% this is how we get values from mask parameters
% OutSamTime = eval(get_param(gcb,'OutSamTime'));
SampsPerSym = eval(get_param(gcb,'SampsPerSym'));


% aa = block.DialogPrm(1).Data;
% bb = block.DialogPrm(2).Data;
% cc = block.DialogPrm(3).Data;

block.NumInputPorts = 1;
block.NumOutputPorts = 1;

block.InputPort(1).Complexity = 'Real';
block.InputPort(1).DataTypeID = 0; % 8 for boolean, 0 for double
block.InputPort(1).SampleTime = [-1 0];


block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Complex';





block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);
block.RegBlockMethod('SetInputPortSampleTime', @SetInputPortSampleTime);
block.RegBlockMethod('SetOutputPortSampleTime', @SetOutputPortSampleTime);
%end

function InitVars()
    global v1 v2 MPSK OutSamTime SampsPerSym;
    v1 = 0;
    v2 = 42;
    MPSK = 4;
%end


function Start(block)

%end


function Outputs(block)
global v1 v2 MPSK OutSamTime SampsPerSym;
din = block.InputPort(1).Data;

switch din
    case 0
        dout = [0.707106781186548 + 0.707106781186548i];
    case 1
        dout = [-0.707106781186548 + 0.707106781186548i];
    case 2
        dout = [-0.707106781186548 - 0.707106781186548i];
    case 3
        dout = [0.707106781186547 - 0.707106781186548i];
    otherwise
        dout = [0.707106781186547 - 0.707106781186548i];
end




% block.OutputPort(1).Data = inn * 2;
block.OutputPort(1).Data = dout; %[0.707106781186548 + 0.707106781186548i];

% block.OutputPort(1).Data = 0;

v1 = v1 + 1;



% lowMode    = block.DialogPrm(1).Data;


%end