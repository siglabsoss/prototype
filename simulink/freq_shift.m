function [ dout ] = freq_shift( din, fs, shift )
%FREQ_SHIFT shifts complex data up or down
%   Din is the data input
%   fs is the samples per second
%   shift is the positive or negative frequency to shift
%
%   This fn can also be used to generate a pure wave like this:
%     freq_shift( ones(40000,1), 100000, 10)
%   will generate a .4 second long vector at 100k samples per second with
%   a +10 hz tone

% shifting by zero is a nop
if( shift == 0 )
    dout = din;
    return
end

[sz,~] = size(din);

% these 4 lines generate a pure complex sine wave FTW!
sampleInc = 1/fs * 2 * pi * shift;
endSample = (sz/fs) * 2 * pi * shift - sampleInc;
tvec = 0:sampleInc:endSample;
shiftTone = complex(sin(tvec),cos(tvec))';

dout = shiftTone .* din;

end

