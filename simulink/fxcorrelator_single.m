% Perform correlation search for a single epoch of data against a known
% comb, and return the data aligned to the comb, if an epoch is detected.  
% Retuns zeros if no epoch is detected.  fxcorrelator_single can be run on am
% array of RF chunks, one in each column.
%
% USAGE:
%
%       aligned_data = fxcorrelator_single(rawdata,srate,clock_comb,detect_threshold);
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


function aligned_data = fxcorrelator_single(rawdata,srate,clock_comb,detect_threshold)

%check for rawdata and comb to be in column form
if size(rawdata,2) > size(rawdata,1)
    rawdata = rawdata';
end
if size(clock_comb,2) > size(clock_comb,1)
    clock_comb = clock_comb';
end

%main knobs
power_padding = 3; %amount of extra padding to apply to the fft
windowtype = @rectwin; %fft window type.  @triang, @rectwin, and @hamming work best
fsearchwindow_low = -100; %frequency search window low, in Hz
fsearchwindow_hi = 200; %frequency search window high, in Hz
combwindow_low = -105; %clock comb freq-domain correlation window low, in Hz
combwindow_hi = 105; %clock comb freq-domain correlation window high, in Hz
%time-domain frequency correction features
freqstep = 0.25;
numsteps = 3;

datalength = size(rawdata,1);
numdatasets = size(rawdata,2);
timestamp = 0:srate:(datalength-1)*srate;
fftlength = 2^(nextpow2(datalength)+power_padding);
timestamp_comb = 0:srate:(length(clock_comb)-1)*srate;
fftlength_detect = 2^(nextpow2(datalength)); %reduced fftlength for signal detection stage.

%short fft of raw data for detection %ADDED FFT SHIFT HERE for indexing
for k=1:1:numdatasets
    rnoisyfft(:,k) = fftshift(fft([window(windowtype,datalength).*rawdata(:,k);zeros([fftlength_detect-datalength,1])]));
    noisyfftsnr(k) = abs(max(rnoisyfft(:,k)))/rms(rnoisyfft(:,k));
end

%create the reduced comb fft for detection %ADDED FFT SHIFT HERE for indexing
freqindex = linspace(0,1/srate,fftlength_detect)-1/srate/2;
comb_fft = fftshift(fft([window(windowtype,length(clock_comb)).*clock_comb;zeros([fftlength_detect-length(clock_comb),1])]));

%SELECTIVITY: COMPUTATION REDUCTION: Limiting the range of valid correlation
fsearch_index_low = floor((fftlength_detect)/2) + round(fsearchwindow_low*srate*fftlength_detect)+1; % need to verify possible off-by-one errors
fsearch_index_hi = ceil((fftlength_detect)/2) + round(fsearchwindow_hi*srate*fftlength_detect);
combwindow_index_low = floor((fftlength_detect)/2) + round(combwindow_low*srate*fftlength_detect)+1; % need to verify possible off-by-one errors
combwindow_index_hi = ceil((fftlength_detect)/2) + round(combwindow_hi*srate*fftlength_detect);
xcorr_comb_paddinglength = (fsearch_index_hi - fsearch_index_low -1) - (combwindow_index_hi-combwindow_index_low-1); %dammit matlab pads the shorter xcorr input
fsearch_length = fsearch_index_hi-fsearch_index_low+1;
fstamp_index_low = floor(fftlength_detect+1) + round(fsearchwindow_low*srate*fftlength_detect) - round(combwindow_hi*srate*fftlength_detect)-xcorr_comb_paddinglength;
fstamp_index_hi = ceil(fftlength_detect-1) + round(fsearchwindow_hi*srate*fftlength_detect) - round(combwindow_low*srate*fftlength_detect);
xcorrfreqstamp = linspace(0,2/srate,fftlength_detect*2-1)-1/srate;
xcorr_fstamp_fsearch = xcorrfreqstamp(fstamp_index_low:fstamp_index_hi);

