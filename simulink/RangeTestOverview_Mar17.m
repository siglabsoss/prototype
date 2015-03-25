clear all
close all


%start data processing block
srate = 1/125000;
load('thursday.mat','clock_comb125k','patternvec','idealdata')
clock_comb=clock_comb125k;
expected_data = my_cpm_demod_offline(idealdata,srate,100,patternvec,1);

index = 1;
load('mar17pt2.mat','ruthandelcamino')
starttime = datetime;
aligned_data = rawdata_correlator(ruthandelcamino,srate,clock_comb);
Correlation_completed_in(index) = datetime-starttime
BER_coherent(index) = 1-sum(my_cpm_demod_offline(aligned_data*ones([size(aligned_data,2) 1]),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = 1-sum(my_cpm_demod_offline(aligned_data(:,1),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,2),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,3),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) / 3;
number_of_good_datasets(index) = size(aligned_data,2);
clear aligned_data
clear ruthandelcamino
close all

index = 2;
load('mar17pt2.mat','oneillandelcamino')
starttime = datetime;
aligned_data = rawdata_correlator(oneillandelcamino,srate,clock_comb);
Correlation_completed_in(index) = datetime-starttime
BER_coherent(index) = 1-sum(my_cpm_demod_offline(aligned_data*ones([size(aligned_data,2) 1]),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = 1-sum(my_cpm_demod_offline(aligned_data(:,1),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,2),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,3),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) / 3;
number_of_good_datasets(index) = size(aligned_data,2);
clear aligned_data
clear oneillandelcamino
close all

index = 3;
load('mar17pt2.mat','belmontcvs')
starttime = datetime;
aligned_data = rawdata_correlator(belmontcvs,srate,clock_comb);
Correlation_completed_in(index) = datetime-starttime
BER_coherent(index) = 1-sum(my_cpm_demod_offline(aligned_data*ones([size(aligned_data,2) 1]),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = 1-sum(my_cpm_demod_offline(aligned_data(:,1),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,2),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,3),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) / 3;
number_of_good_datasets(index) = size(aligned_data,2);
clear aligned_data
clear belmontcvs
close all

index = 4;
load('mar17pt2.mat','sancarlostrain')
starttime = datetime;
aligned_data = rawdata_correlator(sancarlostrain,srate,clock_comb);
Correlation_completed_in(index) = datetime-starttime
BER_coherent(index) = 1-sum(my_cpm_demod_offline(aligned_data*ones([size(aligned_data,2) 1]),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = 1-sum(my_cpm_demod_offline(aligned_data(:,1),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,2),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,3),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) / 3;
number_of_good_datasets(index) = size(aligned_data,2);
clear aligned_data
clear sancarlostrain
close all

index = 5;
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
close all

index = 6;
load('mar17.mat','sequoiatrain')
starttime = datetime;
aligned_data = rawdata_correlator(sequoiatrain,srate,clock_comb);
Correlation_completed_in(index) = datetime-starttime
BER_coherent(index) = 1-sum(my_cpm_demod_offline(aligned_data*ones([size(aligned_data,2) 1]),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = 1-sum(my_cpm_demod_offline(aligned_data(:,1),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,2),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,3),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) / 3;
number_of_good_datasets(index) = size(aligned_data,2);
clear aligned_data
clear sequoiatrain
close all

index = 7;
load('mar17.mat','beechandelcamino')
starttime = datetime;
aligned_data = rawdata_correlator(beechandelcamino,srate,clock_comb);
Correlation_completed_in(index) = datetime-starttime
BER_coherent(index) = 1-sum(my_cpm_demod_offline(aligned_data*ones([size(aligned_data,2) 1]),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = 1-sum(my_cpm_demod_offline(aligned_data(:,1),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,2),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,3),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) / 3;
number_of_good_datasets(index) = size(aligned_data,2);
clear aligned_data
clear beechandelcamino
close all

index = 8;
load('mar17.mat','willowandelcamino')
starttime = datetime;
aligned_data = rawdata_correlator(willowandelcamino,srate,clock_comb);
Correlation_completed_in(index) = datetime-starttime
BER_coherent(index) = 1-sum(my_cpm_demod_offline(aligned_data*ones([size(aligned_data,2) 1]),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = 1-sum(my_cpm_demod_offline(aligned_data(:,1),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,2),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,3),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) / 3;
number_of_good_datasets(index) = size(aligned_data,2);
clear aligned_data
clear willowandelcamino
close all

index = 9;
load('mar17.mat','berkshireandmiddlefield')
starttime = datetime;
aligned_data = rawdata_correlator(berkshireandmiddlefield,srate,clock_comb);
Correlation_completed_in(index) = datetime-starttime
BER_coherent(index) = 1-sum(my_cpm_demod_offline(aligned_data*ones([size(aligned_data,2) 1]),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = 1-sum(my_cpm_demod_offline(aligned_data(:,1),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,2),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,3),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) / 3;
number_of_good_datasets(index) = size(aligned_data,2);
clear aligned_data
clear berkshireandmiddlefield
close all

index = 10;
load('mar17.mat','parkinglot')
starttime = datetime;
aligned_data = rawdata_correlator(parkinglot,srate,clock_comb);
Correlation_completed_in(index) = datetime-starttime
BER_coherent(index) = 1-sum(my_cpm_demod_offline(aligned_data*ones([size(aligned_data,2) 1]),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = 1-sum(my_cpm_demod_offline(aligned_data(:,1),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,2),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) + 1-sum(my_cpm_demod_offline(aligned_data(:,3),srate,100,patternvec,1) == expected_data)/length(expected_data);
BER_single_antenna(index) = BER_single_antenna(index) / 3;
number_of_good_datasets(index) = size(aligned_data,2);
clear aligned_data
clear parkinglot
%close all


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

figure
plot(range,BER_coherent,'bo-')
hold on
plot(range,BER_single_antenna,'go-')
legend('Coherent','Single Antenna')
title('BER of Coherent Receiver and Single Antenna Receiver by Range')
xlabel('Range [mi]')
ylabel('BER (bit error rate)')

figure
plot(range, number_of_good_datasets,'ro-')
title('Number of good datasets found for coherent sum')
xlabel('Range [mi]')
ylabel('Number of Datasets')


%other things to look at:
%BER
%number of packets found