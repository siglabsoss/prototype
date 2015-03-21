function [ dout ] = opti_comb( )
%OPTI_COMB Summary of this function goes here
%   Detailed explanation goes here

samples = 25000;

% 100 is perfect slope triangle in frequency shift domain
% 400,500 is rectangle favoring frequency shift domain
% 1000 is a rectangle favoring time shift domain (bad)
stsdiv = 500;

sts = [samples/stsdiv/-2:1/stsdiv:samples/stsdiv/2];
ss = sinc(sts);

rej1 = reject_fn(25000);

% ss2 = rej1.*ss;






rej2 = reject_fn2(25000);

ss3 = rej2 .* ss;



% rej3 = reject_fn3(25000);
% 
% ss4 = rej3 .* ss3;
% 





hold on;
 plot(ss);
% plot(ss2);
plot(rej1);
plot(rej2);
plot(ss3);
% plot(rej3);
% plot(sig_normalize(ss4));
hold off;


dout = sig_normalize(ss3');

peak_ave_power(ss)
peak_ave_power(dout)



end






% randWalkMixLevel = 0.05;
% 
% rw = rand_walk(samples+1);
% 
% rwlim = bandwidth_chop(rw,25000,-1,1);
% 
% ss4 = sig_normalize(ss3) + (rwlim * randWalkMixLevel);
% 
% 
