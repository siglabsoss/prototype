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


if( iscolumn(din) )
   [sz,~] = size(din);
elseif( isrow(din) )
   din = din.';
   disp 'changing your data into column vector'
   [sz,~] = size(din);
else
    error 'din must be a vector, not a matrix'
end

% shifting by zero is a nop
if( shift == 0 )
    dout = din;
    return
end


% these 4 lines generate a pure complex sine wave FTW!
sampleInc = 1/fs * 2 * pi * shift;
endSample = (sz/fs) * 2 * pi * shift - sampleInc;
tvec = 0:sampleInc:endSample;
shiftTone = complex(cos(tvec),sin(tvec)).';

dout = shiftTone .* din;

end

