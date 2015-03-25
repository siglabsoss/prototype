function [ dout ] = opti_comb3( )
%OPTI_COMB3 Summary of this function goes here
%   Detailed explanation goes here



samples = 25000;
fs = 25000;

global my_global_val;
global my_global_val2;

slider_input = my_global_val;
% slider_input = 3.536325e+01;

slider_input2 = my_global_val2;



% tones       = [my_global_val 20 my_global_val 40];
% toneLengths = [samples/4 samples/4 samples/4 samples/4];

tones       = [my_global_val my_global_val2 ];
toneLengths = [samples/2 samples/2];

% tones       = [slider_input slider_input+1+slider_input2 slider_input/2 slider_input+3*slider_input slider_input/2+4 slider_input+5];
% toneLengths = [samples/6 samples/6 samples/6 samples/6 samples/6 samples/6];


[~,tsz] = size(tones);

dout = zeros(0,0);

for index = 1:tsz
%     disp(tones(index));
    tone = freq_shift(ones(floor(toneLengths(index)),1), fs, tones(index));
    
    if( index ~= 1 )
        for theta = 0:pi/360:2*pi
            % rotate the first sample only
            rot = tone(1) * exp(1i*theta);
            
            % compare it to the last sample in dout
            delta = abs(angle(rot) - angle(dout(end)));
            
            % if angle error is less than 2 degrees
            if( delta < 0.5*pi/180 )
                tone = tone * exp(1i*theta);
                break;
            end
            
        end
    end
    
    dout = [dout; tone];
    
end

% dout = dout(1:24);
% [finalsz,~] = size(dout);
% 
% dout2 = interp1(1:finalsz, dout, [1:finalsz/25:24 24])' ;
% 
% dout = dout';


[finalsz,~] = size(dout);

if( finalsz ~= 25000 )
    dout = interp1(1:finalsz, dout, [1:finalsz/25000:finalsz finalsz])' ;
end

dout = dout;



end

