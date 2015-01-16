function [ ] = splot( vec )
%SPLOT Summary of this function goes here
%   Detailed explanation goes here

[sz,~] = size(vec);

plot3(real(vec),imag(vec),linspace(1,sz,sz))
rotate3d on;

end

