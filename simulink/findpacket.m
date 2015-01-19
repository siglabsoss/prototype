function [ output_args ] = findpacket( )

load('xcorrdata.mat');
% data
% clock_comb

[combLength,~] = size(clock_comb);

% this order matters
xcr = xcorr(clock_comb,data);

% sample at maximum
[maxVal, maxSample] = max(abs(xcr));

% xcorr returns the (last?) sample that matches, so subtract the comb
% lenght for first
startSample = maxSample - combLength;

packet = data(startSample:startSample+combLength);

% cheating
packet = data(3034:3034+combLength-1);



foo = bar;


end

