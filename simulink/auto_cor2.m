function [ integral ] = auto_cor2( comb )
%AUTO_COR Summary of this function goes here
%   Detailed explanation goes here

c = xcorr(comb, comb);

c = c ./ size(comb,2);
c = abs(c);
% c = c .* c;
% c = sqrt(c);

integral = sum(c) / size(comb,2);


end

