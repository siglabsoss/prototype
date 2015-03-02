% Level-2 MATLAB file S-Function for inphase quadrature carrier generation.
%   Copyright 2015 Signal Laboratories, Inc.


function complex_source(block)

 %% Setup S-Function block
  Setup(block);

%endfunction


function Setup(block)

  %% Register number of dialog parameters   
  block.NumDialogPrms = 2;
  
  % block.SetPreCompInpPortInfoToDynamic;
  % block.SetPreCompOutPortInfoToDynamic;

  %% Register number of input and output ports
  block.NumInputPorts = 0;
  block.NumOutputPorts = 1;

  block.OutputPort(1).DatatypeID  = 0; % double
  block.OutputPort(1).Complexity  = 'Complex';
  block.OutputPort(1).SamplingMode = 'Sample';

  %% Register methods
  block.RegBlockMethod('Outputs', @Outputs);
  block.RegBlockMethod('CheckParameters',      @CheckPrms);
  block.RegBlockMethod('ProcessParameters',    @ProcessPrms);
  block.RegBlockMethod('InitializeConditions', @InitConditions);
  block.RegBlockMethod('PostPropagationSetup', @DoPostPropSetup);
  
  %% Set sample time
  SampleTime = block.DialogPrm(2).Data;
  block.SampleTimes = [SampleTime 0];

%endfunction

function DoPostPropSetup(block)

 %% Initialize block workspace
    block.NumDworks                = 1;
        
    block.Dwork(1).Name            = 'Freq'; 
    block.Dwork(1).Dimensions      = 1;
    block.Dwork(1).DatatypeID      = 0; % double
    block.Dwork(1).Complexity      = 'Real';
    block.Dwork(1).UsedAsDiscState = true;

%end function


function InitConditions(block)

  %% Initialize settings
  block.Dwork(1).Data = block.DialogPrm(1).Data;

%end function


function CheckPrms(block)

%end function


function ProcessPrms(block)

% end function


% function DoPostPropSetup(block)

% end function

  
function Outputs(block)

  %% Initialize function variables

  t = block.CurrentTime;
  Freq = block.Dwork(1).Data;

  %% write to block
  block.OutputPort(1).Data = 1i * sin(Freq * t) + cos(Freq * t);

%end
