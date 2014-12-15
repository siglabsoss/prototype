function [ output_args ] = sin_table( steps )
%SIN_TABLE Summary of this function goes here
%   Detailed explanation goes here

minx = 0;
maxx = 2*pi;
inc = (maxx-minx)/steps;
x = 0;

rerange = 2^14;

disp(sprintf('\n\nconst i16 sin_lut[%d] = [\n', steps));
for i=0:(steps-1)
    y = sin(x) * rerange;
    
    y = round(y);
    
    disp(sprintf('%d,', y));
    
    x = x + inc;
end

disp(sprintf('];'));


% sin(1.3);

end

