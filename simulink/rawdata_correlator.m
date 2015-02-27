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

function aligned_data = rawdata_correlator(rawdata,srate,clock_comb)

%main knobs
power_padding = 3; %amount of extra padding to apply to the fft
xcorrdetect = 4.6; %max peak to rms ratio for clock comb xcorr search
windowtype = @triang; %fft window type.  @triang, @rectwin, and @hamming work best

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
end
subplot(displaydatasets,1,1)
title('First 10 chunks of raw data received at antennas (Real)')
xlabel('Time [s]')
ylabel('Magnitude (Ettus Reported)')

%short fft of raw data for detection
for k=1:1:numdatasets
    rnoisyfft(:,k) = fft([window(windowtype,datalength).*rnoisydata(:,k);zeros([fftlength_detect-datalength,1])]);
    noisyfftsnr(k) = abs(max(rnoisyfft(:,k)))/abs(rms(rnoisyfft(:,k)));
end

%create the reduced comb fft for detection
freqindex = linspace(0,1/srate,fftlength_detect)-1/srate/2;
comb_fft = fft([window(windowtype,length(clock_comb)).*clock_comb;zeros([fftlength_detect-length(clock_comb),1])]);

%Sample ranking based on frequency-domain comb correlation
xcorrfreqstamp = linspace(0,2/srate,fftlength_detect*2-1)-1/srate;
for k = 1:1:numdatasets
    [xcorr_freq(:,k), lag(:,k)] = xcorr(abs(fftshift(rnoisyfft(:,k))),abs(fftshift(comb_fft)));
    noisyxcorrsnr(k) = abs(max(xcorr_freq(:,k)))/abs(rms(xcorr_freq(:,k)));
end
goodsets = find(noisyxcorrsnr > xcorrdetect);
number_of_good_datasets = length(goodsets) %print out the number of good datasets found

%plot of the signal detection results
figure
plot(noisyxcorrsnr,'o-')
xlabel('Data Chunk Index')
ylabel('Comb Correlation SNR')

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

figure
for k = 1:displaydatasets
    subplot(displaydatasets,1,k);
    plot(timestamp,real(noisydata(:,k)))
end
subplot(displaydatasets,1,1)
title('First 10 Raw Datasets Where Signal Found (real)')
subplot(displaydatasets,1,displaydatasets)
xlabel('Time [s]')

%long comb fft for phase/time alignment
freqindex = linspace(0,1/srate,fftlength)-1/srate/2;
comb_fft = fft([window(windowtype,length(clock_comb)).*clock_comb;zeros([fftlength-length(clock_comb),1])]);

%long data fft of raw data for detection for phase/time alignment
for k=1:1:numdatasets
    noisyfft(:,k) = fft([window(windowtype,datalength).*noisydata(:,k);zeros([fftlength-datalength,1])]);
end

%run the long xcorr for phase/time alignment
xcorrfreqstamp = linspace(0,2/srate,fftlength*2-1)-1/srate;
for k = 1:1:numdatasets
    [xcorr_freq(:,k), lag(:,k)] = xcorr(abs(fftshift(noisyfft(:,k))),abs(fftshift(comb_fft)));
    [val id] = max(xcorr_freq(:,k));
    recoveredfreqphasexcorr(k) = angle(val);
    freqoffsetxcorr(k) = xcorrfreqstamp(id);
end

%plot the fft xcorr of the samples with the comb
figure
for k = 1:1:displaydatasets
    subplot(displaydatasets,1,k)
    plot(xcorrfreqstamp,abs(xcorr_freq(:,k)))
end
subplot(displaydatasets,1,1)
title('First 10 Freq-Domain Correlations of Noisy Data with Clock Comb (abs val)')
subplot(displaydatasets,1,displaydatasets)
xlabel('Frequency Offset [Hz]')

%frequency align data
for k = 1:1:numdatasets
    freqaligneddataxcorr(:,k) = noisydata(:,k).*(exp(i*2*pi*freqoffsetxcorr(k)*timestamp)');
end

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

end