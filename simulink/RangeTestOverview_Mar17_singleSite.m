clear all
close all


%start data processing block
srate = 1/125000;
load('thursday.mat','clock_comb125k','patternvec','idealdata')
clock_comb=clock_comb125k;
expected_data = my_cpm_demod_offline(idealdata,srate,100,patternvec,1);

index = 1;
load('mar17.mat','hopkins')
starttime = datetime;
aligned_data = rawdata_correlator(hopkins,srate,clock_comb);
Correlation_completed_in(index) = datetime-starttime
BER_coherent(index) = 1-sum(my_cpm_demod_offline(aligned_data*ones([size(aligned_data,2) 1]),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = 1-sum(my_cpm_demod_offline(aligned_data(:,1),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,2),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,3),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) / 3;
number_of_good_datasets(index) = size(aligned_data,2);
clear aligned_data
clear hopkins


%display snr stats
load noisyxcorrsnr_mar17

xcorrsnr_rangetest = [snr_ruth' snr_oneill' snr_belmont' snr_sancarlos' snr_hopkins' snr_sequoia' snr_beech' snr_willow' snr_berkshire' snr_parkinglot'];

range = [6.1 5.13 4.66 4.09 2.44 1.98 1.70 1.33 0.68 0.02];

sd_rangetest = std(xcorrsnr_rangetest);

figure
plot(range,sd_rangetest,'bo-')
xlabel('Range [mi]')
ylabel('Detection Std Dev')
title('Detection deviation by range')

%other things to look at:
%BER
%number of packets found