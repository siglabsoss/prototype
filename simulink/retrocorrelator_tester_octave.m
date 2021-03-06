clear all
close all

%START REAL DATA LOAD BLOCK
%========================

load('mar31e.mat','haywardcaltrainclock')
rawdata = haywardcaltrainclock;
load('thursday.mat','clock_comb125k','idealdata','patternvec')
clock_comb = clock_comb125k;
samples_per_bit_at_fs = 100;
srate = 1/125000;
detect_threshold = 2.5;
ideal_bits = o_cpm_demod(idealdata,srate,100,patternvec,1);

%RAW DATA BLOCK
%=========================
% load('clock_comb195k.mat','clock_comb195k','patternvec','ideal_bits');
% clock_comb = clock_comb195k;
% 
% o_util;
% pipe_type = 'uint8';
% filename200='./SanMateoSouthAndGumArray.raw';
% fid200 = fopen(filename200, 'r'); 
% [rrrawdata, rdcount] = fread(fid200, 9E99, pipe_type);
% fclose(fid200);
% rawdata200 = raw_to_complex(rrrawdata');
% clear rrrawdata;
% rawdata = double(rawdata200(end/2:end));
% fs = 1e8/512;
% srate = 1/fs;
% samples_per_bit_at_fs = 156.25;
% 
% detect_threshold = 2;
%END RAW DATA BLOCK
%=============================



%chunk the data
windowsize = 0.8; % size of chunked data
timestep = 0.3; %time stepping of data chunks.  should be < windowsize - time length of rf packet
rawtime = 0:srate:(length(rawdata)-1)*srate;
timestepsamples = round(windowsize/srate);
for k = 0:floor(rawtime(end)/timestep)-ceil(windowsize/timestep)-1
    rnoisydata(:,k+1) = rawdata(round(k*timestep/srate)+1:round(k*timestep/srate)+timestepsamples);
end

%END REAL DATA LOAD
%=======================

%START SIM DATA LOAD
%=============================
% load('thursday.mat','clock_comb125k','idealdata','patternvec')
% clock_comb = clock_comb125k;
% 
% srate = 1/125000;
% detect_threshold = 2.5;
% 
% %set parameters for generating raw data
% snr_awgn = -3;
% epoch_repeat = 0.8; %in seconds, the repetition rate of epochs
% maxdelay = 0.001; %in seconds, the max delay of any one epoch in its time slot of repetition. epoch time + maxdelay should not be greater that ideallength
% maxLOphase = 2*pi; %max LO phase offset, in radians
% maxFshift = 100; %max frequency shift, in Hz
% numdatasets = 60; %number of epochs in the raw data
% rdatalength = round(epoch_repeat/srate);
% 
% %make raw data
% timestamp = 0:srate:(rdatalength-1)*srate;
% for k = 1:1:numdatasets
%     rnoisydata(:,k) = [idealdata; zeros([rdatalength-length(idealdata) 1])]; %place each epoch into a timeslot
%     delaysamples(k) = round(maxdelay*rand()/srate);
%     phaserotation(k) = maxLOphase*rand(); 
%     Fshift(k) = maxFshift*rand();
%     rnoisydata(:,k) = rnoisydata(:,k).*(exp(i*2*pi*Fshift(k)*timestamp)'); %frequency shift
%     rnoisydata(:,k) = rnoisydata(:,k).*exp(i*phaserotation(k)); %LO phase shift
%     rnoisydata(:,k) = [zeros(delaysamples(k),1);rnoisydata(1:end-delaysamples(k),k)]; %time shift
%     %rnoisydata(:,k) = awgn(rnoisydata(:,k),snr_awgn); %add noise
% end

%END SIM DATA LOAD
%=======================

%plot incoherent sum
datalength = length(rnoisydata(:,1));
timestamp = 0:srate:(datalength-1)*srate;
figure
plot(timestamp,real(rnoisydata*ones([size(rnoisydata,2) 1])))
xlabel('time [s]')
title('Incoherent Sum')

starttime = time; %datetime doesn't work in octave

%matrix version
reply_data = clock_comb;
fsearchwindow_low = -100;
fsearchwindow_hi = 200;
retro_go = 1;
weighting_factor = 0;
[aligned_data retro_data retrostart retroend fxcorrsnr goodsets freqoffset phaseoffset samplesoffset] = retrocorrelator_octave(rnoisydata,srate,clock_comb,detect_threshold,clock_comb,fsearchwindow_low,fsearchwindow_hi,retro_go,weighting_factor);

%single version
% reply_data = clock_comb;
% fsearchwindow_low = -100;
% fsearchwindow_hi = 200;
% retro_go = 1;
% weighting_factor = 0;
% aligned_data = [];
% retro_data = [];
% for k=1:1:size(rnoisydata,2)
%     [aligned_data_single retro_single retrostart retroend fxcorrsnr goodsets freqoffset phaseoffset samplesoffset] = retrocorrelator_octave(rnoisydata(:,k),srate,clock_comb,detect_threshold,clock_comb,fsearchwindow_low,fsearchwindow_hi,retro_go,weighting_factor);
%     if ~(sum(aligned_data_single)==0)
%         aligned_data = [aligned_data, aligned_data_single];
%         retro_data = [retro_data, retro_single];
%     end
% end

Correlation_completed_in = time-starttime

number_of_good_datasets = size(aligned_data,2)

%DIAGNOSTIC PLOTS (only works with matrix version)
%         cal_const = 1.18e-12; %calculated from thermal noise measurements
%         E_te = 1.04e-16; %thermal energy for 10kHz band for windowsize of time.
%         single_antenna_strength = 10*log10(cal_const*(((abs(aligned_data).').^2)*ones(size(aligned_data,1),1)./windowsize)./(E_te/windowsize));
%         coherent_antenna_strength = 10*log10(cal_const*(sum(abs((aligned_data*ones([size(aligned_data,2) 1]))).^2)/windowsize)/(E_te/windowsize));
%         
%         %Antenna Power Plot
%         figure
%         bar([zeros(length(single_antenna_strength)+1,1);coherent_antenna_strength],'b')
%         hold on
%         bar([single_antenna_strength;0],'r')
%         hold off
%         legend('Coherent Epoch','Single Antenna Epoch','Location','NorthWest')
%         xlabel('Antenna Epoch','FontSize',14)
%         ylabel('Epoch Strength (dB)','FontSize',14)
%         ylim([-20 100])
%         title('Current: Antenna Strength (Signal / Thermal Energy) for Coherent and Single','FontSize',14)
%         
%         %Rank Plot
%         figure
%         subplot(2,1,1)
%         plot(fxcorrsnr,'o')
%         xlabel('Data Chunk Index','FontSize',14)
%         ylabel('Comb Correlation SNR','FontSize',14)
%         subplot(2,1,2)
%         hist(fxcorrsnr,20)
%         xlabel('xcorr SNR value','FontSize',14)
%     	ylabel('hit count','FontSize',14)
%         subplot(2,1,1)
%         title('Current: Plot and Histogram of SNR used for Signal Detection','FontSize',14)
%         
%         %corrections plot
%         figure
%         subplot(3,1,1)
%         plot(freqoffset,'o-')
%         title('Current: Frequency Offset Correction Applied','FontSize',14)
%         ylabel('Freq [Hz]','FontSize',14)
%         xlabel('dataset','FontSize',14)
%         subplot(3,1,2)
%         plot(phaseoffset,'o-')
%         title('Current: Phase Offset Correction Applied','FontSize',14)
%         ylabel('Phase [rad]','FontSize',14)
%         xlabel('dataset','FontSize',14)
%         subplot(3,1,3)
%         plot(samplesoffset,'o-')
%         title('Current: Time Offset Correction Applied','FontSize',14)
%         ylabel('Time [samples]','FontSize',14)
%         xlabel('dataset','FontSize',14)
% 
%         %coherent sum plot
%         figure
%         plot(timestamp,real(aligned_data*ones([size(aligned_data,2) 1])))
%         xlabel('time [s]')
%         title('Coherent Sum')

%get BER
BER_coherent = 1-sum(o_cpm_demod(aligned_data*ones([size(aligned_data,2) 1]),srate,samples_per_bit_at_fs,patternvec,1) == ideal_bits)/length(ideal_bits)

%get BER of single antenna
BER_single = 1-sum(o_cpm_demod(aligned_data(:,1),srate,samples_per_bit_at_fs,patternvec,1) == ideal_bits)/length(ideal_bits)

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
subplot(displaydatasets,1,1)
title('First 5 Retrodirective responses')
xlabel('time [s]')

%unwind retro signals
% for k = 1:1:size(retro_data,2)
%     retro_unwind(:,k) = retro_data(:,k).*exp(i*phaserotation(k));
%     retro_unwind(:,k) = [zeros(delaysamples(k),1);retro_unwind(1:end-delaysamples(k),k)]; %time shift
% end
% 
% %sum the retro data
% retro_sum = retro_unwind*ones([size(retro_unwind,2) 1]);
% 
% figure
% plot(0:srate:(size(retro_unwind,1)-1)*srate,retro_sum)
% title('Sum of received retro signal at mobile antenna')
