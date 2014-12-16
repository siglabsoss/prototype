% 

function mypsk(block)

Setup(block);
InitVars();

%end


function Setup(block)

block.NumInputPorts = 1;
block.NumOutputPorts = 1;

block.InputPort(1).Complexity = 'Real';
block.InputPort(1).DataTypeID = 0; % 8 for boolean, 0 for double


block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Complex';




block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);
%end

function InitVars()
    global v1 v2 MPSK;
    v1 = 0;
    v2 = 42;
    MPSK = 4;
%end


function Start(block)

%end


function Outputs(block)
global v1 v2;
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

v1 = v1 + 1;



% lowMode    = block.DialogPrm(1).Data;


%end