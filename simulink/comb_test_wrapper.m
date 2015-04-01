%this is a script framework for testing out clock comb candidates.
%notes:
% - Each comb with correlate with different strength, so remember to tweak detect_threshold for each comb.
% - Correlation values are different for time and frequency domain metods,
% so different detect_threshold will be required.


clear all
close all

%{
%first load a clock comb and ideal data set, and move the relevant data to
%generic variables.
load('idealdataprn.mat')
idealdata = idealdataprn;
clock_comb = idealdataprn(1:length(idealdataprn/2));
pattern_vec = patternVec;
pattern_repeat = patternVecRepeat;
time_detect_threshold = 7.5; %set the detection threshold.  remember there are tons of knobs to tweak inside the correlator function too.
freq_detect_threshold = 1.75; %set the detection threshold.  remember there are tons of knobs to tweak inside the correlator function too.
%}


%alternate load set using thursday.mat
load('thursday.mat')
%idealdata = idealdata; %not needed because name is the same
clock_comb = clock_comb125k;
pattern_vec = patternvec;
pattern_repeat = 1;
time_detect_threshold = 7.5; %set the detection threshold.  remember there are tons of knobs to tweak inside the correlator function too.
freq_detect_threshold = 3.5; %set the detection threshold.  remember there are tons of knobs to tweak inside the correlator function too.


%set the other relavant parameters
srate = 1/125000;

%SNR normalization: use this to select an SNR (I have been targeting an SNR that gives a single-antenna BER of 0.30).
snr_awgn = -10;
expected_data = my_cpm_demod_offline(idealdata,srate,100,pattern_vec,pattern_repeat);
BER_AWGN_ONLY = 1-sum(my_cpm_demod_offline(awgn(idealdata,snr_awgn),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data)

%set parameters for generating raw data
epoch_repeat = 1; %in seconds, the repetition rate of epochs
maxdelay = 1/2; %in seconds, the max delay of any one epoch in its time slot of repetition. epoch time + maxdelay should not be greater that ideallength
maxLOphase = 2*pi; %max LO phase offset, in radians
maxFshift = 100; %max frequency shift, in Hz
numdatasets = 60; %number of epochs in the raw data

%make raw data
timestamp = 0:srate:(epoch_repeat/srate-1)*srate;
for k = 1:1:numdatasets
    noisydata(:,k) = [idealdata; zeros([epoch_repeat/srate-length(idealdata) 1])]; %place each epoch into a timeslot
    delaysamples(k) = round(maxdelay*rand()/srate);
    phaserotation(k) = maxLOphase*rand(); 
    Fshift(k) = maxFshift*rand();
    noisydata(:,k) = noisydata(:,k).*(exp(i*2*pi*Fshift(k)*timestamp)'); %frequency shift
    noisydata(:,k) = noisydata(:,k).*exp(i*phaserotation(k)); %LO phase shift
    noisydata(:,k) = [zeros(delaysamples(k),1);noisydata(1:end-delaysamples(k),k)]; %time shift
end

rawdata = reshape(noisydata,1,numdatasets*epoch_repeat/srate); %make it all into one long sample of rf data

rawdata = awgn(rawdata,snr_awgn); %turn up the noise

%plot the raw data
plot(0:srate:(length(rawdata)-1)*srate,real(rawdata))
title('Raw simulated data with phase, time, frequency, and white noise (real)')
xlabel('time [s]')

%TIME DOMAIN CORRELATION TEST
%==========================================================================
%perform correlation
time_aligned_data = xxcorrelator(rawdata,srate,clock_comb,time_detect_threshold);

%plot coherent sum
figure
plot(0:srate:(size(time_aligned_data,1)-1)*srate,real(time_aligned_data*ones([size(time_aligned_data,2) 1])))
title('Time-Domain Coherent Sum (real)')
xlabel('time[s]')

%print out BER results
Time_BER_coherent = 1-sum(my_cpm_demod_offline(time_aligned_data*ones([size(time_aligned_data,2) 1]),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data)
Time_BER_single_antenna(1) = 1-sum(my_cpm_demod_offline(time_aligned_data(:,1),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data);
Time_BER_single_antenna(2) = 1-sum(my_cpm_demod_offline(time_aligned_data(:,1),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data);
Time_BER_single_antenna(3) = 1-sum(my_cpm_demod_offline(time_aligned_data(:,1),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data);
Time_BER_single_antenna_avg_of_3 = mean(Time_BER_single_antenna)

%FREQ DOMAIN CORRELATION TEST
%==========================================================================
%perform correlation
freq_aligned_data = rawdata_correlator(rawdata,srate,clock_comb,freq_detect_threshold);

%plot coherent sum
figure
plot(0:srate:(size(freq_aligned_data,1)-1)*srate,real(freq_aligned_data*ones([size(freq_aligned_data,2) 1])))
title('Freq-Domain Coherent Sum (real)')
xlabel('time[s]')

%print out BER results
Freq_BER_coherent = 1-sum(my_cpm_demod_offline(freq_aligned_data*ones([size(freq_aligned_data,2) 1]),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data)
Freq_BER_single_antenna(1) = 1-sum(my_cpm_demod_offline(freq_aligned_data(:,1),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data);
Freq_BER_single_antenna(2) = 1-sum(my_cpm_demod_offline(freq_aligned_data(:,1),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data);
Freq_BER_single_antenna(3) = 1-sum(my_cpm_demod_offline(freq_aligned_data(:,1),srate,100,pattern_vec,pattern_repeat) == expected_data)/length(expected_data);
Freq_BER_single_antenna_avg_of_3 = mean(Freq_BER_single_antenna)