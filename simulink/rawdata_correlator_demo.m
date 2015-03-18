%DEMO script for rawdata_correlator

%requires the thursday.mat (~450MB 120-seconds rf dataset)

%fresh slate
%clear all
close all

load mondaymarch2.mat

load thursday.mat

srate = 1/125000;

clock_comb = clock_comb125k;

rawdata = cassiamiddlefield;

%cleanup
clear antennaoff
clear antennaon

starttime = datetime;
aligned_data = rawdata_correlator(rawdata,srate,clock_comb);
Correlation_complteted_in = datetime-starttime

BER_coherent = 1-sum(my_cpm_demod_offline(aligned_data*ones([size(aligned_data,2) 1]),srate,100,patternvec,1) == my_cpm_demod_offline(idealdata,srate,100,patternvec,1))/length(my_cpm_demod_offline(idealdata,srate,100,patternvec,1))

BER_single_antenna = 1-sum(my_cpm_demod_offline(aligned_data(:,1),srate,100,patternvec,1) == my_cpm_demod_offline(idealdata,srate,100,patternvec,1))/length(my_cpm_demod_offline(idealdata,srate,100,patternvec,1))

