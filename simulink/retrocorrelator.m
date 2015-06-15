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
power_padding = 1; %amount of extra padding to apply to the fft
windowtype = @rectwin; %fft window type.  @triang, @rectwin, and @hamming work best
fsearchwindow_low = -100; %frequency search window low, in Hz
fsearchwindow_hi = 200; %frequency search window high, in Hz
combwindow_low = -105; %clock comb freq-domain correlation window low, in Hz
combwindow_hi = 105; %clock comb freq-domain correlation window high, in Hz

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

%DIAGNOSTICS: Display incoming Raw Data
if diag
    if displaydatasets > numdatasets
        displaydatasets = numdatasets;
    end
    
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
        plot(freqindex, abs(rnoisyfft(:,k)))
        ylabel('Magnitude')
        xlabel('Freq [Hz]')
    end
    subplot(displaydatasets,1,1)
    title('First 10 FFTs of received raw data (abs)')
    
    figure
    plot(freqindex, abs(comb_fft))
    title('FFT of Clock Comb (abs)')
    
end

%SELECTIVITY: COMPUTATION REDUCTION: Limiting the range of valid correlation
%note this assumes the comb window is narrower than the data window (this
%should always be the case).
fdata_index_low_detect = floor((fftlength_detect)/2) + round(fsearchwindow_low*srate*fftlength_detect)+1;
fdata_index_hi_detect = ceil((fftlength_detect)/2) + round(fsearchwindow_hi*srate*fftlength_detect);
fcomb_index_low_detect = floor((fftlength_detect)/2) + round(combwindow_low*srate*fftlength_detect)+1;
fcomb_index_hi_detect = ceil((fftlength_detect)/2) + round(combwindow_hi*srate*fftlength_detect);
padded_difference_detect = abs((fdata_index_hi_detect-fdata_index_low_detect+1)-(fcomb_index_hi_detect-fcomb_index_low_detect+1)); %matlab zero-pads the smaller of the two inputs to make them equal length.
fstamp_index_low_detect =  (fftlength_detect - fcomb_index_hi_detect) - padded_difference_detect + (fdata_index_low_detect-1) + 1; %the freqindex offset is equal to the number of removed samples plus 1.
fstamp_index_hi_detect = fstamp_index_low_detect + 2*(fdata_index_hi_detect-fdata_index_low_detect+1)-1-1; 
xcorrfreqstamp_full_detect = linspace(0,2/srate,fftlength_detect*2-1)-1/srate;
xcorrfreqstamp_detect = xcorrfreqstamp_full_detect(fstamp_index_low_detect:fstamp_index_hi_detect);

%Sample ranking based on frequency-domain comb correlation
for k = 1:1:numdatasets
    [xcorr_freq(:,k), lag(:,k)] = xcorr(abs(rnoisyfft(fdata_index_low_detect:fdata_index_hi_detect,k)),abs(comb_fft(fcomb_index_low_detect:fcomb_index_hi_detect)));
    noisyxcorrsnr(k) = abs(max(xcorr_freq(:,k)))/rms(abs(xcorr_freq(:,k)));
end

rawdatasets = numdatasets; %preserve the number of raw datasets
goodsets = find(noisyxcorrsnr > detect_threshold);
numdatasets = length(goodsets);

%if no good datasets found, return empty zeros
if numdatasets < 1
    aligned_data = zeros([datalength 1]);
    retro = zeros([size(aligned_data,1)+1.5/srate 1]);
    return
end

%DIAGNOSTICS: Print detection stats
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
%comb_fft = fft([window(windowtype,length(clock_comb)).*clock_comb;zeros([fftlength-length(clock_comb),1])]);
comb_fft = fft(clock_comb,fftlength);
comb_fftshift = fftshift(comb_fft);

%long data fft of raw data for frequency alignment
for k=1:1:numdatasets
    %noisyfft(:,k) = fft([window(windowtype,datalength).*noisydata(:,k);zeros([fftlength-datalength,1])]);
    noisyfft(:,k) = fft(noisydata(:,k),fftlength);
    noisyfftshift(:,k) = fftshift(noisyfft(:,k));
end

%SELECTIVITY: COMPUTATION REDUCTION: Limiting the range of valid correlation
%note this assumes the comb window is narrower than the data window (this
%should always be the case).
fdata_index_low = floor((fftlength)/2) + round(fsearchwindow_low*srate*fftlength)+1;
fdata_index_hi = ceil((fftlength)/2) + round(fsearchwindow_hi*srate*fftlength);
fcomb_index_low = floor((fftlength)/2) + round(combwindow_low*srate*fftlength)+1;
fcomb_index_hi = ceil((fftlength)/2) + round(combwindow_hi*srate*fftlength);
padded_difference = abs((fdata_index_hi-fdata_index_low+1)-(fcomb_index_hi-fcomb_index_low+1)); %matlab zero-pads the smaller of the two inputs to make them equal length.
fstamp_index_low =  (fftlength - fcomb_index_hi) - padded_difference + (fdata_index_low-1) + 1; %the freqindex offset is equal to the number of removed samples plus 1.
fstamp_index_hi = fstamp_index_low + 2*(fdata_index_hi-fdata_index_low+1)-1-1; 
xcorrfreqstamp_full = linspace(0,2/srate,fftlength*2-1)-1/srate;
xcorrfreqstamp = xcorrfreqstamp_full(fstamp_index_low:fstamp_index_hi);

