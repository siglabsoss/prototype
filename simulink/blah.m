function blah(block)

setup(block);

%end

% inn*5



function setup(block)

block.NumInputPorts = 1;
block.NumOutputPorts = 1;

block.InputPort(1).Complexity = 'Real';
block.InputPort(1).DataTypeID = 0; % 8 for boolean, 0 for double
% block.InputPort(1).SamplingMode = 'Sample';
% block.InputPort(1).Dimensions = 1;
% block.InputPort(1).DirectFeedthrough = 0;


block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';

% block.InputPort(2).Complexity = 'Real';
% block.InputPort(2).DataTypeId = 0;
% block.InputPort(2).SamplingMode = 'Sample';


block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);


%end


function Start(block)

%end

function Outputs(block)

inn = block.InputPort(1).Data;

block.OutputPort(1).Data = inn * 2;



% lowMode    = block.DialogPrm(1).Data;


%end