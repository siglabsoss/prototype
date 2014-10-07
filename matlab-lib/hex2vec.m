function [ vec ] = hex2vec( hex )
%HEX2VEC Summary of this function goes here
%   Detailed explanation goes here

[~,s] = size(hex);

vec = zeros(1,s*4);
j = 1;
for i=1:s
    
    character = hex2dec(hex(i));
    bitsvec = de2bi(character);
    bitsvec = bitsvec(end:-1:1); % reverse
    [~,bitssize] = size(bitsvec);
    
    % pad leading zeros 
    bitsvec = [zeros(1,4-bitssize) bitsvec];
    
    vec(j:j+3) = bitsvec;
    j = j + 4;
end


end


% wrong answer I think:
% de2bi(hex2dec('ffffdeaddffdea77777'))
