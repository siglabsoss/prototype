function [ out ] = xcorr3d_single( data, clock_comb, fs, freqOffset, freqStep, downSample )

if( nargin < 6 )
    downSample = 32;
end

out = [];

index = 1;
for shift = -freqOffset:freqStep:freqOffset
    
    comb = freq_shift(clock_comb, fs, shift);
    xcr = xcorr(data, comb);
    
    if( downSample > 1 )
        xcr = downsample(xcr,downSample);
    end
    out(index,:) = xcr;


    index = index + 1;
end



end

