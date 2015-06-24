% Perform correlation search for a single epoch of data against a known
% comb, and return the data aligned to the comb, if an epoch is detected.  
% Retuns zeros if no epoch is detected.  fxcorrelator_single can be run on am
% array of RF chunks, one in each column.
%
% USAGE:
%
%       aligned_data = retrocorrelator(rawdata,srate,clock_comb,detect_threshold, retroreference);
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


function [aligned_data retro] = retrocorrelator(rawdata,srate,clock_comb,detect_threshold)

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
power_padding = 1; %amount of extra padding to apply to the fft %power padding needs to be at least 1, to ensure at least 2x size of data for full time-domain xcorr
fsearchwindow_low = -100; %frequency search window low, in Hz
fsearchwindow_hi = 200; %frequency search window high, in Hz
combwindow_low = -105; %clock comb freq-domain correlation window low, in Hz
combwindow_hi = 105; %clock comb freq-domain correlation window high, in Hz

%computing basic information
datalength = size(rawdata,1);
numdatasets = size(rawdata,2);
timestamp = (0:srate:(datalength-1)*srate);
timestamp_comb = 0:srate:(length(clock_comb)-1)*srate;
fftlength = 2^(nextpow2(datalength)+power_padding);

%take fft of data
data_fft = fft(rawdata, fftlength); %operates column wise if input is a matrix

%take fft of clock_comb
comb_fft = fft(clock_comb,fftlength);

%DIAGNOSTICS: Display incoming Raw Data
if diag
    if displaydatasets > numdatasets
        displaydatasets = numdatasets;
    end
    
    freqindex = linspace(0,1/srate,fftlength)-1/srate/2;
    
    figure
    for k=1:1:displaydatasets
        subplot(displaydatasets,1,k)
        plot(timestamp, real(rawdata(:,k)))
        ylabel('Magnitude')
        xlabel('Time [s]')
    end
    subplot(displaydatasets,1,1)
    title('First 10 chunks of received raw data (real)')
    
    figure
    plot(timestamp_comb, real(clock_comb))
    title('Clock Comb (real)')
    
    figure
    for k=1:1:displaydatasets
        subplot(displaydatasets,1,k)
        plot(freqindex, abs(fftshift(data_fft(:,k))))
        ylabel('Magnitude')
        xlabel('Freq [Hz]')
    end
    subplot(displaydatasets,1,1)
    title('First 10 FFTs of received raw data (abs)')
    
    figure
    plot(freqindex, abs(fftshift(comb_fft)))
    title('FFT of Clock Comb (abs)')
    
end

%SELECTIVITY: Limiting the range of valid correlation
fdata_index_low = floor((fftlength)/2) + round(fsearchwindow_low*srate*fftlength)+1;
fdata_index_hi = ceil((fftlength)/2) + round(fsearchwindow_hi*srate*fftlength);
fcomb_index_low = floor((fftlength)/2) + round(combwindow_low*srate*fftlength)+1;
fcomb_index_hi = ceil((fftlength)/2) + round(combwindow_hi*srate*fftlength);
fxcorr_index_low = fftlength-fcomb_index_hi+fdata_index_low;
fxcorr_index_hi = fxcorr_index_low + fdata_index_hi - fcomb_index_low + fcomb_index_hi - fcomb_index_low;
xcorrfreqstamp = linspace(0,2/srate,fftlength*2-1)-1/srate;

%frequency mask comb and shift zero freq to center
comb_fmask = zeros(fftlength,1);
comb_fmask(fcomb_index_low:fcomb_index_hi,1) = 1; %mask according to freq limits
masked_comb_fft = fftshift(comb_fft).*comb_fmask;

%frequency mask data
data_fmask = zeros(fftlength,1);
data_fmask(fdata_index_low:fdata_index_hi,1) = 1; %mask according to freq limits
masked_data_fft = fftshift(data_fft).*(data_fmask*ones(1,numdatasets));

%cross-correlate abs of masked frequency spectra using fft
fxcorr = ifft(fft(abs(masked_data_fft),fftlength*2).*(conj(fft(abs(masked_comb_fft),fftlength*2))*ones(1,numdatasets))); %perform correlation
fxcorr = [fxcorr(end-fftlength+2:end,:);fxcorr(1:fftlength,:)]; %limit to original input length

%Sample ranking based on frequency-domain comb correlation
%operates column wise if input is a matrix
[fxcorr_max_val,fxcorr_max_id] = max(fxcorr);
fxcorrsnr = abs(fxcorr_max_val)./rms(abs(fxcorr(fxcorr_index_low:fxcorr_index_hi))); %reduce to only valid window to make snr normalization correct
freqoffset = xcorrfreqstamp(fxcorr_max_id(k));

%index the good sets.
goodsets = find(fxcorrsnr > detect_threshold); %select good sets
numgoodsets = length(goodsets); %set a new numdatasets

