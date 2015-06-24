% Perform correlation search for a single epoch of data against a known
% comb, and return the data aligned to the comb, if an epoch is detected.  
% Retuns zeros if no epoch is detected.  fxcorrelator_single can be run on am
% array of RF chunks, one in each column.
%
% USAGE:
%
%       [aligned_data retro] = retrocorrelator_octave(rawdata,srate,clock_comb,detect_threshold);
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

function [aligned_data retro numdatasets retrostart retroend samplesoffset] = retrocorrelator_octave(rawdata,srate,clock_comb,reply_data,detect_threshold,fsearchwindow_low,fsearchwindow_hi)

%diagnostic functions
diag = 0;
displaydatasets = 4;
if diag
    close all
end

edwin_timer = clock;
service_all();
% disp(sprintf('t0 %g', etime(clock,edwin_timer)));

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
% fsearchwindow_low = -200 + 10E3; %frequency search window low, in Hz
% fsearchwindow_hi = 200 + 10E3; %frequency search window high, in Hz
combwindow_low = -105; %clock comb freq-domain correlation window low, in Hz
combwindow_hi = 105; %clock comb freq-domain correlation window high, in Hz
%time-domain frequency correction features
freqstep = 0.25;
numsteps = 3;
silence_padding_factor = 0.4; % a factor of fs which is added to the window

datalength = size(rawdata,1);
numdatasets = size(rawdata,2);
timestamp = 0:srate:(datalength-1)*srate;
fftlength = 2^(nextpow2(datalength)+power_padding);
timestamp_comb = 0:srate:(length(clock_comb)-1)*srate;
fftlength_detect = 2^(nextpow2(datalength)); %reduced fftlength for signal detection stage.
retrostart = -1;
retroend = -1;
samplesoffset = -1;

%short fft of raw data for detection %ADDED FFT SHIFT HERE for indexing
for k=1:1:numdatasets
    rnoisyfft(:,k) = fftshift(fft([window(windowtype,datalength).*rawdata(:,k);zeros([fftlength_detect-datalength,1])]));
    noisyfftsnr(k) = abs(max(rnoisyfft(:,k)))/o_rms(rnoisyfft(:,k));
end

service_all();
% disp(sprintf('t1 %g', etime(clock,edwin_timer)));

%create the reduced comb fft for detection %ADDED FFT SHIFT HERE for indexing
freqindex = linspace(0,1/srate,fftlength_detect)-1/srate/2;
comb_fft = fftshift(fft([window(windowtype,length(clock_comb)).*clock_comb;zeros([fftlength_detect-length(clock_comb),1])]));

service_all();
% disp(sprintf('t2 %g', etime(clock,edwin_timer)));


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
    title('First 4 chunks of received raw data (real)')
    
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
    title('First 4 FFTs of received raw data (abs)')
    
    figure
    plot(freqindex, abs(comb_fft))
    title('FFT of Clock Comb (abs)')
    
end


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
    noisyxcorrsnr(k) = abs(max(xcorr_freq(:,k)))/o_rms(xcorr_freq(:,k));
end

service_all();
% disp(sprintf('t3 %g', etime(clock,edwin_timer)));

rawdatasets = numdatasets; %preserve the number of raw datasets
goodsets = find(noisyxcorrsnr > detect_threshold);
numdatasets = length(goodsets);

%diagnostics
%{
%close all
figure
subplot(2,1,1)
plot(noisyxcorrsnr,'o')
hold on
plot(goodsets,noisyxcorrsnr(goodsets),'mo')
xlabel('Data Chunk Index')
ylabel('Comb Correlation SNR')
subplot(2,1,2)
hist(noisyxcorrsnr,20)
xlabel('xcorr SNR value')
ylabel('hit count')
subplot(2,1,1)
title('Plot and Histogram of SNR used for Signal Detection')
%}

if numdatasets < 1
    aligned_data = zeros([datalength 1]);
    retro = zeros([size(aligned_data,1)+silence_padding_factor/srate 1]);
    return
end

noisyxcorrsnr

service_all();
% disp(sprintf('t4 %g', etime(clock,edwin_timer)));

%DIAGNOSTICS: Print detection stats
if diag 
    figure
    subplot(2,1,1)
    plot(noisyxcorrsnr,'o')
    hold on
    plot(goodsets,noisyxcorrsnr(goodsets),'mo')
    xlabel('Data Chunk Index')
    ylabel('Comb Correlation SNR')
    subplot(2,1,2)
    hist(noisyxcorrsnr,20)
    xlabel('xcorr SNR value')
    ylabel('hit count')
    subplot(2,1,1)
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

service_all();
% disp(sprintf('t5 %g', etime(clock,edwin_timer)));

%long comb fft for frequency alignment
freqindex = linspace(0,1/srate,fftlength)-1/srate/2;
comb_fft = fftshift(fft([window(windowtype,length(clock_comb)).*clock_comb;zeros([fftlength-length(clock_comb),1])]));

