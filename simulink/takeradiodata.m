%function takeradiodata(clock_comb,bendata,edwindata)
%todo:
%add phase LO differences
%add more than one cycle of time delay
%add amplitude variability
%awgn should be after the time shifts

close all

%uncomment these to make this run as a script
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
    [xcorr_freq(:,k), lag(:,k)] = xcorr(abs(fftshift(noisyfft(:,k))),abs(fftshift(comb_fft)));
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
%{
%}

%{ 
%comment this out to make this run as a script
%I-Q test
ctrlfreq = 0;

figure
datatime = 0:srate:(length(noisydata(:,1))-1)*srate;
subplot 211
plot(real(clock_comb))
hold on
plot(imag(clock_comb),'m')
title('Ideal Clock Comb, I and Q')
subplot 212
plot(real(noisydata(:,2)))
hold on
plot(imag(noisydata(:,2)),'m')
title('Radio data input, I and Q')


ctrlfig = figure;
ctrlax = axes('Parent', ctrlfig);
plot(real(noisydata(:,2)),'b','Parent',ctrlax)
hold on
plot(imag(noisydata(:,2)),'m','Parent',ctrlax)
hold off


title('Radio data input, I and Q')
uicontrol('Parent',ctrlfig, 'Style','slider', 'Value',0, 'Min',-1000,'Max',1000, 'SliderStep',[1 100]./2000,'Position',[150 5 300 20], 'Callback',@slider_callback);
hTxta = uicontrol('Style','text', 'Position',[500 28 20 15], 'String','0Hz');

function slider_callback(hObj, eventdata)
        ctrlfreq = (get(hObj,'Value'));        %# get Lo phase
        plot(real(noisydata(:,2).*exp(i*2*pi*ctrlfreq*datatime)'),'b','Parent',ctrlax)
        hold on
        plot(imag(noisydata(:,2).*exp(i*2*pi*ctrlfreq*datatime)'),'m','Parent',ctrlax)
        hold off
        set(hTxta, 'String',[num2str(ctrlfreq) 'Hz'])       %# update text
end

end
%}