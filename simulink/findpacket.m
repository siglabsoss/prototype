function [ packet, startSample ] = findpacket(clock_comb, data )

% load('xcorrdata.mat');
% data
% data1
% clock_comb

[combLength,~] = size(clock_comb);

% this order matters, data first (longer) for a positive value of lag
[xcr, lag] = xcorr(data,clock_comb);

% sample at maximum
[maxVal, maxSample] = max(abs(xcr));

% lag between comb and sample at max
startSample = lag(maxSample);

packet = data(startSample:startSample+combLength);
