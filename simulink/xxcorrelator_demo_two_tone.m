%to address:
%can the correlator accept just the code portion of the clock comb or does
%it need the zeros portion too?

clear all
close all

%load idealdataprn
load('thursday.mat','clock_comb125k','patternvec','idealdata')
patternVec = patternvec;
clock_comb = clock_comb125k;
idealdataprn = idealdata;

srate = 1/125000;
datalength = 1/srate;
ideallength = length(idealdataprn);
numdatasets = 60;
maxdelay = 1/2;
maxLOphase = 2*pi;
maxFshift = 100;
snr = 0;
timestamp = 0:srate:(datalength-1)*srate;
%clock_comb = [idealdataprn(1:25000,1); zeros([25000 1])];

%SNR normalization
expected_data = my_cpm_demod_offline(idealdataprn,srate,100,patternVec,1);
BER_AWGN_ONLY = 1-sum(my_cpm_demod_offline(awgn(idealdataprn,snr),srate,100,patternVec,1) == expected_data)/length(expected_data)

for k = 1:1:numdatasets
    noisydata(:,k) = [idealdataprn; zeros([datalength-ideallength 1])]; 
    delaysamples(k) = round(maxdelay*rand()/srate);
    phaserotation(k) = maxLOphase*rand(); 
    Fshift(k) = maxFshift*rand();
    noisydata(:,k) = noisydata(:,k).*(exp(i*2*pi*Fshift(k)*timestamp)'); %frequency shift
    noisydata(:,k) = noisydata(:,k).*exp(i*phaserotation(k)); %LO phase shift
    noisydata(:,k) = [zeros(delaysamples(k),1);noisydata(1:end-delaysamples(k),k)]; %time shift
    noisydata(:,k) = awgn(noisydata(:,k),snr); %white noise
end

rawdata = reshape(noisydata,1,numdatasets*datalength);

figure
plot(0:srate:(length(clock_comb)-1)*srate,clock_comb);
title('Clock Comb')
xlabel('time [s]')

figure
timestamp = 0:srate:(length(rawdata)-1)*srate;
plot(timestamp,real(rawdata))
title('Raw Data')
xlabel('time [s]')

%{
aligned_data = xxcorrelator(rawdata,srate,clock_comb);

%demodulate results

expected_data = my_cpm_demod_offline(idealdataprn,srate,100,patternVec,1);

BER_coherent = 1-sum(my_cpm_demod_offline(aligned_data*ones([size(aligned_data,2) 1]),srate,100,patternVec,1) == expected_data)/length(expected_data)

BER_single_antenna = 1-sum(my_cpm_demod_offline(aligned_data(:,1),srate,100,patternVec,1) == expected_data)/length(expected_data)
%}