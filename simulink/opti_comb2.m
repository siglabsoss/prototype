function [ dout ] = opti_comb2(  )
%OPTI_COMB2 Summary of this function goes here
%   Detailed explanation goes here




samples = 25000;

stsdiv = 200;

% we don't want to use the sync function around 0
sincTimeOffset = -70;

sts = [samples/stsdiv/-2:1/stsdiv:samples/stsdiv/2];

sts = sts + sincTimeOffset;

a1 = 180;

ss = sinc(sts)*a1;


ss2 = cos(ss) + 1i*sin(ss);

oc2 = ss2';
% oc2 = ss';

% figure;
% plot(real(oc2));
% figure;
% splot(oc2);


firstBwChop = 55;

% bandwith limit
oc2bwlim = bandwidth_chop(oc2,25000,-1*firstBwChop,firstBwChop);

oc2chop = oc2bwlim; %(1:11500);

% higher means more rand walk
randWalkMixLevel = 0.9;


ocrand = sig_normalize(oc2chop) + (rand_walk(samples+1)') * randWalkMixLevel;
% ocrand = sig_normalize(oc2chop);


secondBwChop = 700;

ocrandlim = bandwidth_chop(ocrand,25000,-1*secondBwChop,secondBwChop);


dout = ocrand;
% dout = ss;


end

