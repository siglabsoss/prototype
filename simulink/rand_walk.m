function [ dout ] = rand_walk( samples )
%RAND_WALK random walk min, -1 max 1
%   Detailed explanation goes here

soften = 7;

% if x walks over bounds, a value of 1 will pin x at the rail
% a value of 2 will bounce back over the ammount that was violated
%   x was 0.9
%   x is added to 1.4
%   final value is:  1.4 - (1.4-1)*bounce
bounce = 1;

dout = [];
x = 0;
for i = 1:samples
        random = (rand(1, 1)*2 - 1)/soften;
        x = x + random;
        
        if( x > 1 )
            delta = x - 1;
            x = x - delta*bounce;
        end
        
        if( x < -1 )
            delta = -1 - x;
            x = x + delta*bounce;
        end
        
        dout(i) = x;
end


end

