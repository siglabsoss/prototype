function [ out ] = xcorr3d( data, clock_comb, fs)

% plus and minus this value
freqOffset = 550;
freqStep = 0.4;

freqStep = 1;

% chunk size in seconds
chunkSizeSeconds = 0.4;
chunkSizeSamples = chunkSizeSeconds * fs;



[sz,~] = size(data);

sampleVec = 1:chunkSizeSamples:sz-chunkSizeSamples+1;


for startSample = sampleVec
    
    endSample = startSample + chunkSizeSamples;
    endSample = min(endSample,sz);

    xcorrout = xcorr3d_single( data(startSample:endSample), clock_comb, fs, freqOffset, freqStep );

    % take the maximum in this direction (along frequency)
    [a,b] = max(abs(xcorrout),[],2);

    figure;plot(a);

    % find the maximum frequency
    [c,d] = max(a);
end



%xcorr3d_single uses this method to choose frequencies
vec = [-freqOffset:freqStep:freqOffset];


end

