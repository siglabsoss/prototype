% %wrapper script for range testing.  takes in data and comb, runs time- and
% %frequency-domain correlation on them, then demodulates.
% 
% clear freq_aligned_data
% clear time_aligned_data
% clear rawdata
% clear clock_comb
% clear expected_data
% clear idealdata
% clear pattern_vec
% clear Freq_BER_coherent
% clear Freq_BER_single_antenna
% clear Time_BER_coherent
% clear Time_BER_single_antenna
% 
% close all
% 
% %load dual tone ideal data and compute expected data
% srate = 1/125000;
% load('thursday.mat','patternvec','clock_comb125k','idealdata')
% pattern_vec = patternvec;
% pattern_repeat = 1;
% clock_comb = clock_comb125k;
% expected_data = my_cpm_demod_offline(idealdata,srate,100,pattern_vec,pattern_repeat);
% 
% %settings
% freq_detect_threshold = 2.5;
% time_detect_threshold = 7;
% 
% %load range test data
% index = 1;
% range = 0; %in miles
% load('mar31a.mat','parkingclock')
% rawdata = parkingclock;
% 
% %chunk the data
% windowsize = 0.8; % size of chunked data
% timestep = 0.3; %time stepping of data chunks.  should be < windowsize - time length of rf packet
% rawtime = 0:srate:(length(rawdata)-1)*srate;
% for k = 0:floor(rawtime(end)/timestep)-ceil(windowsize/timestep)
%     rnoisydata(:,k+1) = rawdata(round(k*timestep/srate)+1:round(k*timestep/srate+windowsize/srate));
% end
% [freq_aligned_data retro] = fxcorrelator_single_retro(rnoisydata,srate,clock_comb,freq_detect_threshold);
% Freq_BER_coherent = 1-sum(my_cpm_demod_offline(freq_aligned_data*ones([size(freq_aligned_data,2) 1]),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data)
% Freq_BER_single_antenna = 1-sum(my_cpm_demod_offline(freq_aligned_data(:,1),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna + 1-sum(my_cpm_demod_offline(freq_aligned_data(:,2),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna + 1-sum(my_cpm_demod_offline(freq_aligned_data(:,3),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna / 3;
% freq_number_of_good_datasets = size(freq_aligned_data,2);
% 
% RANGETEST_CLOCK_SUMMARY(index,:) = [range Freq_BER_coherent Freq_BER_single_antenna freq_detect_threshold freq_number_of_good_datasets]
% 
% clear freq_aligned_data
% clear rawdata
% clear Freq_BER_single_antenna
% clear rnoisydata
% clear Freq_BER_coherent
% 
% %load range test data
% index = 2;
% range = 1.97; %in miles
% load('mar31a.mat','sequoiaclock')
% rawdata = sequoiaclock;
% %chunk the data
% windowsize = 0.8; % size of chunked data
% timestep = 0.3; %time stepping of data chunks.  should be < windowsize - time length of rf packet
% rawtime = 0:srate:(length(rawdata)-1)*srate;
% for k = 0:floor(rawtime(end)/timestep)-ceil(windowsize/timestep)
%     rnoisydata(:,k+1) = rawdata(round(k*timestep/srate)+1:round(k*timestep/srate+windowsize/srate));
% end
% [freq_aligned_data retro] = fxcorrelator_single_retro(rnoisydata,srate,clock_comb,freq_detect_threshold);
% Freq_BER_coherent = 1-sum(my_cpm_demod_offline(freq_aligned_data*ones([size(freq_aligned_data,2) 1]),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data)
% Freq_BER_single_antenna = 1-sum(my_cpm_demod_offline(freq_aligned_data(:,1),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna + 1-sum(my_cpm_demod_offline(freq_aligned_data(:,2),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna + 1-sum(my_cpm_demod_offline(freq_aligned_data(:,3),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna / 3;
% freq_number_of_good_datasets = size(freq_aligned_data,2);
% 
% RANGETEST_CLOCK_SUMMARY(index,:) = [range Freq_BER_coherent Freq_BER_single_antenna freq_detect_threshold freq_number_of_good_datasets]
% 
% clear freq_aligned_data
% clear rawdata
% clear Freq_BER_single_antenna
% clear rnoisydata
% clear Freq_BER_coherent
% 
% %load range test data
% index = 3;
% range = 4.10; %in miles
% load('mar31b.mat','stcarlostrainclock')
% rawdata = stcarlostrainclock;
% %chunk the data
% windowsize = 0.8; % size of chunked data
% timestep = 0.3; %time stepping of data chunks.  should be < windowsize - time length of rf packet
% rawtime = 0:srate:(length(rawdata)-1)*srate;
% for k = 0:floor(rawtime(end)/timestep)-ceil(windowsize/timestep)
%     rnoisydata(:,k+1) = rawdata(round(k*timestep/srate)+1:round(k*timestep/srate+windowsize/srate));
% end
% [freq_aligned_data retro] = fxcorrelator_single_retro(rnoisydata,srate,clock_comb,freq_detect_threshold);
% Freq_BER_coherent = 1-sum(my_cpm_demod_offline(freq_aligned_data*ones([size(freq_aligned_data,2) 1]),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data)
% Freq_BER_single_antenna = 1-sum(my_cpm_demod_offline(freq_aligned_data(:,1),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna + 1-sum(my_cpm_demod_offline(freq_aligned_data(:,2),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna + 1-sum(my_cpm_demod_offline(freq_aligned_data(:,3),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna / 3;
% freq_number_of_good_datasets = size(freq_aligned_data,2);
% 
% RANGETEST_CLOCK_SUMMARY(index,:) = [range Freq_BER_coherent Freq_BER_single_antenna freq_detect_threshold freq_number_of_good_datasets]
% 
% clear freq_aligned_data
% clear rawdata
% clear Freq_BER_single_antenna
% clear rnoisydata
% clear Freq_BER_coherent
% 
% 
% %load range test data
% index = 4;
% range = 5.14; %in miles
% load('mar31b.mat','oneilclock')
% rawdata = oneilclock;
% %chunk the data
% windowsize = 0.8; % size of chunked data
% timestep = 0.3; %time stepping of data chunks.  should be < windowsize - time length of rf packet
% rawtime = 0:srate:(length(rawdata)-1)*srate;
% for k = 0:floor(rawtime(end)/timestep)-ceil(windowsize/timestep)
%     rnoisydata(:,k+1) = rawdata(round(k*timestep/srate)+1:round(k*timestep/srate+windowsize/srate));
% end
% [freq_aligned_data retro] = fxcorrelator_single_retro(rnoisydata,srate,clock_comb,freq_detect_threshold);
% Freq_BER_coherent = 1-sum(my_cpm_demod_offline(freq_aligned_data*ones([size(freq_aligned_data,2) 1]),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data)
% Freq_BER_single_antenna = 1-sum(my_cpm_demod_offline(freq_aligned_data(:,1),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna + 1-sum(my_cpm_demod_offline(freq_aligned_data(:,2),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna + 1-sum(my_cpm_demod_offline(freq_aligned_data(:,3),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna / 3;
% freq_number_of_good_datasets = size(freq_aligned_data,2);
% 
% RANGETEST_CLOCK_SUMMARY(index,:) = [range Freq_BER_coherent Freq_BER_single_antenna freq_detect_threshold freq_number_of_good_datasets]
% 
% clear freq_aligned_data
% clear rawdata
% clear Freq_BER_single_antenna
% clear rnoisydata
% clear Freq_BER_coherent
% 
% 
% %load range test data
% index = 5;
% range = 6.10; %in miles
% load('mar31d.mat','ruthandelcaminoclock2')
% rawdata = ruthandelcaminoclock2;
% %chunk the data
% windowsize = 0.8; % size of chunked data
% timestep = 0.3; %time stepping of data chunks.  should be < windowsize - time length of rf packet
% rawtime = 0:srate:(length(rawdata)-1)*srate;
% for k = 0:floor(rawtime(end)/timestep)-ceil(windowsize/timestep)
%     rnoisydata(:,k+1) = rawdata(round(k*timestep/srate)+1:round(k*timestep/srate+windowsize/srate));
% end
% [freq_aligned_data retro] = fxcorrelator_single_retro(rnoisydata,srate,clock_comb,freq_detect_threshold);
% Freq_BER_coherent = 1-sum(my_cpm_demod_offline(freq_aligned_data*ones([size(freq_aligned_data,2) 1]),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data)
% Freq_BER_single_antenna = 1-sum(my_cpm_demod_offline(freq_aligned_data(:,1),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna + 1-sum(my_cpm_demod_offline(freq_aligned_data(:,2),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna + 1-sum(my_cpm_demod_offline(freq_aligned_data(:,3),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna / 3;
% freq_number_of_good_datasets = size(freq_aligned_data,2);
% 
% RANGETEST_CLOCK_SUMMARY(index,:) = [range Freq_BER_coherent Freq_BER_single_antenna freq_detect_threshold freq_number_of_good_datasets]
% 
% clear freq_aligned_data
% clear rawdata
% clear Freq_BER_single_antenna
% clear rnoisydata
% clear Freq_BER_coherent
% 
% 
% %load range test data
% index = 6;
% range = 6.97; %in miles
% load('mar31e.mat','hillsdalecaltrainclock')
% rawdata = hillsdalecaltrainclock;
% %chunk the data
% windowsize = 0.8; % size of chunked data
% timestep = 0.3; %time stepping of data chunks.  should be < windowsize - time length of rf packet
% rawtime = 0:srate:(length(rawdata)-1)*srate;
% for k = 0:floor(rawtime(end)/timestep)-ceil(windowsize/timestep)
%     rnoisydata(:,k+1) = rawdata(round(k*timestep/srate)+1:round(k*timestep/srate+windowsize/srate));
% end
% [freq_aligned_data retro] = fxcorrelator_single_retro(rnoisydata,srate,clock_comb,freq_detect_threshold);
% Freq_BER_coherent = 1-sum(my_cpm_demod_offline(freq_aligned_data*ones([size(freq_aligned_data,2) 1]),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data)
% Freq_BER_single_antenna = 1-sum(my_cpm_demod_offline(freq_aligned_data(:,1),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna + 1-sum(my_cpm_demod_offline(freq_aligned_data(:,2),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna + 1-sum(my_cpm_demod_offline(freq_aligned_data(:,3),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna / 3;
% freq_number_of_good_datasets = size(freq_aligned_data,2);
% 
% RANGETEST_CLOCK_SUMMARY(index,:) = [range Freq_BER_coherent Freq_BER_single_antenna freq_detect_threshold freq_number_of_good_datasets]
% 
% clear freq_aligned_data
% clear rawdata
% clear Freq_BER_single_antenna
% clear rnoisydata
% clear Freq_BER_coherent
% 
% %load range test data
% index = 7;
% range = 8.08; %in miles
% load('mar31e.mat','haywardcaltrainclock')
% rawdata = haywardcaltrainclock;
% %chunk the data
% windowsize = 0.8; % size of chunked data
% timestep = 0.3; %time stepping of data chunks.  should be < windowsize - time length of rf packet
% rawtime = 0:srate:(length(rawdata)-1)*srate;
% for k = 0:floor(rawtime(end)/timestep)-ceil(windowsize/timestep)
%     rnoisydata(:,k+1) = rawdata(round(k*timestep/srate)+1:round(k*timestep/srate+windowsize/srate));
% end
% [freq_aligned_data retro] = fxcorrelator_single_retro(rnoisydata,srate,clock_comb,freq_detect_threshold);
% Freq_BER_coherent = 1-sum(my_cpm_demod_offline(freq_aligned_data*ones([size(freq_aligned_data,2) 1]),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data)
% Freq_BER_single_antenna = 1-sum(my_cpm_demod_offline(freq_aligned_data(:,1),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna + 1-sum(my_cpm_demod_offline(freq_aligned_data(:,2),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna + 1-sum(my_cpm_demod_offline(freq_aligned_data(:,3),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna / 3;
% freq_number_of_good_datasets = size(freq_aligned_data,2);
% 
% RANGETEST_CLOCK_SUMMARY(index,:) = [range Freq_BER_coherent Freq_BER_single_antenna freq_detect_threshold freq_number_of_good_datasets]
% 
% clear freq_aligned_data
% clear rawdata
% clear Freq_BER_single_antenna
% clear rnoisydata
% clear Freq_BER_coherent
% 
% 
% %load range test data
% index = 8;
% range = 9.15; %in miles
% load('mar31h.mat','sanmateocaltrainclock')
% rawdata = sanmateocaltrainclock;we're bpoth
% %chunk the data
% windowsize = 0.8; % size of chunked data
% timestep = 0.3; %time stepping of data chunks.  should be < windowsize - time length of rf packet
% rawtime = 0:srate:(length(rawdata)-1)*srate;
% for k = 0:floor(rawtime(end)/timestep)-ceil(windowsize/timestep)
%     rnoisydata(:,k+1) = rawdata(round(k*timestep/srate)+1:round(k*timestep/srate+windowsize/srate));
% end
% [freq_aligned_data retro] = fxcorrelator_single_retro(rnoisydata,srate,clock_comb,freq_detect_threshold);
% Freq_BER_coherent = 1-sum(my_cpm_demod_offline(freq_aligned_data*ones([size(freq_aligned_data,2) 1]),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data)
% Freq_BER_single_antenna = 1-sum(my_cpm_demod_offline(freq_aligned_data(:,1),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna + 1-sum(my_cpm_demod_offline(freq_aligned_data(:,2),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna + 1-sum(my_cpm_demod_offline(freq_aligned_data(:,3),srate,100,pattern_vec,1) == expected_data)/length(expected_data);
% Freq_BER_single_antenna = Freq_BER_single_antenna / 3;
% freq_number_of_good_datasets = size(freq_aligned_data,2);
% 
% RANGETEST_CLOCK_SUMMARY(index,:) = [range Freq_BER_coherent Freq_BER_single_antenna freq_detect_threshold freq_number_of_good_datasets]
% 
% clear freq_aligned_data
% clear rawdata
% clear Freq_BER_single_antenna
% clear rnoisydata
% clear Freq_BER_coherent

clear all
close all
load('RangeTestOverview_Mar31.mat')

% now in METRIC!


SUMMARY_AVERAGED(:,1) = RANGETEST_CLOCK_SUMMARY([1 2 3 4 5 7 8 9 12],1);
SUMMARY_AVERAGED(:,2) = RANGETEST_CLOCK_SUMMARY([1 2 3 4 5 7 8 9 12],2);
SUMMARY_AVERAGED(:,3) = (RANGETEST_CLOCK_SUMMARY([1 2 3 4 5 7 8 9 12],3)+RANGETEST_CLOCK_SUMMARY([1 2 3 4 5 7 8 9 12],4)+RANGETEST_CLOCK_SUMMARY([1 2 3 4 5 7 8 9 12],5))./3;


figure
plot(SUMMARY_AVERAGED(:,1),SUMMARY_AVERAGED(:,[2 3]),'-o')
xlabel('Range [km]')
ylabel('Bit Error Rate')
title('Bit Error Rate of Coherent Receiver vs. Single Antenna by Range')
legend('Coherent Receiver', 'Single Antenna')
ylim([0 0.6])
xlim([0 10])
