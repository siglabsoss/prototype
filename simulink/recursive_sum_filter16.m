function [ dout ] = recursive_sum_filter( din, k, float_scale)
%RECURSIVE_SUM_FILTER Summary of this function goes here
%   Detailed explanation goes here

sz = length(din);
dout = int16(zeros(sz,1));

kdelay = zeros(k-1,1);
div_delay = 0;

% samp = din(1);
% dout(1) = samp;

max1 = 0;
max2 = 0;

inversek = int16(round(float_scale/k));

for j=1:sz
    samp = din(j);
    
    
    
    div = complex_mult16(samp,inversek);
    
    sum1 = complex_add32(div,div_delay);
    max1 = max(abs(imag(sum1)),max(abs(real(sum1)),max1)); % diagnosis only, do not imliment
    
    sum2 = complex_sub32(sum1,kdelay(1));
    max2 = max(abs(imag(sum2)), max(abs(real(sum2)),max2)); % diagnosis only, do not imliment
    
    dout(j) = sum2;
    
    kdelay(1) = []; % destroy first value
    kdelay(end+1) = div_delay;
    
    div_delay = sum1; 
end

disp(sprintf('max in sum1 was %d', max1));
disp(sprintf('max in sum2 was %d', max2));

end

