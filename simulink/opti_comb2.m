function [ dout ] = opti_comb2(  )
%OPTI_COMB2 Summary of this function goes here
%   Detailed explanation goes here




samples = 25000;

stsdiv = 100;

sts = [samples/stsdiv/-2:1/stsdiv:samples/stsdiv/2];

a1 = 180;

ss = sinc(sts)*a1;


ss2 = cos(ss) + 1i*sin(ss);

oc2 = ss2';

% figure;
% plot(real(oc2));
% figure;
% splot(oc2);


firstBwChop = 110;

% bandwith limit
oc2bwlim = bandwidth_chop(oc2,25000,-1*firstBwChop,firstBwChop);

oc2chop = oc2bwlim(1:11500);

% higher means more rand walk
randWalkMixLevel = 0.9;


ocrand = sig_normalize(oc2chop) + (rand_walk(11500)') * randWalkMixLevel;


secondBwChop = 700;

ocrandlim = bandwidth_chop(ocrand,25000,-1*secondBwChop,secondBwChop);


dout = ocrand;


end