%DIAGNOSTICS: Print detection stats
if diag 
    
    figure
    for k=1:1:displaydatasets
        subplot(displaydatasets,1,k)
        plot(xcorrfreqstamp(fxcorr_index_low:fxcorr_index_hi), abs(fxcorr(fxcorr_index_low:fxcorr_index_hi,k)))
        ylabel('Magnitude')
        xlabel('Freq [Hz]')
    end
    subplot(displaydatasets,1,1)
    title('First 10 Frequency-Domain Correlations for Freq Alignment (abs)')
    
    figure
    subplot 211
    plot(fxcorrsnr,'o')
    hold on
    plot(goodsets,fxcorrsnr(goodsets),'mo')
    xlabel('Data Chunk Index')
    ylabel('Comb Correlation SNR')
    subplot 212
    histogram(fxcorrsnr,20)
    xlabel('xcorr SNR value')
    ylabel('hit count')
    subplot 211
    title('Plot and Histogram of SNR used for Signal Detection')
end

%if no good datasets found, return empty zeros
if numgoodsets < 1
    aligned_data = zeros([datalength 1]);
    retro = zeros([size(aligned_data,1)+1.5/srate 1]);
    return
end

%frequency align data (reduces to just the goodsets at this point)
for k = 1:1:numgoodsets
    freqalignedfft(:,k) = circshift(data_fft(:,goodsets(k)),-fxcorr_max_id(goodsets(k))); %note: in order for this to work, both ffts must be the same length
end
   
%perform fft-version time-domain clock_comb xcorrelation
txcorr = ifft(freqalignedfft.*(conj(comb_fft*ones(1,numgoodsets)))); %note that fftlength has to be > 2*datalength for this to work
txcorr = [txcorr(end-datalength+2:end,:);txcorr(1:datalength,:)]; %limit to original data length
[txcorr_max_val,txcorr_max_id] = max(txcorr); %find peak
phaseoffset = angle(txcorr_max_val); %recover phase offset
samplesoffset = txcorr_max_id - datalength; %recover time offset

%ALIGN ALL: freq, time and phase align data, return data
startindex = max([samplesoffset;ones(1,numgoodsets)]);
stopindex = datalength+min([samplesoffset;zeros(1,numgoodsets)]);

aligned_data = zeros(datalength,numgoodsets); %initialize aligned_data output matrix
for k = 1:1:numgoodsets
    aligned_data(:,k) = [zeros([-samplesoffset(k) 1]); rawdata(startindex:stopindex,goodsets(k)).*exp(i*2*pi*-freqoffset(goodsets(k))*timestamp(startindex:stopindex).');zeros([samplesoffset(k)-1 1])]./exp(i*(phaseoffset(k))); %remember freqoffset is numdatasets (not numgoodsets) wide.
end

%DIAGNOSTICS: display Freq-Correction and Time-Correction
%Cross-Correlations, Corrections and corrected data
if diag
    if displaydatasets > numgoodsets
        displaydatasets = numgoodsets;
    end
    
    xcorrtimestamp = [flip(-timestamp,1);timestamp(2:end)]; %zero in the middle
    
    figure
    for k=1:1:displaydatasets
        subplot(displaydatasets,1,k)
        plot(xcorrtimestamp, abs(xcorr_data(:,k)))
        ylabel('Magnitude')
        xlabel('Time [s]')
    end
    subplot(displaydatasets,1,1)
    title('First 10 Time-Domain Correlations for Time/Phase Alignment')
    
    figure
    subplot 311
    plot(freqoffset,'o-')
    title('Frequency Offset Correction Applied')
    ylabel('Freq [Hz]')
    xlabel('dataset')
    subplot 312
    plot(recoveredphasexcorr,'o-')
    title('Phase Offset Correction Applied')
    ylabel('Phase [rad]')
    xlabel('dataset')
    subplot 313
    plot(samplesoffsetxcorr,'o-')
    title('Time Offset Correction Applied')
    ylabel('Time [samples]')
    xlabel('dataset')
    
    figure
    for k=1:1:displaydatasets
        subplot(displaydatasets,1,k)
        plot(timestamp, real(aligned_data(:,k)))
        ylabel('Magnitude')
        xlabel('Time [s]')
    end
    subplot(displaydatasets,1,1)
    title('First 10 Frequency-, Time-, and Phase-Aligned Datasets (real)')
end

%===========================================
%create retro-directive transmit signal
%===========================================

%create blank array of samples, 1.5s longer than the input vector.
%this creates the zero padding as well as makes the retro output of
%non-detected epochs zero.
retro = zeros([size(aligned_data,1)+1.5/srate numdatasets]);

%time advance and phase conjugate the clock comb for each epoch
for k=1:1:numdatasets
    retro(samplesoffset(k)+1/srate:samplesoffset(k)+1/srate+length(clock_comb)-1,goodsets(k)) = clock_comb./exp(i*(phaseoffset(k)));
end

if diag
    phaseoffset %print these out
    samplesoffset %print these out
    freqoffset %print these out
    retro_time = 0:srate:(size(retro,1)-1)*srate;
    figure
    for k=1:1:displaydatasets
        subplot(displaydatasets,1,k)
        plot(retro_time, real(retro(:,k)),'r')
        ylabel('Magnitude')
        xlabel('Time [s]')
    end
    subplot(displaydatasets,1,1)
    title('First 10 Retrodirective Return Signals (real)')
end

end