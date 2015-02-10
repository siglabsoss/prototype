% BJM: this is an example of some crazy stuff a custom block can do

function customsat_callback(action,block)
% CUSTOMSAT_CALLBACK contains callbacks for custom saturation block

%   Copyright 2003-2007 The MathWorks, Inc.

%% Use function handle to call appropriate callback
feval(action,block)

%% Upper bound callback
function upperbound_callback(block)

vals = get_param(block,'MaskValues');
vis = get_param(block,'MaskVisibilities');
portStr = {'port_label(''input'',1,''uSig'')'};
switch vals{1}
    case 'No limit'
        set_param(block,'MaskVisibilities',[vis(1);{'off'};vis(3:4)]);
    case 'Enter limit as parameter'
        set_param(block,'MaskVisibilities',[vis(1);{'on'};vis(3:4)]);
    case 'Limit using input signal'
        set_param(block,'MaskVisibilities',[vis(1);{'off'};vis(3:4)]);
        portStr = [portStr;{'port_label(''input'',2,''up'')'}];
end
if strcmp(vals{3},'Limit using input signal'),
    portStr = [portStr;{['port_label(''input'',',num2str(length(portStr)+1), ...
        ',''low'')']}];
end
set_param(block,'MaskDisplay',char(portStr));

%% Lower bound callback
function lowerbound_callback(block)

vals = get_param(block,'MaskValues');
vis = get_param(block,'MaskVisibilities');
portStr = {'port_label(''input'',1,''uSig'')'};
if strcmp(vals{1},'Limit using input signal'),
    portStr = [portStr;{'port_label(''input'',2,''up'')'}];
end

switch vals{3}
    case 'No limit'
        set_param(block,'MaskVisibilities',[vis(1:3);{'off'}]);
    case 'Enter limit as parameter'
        set_param(block,'MaskVisibilities',[vis(1:3);{'on'}]);
    case 'Limit using input signal'
        set_param(block,'MaskVisibilities',[vis(1:3);{'off'}]);
        portStr = [portStr;{['port_label(''input'',',num2str(length(portStr)+1), ...
            ',''low'')']}];
end
set_param(block,'MaskDisplay',char(portStr));

%% Upper bound parameter callback
function upperparam_callback(block)


%% Lower bound parameter callback
function lowerparam_callback(block)

