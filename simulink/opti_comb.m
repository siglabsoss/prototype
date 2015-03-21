function [ dout ] = opti_comb( )
%OPTI_COMB Summary of this function goes here
%   Detailed explanation goes here

samples = 25000;

sts = [-125:0.01:125];

ss = sinc(sts);
ss2 = reject_fn(25000).*ss;

peak_ave_power(ss)
peak_ave_power(ss2)


dout = sig_normalize(ss2');




% test messin
% dout = dout + (sin(sts)')/50;
% dout = dout + rand(samples+1,1)/5;
% dout = dout + (rand_walk(samples+1)')/8;



end

