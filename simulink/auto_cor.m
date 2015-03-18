function [ score ] = auto_cor( comb )
%AUTO_COR Summary of this function goes here
%   Detailed explanation goes here

c = xcorr(comb, comb);

[a,b] = max(abs(c));

sq = c .* c;

ssum = sum(sq);

top = c(b) * c(b);

bottom = ssum - top;


score = abs(top) / abs(bottom);

% c = c ./ size(comb,2);
% c = abs(c);
% c = c .* c;
% c = sqrt(c);

% integral = sum(c) / size(comb,2);


end

