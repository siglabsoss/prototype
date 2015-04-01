%wrapper script for range testing.  takes in data and comb, runs time- and
%frequency-domain correlation on them, then demodulates.

clear all
close all

%load range test data
load('mar31b.mat','oneilclock')
rawdata = oneilclock;

%load dual tone ideal data and compute expected data
srate = 1/125000;
load('thursday.mat','patternvec','clock_comb125k','idealdata')
pattern_vec = patternvec;
pattern_repeat = 1;
clock_comb = clock_comb125k;
expected_data = my_cpm_demod_offline(idealdata,srate,100,pattern_vec,pattern_repeat);

%settings
freq_detect_threshold = 2.5;
time_detect_threshold = 10;

%perform frequency-domain correlation
freq_aligned_data = rawdata_correlator(rawdata,srate,clock_comb,freq_detect_threshold);

%demodulate
Freq_BER_coherent = 1-sum(my_cpm_demod_offline(freq_aligned_data*ones([size(freq_aligned_data,2) 1]),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data)

%perform time-domain correlation
time_aligned_data = xxcorrelator(rawdata,srate,clock_comb,time_detect_threshold);

%demodulate
Time_BER_coherent = 1-sum(my_cpm_demod_offline(time_aligned_data*ones([size(time_aligned_data,2) 1]),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data)

%do a single antenna correlation of each
Freq_BER_single_antenna = 1-sum(my_cpm_demod_offline(freq_aligned_data(:,1),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data)
Time_BER_single_antenna = 1-sum(my_cpm_demod_offline(time_aligned_data(:,1),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data)

RANGETEST_CLOCK_SUMMARY = [Freq_BER_coherent Time_BER_coherent Freq_BER_single_antenna Time_BER_single_antenna freq_detect_threshold time_detect_threshold]


