%wrapper script for range testing.  takes in data and comb, runs time- and
%frequency-domain correlation on them, then demodulates.

clear freq_aligned_data
clear time_aligned_data
clear rawdata
clear clock_comb
clear expected_data
clear idealdata
clear pattern_vec
clear Freq_BER_coherent
clear Freq_BER_single_antenna
clear Time_BER_coherent
clear Time_BER_single_antenna

close all

%load dual tone ideal data and compute expected data
srate = 1/125000;
load('mar31drivetest_combs.mat','clock_comb_prn','txdata')
pattern_vec = [1 0];
pattern_repeat = 1;
clock_comb = clock_comb_prn;
idealdata = txdata;
expected_data = my_cpm_demod_offline(idealdata,srate,100,pattern_vec,pattern_repeat);

%settings
freq_detect_threshold = 1.9;
time_detect_threshold = 7.2;

%load range test data
index = 7;
range = 8.08; %in miles
load('mar31e.mat','haywardcaltrainprn')
rawdata = haywardcaltrainprn;
freq_aligned_data = rawdata_correlator(rawdata,srate,clock_comb,freq_detect_threshold);
Freq_BER_coherent = 1-sum(my_cpm_demod_offline(freq_aligned_data*ones([size(freq_aligned_data,2) 1]),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data)
Freq_BER_single_antenna = 1-sum(my_cpm_demod_offline(freq_aligned_data(:,1),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
Freq_BER_single_antenna = Freq_BER_single_antenna + 1-sum(my_cpm_demod_offline(freq_aligned_data(:,2),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
Freq_BER_single_antenna = Freq_BER_single_antenna + 1-sum(my_cpm_demod_offline(freq_aligned_data(:,3),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
Freq_BER_single_antenna = Freq_BER_single_antenna / 3;
freq_number_of_good_datasets = size(freq_aligned_data,2);
time_aligned_data = xxcorrelator(rawdata,srate,clock_comb,time_detect_threshold);
Time_BER_coherent = 1-sum(my_cpm_demod_offline(time_aligned_data*ones([size(time_aligned_data,2) 1]),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data)
Time_BER_single_antenna = 1-sum(my_cpm_demod_offline(time_aligned_data(:,1),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
Time_BER_single_antenna = Time_BER_single_antenna + 1-sum(my_cpm_demod_offline(time_aligned_data(:,2),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
Time_BER_single_antenna = Time_BER_single_antenna + 1-sum(my_cpm_demod_offline(time_aligned_data(:,3),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
Time_BER_single_antenna = Time_BER_single_antenna / 3;
time_number_of_good_datasets = size(time_aligned_data,2);

RANGETEST_PRN_SUMMARY(index,:) = [range Freq_BER_coherent Time_BER_coherent Freq_BER_single_antenna Time_BER_single_antenna freq_detect_threshold time_detect_threshold freq_number_of_good_datasets time_number_of_good_datasets]

clear freq_aligned_data
clear time_aligned_data
clear rawdata
clear clock_comb
clear expected_data
clear idealdata
clear pattern_vec
clear Freq_BER_coherent
clear Freq_BER_single_antenna
clear Time_BER_coherent
clear Time_BER_single_antenna



