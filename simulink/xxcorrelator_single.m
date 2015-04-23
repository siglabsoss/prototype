% Perform correlation search for a single epoch of data against a known
% comb, and return the data aligned to the comb, if an epoch is detected.  
% Retuns zeros if no epoch is detected.  xxcorrelator_single can be run on am
% array of RF chunks, one in each column.
%
% USAGE:
%
%       [aligned_data, aligned_phase, aligned_freq] = xxcorrelator_single(rawdata,srate,clock_comb,detect_threshold);
%
% rawdata is a single-dimensional array of data samples at srate.
% rawdata must be longer than clock_comb.  If rawdata is an array, each
% chunk of rawdata show be in column form.
%
% srate is equal to the time value of each sample, i.e. 125kHz data has
% srate = 1/125000
%
% clock_comb must have the same srate as rawdata
% 
% detect_threshold is the cross-correlation threshold used to determine if
% a signal epoch is present.
% 
% aligned_data is the data output aligned with respect to the input
% clock_comb.  If rawdata is an array and more than one epoch is detected,
% each sequence of aligned data will occupy one column of the ouput.
% 
% aligned_phase is the phase of the received comb in radians, relative to
% the receiver LO.  This is an array if the input is a matrix.
% 
% aligned_freq is the is the frequency of the received comb in Hz,
% relateive to the receiver LO.  This is an array if the input is a matrix.

function [aligned_data, aligned_phase, aligned_freq] = xxcorrelator_single(rawdata,srate,clock_comb,detect_threshold)

%check for rawdata and comb to be in column form
if size(rawdata,2) > size(rawdata,1)
    rawdata = rawdata';
end
if size(clock_comb,2) > size(clock_comb,1)
    clock_comb = clock_comb';
end

%main knobs
fsearchwindow_low = -100; %frequency search window low, in Hz
fsearchwindow_hi = 200; %frequency search window high, in Hz

%XXCORR features
downsample_rate = 40; %downsampling rate for signal search
fstep = 0.5; %frequency search step in Hz
enhance_fstep = 0.25; %in Hz
enhance_numsteps = 11;
xcorr_detect = detect_threshold;

%other knobs
windowsize = 0.8; % size of chunked data
timestep = 0.3; %time stepping of data chunks.  should be < windowsize - time length of rf packet

datalength = size(rawdata,1);
numdatasets = size(rawdata,2);
timestamp = 0:srate:(datalength-1)*srate;
timestamp_comb = 0:srate:(length(clock_comb)-1)*srate;

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


for n = 1:1:size(rawdata,2)
    for k = 1:1:length(freqshift)
        xxcorr_data = xcorr(downsample(rawdata(:,n),downsample_rate),clock_comb_search(:,k));
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
numdatasets = length(goodsets);

%diagnostics
%{
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
%}

if numdatasets < 1
    aligned_data = zeros([datalength 1]);
    return
end


for k = 1:1:numdatasets
    freqaligneddataxcorr(:,k) = rawdata(:,goodsets(k)).*(exp(i*2*pi*fsearch_freq(goodsets(k))*timestamp)');
end

%high resolution frequency correction
freqaligneddataxcorr = frequency_enhance(freqaligneddataxcorr,clock_comb,timestamp,enhance_fstep,enhance_numsteps);

%perform clock_comb xcorrelation
xcorrtimestamp = [flip(-timestamp,2) timestamp(2:end)]; %zero in the middle
for k = 1:1:numdatasets
    xcorr_data(:,k) = xcorr(freqaligneddataxcorr(:,k),clock_comb);
    [val id] = max(xcorr_data(:,k));
    recoveredphasexcorr(k) = angle(val);
    samplesoffsetxcorr(k) = id - datalength;
end

%time and phase align data
for k = 1:1:numdatasets
    aligned_data(:,k) = [zeros([-samplesoffsetxcorr(k) 1]); freqaligneddataxcorr(max([samplesoffsetxcorr(k) 1]):end+min([samplesoffsetxcorr(k) 0]),k);zeros([samplesoffsetxcorr(k)-1 1])]./exp(i*(recoveredphasexcorr(k)));
end

%more outputs
aligned_phase = recoveredphasexcorr;
aligned_freq = fsearch_freq(goodsets);

end

