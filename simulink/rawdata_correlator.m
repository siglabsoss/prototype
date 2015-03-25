%USAGE:
%
%       aligned_data = rawdata_correlator(rawdata,srate,clock_comb);
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
%   - This new version of rawdata_correlator features frequency windowing
%   knobs for computational reduction.
% 
% These are useful phrases:
%   BER_coherent = 1-sum(my_cpm_demod_offline(aligned_data*ones([size(aligned_data,2) 1]),srate,100,patternvec,1) == my_cpm_demod_offline(idealdata,srate,100,patternvec,1))/length(my_cpm_demod_offline(idealdata,srate,100,patternvec,1))
%   BER_single_antenna = 1-sum(my_cpm_demod_offline(aligned_data(:,1),srate,100,patternvec,1) == my_cpm_demod_offline(idealdata,srate,100,patternvec,1))/length(my_cpm_demod_offline(idealdata,srate,100,patternvec,1))
%

%todo:
% convert to clock comb xcorr for signal finding in presense of interferers
% write a generic goodsets function
% do not pad the pre-selection fft DONE
% fft data reduction by bandlimiting DONE
% add an on/off for plots
% consider using nextpow2 with 0 power padding for the ranking xcorr (but
% be careful of windowing issues) DONE
% turn for loop operations into matrix operations
% or turn for loops into parallel for loops

function aligned_data = rawdata_correlator(rawdata,srate,clock_comb,detect_threshold)

starttime = datetime;

%main knobs
power_padding = 3; %amount of extra padding to apply to the fft
xcorrdetect = detect_threshold; %max peak to rms ratio for clock comb xcorr search
windowtype = @triang; %fft window type.  @triang, @rectwin, and @hamming work best
fsearchwindow_low = -100; %frequency search window low, in Hz
fsearchwindow_hi = 200; %frequency search window high, in Hz
combwindow_low = -105; %clock comb freq-domain correlation window low, in Hz
combwindow_hi = 105; %clock comb freq-domain correlation window high, in Hz
%time-domain frequency correction features
freqstep = 0.25;
numsteps = 3;

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
fftlength = 2^(nextpow2(datalength)+power_padding);
timestamp_comb = 0:srate:(length(clock_comb)-1)*srate;
fftlength_detect = 2^(nextpow2(datalength)); %reduced fftlength for signal detection stage.

figure
for k = 1:1:displaydatasets
    subplot(displaydatasets,1,k)
    plot(timestamp,real(rnoisydata(:,k)))
    xlim([0 1])
    ylim([-0.5 0.5].*1e-3)
end
subplot(displaydatasets,1,1)
title('First 10 chunks of raw data received at antennas (Real)')
subplot(displaydatasets,1,displaydatasets)
xlabel('Time [s]')

figure
incoherentsum = rnoisydata * ones([size(rnoisydata,2) 1]);
plot(timestamp, real(incoherentsum))
title('Incoherent Sum of Signals (Real)')
xlabel('Time [s]')

%short fft of raw data for detection %ADDED FFT SHIFT HERE for indexing
for k=1:1:numdatasets
    rnoisyfft(:,k) = fftshift(fft([window(windowtype,datalength).*rnoisydata(:,k);zeros([fftlength_detect-datalength,1])]));
    noisyfftsnr(k) = abs(max(rnoisyfft(:,k)))/rms(rnoisyfft(:,k));
end

%create the reduced comb fft for detection %ADDED FFT SHIFT HERE for indexing
freqindex = linspace(0,1/srate,fftlength_detect)-1/srate/2;
comb_fft = fftshift(fft([window(windowtype,length(clock_comb)).*clock_comb;zeros([fftlength_detect-length(clock_comb),1])]));

%plot the first 10 ffts
figure
for k=1:1:displaydatasets
    subplot(displaydatasets,1,k)
    plot(freqindex,abs(rnoisyfft(:,k)))
    xlabel('Hz')
end
subplot(displaydatasets,1,1)
title('FFT of First 10 Raw Datasets')

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


%{
%NON-ABS version
for k = 1:1:numdatasets
    [xcorr_freq(:,k), lag(:,k)] = xcorr(rnoisyfft(fsearch_index_low:fsearch_index_hi,k),comb_fft(combwindow_index_low:combwindow_index_hi));
    noisyxcorrsnr(k) = abs(max(xcorr_freq(:,k)))/rms(abs(xcorr_freq(:,k)));
end
%}


