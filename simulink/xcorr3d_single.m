function [ out ] = xcorr3d_single( data, clock_comb, fs, freqOffset, freqStep )

out = [];

index = 1;
for shift = -freqOffset:freqStep:freqOffset
    
    comb = freq_shift(clock_comb, fs, shift);
    xcr = xcorr(data, comb);
    
    xcr = downsample(xcr,4);
    out(index,:) = xcr;


    index = index + 1;
end



end

