function [ ] = ldpcgendig()
%LDPCGENDIG Summary of this function goes here
%   Detailed explanation goes here


n = 160;
k = 8;

% n = 17600;
% k = 176;

quiet = 0;


onesrangemax = 8; %round(n/8);
onesrangemin = 2;
% rndstate = [1, 2, 3, 4];

valid = 0;
while( ~valid )

rndstate = randi(4294967295, 1, 4);  % uint32_t max in a 1 by 4 vector
maxonecols = 3;%randi(onesrangemax-1,1)+1;  % in the onesrangemax
minonecols = 1;%randi(onesrangemin); %1;%randi(maxonecols,1,1);        % less then that

% disp(maxonecols);
% disp(minonecols);

disp(sprintf('try ldpcgengen(%d, %d, %d, %d, [%d %d %d %d])', n, k, minonecols, maxonecols, rndstate));

[~,~,valid] = ldpcgengen( n, k, minonecols, maxonecols, rndstate, quiet );



end

disp(sprintf('got result with ldpcgengen(%d, %d, %d, %d, [%d %d %d %d])', n, k, minonecols, maxonecols, rndstate));

% valid


end

