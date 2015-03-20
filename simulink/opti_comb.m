function [ dout ] = opti_comb( )
%OPTI_COMB Summary of this function goes here
%   Detailed explanation goes here

samples = 25000;
ss = sinc([-125:0.01:125]);
ss2 = reject_fn(25000).*ss;

peak_ave_power(ss)
peak_ave_power(ss2)


dout = ss2';

end

