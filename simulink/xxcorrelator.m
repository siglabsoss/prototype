%USAGE:
%
%       aligned_data = xxcorrelator(rawdata,srate,clock_comb,detect_threshold);
%
% To get the coherent sum, just use aligned_data*ones([size(aligned_data,2) 1])
% 
% rawdata is a single-dimensional array of data samples at srate
%
% srate is equal to the time value of each sample, i.e. 125kHz data has
% srate = 1/125000
%
% clock_comb must have the same srate as rawdata
% 
% note:
%   - This function is hard-coded to use 400ms long RF packets (and clock
%     comb)
%   - Poking around in the function: try changing windowtype and
%     power_padding
% 
% These are useful phrases:
%   BER_coherent = 1-sum(my_cpm_demod_offline(aligned_data*ones([size(aligned_data,2) 1]),srate,100,patternvec,1) == my_cpm_demod_offline(idealdata,srate,100,patternvec,1))/length(my_cpm_demod_offline(idealdata,srate,100,patternvec,1))
%   BER_single_antenna = 1-sum(my_cpm_demod_offline(aligned_data(:,1),srate,100,patternvec,1) == my_cpm_demod_offline(idealdata,srate,100,patternvec,1))/length(my_cpm_demod_offline(idealdata,srate,100,patternvec,1))
%

%todo:
% convert to clock comb xcorr for signal finding in presense of interferers
% write a generic goodsets function
% do not pad the pre-selection fft
% fft data reduction by bandlimiting
% add an on/off for plots
% consider using nextpow2 with 0 power padding for the ranking xcorr (but
% be careful of windowing issues)
% turn for loop operations into matrix operations
% or turn for loops into parallel for loops

%function aligned_data = rawdata_correlator(rawdata,srate,clock_comb)

%{
%start block of standalone test
clear all
close all
load('thursday.mat','clock_comb125k','patternvec','idealdata'); 
load('mar17pt2.mat','ruthandelcamino');
srate = 1/125000;
clock_comb = clock_comb125k;
rawdata = ruthandelcamino;
%end block of standalone test
%}

function aligned_data = xxcorrelator(rawdata,srate,clock_comb,detect_threshold)

starttime = datetime;

%main knobs
%power_padding = 3; %amount of extra padding to apply to the fft
%windowtype = @triang; %fft window type.  @triang, @rectwin, and @hamming work best
fsearchwindow_low = -100; %frequency search window low, in Hz
fsearchwindow_hi = 200; %frequency search window high, in Hz
%combwindow_low = -105; %clock comb freq-domain correlation window low, in Hz
%combwindow_hi = 105; %clock comb freq-domain correlation window high, in Hz

%XXCORR features
downsample_rate = 40; %downsampling rate for signal search
fstep = 0.5; %frequency search step in Hz
enhance_fstep = 0.25; %in Hz
enhance_numsteps = 11;
xcorr_detect = detect_threshold;

%other knobs
windowsize = 0.8; % size of chunked data
timestep = 0.3; %time stepping of data chunks.  should be < windowsize - time length of rf packet


%plot out the raw data coming in
figure
rawtime = 0:srate:(length(rawdata)-1)*srate;
plot(rawtime, real(rawdata))
title('Raw RF Data Input (real)')

%chunk the data
for k = 0:floor(rawtime(end)/timestep)-ceil(windowsize/timestep)
    rnoisydata(:,k+1) = rawdata(round(k*timestep/srate)+1:round(k*timestep/srate+windowsize/srate));
end

datalength = length(rnoisydata(:,1));
numdatasets = k+1;
displaydatasets = 10;
timestamp = 0:srate:(datalength-1)*srate;
timestamp_comb = 0:srate:(length(clock_comb)-1)*srate;


figure
for k = 1:1:displaydatasets
    subplot(displaydatasets,1,k)
    plot(timestamp,real(rnoisydata(:,k)))
    xlim([0 1])
end
subplot(displaydatasets,1,1)
title('First 10 chunks of raw data received at antennas (Real)')
xlabel('Time [s]')


%COARSE SIGNAL SEARCH
%==========================================================================

srate_search = srate*downsample_rate;
timestamp_search = downsample(timestamp,downsample_rate);

freqshift = fsearchwindow_low:fstep:fsearchwindow_hi;
clock_comb_downsample = downsample(clock_comb,downsample_rate);
timestamp_comb_search = 0:srate_search:(length(clock_comb_downsample)-1)*srate_search;
for k = 1:1:length(freqshift)
    clock_comb_search(:,k) = clock_comb_downsample.*exp(i*2*pi*-freqshift(k)*timestamp_comb_search)';
end


for n = 1:1:size(rnoisydata,2)
    for k = 1:1:length(freqshift)
        xxcorr_data = xcorr(downsample(rnoisydata(:,n),downsample_rate),clock_comb_search(:,k));
        [val id] = max(xxcorr_data);
        fshift_max(k) = abs(val);
        fshift_time_rms(k) = rms(xxcorr_data);
    end
    [val id] = max(fshift_max);
    fsearch_max(n) = abs(val);
    fsearch_freq(n) = freqshift(id);
    fsearch_snr(n) = fsearch_max(n)/rms(fshift_time_rms);
