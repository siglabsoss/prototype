%todo:
% convert to clock comb xcorr for signal finding in presense of interferers

close all
clear all

load rawdata_20s_100k.mat
load clock_comb_100k.mat

srate = 1/100000;
rawtime = 0:srate:(length(rawdata)-1)*srate;
windowsize = 0.8;
timestep = 0.3;
power_padding = 4;
fftdetect = 30; %max peak to rms ratio for fft-only search
xcorrdetect = 14; %max peak to rms ratio for clock comb xcorr search
windowtype = @gausswin;

figure
plot(rawtime, real(rawdata))
title('Raw RF Data (real)')

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

figure
for k = 1:1:displaydatasets
    subplot(displaydatasets,1,k)
    plot(timestamp,real(rnoisydata(:,k)))
    xlim([0 1])
end
subplot(displaydatasets,1,1)
title('First 10 chunks of raw data received at antennas (Real)')

%basic fft of raw data
for k=1:1:numdatasets
    rnoisyfft(:,k) = fft([window(windowtype,datalength).*rnoisydata(:,k);zeros([fftlength-datalength,1])]);
    noisyfftsnr(k) = abs(max(rnoisyfft(:,k)))/abs(rms(rnoisyfft(:,k)));
end
%goodsets = find(noisyfftsnr > fftdetect); %UNCOMMENT THIS TO GO BACK TO
%FFT-ONLY SELECTION


figure
freqindex = linspace(0,1/srate,fftlength)-1/srate/2;
for k = 1:1:displaydatasets
    subplot(displaydatasets,1,k)
    plot(freqindex,abs(fftshift(rnoisyfft(:,k))))
end
subplot(displaydatasets,1,1)
title('First 10 Chunks Noisy Data FFT')


%create comb fft
figure
freqindex = linspace(0,1/srate,fftlength)-1/srate/2;
comb_fft = fft([window(windowtype,length(clock_comb)).*clock_comb;zeros([fftlength-length(clock_comb),1])]);
plot(freqindex,abs(fftshift(comb_fft)));
title('padded fft of clock comb')

%Alternate sample ranking based on comb correlation
xcorrfreqstamp = linspace(0,2/srate,fftlength*2-1)-1/srate;
for k = 1:1:numdatasets
    [xcorr_freq(:,k), lag(:,k)] = xcorr(abs(fftshift(rnoisyfft(:,k))),abs(fftshift(comb_fft)));
    [val id] = max(xcorr_freq(:,k));
    recoveredfreqphasexcorr(k) = angle(val);
    freqoffsetxcorr(k) = xcorrfreqstamp(id);
    noisyxcorrsnr(k) = abs(max(xcorr_freq(:,k)))/abs(rms(xcorr_freq(:,k)));
end
goodsets = find(noisyxcorrsnr > xcorrdetect);


%reduce to just the good datasets
for k = 1:length(goodsets)
    noisydata(:,k) = rnoisydata(:,goodsets(k));
    noisyfft(:,k) = rnoisyfft(:,goodsets(k));
    freqoffsetxcorr(k) = freqoffsetxcorr(goodsets(k));
end

numdatasets = length(goodsets);

figure
for k = 1:numdatasets
    subplot(numdatasets,1,k);
    plot(timestamp,real(noisydata(:,k)))
end
subplot(numdatasets,1,1)
title('Raw datasets where signal found (real)')


%plot the xcorr of the samples with the comb
figure
for k = 1:1:numdatasets
    subplot(numdatasets,1,k)
    plot(xcorrfreqstamp,abs(xcorr_freq(:,k)))
end
subplot(numdatasets,1,1)
title('Correlation of Noisy Data FFT with Clock Comb FFT (abs val)')

%{
%UNCOMMENT THIS SECTION TO USE FFT-Only sample selection
figure
xcorrfreqstamp = linspace(0,2/srate,fftlength*2-1)-1/srate;
for k = 1:1:numdatasets
    subplot(numdatasets,1,k)
    [xcorr_freq(:,k), lag(:,k)] = xcorr(abs(fftshift(noisyfft(:,k))),abs(fftshift(comb_fft)));
    plot(xcorrfreqstamp,abs(xcorr_freq(:,k)))
    [val id] = max(xcorr_freq(:,k));
    recoveredfreqphasexcorr(k) = angle(val);
    freqoffsetxcorr(k) = xcorrfreqstamp(id);
end
subplot(numdatasets,1,1)
title('Correlation of Noisy Data FFT with Clock Comb FFT (abs val)')
%}

%frequency align data
figure
for k = 1:1:numdatasets
    subplot(numdatasets,1,k)
    freqaligneddataxcorr(:,k) = noisydata(:,k).*(exp(i*2*pi*freqoffsetxcorr(k)*timestamp)');
    plot(timestamp, real(freqaligneddataxcorr(:,k)))
    subplot(numdatasets,1,k)
end
subplot(numdatasets,1,1)
title('FFT-Correlation Frequency-Aligned Data (Real)')

%perform clock_comb xcorrelation
figure
xcorrtimestamp = [flip(-timestamp,2) timestamp(2:end)]; %zero in the middle
for k = 1:1:numdatasets
    subplot(numdatasets,1,k)
    xcorr_data(:,k) = xcorr(freqaligneddataxcorr(:,k),clock_comb);
    plot(xcorrtimestamp,abs(xcorr_data(:,k)))
    [val id] = max(xcorr_data(:,k));
    recoveredphasexcorr(k) = angle(val);
    samplesoffsetxcorr(k) = id - datalength;
end
subplot(numdatasets,1,1)
title('Correlation of Noisy Data with Clock Comb (abs val)')

%time and phase align data
figure
for k = 1:1:numdatasets
    subplot(numdatasets,1,k)
    aligneddataxcorr(:,k) = [freqaligneddataxcorr(samplesoffsetxcorr(k):end,k);zeros([samplesoffsetxcorr(k)-1 1])]./exp(i*(recoveredphasexcorr(k)));
    subplot(numdatasets,1,k)
    plot(timestamp, real(aligneddataxcorr(:,k)))
end
subplot(numdatasets,1,1)
title('Correlation Time and Phase Aligned Data (Real)')    


figure
coherentsumxcorr = aligneddataxcorr * ones([numdatasets 1]);
plot(timestamp, real(coherentsumxcorr))
title('Correlation Coherent Sum of Signals (Real)')