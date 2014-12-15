function [ vec ] = ft( )
%FT Summary of this function goes here
%   Detailed explanation goes here

steps = 1024;


minx = 0;
maxx = 2*pi;
inc = (maxx-minx)/steps;
x = 0;

rerange = 1;

vec = zeros(1,steps);

% disp(sprintf('\n\nconst i16 sin_lut[%d] = [\n', steps));
for i=0:(steps-1)
    y = sin(x) * rerange;
    
    vec(i+1) = y;
    
    y = round(y);
    
%     disp(sprintf('%d,', y));
    
    x = x + inc;
end

% disp(sprintf('];'));

disp(vec);


% sin(1.3);

end

