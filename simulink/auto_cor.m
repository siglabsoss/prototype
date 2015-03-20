function [ score ] = auto_cor( comb, snr )
%AUTO_COR Summary of this function goes here
%   Detailed explanation goes here

% normalize comb (so largest value is 1)
comb = comb .* (1/max(abs(comb)));



combb = comb;

if( nargin > 1 )
    combb = awgn(comb,snr); %white noise
end



c = xcorr(comb, combb);

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

