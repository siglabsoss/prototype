close all

load thursday.mat
load mondaymarch2.mat

windowtype = @flattopwin;

fftlength=2^nextpow2(length(clock_comb));

datalength = length(clock_comb);

comb_fft = fftshift(fft([window(windowtype,datalength).*clock_comb;zeros([fftlength-datalength,1])]));

freqstamp = linspace(0,1/srate,fftlength)-1/srate/2;
hz_per_sample = 1/srate/fftlength;

figure
plot(freqstamp,abs(fftshift(comb_fft)))
title('Clock Comb FFT')
xlabel('Freq [Hz]')



fsearchwindow = 1000; % in Hz

index_low = floor(fftlength/2) - round(fsearchwindow*srate*fftlength);

index_hi = ceil(fftlength/2) + round(fsearchwindow*srate*fftlength);

freqstamp_sub = freqstamp(index_low:index_hi);

figure
splot(comb_fft(index_low:index_hi))
figure
plot(freqstamp_sub,comb_fft(index_low:index_hi))