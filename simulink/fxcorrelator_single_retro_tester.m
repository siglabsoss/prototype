clear all
close all

%START REAL DATA LOAD BLOCK
%========================

%load('mar17pt2.mat','ruthandelcamino')
load('mar31e.mat', 'haywardcaltrainclock')
%load('mar31f.mat', 'haywardcaltrainclockgain20')
%load('mar31h.mat', 'sanmateocaltrainclock')
%load('mar31g.mat', 'sanmateocaltrainclockgain10')
%load('mar31g.mat', 'sanmateocaltrainclockgain20')
rawdata = haywardcaltrainclock;
load('thursday.mat','clock_comb125k','idealdata','patternvec')
clock_comb = clock_comb125k;

%settings
srate = 1/125000;
detect_threshold = 2.2;
%detect_threshold = 3.8; %original is 2.5
%detect_threshold = 9;

%chunk the data
windowsize = 0.8; % size of chunked data
timestep = 0.3; %time stepping of data chunks.  should be < windowsize - time length of rf packet
rawtime = 0:srate:(length(rawdata)-1)*srate;
for k = 0:floor(rawtime(end)/timestep)-ceil(windowsize/timestep)
    rnoisydata(:,k+1) = rawdata(round(k*timestep/srate)+1:round(k*timestep/srate+windowsize/srate));
end

%{
%test: full FFT of the input data
rawfft = fftshift(fft(rawdata));
figure
plot(linspace(0,1/srate,length(rawdata))-1/srate/2,abs(rawfft))
title('FFT of entire 60s of Raw Data')
ylabel('Magnitude')
xlabel('Freq [Hz]')
%}

%END REAL DATA LOAD
%=======================

%START SIM DATA LOAD
%{
%=============================
load('thursday.mat','clock_comb125k','idealdata','patternvec')
clock_comb = clock_comb125k;

srate = 1/125000;
detect_threshold = 2.5;

%set parameters for generating raw data
snr_awgn = -3;
epoch_repeat = 0.8; %in seconds, the repetition rate of epochs
maxdelay = 0.001; %in seconds, the max delay of any one epoch in its time slot of repetition. epoch time + maxdelay should not be greater that ideallength
maxLOphase = 2*pi; %max LO phase offset, in radians
maxFshift = 100; %max frequency shift, in Hz
numdatasets = 60; %number of epochs in the raw data
rdatalength = round(epoch_repeat/srate);

%make raw data
timestamp = 0:srate:(rdatalength-1)*srate;
for k = 1:1:numdatasets
    rnoisydata(:,k) = [idealdata; zeros([rdatalength-length(idealdata) 1])]; %place each epoch into a timeslot
    delaysamples(k) = round(maxdelay*rand()/srate);
    phaserotation(k) = maxLOphase*rand(); 
    Fshift(k) = maxFshift*rand();
    rnoisydata(:,k) = rnoisydata(:,k).*(exp(i*2*pi*Fshift(k)*timestamp)'); %frequency shift
    rnoisydata(:,k) = [zeros(delaysamples(k),1);rnoisydata(1:end-delaysamples(k),k)]; %time shift
    rnoisydata(:,k) = rnoisydata(:,k).*exp(i*phaserotation(k)); %LO phase shift
    rnoisydata(:,k) = awgn(rnoisydata(:,k),snr_awgn); %add noise
end

%}
%END SIM DATA LOAD
%==========================

%plot incoherent sum
datalength = length(rnoisydata(:,1));
timestamp = 0:srate:(datalength-1)*srate;
figure
plot(timestamp,real(rnoisydata*ones([size(rnoisydata,2) 1])))
xlabel('time [s]')
title('Incoherent Sum')

starttime = datetime;

%matrix version
%[aligned_data retro_data] = fxcorrelator_single_retro(rnoisydata,srate,clock_comb,detect_threshold);
%[aligned_data retro_data] = fxcorrelator_single_retro_full(rnoisydata,srate,clock_comb,detect_threshold);
[aligned_data retro_data] = fxcorrelator_single_retro(rnoisydata,srate,clock_comb,detect_threshold);

%single version

% aligned_data = [];
% retro_data = [];
% for k=1:1:size(rnoisydata,2)
%     [aligned_data_single retro_single] = fxcorrelator_single_retro(rnoisydata(:,k),srate,clock_comb,detect_threshold);
%     if ~(sum(aligned_data_single)==0)
%         aligned_data = [aligned_data, aligned_data_single];
%         retro_data = [retro_data, retro_single];
%     end
% end


Correlation_completed_in = datetime-starttime

number_of_good_datasets = size(aligned_data,2)

figure
plot(timestamp,real(aligned_data*ones([size(aligned_data,2) 1])))
xlabel('time [s]')
title('Coherent Sum')

expected_data = my_cpm_demod_offline(idealdata,srate,100,patternvec,1);
BER_coherent = 1-sum(my_cpm_demod_offline(aligned_data*ones([size(aligned_data,2) 1]),srate,100,patternvec,1) == expected_data)/length(expected_data)

displaydatasets = 5;

%plot first 5 retro signals
retro_time = 0:srate:(size(retro_data,1)-1)*srate;
figure
for k = 1:1:displaydatasets
    subplot(displaydatasets,1,k)
    plot(retro_time,real(retro_data(:,k))*1e-3,'m')
    hold on
    plot(timestamp,real(rnoisydata(:,k)))
    ylim([-1e-3 1e-3])
end


%START RETRO RECONSTUCTION BLOCK
%note this block doesn't work with real data
%{

%unwind retro signals
for k = 1:1:size(retro_data,2)
    retro_unwind(:,k) = retro_data(:,k).*exp(i*phaserotation(k));
    retro_unwind(:,k) = [zeros(delaysamples(k),1);retro_unwind(1:end-delaysamples(k),k)]; %time shift
end

%sum the retro data 
retro_sum = retro_unwind*ones([size(retro_unwind,2) 1]);

figure
plot(0:srate:(size(retro_unwind,1)-1)*srate,retro_sum)
title('Sum of received retro signal at mobile antenna')
%}
%END RETRO RECONSTRUCTION BLOCK


