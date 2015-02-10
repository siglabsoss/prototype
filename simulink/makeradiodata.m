%todo:
%add phase LO differences
%add more than one cycle of time delay

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

maxdelay = 1/50; %magic number :(
maxLOphase = 1.56; %magic number :(

snr = 3;

power_padding = 4;

srate = 0.00001;
datalength = length(idealdata);
fftlength = 2^(nextpow2(datalength)+power_padding);
%fftlength = datalength;
timestamp = 0:srate:(datalength-1)*srate;

numdatasets = 10;

noisydata1 = awgn(idealdata,snr);

subplot 211
plot(real(idealdata))
subplot 212
plot(real(noisydata1))


%make AWGN data with random delay and random phase
for k = 1:1:numdatasets
    noisydata(:,k) = idealdata; %bypass for testing
    delaysamples(k) = round(maxdelay*rand()/srate);
    phaserotation(k) = maxLOphase*rand(); 
    noisydata(:,k) = awgn(idealdata,snr);
    noisydata(:,k) = noisydata(:,k).*exp(i*phaserotation(k));
    noisydata(:,k) = [zeros(delaysamples(k),1);noisydata(1:end-delaysamples(k),k)];
    %noisydata(:,k) = idealdata; %bypass for testing
end

%run findtones
for k = 1:1:numdatasets
    fa(:,:,k) = findtones([flattopwin(datalength).*noisydata(:,k);zeros([fftlength-datalength,1])]);
    %fa(:,:,k) = findtones(noisydata(:,k));
end

figure
plot(abs(fftshift(fft([flattopwin(datalength).*noisydata(:,k);zeros([fftlength-datalength,1])]))))

%plot data and recovered beat tone
figure
for k = 1:1:numdatasets
    subplot(numdatasets,1,k)
    plot(timestamp,real(noisydata(:,k)))
    hold on
    plot(timestamp,cos(2*pi*timestamp*(fa(1,1,k)-fa(2,1,k))/2+(fa(1,2,k)-fa(2,2,k))/2),'m')
end
subplot(numdatasets,1,1)
title('Recovered Beat Tones')

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
end
subplot(numdatasets,1,1)
title('Time Aligned Data')

%recover the phase offset of the LO
figure
for k = 1:1:numdatasets
    recoveredphase(k) = fa(1,2,k)-timeoffset(k)*fa(1,1,k)*2*pi;
    subplot(numdatasets,1,k)
    plot(timestamp+timeoffset(k),real(noisydata(:,k)./exp(i*(recoveredphase(k)))))
    hold on
    plot(timestamp+timeoffset(k),cos(2*pi*timestamp*(fa(1,1,k)-fa(2,1,k))/2+(fa(1,2,k)-fa(2,2,k))/2),'m')
    xlim([0 0.5])
    ylim([-1 1])
end
subplot(numdatasets,1,1)
title('Time and Phase Aligned Data')

figure
incoherentsum = noisydata * ones([numdatasets 1]);
plot(timestamp, real(incoherentsum))
title('Incoherent Sum of Signals')

figure
for k = 1:1:numdatasets
    samplesoffset(k) = round(maxdelay/srate - timeoffset(k)/srate);
    aligneddata(:,k) = [noisydata(samplesoffset(k):end,k);zeros([samplesoffset(k)-1 1])]./exp(i*(recoveredphase(k)));
    subplot(numdatasets,1,k)
    plot(timestamp, real(aligneddata(:,k)))
end

figure
coherentsum = aligneddata * ones([numdatasets 1]);
plot(timestamp, real(coherentsum))
title('Coherent Sum of Signals')