%Sample ranking based on frequency-domain comb correlation
freqstamp_fsearch = xcorrfreqstamp(fstamp_index_low:fstamp_index_hi);
for k = 1:1:numdatasets
    [xcorr_freq(:,k), lag(:,k)] = xcorr(abs(rnoisyfft(fsearch_index_low:fsearch_index_hi,k)),abs(comb_fft(combwindow_index_low:combwindow_index_hi)));
    noisyxcorrsnr(k) = abs(max(xcorr_freq(:,k)))/rms(abs(xcorr_freq(:,k)));
end

goodsets = find(noisyxcorrsnr > detect_threshold);
numdatasets = length(goodsets);

%diagnostics
%{
close all
figure
subplot 211
plot(noisyxcorrsnr,'o')
hold on
plot(goodsets,noisyxcorrsnr(goodsets),'mo')
xlabel('Data Chunk Index')
ylabel('Comb Correlation SNR')
subplot 212
histogram(noisyxcorrsnr,20)
xlabel('xcorr SNR value')
ylabel('hit count')
subplot 211
title('Plot and Histogram of SNR used for Signal Detection')
%}


if numdatasets < 1
    aligned_data = zeros([datalength 1]);
    return
end

%CLEANUP: reduce to just the good datasets
for k = 1:numdatasets
    noisydata(:,k) = rawdata(:,goodsets(k));
end

%CLEANUP: remove from memory

clear xcorr_freq
clear xcorrfreqstamp
clear comb_fft
clear rawdata
clear rnoisydata
clear lag

%long comb fft for frequency alignment
freqindex = linspace(0,1/srate,fftlength)-1/srate/2;
comb_fft = fftshift(fft([window(windowtype,length(clock_comb)).*clock_comb;zeros([fftlength-length(clock_comb),1])]));

%long data fft of raw data for frequency alignment
for k=1:1:numdatasets
    noisyfft(:,k) = fftshift(fft([window(windowtype,datalength).*noisydata(:,k);zeros([fftlength-datalength,1])]));
end

%SELECTIVITY: COMPUTATION REDUCTION: Limiting the range of valid correlation
fsearch_index_low = floor((fftlength)/2) + round(fsearchwindow_low*srate*fftlength)+1; % need to verify possible off-by-one errors
fsearch_index_hi = ceil((fftlength)/2) + round(fsearchwindow_hi*srate*fftlength);
combwindow_index_low = floor((fftlength)/2) + round(combwindow_low*srate*fftlength)+1; % need to verify possible off-by-one errors
combwindow_index_hi = ceil((fftlength)/2) + round(combwindow_hi*srate*fftlength);
xcorr_comb_paddinglength = (fsearch_index_hi - fsearch_index_low -1) - (combwindow_index_hi-combwindow_index_low-1); %dammit matlab pads the shorter xcorr input
fsearch_length = fsearch_index_hi-fsearch_index_low+1;
fstamp_index_low = floor(fftlength+1) + round(fsearchwindow_low*srate*fftlength) - round(combwindow_hi*srate*fftlength)-xcorr_comb_paddinglength;
fstamp_index_hi = ceil(fftlength-1) + round(fsearchwindow_hi*srate*fftlength) - round(combwindow_low*srate*fftlength);
xcorrfreqstamp = linspace(0,2/srate,fftlength*2-1)-1/srate;
xcorr_fstamp_fsearch = xcorrfreqstamp(fstamp_index_low:fstamp_index_hi);

%run the long xcorr for frequency alignment
for k = 1:1:numdatasets
    [xcorr_freq(:,k), lag(:,k)] = xcorr(abs(noisyfft(fsearch_index_low:fsearch_index_hi,k)),abs(comb_fft(combwindow_index_low:combwindow_index_hi)));
    [val id] = max(xcorr_freq(:,k));
    recoveredfreqphasexcorr(k) = angle(val);
    freqoffsetxcorr(k) = xcorr_fstamp_fsearch(id);
end

%frequency align data
for k = 1:1:numdatasets
    freqaligneddataxcorr(:,k) = noisydata(:,k).*(exp(i*2*pi*freqoffsetxcorr(k)*timestamp)');
end

%time domain correlation for better frequency accuracy
freqaligneddataxcorr = frequency_enhance(freqaligneddataxcorr,clock_comb,timestamp,freqstep,numsteps);

%perform time-domain clock_comb xcorrelation
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

end