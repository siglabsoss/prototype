function [ result ] = ldpccheck( H, cw )
%LDPCCHECK Summary of this function goes here
%   Detailed explanation goes here

result = mod(H * cw',2);


end

