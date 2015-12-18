% Perform correlation search for a single epoch of data against a known
% comb, and return the data aligned to the comb, if an epoch is detected.  
% Retuns zeros if no epoch is detected.  fxcorrelator_single can be run on am
% array of RF chunks, one in each column.
%
% USAGE:
%
%       [aligned_data retro] = retrocorrelator(rawdata,srate,clock_comb);
%
% OPTIONAL INPUTS:
% 
%       [aligned_data retro] = retrocorrelator(rawdata,srate,clock_comb,detect_threshold,reply_data,fsearchwindow_low,fsearchwindow_hi,retro_go,weighting_factor);
%
% OPTIONAL OUTPUTS:
%       
%       [aligned_data retro retrostart retroend fxcorrsnr goodsets freqoffset phaseoffset samplesoffset] = retrocorrelator(rawdata,srate,clock_comb);
% 
% detect_threshold,reply_data,fsearchwindow_low,fsearchwindow_hi,retro_go,
% weighting_factor are optional.  Defaults will be used if not 
% specified.
%
% rawdata is complex input data at srate.  rawdata must be longer than 
% clock_comb.  If rawdata is an array, each chunk of rawdata should be in
% column form.
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
% delayed exactly 1s from the starting epoch of the input signal.  By
% default it returns the clock comb with conjugated phase.


function [aligned_data retro retrostart retroend fxcorrsnr goodsets freqoffset phaseoffset samplesoffset] = retrocorrelator_verbose(rawdata,srate,clock_comb,varargin)

%verbose function settings
numplots = 6;

%convenience: input handling
%assign defaults
detect_threshold = 2.5;
reply_data = clock_comb;
fsearchwindow_low = -100; %frequency search window low, in Hz
fsearchwindow_hi = 200; %frequency search window high, in Hz
retro_go = 1;
weighting_factor = 0;

%serve optional arguments
switch nargin
    case 4
        detect_threshold = varargin{1};
    case 5
        detect_threshold = varargin{1};
        clear reply_data;
        reply_data = varargin{2};
    case 6
        detect_threshold = varargin{1};
        clear reply_data;
        reply_data = varargin{2};
        fsearchwindow_low = varargin{3};
    case 7
        detect_threshold = varargin{1};
        clear reply_data;
        reply_data = varargin{2};
        fsearchwindow_low = varargin{3};
        fsearchwindow_hi = varargin{4};
    case 8
        detect_threshold = varargin{1};
        clear reply_data;
        reply_data = varargin{2};
        fsearchwindow_low = varargin{3};
        fsearchwindow_hi = varargin{4};
        retro_go = varargin{5};
    case 9
        detect_threshold = varargin{1};
        clear reply_data;
        reply_data = varargin{2};
        fsearchwindow_low = varargin{3};
        fsearchwindow_hi = varargin{4};
        retro_go = varargin{5};
        weighting_factor = varargin{6};       
end
        
%check for rawdata and comb to be in column form
if size(rawdata,2) > size(rawdata,1)
    rawdata = rawdata';
end
if size(clock_comb,2) > size(clock_comb,1)
    clock_comb = clock_comb';
end

    

%internal knobs
power_padding = 1; %amount of extra padding to apply to the fft %power padding needs to be at least 1, to ensure at least 2x size of data for full time-domain xcorr
combwindow_low = -105; %clock comb freq-domain correlation window low, in Hz
combwindow_hi = 105; %clock comb freq-domain correlation window high, in Hz
silence_padding_factor = 0.4; % a factor of fs which is added to the window

%computing basic information
datalength = size(rawdata,1);
numdatasets = size(rawdata,2);
timestamp = (0:srate:(datalength-1)*srate).'; %easier if these are columns
timestamp_comb = (0:srate:(length(clock_comb)-1)*srate).'; %easier if these are columns
fftlength = 2^(nextpow2(datalength)+power_padding);


%plot raw data
figure
for k = 1:1:min(numplots,numdatasets)
    subplot(min(numplots,numdatasets),1,k)
    plot(timestamp, real(rawdata(:,k)))
end
subplot(min(numplots,numdatasets),1,1)
title('First 6 Raw Data Inputs (Real)')
subplot(min(numplots,numdatasets),1,min(numplots,numdatasets))
xlabel('time [s]')
ylabel('magnitude [counts]')

%take fft of data
data_fft = fft(rawdata, fftlength); %operates column wise if input is a matrix

