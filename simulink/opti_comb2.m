function [ dout ] = opti_comb2(  )
%OPTI_COMB2 Summary of this function goes here
%   Detailed explanation goes here




samples = 25000;

sts = [-125:0.01:125];

a1 = 180;

ss = sinc(sts)*a1;


ss2 = cos(ss) + 1i*sin(ss);

oc2 = ss2';


oc2chop = bandwidth_chop(oc2,25000,-110,110);
ocrand = sig_normalize(oc2chop(1:11500)) + (rand_walk(11500)')/1;

dout = ocrand;


end