%run the long xcorr for frequency alignment
for k = 1:1:numdatasets
    [xcorr_freq(:,k), lag(:,k)] = xcorr(abs(noisyfftshift(fdata_index_low:fdata_index_hi,k)),abs(comb_fftshift(fcomb_index_low:fcomb_index_hi)));
    [val(k) id(k)] = max(xcorr_freq(:,k));
    recoveredfreqphasexcorr(k) = angle(val(k));
    freqoffsetxcorr(k) = xcorrfreqstamp(id(k));
end

%frequency align data
for k = 1:1:numdatasets
    freqaligneddataxcorr(:,k) = noisydata(:,k).*(exp(i*2*pi*-freqoffsetxcorr(k)*timestamp).'); %warning: matlab ' operator transposes row/col and conjugates, use .'
    %do this in the pure fft domain
    freqalignedfft(:,k) = circshift(noisyfft(:,k),-id(k));
end

%DIAGNOSTICS: testing the freq shift fft
if diag
    figure
    for k=1:1:displaydatasets
        subplot(displaydatasets,1,k)
        plot(abs(fft(noisydata(:,k),fftlength)))
        hold on
        plot(abs(fft(freqaligneddataxcorr(:,k),fftlength)),'m')
        plot(abs(freqalignedfft(:,k)),'c')
    end
    subplot(displaydatasets,1,1)
    title('freq shift diag: original vs shifted fft)')

end
   
    

% %perform time-domain clock_comb xcorrelation
% xcorrtimestamp = [flip(-timestamp,2) timestamp(2:end)]; %zero in the middle
% for k = 1:1:numdatasets
%     xcorr_data(:,k) = xcorr(freqaligneddataxcorr(:,k),clock_comb);
%     [val id] = max(xcorr_data(:,k));
%     recoveredphasexcorr(k) = angle(val);
%     samplesoffsetxcorr(k) = id - datalength;
% end

%perform fft-version time-domain clock_comb xcorrelation
% xcorrtimestamp = linspace(-timestamp(end),timestamp(end),fftlength); %zero in the middle
for k = 1:1:numdatasets
    xcorr_data(:,k) = ifft(fft(freqaligneddataxcorr(:,k),fftlength).*conj(fft(clock_comb,fftlength)));
    %xcorr_data(:,k) = ifft(noisyfft(:,k).*conj(comb_fft));
    xcorr_data2(:,k) = [xcorr_data(end-datalength+1:end,k);xcorr_data(1:datalength+1,k)];
    [val id] = max(xcorr_data2(:,k));
    recoveredphasexcorr(k) = angle(val);
    samplesoffsetxcorr(k) = id - datalength;
end

%time and phase align data, return data
for k = 1:1:numdatasets
    aligned_data(:,k) = [zeros([-samplesoffsetxcorr(k) 1]); freqaligneddataxcorr(max([samplesoffsetxcorr(k) 1]):end+min([samplesoffsetxcorr(k) 0]),k);zeros([samplesoffsetxcorr(k)-1 1])]./exp(i*(recoveredphasexcorr(k)));
end

%DIAGNOSTICS: display Freq-Correction and Time-Correction
%Cross-Correlations, Corrections and corrected data
if diag
    if displaydatasets > numdatasets
        displaydatasets = numdatasets;
    end
    figure
    for k=1:1:displaydatasets
        subplot(displaydatasets,1,k)
        plot(xcorrfreqstamp, abs(xcorr_freq(:,k)))
        ylabel('Magnitude')
        xlabel('Freq [Hz]')
    end
    subplot(displaydatasets,1,1)
    title('First 10 Frequency-Domain Correlations for Freq Alignment (abs)')
    
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
    plot(freqoffsetxcorr,'o-')
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
retro = zeros([size(aligned_data,1)+1.5/srate rawdatasets]);

% %time advance and phase conjugate the clock comb for each epoch
% for k=1:1:numdatasets
%     retro(samplesoffsetxcorr(k)+1/srate:samplesoffsetxcorr(k)+1/srate+length(clock_comb)-1,goodsets(k)) = clock_comb./exp(i*(recoveredphasexcorr(k)));
% end

%keep it simple for testing: just a negative, phase-shifted sine way
f_retro = -20000;
for k=1:1:numdatasets
    retro(samplesoffsetxcorr(k)+1/srate:samplesoffsetxcorr(k)+1/srate+length(clock_comb)-1,goodsets(k)) = exp(i*2*pi*f_retro*timestamp_comb).*exp(i*(recoveredphasexcorr(k)));
end


if diag
    recoveredphasexcorr %print these out
    samplesoffsetxcorr %print these out
    freqoffsetxcorr %print these out
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