%ABS Version
for k = 1:1:numdatasets
    [xcorr_freq(:,k), lag(:,k)] = xcorr(abs(rnoisyfft(fsearch_index_low:fsearch_index_hi,k)),abs(comb_fft(combwindow_index_low:combwindow_index_hi)));
    noisyxcorrsnr(k) = abs(max(xcorr_freq(:,k)))/rms(abs(xcorr_freq(:,k)));
end


goodsets = find(noisyxcorrsnr > xcorrdetect);
number_of_good_datasets = length(goodsets) %print out the number of good datasets found

displaydatasets = min([displaydatasets number_of_good_datasets]);

%plot of the signal detection results
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

%plot a few of the the correlations
figure
for k = 1:1:displaydatasets
    subplot(displaydatasets,1,k)
    plot(xcorr_fstamp_fsearch,abs(xcorr_freq(:,k)))
end
xlabel('Freq [Hz]')
subplot(displaydatasets,1,1)
title('Freq-Domain Cross Correlation of First 10 datasets')

%CLEANUP: reduce to just the good datasets
for k = 1:length(goodsets)
    noisydata(:,k) = rnoisydata(:,goodsets(k));
end

%CLEANUP: remove from memory
numdatasets = length(goodsets);
clear xcorr_freq
clear xcorrfreqstamp
clear comb_fft
clear rnoisyfft
clear rnoisydata
clear lag

displaydatasets = min(displaydatasets,numdatasets);

figure
for k = 1:displaydatasets
    subplot(displaydatasets,1,k);
    plot(timestamp,real(noisydata(:,k)))
end
subplot(displaydatasets,1,1)
title('First 10 Raw Datasets Where Signal Found (real)')
subplot(displaydatasets,1,displaydatasets)
xlabel('Time [s]')

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


%{
%NON-ABS VERSION:
%run the long xcorr for frequency alignment
for k = 1:1:numdatasets
    [xcorr_freq(:,k), lag(:,k)] = xcorr(noisyfft(fsearch_index_low:fsearch_index_hi,k),comb_fft(combwindow_index_low:combwindow_index_hi));
    [val id] = max(xcorr_freq(:,k));
    recoveredfreqphasexcorr(k) = angle(val);
    freqoffsetxcorr(k) = xcorr_fstamp_fsearch(id);
end
%}


%ABS VERSION:
%run the long xcorr for frequency alignment
for k = 1:1:numdatasets
    [xcorr_freq(:,k), lag(:,k)] = xcorr(abs(noisyfft(fsearch_index_low:fsearch_index_hi,k)),abs(comb_fft(combwindow_index_low:combwindow_index_hi)));
    [val id] = max(xcorr_freq(:,k));
    recoveredfreqphasexcorr(k) = angle(val);
    freqoffsetxcorr(k) = xcorr_fstamp_fsearch(id);
end



%plot the fft xcorr of the samples with the comb
figure
for k = 1:1:displaydatasets
    subplot(displaydatasets,1,k)
    plot(xcorr_fstamp_fsearch,abs(xcorr_freq(:,k)))
end
subplot(displaydatasets,1,1)
title('First 10 Freq-Domain Correlations of Noisy Data with Clock Comb (abs val)')
subplot(displaydatasets,1,displaydatasets)
xlabel('Frequency Offset [Hz]')

%frequency align data
for k = 1:1:numdatasets
    freqaligneddataxcorr(:,k) = noisydata(:,k).*(exp(i*2*pi*freqoffsetxcorr(k)*timestamp)');
end

freqaligneddataxcorr = frequency_enhance(freqaligneddataxcorr,clock_comb,timestamp,freqstep,numsteps);

%plot frequency aligned data
figure
for k = 1:1:displaydatasets
    subplot(displaydatasets,1,k)
    plot(timestamp, real(freqaligneddataxcorr(:,k)))
end
subplot(displaydatasets,1,1)
title('First 10 Frequency-Aligned Data (Real)')
subplot(displaydatasets,1,displaydatasets)
xlabel('Time [s]')

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