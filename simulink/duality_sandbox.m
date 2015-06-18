close all
clear all

load('thursday.mat', 'clock_comb125k')
clock_comb = clock_comb125k;

fftlength = 2^nextpow2(length(clock_comb));
datalength = length(clock_comb);
srate = 1/125000;
timestamp = 0:srate:(datalength-1)*srate;
f_shift = 0;
comb_shift = clock_comb.*exp(i*2*pi*f_shift*timestamp).';

figure
subplot 311
plot(abs(xcorr(clock_comb)))
title('Autocorrelation of Clock Comb')
subplot 312
plot(abs(conj(fft(clock_comb,fftlength)).*fft(clock_comb,fftlength)))
title('Multiplication of FFT and conj(FFT)')
subplot 313
fftxcorr = ifft(fft(clock_comb,2*fftlength).*conj(fft(clock_comb,2*fftlength)));
fftxcorr = [fftxcorr(end-datalength+1:end); fftxcorr(1:datalength+1)];
plot(abs(fftxcorr))
hold on
plot(abs(xcorr(clock_comb)),'m')
title('fft autocorrelation vs autocorrelation')

figure
subplot 211
plot(abs(fft(clock_comb)))
title('FFT of Clock Comb')
subplot 212
plot(abs(flip(ifft(clock_comb))))
title('freq-reversed IFFT of Clock Comb')
%conclusion: fft(x) = flip(ifft(x))

figure
plot(abs(fft(clock_comb)))
hold on
plot(abs(flip(ifft(clock_comb))),'m')
title('FFT vs IFFT of Clock Comb')

%using duality
%duality states that the fft(fft(x(t))) = 2*pi*x(-t)
%the xcorr implementaion of the xcorr of fft is:
%ifft(fft(fft(x(t))).*conj(fft(fft(y(t)))))
%which reduces to
%ifft(2*pi*flip(x).*conj(flip(y)))
figure
subplot 311
freqcorr = xcorr(fft(clock_comb,fftlength),fft(comb_shift,fftlength));
plot(abs(freqcorr));
title('autocorrelation of fft of clock comb')
subplot 312
fft_freqcorr = ifft([fftlength*flip([clock_comb;zeros([fftlength-datalength 1])])].*conj([fftlength*flip([comb_shift;zeros([fftlength-datalength 1])]);]));
fft_freqcorr = [fft_freqcorr(end-fftlength+2:end); fft_freqcorr(1:fftlength)];
plot(abs(fft_freqcorr),'m')
hold on
plot(abs(freqcorr),'b:')
title('duality applied to correlation theorem')
subplot 313
fft_fft_freqcorr = ifft(fft(fft(clock_comb,fftlength)).*conj(fft(fft(clock_comb,fftlength))));
fft_fft_freqcorr = [fft_fft_freqcorr(end-fftlength+2:end); fft_fft_freqcorr(1:fftlength)];
plot(abs(fft_fft_freqcorr))
title('ifft of fft of fft method')

%testing the duality theorem
ffft = fft(fft(clock_comb,fftlength));
duality_fft = fftlength*flip([clock_comb;zeros([fftlength-datalength 1])]);
figure
plot(real(ffft))
hold on
plot(imag(ffft),'b:')
plot(real(duality_fft),'m')
plot(imag(duality_fft),'m:')
