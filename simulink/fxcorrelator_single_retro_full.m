% Perform correlation search for a single epoch of data against a known
% comb, and return the data aligned to the comb, if an epoch is detected.  
% Retuns zeros if no epoch is detected.  fxcorrelator_single can be run on am
% array of RF chunks, one in each column.
%
% USAGE:
%
%       aligned_data = fxcorrelator_single_retro(rawdata,srate,clock_comb,detect_threshold, retroreference);
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
% retro is the return transmission signal.  It is padded with zeros and
% delayed exactly 1s from the starting epoch of the input signal.  Right
% now it just returns the clock comb with conjugated phase.

function [aligned_data retro] = fxcorrelator_single_retro_full(rawdata,srate,clock_comb,detect_threshold)

%diagnostic functions
diag = 1;
displaydatasets = 10;
if diag
    close all
end

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

%diagnostics
if diag
    if displaydatasets > numdatasets
        displaydatasets = numdatasets;
    end
    figure
    for k=1:1:displaydatasets
        subplot(displaydatasets,1,k)
        plot(linspace(0,1/srate,fftlength_detect)-1/srate/2, abs(rnoisyfft(:,k)))
        ylabel('Magnitude')
        xlabel('Freq [Hz]')
    end
    subplot(displaydatasets,1,1)
    title('First 10 FFTs of input data (abs)')
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
%freqstamp_fsearch = xcorrfreqstamp(fstamp_index_low:fstamp_index_hi);
freqstamp_fsearch = xcorrfreqstamp; %for full range freq test 
detect_start = fftlength_detect+15; %define limits for full test correlation -115 is equiv to -109Hz
for k = 1:1:numdatasets
    %[xcorr_freq(:,k), lag(:,k)] = xcorr(abs(rnoisyfft(fsearch_index_low:fsearch_index_hi,k)),abs(comb_fft(combwindow_index_low:combwindow_index_hi)));
    [xcorr_freq(:,k), lag(:,k)] = xcorr(abs(rnoisyfft(:,k)),abs(comb_fft));
    %noisyxcorrsnr(k) = abs(max(xcorr_freq(:,k)))/rms(abs(xcorr_freq(:,k)));
    noisyxcorrsnr(k) = abs(max(xcorr_freq(detect_start:end,k)))/rms(abs(xcorr_freq(:,k))); %for full range freq test
end

rawdatasets = numdatasets; %preserve the number of raw datasets
goodsets = find(noisyxcorrsnr > detect_threshold);
numdatasets = length(goodsets);

%diagnostics
if diag
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
end


if numdatasets < 1
    aligned_data = zeros([datalength 1]);
    retro = zeros([size(aligned_data,1)+1.5/srate 1]);
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
%xcorr_fstamp_fsearch = xcorrfreqstamp(fstamp_index_low:fstamp_index_hi);
xcorr_fstamp_fsearch = xcorrfreqstamp;

%run the long xcorr for frequency alignment
freq_start = fftlength+150; %for full freq corr test -1000 is equiv to -109Hz
for k = 1:1:numdatasets
    %[xcorr_freq(:,k), lag(:,k)] = xcorr(abs(noisyfft(fsearch_index_low:fsearch_index_hi,k)),abs(comb_fft(combwindow_index_low:combwindow_index_hi)));
    [xcorr_freq(:,k), lag(:,k)] = xcorr(abs(noisyfft(:,k)),abs(comb_fft));
    %[val id] = max(xcorr_freq(:,k));
    [val id] = max(xcorr_freq(freq_start:end,k)); %for full freq corr test
    recoveredfreqphasexcorr(k) = angle(val);
    %freqoffsetxcorr(k) = xcorr_fstamp_fsearch(id);
    freqoffsetxcorr(k) = xcorr_fstamp_fsearch(id+freq_start-1); %for full freq corr test
end


%diagnostics
if diag
    if displaydatasets > numdatasets
        displaydatasets = numdatasets;
    end
    figure
    for k=1:1:displaydatasets
        subplot(displaydatasets,1,k)
        plot(xcorr_fstamp_fsearch, abs(xcorr_freq(:,k)))
        ylabel('Magnitude')
        xlabel('Freq [Hz]')
    end
    subplot(displaydatasets,1,1)
    title('First 10 Frequency-Domain Correlations for Freq Alignment')
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

if diag
    if displaydatasets > numdatasets
        displaydatasets = numdatasets;
    end
    figure
    for k=1:1:displaydatasets
        subplot(displaydatasets,1,k)
        plot(xcorrtimestamp, abs(xcorr_data(:,k)))
        ylabel('Magnitude')
        xlabel('time offset [s]')
    end
    subplot(displaydatasets,1,1)
    title('First 10 Time-Domain Correlations')
end
      

%plot phase and time corrections
if diag    
    figure
    subplot 311
    plot(freqoffsetxcorr,'o-')
    title('Frequency Offset')
    ylabel('Freq [Hz]')
    xlabel('dataset')
    subplot 312
    plot(recoveredphasexcorr,'o-')
    title('Phase Offset')
    ylabel('Phase [rad]')
    xlabel('dataset')
    subplot 313
    plot(samplesoffsetxcorr,'o-')
    title('Time offset in samples')
    ylabel('offset [samples]')
    xlabel('dataset')
    
    figure
    histogram(freqoffsetxcorr)
    xlabel('freq [Hz]')
    ylabel('hit count')
    title('Histogram of Frequency Offsets')
end


%time and phase align data
for k = 1:1:numdatasets
    aligned_data(:,k) = [zeros([-samplesoffsetxcorr(k) 1]); freqaligneddataxcorr(max([samplesoffsetxcorr(k) 1]):end+min([samplesoffsetxcorr(k) 0]),k);zeros([samplesoffsetxcorr(k)-1 1])]./exp(i*(recoveredphasexcorr(k)));
end

if diag
    if displaydatasets > numdatasets
        displaydatasets = numdatasets;
    end
    figure
    for k=1:1:displaydatasets
        subplot(displaydatasets,1,k)
        plot(timestamp, aligned_data(:,k))
        ylabel('Magnitude')
        xlabel('time offset [s]')
    end
    subplot(displaydatasets,1,1)
    title('First 10 Phase/Freq/Time-Aligned Datasets')
end

%===========================================
%create retro-directive transmit signal
%===========================================

%create blank array of samples, 1.5s longer than the input vector.
%this creates the zero padding as well as makes the retro output of
%non-detected epochs zero.
retro = zeros([size(aligned_data,1)+1.5/srate rawdatasets]);

%time advance and phase conjugate the clock comb for each epoch
for k=1:1:numdatasets
    retro(samplesoffsetxcorr(k)+1/srate:samplesoffsetxcorr(k)+1/srate+length(clock_comb)-1,goodsets(k)) = clock_comb./exp(i*(recoveredphasexcorr(k)));
end

end