function [ output ] = unrollangle( input )
%UNROLLANGLE pass the output of angle() into this to remove discontinuous
%samples

thresh = pi;

adjust = 0;

[sz,~] = size(input);

output = zeros(sz,1);

% first sample b/c loop below starts at 2
output(1) = input(1);

for index = 2:sz
    samp = input(index);
    prev = input(index-1);
    
    if(abs(samp-prev) > thresh)
        direction = 1;
        if( samp > prev )
            direction = -1;
        end
        adjust = adjust + 2*pi*direction;
    end
    
    output(index) = input(index) + adjust;
end

end

