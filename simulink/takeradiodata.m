%todo:
%add phase LO differences
%add more than one cycle of time delay
%add amplitude variability
%awgn should be after the time shifts

close all

load edwindata.mat
load bendata.mat
load clock_comb_100k.mat

clear noisydata
clear fa
clear timestamp
clear aligneddata
clear timeoffset
clear samplesoffset
clear incoherentsum
clear coherentsum
clear recoveredphase
clear xcorr_data
clear datalength
clear recoveredfreqphasexcorr
clear freqoffsetxcorr
clear xcorr_freq
clear freqaligneddataxcorr
clear noisyfft
clear freqindex
clear comb_fft
clear xcorrfreqstamp

maxdelay = 1/30; %magic number :(
maxLOphase = 2.14; %magic number :(
maxFshift = 1000; %in hertz

snr = -6;

power_padding = 4;

srate = 0.00001;
datalength = length(bendata);
fftlength = 2^(nextpow2(datalength)+power_padding);
timestamp = 0:srate:(datalength-1)*srate;

numdatasets = 2;

subplot 311
plot(real(clock_comb))
title('Clock Comb')
subplot 312
plot(timestamp,real(bendata))
title('Ben Data (Real)')
subplot 313
plot(timestamp,real(edwindata))
title('Edwin Data (Real)')

%trim data
noisydata(:,1) = bendata(140000:200000);
noisydata(:,2) = edwindata(90000:150000);
datalength = length(noisydata(:,1));
timestamp = 0:srate:(datalength-1)*srate;


figure
freqindex = linspace(0,1/srate,fftlength)-1/srate/2;
comb_fft = fft([flattopwin(length(clock_comb)).*clock_comb;zeros([fftlength-length(clock_comb),1])]);
plot(freqindex,abs(fftshift(comb_fft)));
title('padded fft of clock comb')

%plot raw data
figure
for k = 1:1:numdatasets
    subplot(numdatasets,1,k)
    plot(timestamp,real(noisydata(:,k)))
    xlim([0 1])
    ylim([-1e-2 1e-2])
end
subplot(numdatasets,1,1)
title('Raw data received at antennas (Real)')


figure
incoherentsum = noisydata * ones([numdatasets 1]);
plot(timestamp, real(incoherentsum))
title('Incoherent Sum of Signals (Real)')


%perform clock_comb frequency xcorrelation
figure
freqindex = linspace(0,1/srate,fftlength)-1/srate/2;
for k = 1:1:numdatasets
    subplot(numdatasets,1,k)
    noisyfft(:,k) = fft([flattopwin(datalength).*noisydata(:,k);zeros([fftlength-datalength,1])]);
    plot(freqindex,abs(fftshift(noisyfft(:,k))))
end
subplot(numdatasets,1,1)
title('Noisy Data FFT')

figure
xcorrfreqstamp = linspace(0,2/srate,fftlength*2-1)-1/srate;
for k = 1:1:numdatasets
    subplot(numdatasets,1,k)
    [xcorr_freq(:,k), lag(:,k)] = xcorr(fftshift(noisyfft(:,k)),fftshift(comb_fft));
    plot(xcorrfreqstamp,abs(xcorr_freq(:,k)))
    [val id] = max(xcorr_freq(:,k));
    recoveredfreqphasexcorr(k) = angle(val);
    freqoffsetxcorr(k) = xcorrfreqstamp(id);
end
subplot(numdatasets,1,1)
title('Correlation of Noisy Data FFT with Clock Comb FFT (abs val)')

%{
%frequency align data
figure
for k = 1:1:numdatasets
    subplot(numdatasets,1,k)
    freqaligneddataxcorr(:,k) = noisydata(:,k).*(exp(i*2*pi*freqoffsetxcorr(k)*timestamp)');
    plot(timestamp, real(freqaligneddataxcorr(:,k)))
    xlim([0 0.5])
    subplot(numdatasets,1,k)
    ylim([-3 3])
end
subplot(numdatasets,1,1)
title('FFT-Correlation Frequency-Aligned Data (Real)')  

%perform clock_comb xcorrelation
figure
xcorrtimestamp = [flip(-timestamp,2) timestamp(2:end)];
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
    xlim([0 0.5])
    ylim([-3 3])
end
subplot(numdatasets,1,1)
title('Correlation Time and Phase Aligned Data (Real)')    

figure
coherentsumxcorr = aligneddataxcorr * ones([numdatasets 1]);
plot(timestamp, real(coherentsumxcorr))
title('Correlation Coherent Sum of Signals (Real)')

%}