%take fft of clock_comb
comb_fft = fft(clock_comb,fftlength);

%plot data fft
figure
for k = 1:1:min(numplots,numdatasets)
    subplot(min(numplots,numdatasets),1,k)
    plot(real(fftshift(data_fft(:,k))))
end
subplot(min(numplots,numdatasets),1,1)
title('First 6 FFTs of Data (Real)')
subplot(min(numplots,numdatasets),1,min(numplots,numdatasets))
xlabel('samples')
ylabel('magnitude [counts]')

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
masked_data_fft = fftshift(data_fft,1).*(data_fmask*ones(1,numdatasets));

%cross-correlate abs of masked frequency spectra using fft
fxcorr = ifft(fft(abs(masked_data_fft),fftlength*2).*(conj(fft(abs(masked_comb_fft),fftlength*2))*ones(1,numdatasets))); %perform correlation

%plot FXCORR
figure
for k = 1:1:min(numplots,numdatasets)
    subplot(min(numplots,numdatasets),1,k)
    plot(abs(fftshift(fxcorr(:,k))))
end
subplot(min(numplots,numdatasets),1,1)
title('First 6 Frequency-Domain Correlations (Abs)')
subplot(min(numplots,numdatasets),1,min(numplots,numdatasets))
xlabel('samples')
ylabel('magnitude [counts]')

fxcorr = [fxcorr(end-fftlength+2:end,:);fxcorr(1:fftlength,:)]; %limit to original input length



%Sample ranking based on frequency-domain comb correlation
%operates column wise if input is a matrix
[fxcorr_max_val,fxcorr_max_id] = max(fxcorr(fxcorr_index_low:fxcorr_index_hi,:)); %limited to valid window
fxcorrsnr = abs(fxcorr_max_val)./rms(abs(fxcorr(fxcorr_index_low:fxcorr_index_hi,:))); %reduce to only valid window to make snr normalization correct
fxcorr_max_id = fxcorr_max_id + fxcorr_index_low - 1; %return to original index referenced to original fft
freqoffset = xcorrfreqstamp(fxcorr_max_id);

%index the good sets.
goodsets = find(fxcorrsnr > detect_threshold); %select good sets
numgoodsets = length(goodsets); %set a new numdatasets

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

%plot TXCORR
figure
for k = 1:1:min(numplots,numgoodsets)
    subplot(min(numplots,numgoodsets),1,k)
    plot(abs(txcorr(:,k)))
end
subplot(min(numplots,numgoodsets),1,1)
title('First 6 Time-Domain Correlations (Abs)')
subplot(min(numplots,numgoodsets),1,min(numplots,numgoodsets))
xlabel('samples')
ylabel('magnitude [counts]')

[txcorr_max_val,txcorr_max_id] = max(txcorr); %find peak
phaseoffset = angle(txcorr_max_val); %recover phase offset
samplesoffset = txcorr_max_id - datalength; %recover time offset

%ALIGN ALL: freq, time and phase align data, return data
startindex = max([samplesoffset;ones(1,numgoodsets)]);
stopindex = datalength+min([samplesoffset;zeros(1,numgoodsets)]);

aligned_data = zeros(datalength,numgoodsets); %initialize aligned_data output matrix
for k = 1:1:numgoodsets
    aligned_data(:,k) = [zeros([-samplesoffset(k) 1]); rawdata(startindex(k):stopindex(k),goodsets(k)).*exp(i*2*pi*-freqoffset(goodsets(k))*timestamp(startindex(k):stopindex(k)));zeros([samplesoffset(k)-1 1])]./exp(i*(phaseoffset(k))); %remember freqoffset is numdatasets (not numgoodsets) wide.
end

%===========================================
%create retro-directive transmit signal
%===========================================

%create blank array of samples, 1.5s longer than the input vector.
%this creates the zero padding as well as makes the retro output of
%non-detected epochs zero.
retro = zeros([size(aligned_data,1)+round(silence_padding_factor/srate) numdatasets]);

%time advance and phase conjugate the clock comb for each epoch
retrostart = samplesoffset+round(1/srate);
retroend = samplesoffset+round(1/srate)+length(clock_comb)-1;
for k=1:1:numgoodsets
    if retro_go
        retro(retrostart(k):retroend(k),goodsets(k)) = reply_data./exp(1i*(phaseoffset(k)));
    else
        retro(retrostart(k):retroend(k),goodsets(k)) = reply_data;
    end
end

end