function [ dout ] = sig_agc( din )
%SIG_AGC Summary of this function goes here
%   Detailed explanation goes here

segments = 20000;

[sz,~] = size(din);

samps = floor(sz/segments)


dout = zeros(sz,1);

for index = 1:segments
    startSamp = (index-1)*samps + 1;
    endSamp = startSamp + samps;
    
    data = din(startSamp:endSamp);
    
    maxVal = max(abs(data));
    dataNorm = data / maxVal; 


    dout(startSamp:endSamp) = dataNorm;
end

