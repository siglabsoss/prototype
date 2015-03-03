% Level-2 MATLAB file S-Function for inphase quadrature carrier generation.
%   Copyright 2015 Signal Laboratories, Inc.


function mr_cpm_mod1(block)

 %% Setup S-Function block
  Setup(block);

%endfunction


function Setup(block)

  %% Register number of dialog parameters   
  block.NumDialogPrms = 0;
  
  % block.SetPreCompInpPortInfoToDynamic;
  % block.SetPreCompOutPortInfoToDynamic;

  %% Register number of input and output ports
  block.NumInputPorts = 1;
  block.NumOutputPorts = 1;

  block.InputPort(1).Complexity = 'Real';
  block.InputPort(1).DataTypeID = 0; % 8 for boolean, 0 for double

  block.OutputPort(1).DatatypeID  = 0; % double
  block.OutputPort(1).Complexity  = 'Complex';
  block.OutputPort(1).SamplingMode = 'Sample';

  %% Register methods
  block.RegBlockMethod('Outputs', @Outputs);
  block.RegBlockMethod('CheckParameters',        @CheckPrms);
  block.RegBlockMethod('ProcessParameters',      @ProcessPrms);
  block.RegBlockMethod('InitializeConditions',   @InitConditions);
  block.RegBlockMethod('PostPropagationSetup',   @DoPostPropSetup);
  % block.RegBlockMethod('SetInputPortSampleTime', @InitInputSampleTime);
  % block.RegBlockMethod('SetOutputPortSampleTime',@InitOutputSampleTime);
  
%endfunction

function InitOutputSampleTime(block)

%end function

function InitInputSampleTime(block)

%end function

function DoPostPropSetup(block)

 %% Initialize block workspace
    block.NumDworks                = 1;
        
    block.Dwork(1).Name            = 'theta_prime'; 
    block.Dwork(1).Dimensions      = 1;
    block.Dwork(1).DatatypeID      = 0; % double
    block.Dwork(1).Complexity      = 'Real';
    block.Dwork(1).UsedAsDiscState = true;

%end function


function InitConditions(block)

  %% Initialize settings
  % block.Dwork(1).Data = block.DialogPrm(1).Data;

%end function


function CheckPrms(block)

%end function


function ProcessPrms(block)

% end function


% function DoPostPropSetup(block)

% end function

  
function Outputs(block)
global theta_prime;

  %% Initialize function variables
  t = block.CurrentTime;
  input = block.InputPort(1).Data; % fill into filter
  
  %% Do the math
  Df = 2 * pi; % frequency deviation
  theta = Df * real(input) + theta_prime; % integrate
  theta_prime = theta;
  output = 1i .* sin(theta) + cos(theta);

  %% write to block
  block.OutputPort(1).Data = output;

%end






