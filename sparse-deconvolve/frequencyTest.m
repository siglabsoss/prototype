function [ score ] = frequencyTest( sparse )
%FREQUENCYTEST Summary of this function goes here
%   Detailed explanation goes here

% settings
fdev = 0.1;
fstep = fdev/33;
oversample = 10; % can also be thought of as counts per bit


% calculated
fmin = 1 - fdev;
fmax = 1 + fdev;

sparsecomb = sparse * oversample;

iterations = (fdev/fstep) * 2;

output = zeros(1,iterations);
outcount = 1;

for f = fmin:fstep:fmax
    shift = round(sparsecomb * f);
    
    
    score = crossCorRaw(sparsecomb, shift, 0);
%     disp(score);
    output(outcount) = score;
    outcount = outcount + 1;
    
%     break;
end

output = output / max(output);

plot([fmin:fstep:fmax], output );
figure
plot(output);



end

