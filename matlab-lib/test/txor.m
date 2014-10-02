function [ v ] = txor( iterations )
%TXOR test xor128, returns vector v of length iterations with random number
% output from xor128

% output
v = zeros(iterations,1);

state = [123456789, 362436069, 521288629, 88675123];


i = 1;

while i <= iterations
    disp(i);
    
    [t,state] = xor128(state);
    v(i) = t;
    
    i = i + 1;
end

