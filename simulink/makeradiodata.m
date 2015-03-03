%todo:
%add phase LO differences
%add more than one cycle of time delay
%add amplitude variability
%awgn should be after the time shifts


close all

%load idealdata.mat

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


maxdelay = 1/50; %magic number :(
maxLOphase = 1.6; %magic number :(
maxFshift = 1000; %in hertz

snr = 3;

power_padding = 4;

srate = 0.00001;
datalength = length(idealdata);
fftlength = 2^(nextpow2(datalength)+power_padding);
%fftlength = datalength;
timestamp = 0:srate:(datalength-1)*srate;

numdatasets = 10;

%make AWGN data with random delay and random phase
for k = 1:1:numdatasets
    noisydata(:,k) = idealdata; %bypass for testing
    delaysamples(k) = round(maxdelay*rand()/srate);
    phaserotation(k) = maxLOphase*rand(); 
    Fshift(k) = maxFshift*rand();
    %noisydata(:,k) = awgn(noisydata(:,k),snr);
    %noisydata(:,k) = [zeros(delaysamples(k),1);noisydata(1:end-delaysamples(k),k)];
    noisydata(:,k) = noisydata(:,k).*(exp(i*2*pi*Fshift(k)*timestamp)'); %frequency shift
    noisydata(:,k) = noisydata(:,k).*exp(i*phaserotation(k)); %LO phase shift
    noisydata(:,k) = [zeros(delaysamples(k),1);noisydata(1:end-delaysamples(k),k)]; %time shift
    noisydata(:,k) = awgn(noisydata(:,k),snr); %white noise
    %noisydata(:,k) = idealdata; %bypass for testing
end

subplot 311
plot(timestamp,real(idealdata))
title('Ideal Data (Real)')
subplot 312
plot(real(clock_comb))
hold on
%plot(imag(clock_comb),'m:')
title('Ideal Clock Comb (Real)')
subplot 313
plot(timestamp,real(noisydata(:,1)))


%run findtones
for k = 1:1:numdatasets
    %fa(:,:,k) = findtones([flattopwin(datalength).*noisydata(:,k);zeros([fftlength-datalength,1])]);
    %fa(:,:,k) = findtones(noisydata(:,k));
    fa(:,:,k) = findtones([noisydata(:,k);zeros([fftlength-datalength,1])]);
end

figure
subplot 311
noisy_fft = fft([flattopwin(datalength).*noisydata(:,k);zeros([fftlength-datalength,1])]);
plot(abs(fftshift(noisy_fft)));
title('sample padded fft of one noisy channel')
subplot 312
%comb_fft = fft(clock_comb,fftlength);
comb_fft = fft([flattopwin(length(clock_comb)).*clock_comb;zeros([fftlength-length(clock_comb),1])]);
plot(abs(fftshift(comb_fft)));
title('padded fft of clock comb')
subplot 313
plot(abs(xcorr(noisy_fft, comb_fft)))
title('Cross-Correlation in Freq Domain')

%plot raw data
figure
for k = 1:1:numdatasets
    subplot(numdatasets,1,k)
    plot(timestamp,real(noisydata(:,k)))
    xlim([0 0.5])
    ylim([-3 3])
end
subplot(numdatasets,1,1)
title('Raw data received at antennas (Real)')

%{
%plot data and recovered beat tone
figure
for k = 1:1:numdatasets
    subplot(numdatasets,1,k)
    plot(timestamp,real(noisydata(:,k)))
    hold on
    plot(timestamp,cos(2*pi*timestamp*(fa(1,1,k)-fa(2,1,k))/2+(fa(1,2,k)-fa(2,2,k))/2),'m')
    xlim([0 0.5])
    ylim([-3 3])
end
subplot(numdatasets,1,1)
title('Recovered Beat Tones (Real)')

%{
for k = 1:1:numdatasets
    subplot(numdatasets,2,k+numdatasets)
    plot(abs(fftshift(fft([noisydata(:,k);zeros([fftlength-datalength,1])]))))
end
%}

figure
for k = 1:1:numdatasets
    subplot(numdatasets,1,k)
    timeoffset(k) = (fa(1,2,k)-fa(2,2,k))/(2*pi*((fa(1,1,k)-fa(2,1,k)))); %why is there no div/2 here?
    %timeoffset(k) = mod(timeoffset(k),-1/((fa(1,1,k)-fa(2,1,k))/2)); %THIS IS A HACK
    %if timeoffset(k) > 0
    %    timeoffset(k) = timeoffset(k) - 1/((fa(1,1,k)-fa(2,1,k))/2);
    %end
    plot(timestamp+timeoffset(k),real(noisydata(:,k)))
    hold on
    plot(timestamp+timeoffset(k),cos(2*pi*timestamp*(fa(1,1,k)-fa(2,1,k))/2+(fa(1,2,k)-fa(2,2,k))/2),'m')
    xlim([0 0.5])
    ylim([-3 3])
end
subplot(numdatasets,1,1)
title('Time Aligned Data (Real)')

%recover the phase offset of the LO
for k = 1:1:numdatasets
    recoveredphase(k) = fa(1,2,k)-timeoffset(k)*fa(1,1,k)*2*pi;
    %{
    subplot(numdatasets,1,k)
    plot(timestamp+timeoffset(k),real(noisydata(:,k)./exp(i*(recoveredphase(k)))))
    hold on
    plot(timestamp+timeoffset(k),cos(2*pi*timestamp*(fa(1,1,k)-fa(2,1,k))/2+(fa(1,2,k)-fa(2,2,k))/2),'m')
    xlim([0 0.5])
    ylim([-1 1])
    %}
end
%}

figure
incoherentsum = noisydata * ones([numdatasets 1]);
plot(timestamp, real(incoherentsum))
title('Incoherent Sum of Signals (Real)')

%{
figure
for k = 1:1:numdatasets
    samplesoffset(k) = round(maxdelay/srate - timeoffset(k)/srate);
    aligneddata(:,k) = [noisydata(samplesoffset(k):end,k);zeros([samplesoffset(k)-1 1])]./exp(i*(recoveredphase(k)));
    subplot(numdatasets,1,k)
    plot(timestamp, real(aligneddata(:,k)))
    hold on
    plot(timestamp+timeoffset(k),cos(2*pi*timestamp*(fa(1,1,k)-fa(2,1,k))/2+(fa(1,2,k)-fa(2,2,k))/2),'m')
    xlim([0 0.5])
    ylim([-3 3])
end
subplot(numdatasets,1,1)
title('FFT Time and Phase Aligned Data (Real)')


figure
coherentsum = aligneddata * ones([numdatasets 1]);
plot(timestamp, real(coherentsum))
title('FFT Coherent Sum of Signals (Real)')
%}

%perform clock_comb frequency xcorrelation
figure
freqindex = linspace(0,1/srate,fftlength)-1/srate/2;
xcorrfreqstamp = linspace(0,2/srate,fftlength*2-1)-1/srate;
for k = 1:1:numdatasets
    subplot(numdatasets,1,k)
    noisyfft(:,k) = fft([flattopwin(datalength).*noisydata(:,k);zeros([fftlength-datalength,1])]);
    xcorr_freq(:,k) = xcorr(fftshift(noisyfft(:,k)),fftshift(comb_fft));
    plot(xcorrfreqstamp,abs(xcorr_freq(:,k)))
    [val id] = max(xcorr_freq(:,k));
    recoveredfreqphasexcorr(k) = angle(val);
    freqoffsetxcorr(k) = xcorrfreqstamp(id);
end
subplot(numdatasets,1,1)
title('Correlation of Noisy Data FFT with Clock Comb FFT (abs val)')

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