service_all();
% disp(sprintf('t6 %g', etime(clock,edwin_timer)));

%long data fft of raw data for frequency alignment
for k=1:1:numdatasets
    noisyfft(:,k) = fftshift(fft([window(windowtype,datalength).*noisydata(:,k);zeros([fftlength-datalength,1])]));
end

service_all();
% disp(sprintf('t7 %g', etime(clock,edwin_timer)));

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

service_all();
% disp(sprintf('t8 %g', etime(clock,edwin_timer)));

%frequency align data
for k = 1:1:numdatasets
    freqaligneddataxcorr(:,k) = noisydata(:,k).*(exp(1i*2*pi*freqoffsetxcorr(k)*timestamp)');
end

service_all();
% disp(sprintf('t9 %g', etime(clock,edwin_timer)));

%time domain correlation for better frequency accuracy
% removed frequency_enhance at edwins request...
% freqaligneddataxcorr = frequency_enhance(freqaligneddataxcorr,clock_comb,timestamp,freqstep,numsteps);

% service_all();
% disp(sprintf('t10 %g', etime(clock,edwin_timer)));


%perform time-domain clock_comb xcorrelation
timestampflip = (datalength-1)*srate:-srate:0;
xcorrtimestamp = [-timestampflip, timestamp(2:end)]; %zero in the middle %note flip doesn't work in octave
for k = 1:1:numdatasets
    xcorr_data(:,k) = xcorr(freqaligneddataxcorr(:,k),clock_comb);
    [val id] = max(xcorr_data(:,k));
    recoveredphasexcorr(k) = angle(val);
    samplesoffsetxcorr(k) = id - datalength;
end

service_all();
% disp(sprintf('t11 %g', etime(clock,edwin_timer)));
%plot phase and time corrections
%{
figure
subplot(2,1,1)
plot(recoveredphasexcorr,'o-')
title('Phase Offset')
ylabel('Phase [rad]')
xlabel('dataset')
subplot(2,1,2)
plot(samplesoffsetxcorr,'o-')
title('Time offset in samples')
ylabel('offset [samples]')
xlabel('dataset')
%}

%time and phase align data
for k = 1:1:numdatasets
    aligned_data(:,k) = [zeros([-samplesoffsetxcorr(k) 1]); freqaligneddataxcorr(max([samplesoffsetxcorr(k) 1]):end+min([samplesoffsetxcorr(k) 0]),k);zeros([samplesoffsetxcorr(k)-1 1])]./exp(1i*(recoveredphasexcorr(k)));
end

service_all();

%DIAGNOSTICS: display Freq-Correction and Time-Correction
%Cross-Correlations, Corrections and corrected data
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
    title('First 4 Frequency-Domain Correlations for Freq Alignment (abs)')
    
    figure
    for k=1:1:displaydatasets
        subplot(displaydatasets,1,k)
        plot(xcorrtimestamp, abs(xcorr_data(:,k)))
        ylabel('Magnitude')
        xlabel('Time [s]')
    end
    subplot(displaydatasets,1,1)
    title('First 4 Time-Domain Correlations for Time/Phase Alignment')
    
    figure
    subplot(3,1,1)
    plot(freqoffsetxcorr,'o-')
    title('Frequency Offset Correction Applied')
    ylabel('Freq [Hz]')
    xlabel('dataset')
    subplot(3,1,2)
    plot(recoveredphasexcorr,'o-')
    title('Phase Offset Correction Applied')
    ylabel('Phase [rad]')
    xlabel('dataset')
    subplot(3,1,3)
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
    title('First 4 Frequency-, Time-, and Phase-Aligned Datasets (real)')
end

% disp(sprintf('t12 %g', etime(clock,edwin_timer)));

%===========================================
%create retro-directive transmit signal
%===========================================

%create blank array of samples, silence_padding_factor (1.5) seconds longer than the input vector.
%this creates the zero padding as well as makes the retro output of
%non-detected epochs zero.
retro = zeros([size(aligned_data,1)+silence_padding_factor/srate rawdatasets]);


%if( length(clock_comb) ~= length(reply_data) )
%    disp('edwin help!');
%end

%time advance and phase conjugate the clock comb for each epoch
%NEED TO GENERALIZE THIS TO SINGLE SAMPLES
samplesoffset = samplesoffsetxcorr;
for k=1:1:numdatasets
    retrostart = samplesoffsetxcorr(k)+round(1/srate);
    retroend = samplesoffsetxcorr(k)+round(1/srate)+length(clock_comb)-1;
    retro(retrostart : retroend, goodsets(k)) = reply_data./exp(1i*(recoveredphasexcorr(k)));
%     retro(retrostart : retroend, goodsets(k)) = clock_comb;
end

service_all();
% disp(sprintf('t13 %g', etime(clock,edwin_timer)));
end