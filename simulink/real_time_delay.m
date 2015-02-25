function real_time_delay(block)

Setup(block);


function Setup(block)

global rtdTotalSamples

rtdTotalSamples = 0;


block.NumInputPorts = 0;
block.NumOutputPorts = 1;


block.OutputPort(1).DatatypeID  = 2; % int8
block.OutputPort(1).Complexity  = 'Real';
block.OutputPort(1).SamplingMode = 'Sample';
% sample time of 0.1 means that we cannot control delay for the first 0.1
% seconds of the simulation.  Setting it lower will reduce this slop.
% However, setting sample rate too low bogs down simulation
block.OutputPort(1).SampleTime = [0.1,0];


block.RegBlockMethod('Outputs', @Outputs);
block.RegBlockMethod('SetOutputPortSampleTime', @SetOutputPortSampleTime);
% %end




function SetOutputPortSampleTime(block, portNumber, time)
%end


  
function Outputs(block)
global rtdTotalSamples rtdStartTime

    timeDelay = eval(get_param(gcb,'TimeDelay')) - 0.1;  % tweak for first sample time
  
    if( rtdTotalSamples == 0 )
        rtdStartTime = now;
        rtdTotalSamples = rtdTotalSamples + 1;
    end

    
    deltaT = 0;
    
    
    while( deltaT < timeDelay ) % && index < 10000
        % what the hell time scale is this!?
        deltaT = (now - rtdStartTime) * 1000 * 100 * 0.86 ;
%         index = index + 1;
    end
   
    block.OutputPort(1).Data = int8(0);




















% totalSamples = totalSamples + 1;

%end