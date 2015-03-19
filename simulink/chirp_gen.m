function [ dout ] = chirp_gen( samples, fs, startHz, endHz )
%CHIRP_GEN makes a chirp of specifid sample length with given fs, 

% not used
din = ones(samples,1);


toneDelta = endHz - startHz;

tvec2 = [];

for sam=1:samples
    % I have no idea why we divide by 2 here!
    curTone = (toneDelta*((sam-1)/(samples-1))/2 + startHz);
    
    tb2 = 1/fs * 2 * pi * curTone;
    tvec2(sam) = tb2*sam;
end


dout = complex(sin(tvec2),cos(tvec2))';

end

