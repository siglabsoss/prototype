close all
load thursday.mat

srate = 1/125000;
clock_comb = clock_comb125k;
timestamp = 0:srate:srate*(length(clock_comb)-1);

figure
plot(timestamp, real(clock_comb))

figure
clock_self_corr = xcorr(clock_comb,clock_comb);
corrtimestamp = [-flip(timestamp) timestamp(2:end)];
plot(corrtimestamp,abs(clock_self_corr));
phasestep = pi/4; 
fftphasestep = pi/4;

numsets = 20;
freqstep = 1; %in Hz

figure
for k = 1:1:numsets
    freqshift = freqstep*(k-10);
    subplot(numsets,1,k)
    clock_corr_freq(:,k) = xcorr(clock_comb,clock_comb.*exp(i*2*pi*freqshift*timestamp)');
    plot(corrtimestamp, abs(clock_corr_freq(:,k)));
    ylim([0 4e4])
    title(sprintf('%s Hz freq shifted',num2str(freqshift)))
end
subplot(numsets,1,k)

numsets = 8;
figure
for k = 1:1:numsets
    phaseshift = phasestep*k;
    subplot(numsets,1,k)
    clock_corr_phase(:,k) = xcorr(clock_comb,clock_comb*exp(i*2*phaseshift));
    plot(corrtimestamp, abs(clock_corr_phase(:,k)));
    ylim([0 4e4])
    title(sprintf('%s degrees phase shifted',num2str(phaseshift*360/2/pi)))
end
subplot(numsets,1,k)

figure
comb_fft = fftshift(fft(clock_comb));
numsets = 8;
corrfreqstamp = linspace(0,2/srate,2*length(comb_fft)-1)-1/srate;
for k = 1:1:numsets
    fftphaseshift = fftphasestep*k;
    subplot(numsets,1,k)
    shifted_comb_fft(:,k) = fftshift(fft(clock_comb*exp(i*2*pi*fftphaseshift)));
    fft_corr(:,k) = xcorr(comb_fft,shifted_comb_fft(:,k));
    plot(corrfreqstamp, abs(fft_corr(:,k)));
    ylim([0 2e9])
    xlim([-200 200])
    title(sprintf('fft xcorr one input %s degrees phase shifted',num2str(fftphaseshift*360/2/pi)))
end
subplot(numsets,1,k)