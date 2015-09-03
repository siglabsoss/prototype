function [ dout ] = recursive_sum_filter( din, k )
%RECURSIVE_SUM_FILTER Summary of this function goes here
%   Detailed explanation goes here

sz = length(din);
dout = zeros(sz,1);

kdelay = zeros(k-1,1);
div_delay = 0;

% samp = din(1);
% dout(1) = samp;

for j=1:sz
    samp = din(j);
    
    div = samp / k;
    
    sum1 = div + div_delay;
    
    sum2 = sum1 - kdelay(1);
    
    dout(j) = sum2;
    
    kdelay(1) = []; % destroy first value
    kdelay(end+1) = div_delay;
    
    div_delay = sum1; 
end

end

