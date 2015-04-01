%wrapper script for range testing.  takes in data and comb, runs time- and
%frequency-domain correlation on them, then demodulates.

clear all
close all

load('thursday.mat','patternvec','clock_comb125k')