end



%REDUCE TO DETECTED DATASETS AND CENTER ON DETECTED FSHIFT
%==========================================================================
goodsets = find(fsearch_snr > xcorr_detect);
number_of_good_datasets = length(goodsets) %print out the number of good datasets found
numdatasets = number_of_good_datasets;

figure
subplot 211
plot(fsearch_snr,'bo-')
hold on
plot(goodsets,fsearch_snr(goodsets),'mo')
title('Max Correlation Response Across Time and Frequency')
ylabel('Response')
xlabel('Data Chunk')
subplot 212
hist(fsearch_snr)
title('Histogram of Max Correlation Response')

figure
plot(fsearch_freq(goodsets),'bo')
title('Coarse Frequency Correction')
xlabel('Dataset')
ylabel('Correction [Hz]')


for k = 1:1:numdatasets
    freqaligneddataxcorr(:,k) = rnoisydata(:,goodsets(k)).*(exp(i*2*pi*fsearch_freq(goodsets(k))*timestamp)');
end

freqaligneddataxcorr = frequency_enhance(freqaligneddataxcorr,clock_comb,timestamp,enhance_fstep,enhance_numsteps);

%END XCORR VERSION OF FREQ ALIGMENT
%==========================================================================


%perform clock_comb xcorrelation
xcorrtimestamp = [flip(-timestamp,2) timestamp(2:end)]; %zero in the middle
for k = 1:1:numdatasets
    xcorr_data(:,k) = xcorr(freqaligneddataxcorr(:,k),clock_comb);
    [val id] = max(xcorr_data(:,k));
    recoveredphasexcorr(k) = angle(val);
    samplesoffsetxcorr(k) = id - datalength;
end

%plot the xcorr of the samples with the comb
figure
for k = 1:1:displaydatasets
    subplot(displaydatasets,1,k)
    plot(xcorrtimestamp,abs(xcorr_data(:,k)))
end
subplot(displaydatasets,1,1)
title('First 10 Time-Domain Correlations of Noisy Data with Clock Comb (abs val)')
subplot(displaydatasets,1,displaydatasets)
xlabel('Time Offset [s]')

%time and phase align data
for k = 1:1:numdatasets
    aligned_data(:,k) = [zeros([-samplesoffsetxcorr(k) 1]); freqaligneddataxcorr(max([samplesoffsetxcorr(k) 1]):end+min([samplesoffsetxcorr(k) 0]),k);zeros([samplesoffsetxcorr(k)-1 1])]./exp(i*(recoveredphasexcorr(k)));
end

%{
% OLD VERSION THAT ONLY SUPPORTS POSITIVE OFFSETS.
% TO BE REMOVED IN NEXT REVISION
goodsets2 = find(samplesoffsetxcorr > 0); % filter out partial coverage (datasets that don't have a start)
%reduce to just the good datasets
for k = 1:length(goodsets2)
    freqaligneddataxcorr2(:,k) = freqaligneddataxcorr(:,goodsets2(k));
    samplesoffsetxcorr2(:,k) = samplesoffsetxcorr(:,goodsets2(k));
    recoveredphasexcorr2(k) = recoveredphasexcorr(goodsets2(k));
end
numdatasets = length(goodsets2);

%time and phase align data
for k = 1:1:numdatasets
    aligned_data(:,k) = [freqaligneddataxcorr2(samplesoffsetxcorr2(k):end,k);zeros([samplesoffsetxcorr2(k)-1 1])]./exp(i*(recoveredphasexcorr2(k)));
end

displaydatasets = min(displaydatasets,numdatasets);
%}

%plot the Aligned Data
figure
for k = 1:1:displaydatasets
    subplot(displaydatasets,1,k)
    plot(timestamp, real(aligned_data(:,k)))
end
subplot(displaydatasets,1,1)
title('First 10 Correlation Time and Phase Aligned Data (Real)')
subplot(displaydatasets,1,displaydatasets)
xlabel('Time [s]')

figure
coherentsumxcorr = aligned_data * ones([numdatasets 1]);
plot(timestamp, real(coherentsumxcorr))
title('Correlation Coherent Sum of Signals (Real)')

Correlation_completed_in = datetime-starttime

end

%demodulate results, part of standalone test

%{
expected_data = my_cpm_demod_offline(idealdata,srate,100,patternvec,1);

BER_coherent = 1-sum(my_cpm_demod_offline(aligned_data*ones([size(aligned_data,2) 1]),srate,100,patternvec,1) == expected_data)/length(expected_data)

BER_single_antenna = 1-sum(my_cpm_demod_offline(aligned_data(:,1),srate,100,patternvec,1) == expected_data)/length(expected_data)
%}
