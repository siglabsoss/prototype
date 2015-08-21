%generate test data for David's FPGA correlator prototype

clear all
close all

load('thursday.mat','clock_comb125k')

clock_comb = clock_comb125k;
srate = 1/125000;
downsample_factor = 4;
new_datarate = 1/srate/downsample_factor

%create a 16k downsample of clock_comb
new_srate = downsample_factor*srate
clock_comb_downsample = resample(clock_comb,1,downsample_factor);
clock_comb_16klength = [clock_comb_downsample; zeros([2^nextpow2(length(clock_comb_downsample))-length(clock_comb_downsample) 1])];
sampledatalength = length(clock_comb_16klength)
timestamp = 0:new_srate:(length(clock_comb_16klength)-1)*new_srate;

precomputed1_conj_fft_abs_fftshift_fft_comb_32k = conj(fft([abs(fftshift(fft(clock_comb_16klength))); zeros([2^15-length(clock_comb_16klength) 1])]));

%CREATE NOISY SHIFTED DATA
%uncomment the following lines to make non-ideal datal
freqshift = 75; %in HZ
timeshift = 100*new_srate; %in s
phaseshift = pi/2; %in rad
%frequency shift:
shifted_clock_comb_16klength = clock_comb_16klength.*exp(i*2*pi*freqshift*timestamp)';
%phase shift:
shifted_clock_comb_16klength = shifted_clock_comb_16klength.*exp(i*phaseshift);
%time shift:
shifted_clock_comb_16klength = [zeros([timeshift/new_srate 1]) ; shifted_clock_comb_16klength(1:end-timeshift/new_srate)];
%add noise:
%shifted_clock_comb_16klength = awgn(shifted_clock_comb_16klength, 3);


step1_data_16k = shifted_clock_comb_16klength;

step2_fft_data_16k = fft(step1_data_16k);

step3_fftshift_fft_data_16k = fftshift(step2_fft_data_16k);

step4_abs_fftshift_fft_data_32k = [abs(step3_fftshift_fft_data_16k); zeros([2^15-length(step3_fftshift_fft_data_16k) 1])];

step5_fft_abs_fftshift_fft_data_32k = fft(step4_abs_fftshift_fft_data_32k);

step6_multiply_fftfft_conjfftfft_32k = step5_fft_abs_fftshift_fft_data_32k.*precomputed1_conj_fft_abs_fftshift_fft_comb_32k;

step7_ifft_multiply_32k = ifft(step6_multiply_fftfft_conjfftfft_32k);

step8_reshape_freq_ifft_32k = [step7_ifft_multiply_32k(sampledatalength+2:end);step7_ifft_multiply_32k(1:sampledatalength)];

sanitycheck = xcorr(abs(fftshift(fft(shifted_clock_comb_16klength))),abs(fftshift(fft(clock_comb_16klength))));

%PHASE TWO: TIME CORRELATION

precomputed2_conj_fft_comb_32k = conj(fft([clock_comb_16klength; zeros([2^15-sampledatalength 1])]));

%calc circshift
[val derived_freqshift] = max(step8_reshape_freq_ifft_32k);
derived_freqshift = derived_freqshift - sampledatalength

step9_padded_fft_data_32k = fft(step1_data_16k, sampledatalength*2);

step10_circshift_fft_data_32k = circshift(step9_padded_fft_data_32k,-derived_freqshift*2);

step11_multiply_circshift_fft_conj_fft_comb_32k = step10_circshift_fft_data_32k .* precomputed2_conj_fft_comb_32k;

step12_ifft_multiply_32k = ifft(step11_multiply_circshift_fft_conj_fft_comb_32k);

step13_reshape_time_ifft_32k = [step12_ifft_multiply_32k(sampledatalength+2:end);step12_ifft_multiply_32k(1:sampledatalength)];

%calc timeshift
[val derived_timeshift] = max(step13_reshape_time_ifft_32k);
derived_timeshift = derived_timeshift - sampledatalength

derived_phaseshift = angle(val)

step14_freq_aligned_data = step1_data_16k.*exp(i*2*pi*timestamp*derived_freqshift/sampledatalength/new_srate)';

%calc shift indices
startindex = max([derived_timeshift; 1]);
stopindex = sampledatalength+min([derived_timeshift;0]);

step15_freq_time_aligned_data = [zeros([-derived_timeshift 1]); step14_freq_aligned_data(startindex:stopindex); zeros([derived_timeshift-1 1])];

step16_freq_time_phase_aligned_data = step15_freq_time_aligned_data*exp(i*2*pi*-derived_phaseshift);

time_sanitycheck = xcorr(step1_data_16k.*exp(i*2*pi*(derived_freqshift/sampledatalength/new_srate)*timestamp)',clock_comb_16klength);

figure
subplot 511
plot(real(step1_data_16k))
title('Input Data')
subplot 512
plot(real(step2_fft_data_16k))
title('FFT of input data')
subplot 513
plot(real(step3_fftshift_fft_data_16k))
title('FFTshifted FFT of data')
subplot 514
plot(real(step4_abs_fftshift_fft_data_32k))
title('ABS of FFTshifted FFT of data, padded to 32k')
subplot 515
plot(real(step5_fft_abs_fftshift_fft_data_32k))
title('FFT of ABS of FFTshifted FFT of data')

figure
subplot 511
plot(real(precomputed1_conj_fft_abs_fftshift_fft_comb_32k))
title('Precomputed CONJ of comb path')
subplot 512
plot(real(step6_multiply_fftfft_conjfftfft_32k))
title('Multiply of input paths')
subplot 513
plot(real(step7_ifft_multiply_32k))
title('IFFT of the multiply')
subplot 514
plot(real(step8_reshape_freq_ifft_32k))
title('Final Freq Correlation output')
subplot 515
plot(real(sanitycheck))
title('Sanity Check: XCORR of ABS(FFTSHIFT(FFT(input data)))')

figure
plot(step8_reshape_freq_ifft_32k-sanitycheck)
title('Freq Correlation Sanity Check Errors')

figure 
subplot 511
plot(real(precomputed2_conj_fft_comb_32k))
title('Precomputed padded conj of fft of comb')
subplot 512
plot(real(step9_padded_fft_data_32k))
title('Padded FFT of input data')
subplot 513
plot(real(step10_circshift_fft_data_32k))
title('Circshifted FFT of padded data')
subplot 514
plot(real(step11_multiply_circshift_fft_conj_fft_comb_32k))
title('Multiply of Time Correlation')
subplot 515
plot(real(step12_ifft_multiply_32k))
title('Time Correlation iFFT')

figure
subplot 511
plot(abs(step13_reshape_time_ifft_32k))
title('Time Correlator Output')
subplot 512
plot(real(step14_freq_aligned_data))
title('Frequency Aligned Data')
subplot 513
plot(real(step15_freq_time_aligned_data))
title('Frequency and Time Aligned Data')
subplot 514
plot(real(step16_freq_time_phase_aligned_data))
title('Final Aligned Data Output')

figure
plot(abs(step13_reshape_time_ifft_32k-time_sanitycheck))
title('Time Correlation Sanity Check Errors')

figure
plot(timestamp, imag(clock_comb_16klength),'m-')
hold on
plot(timestamp, imag(step16_freq_time_phase_aligned_data))
xlabel('time[s]')
ylabel('magnitude')
title('Check: Final Alignment of Data')

% csvwrite('step1_data_16k.csv',[real(step1_data_16k) imag(step1_data_16k)])
% csvwrite('step2_fft_data_16k.csv',[real(step2_fft_data_16k) imag(step2_fft_data_16k)])
% csvwrite('step3_fftshift_fft_data_16k.csv',[real(step3_fftshift_fft_data_16k) imag(step3_fftshift_fft_data_16k)])
% csvwrite('step4_abs_fftshift_fft_data_32k.csv',[real(step4_abs_fftshift_fft_data_32k) imag(step4_abs_fftshift_fft_data_32k)])
% csvwrite('step5_fft_abs_fftshift_fft_data_32k.csv',[real(step5_fft_abs_fftshift_fft_data_32k) imag(step5_fft_abs_fftshift_fft_data_32k)])
% csvwrite('step6_multiply_fftfft_conjfftfft_32k.csv',[real(step6_multiply_fftfft_conjfftfft_32k) imag(step6_multiply_fftfft_conjfftfft_32k)])
% csvwrite('step7_ifft_multiply.csv',[real(step7_ifft_multiply_32k) imag(step7_ifft_multiply_32k)])
% csvwrite('step8_reshape_ifft.csv',[real(step8_reshape_ifft_32k) imag(step8_reshape_ifft_32k)])
% csvwrite('precomputed1_conj_fft_abs_fftshift_fft_comb_32k.csv',[real(precomputed1_conj_fft_abs_fftshift_fft_comb_32k) imag(precomputed1_conj_fft_abs_fftshift_fft_comb_32k)])
csvwrite('freqshift39L_timeshift_100R_step1_data_16k.csv',[real(step1_data_16k) imag(step1_data_16k)])
csvwrite('freqshift39L_timeshift_100R_step2_fft_data_16k.csv',[real(step2_fft_data_16k) imag(step2_fft_data_16k)])
csvwrite('freqshift39L_timeshift_100R_step3_fftshift_fft_data_16k.csv',[real(step3_fftshift_fft_data_16k) imag(step3_fftshift_fft_data_16k)])
csvwrite('freqshift39L_timeshift_100R_step4_abs_fftshift_fft_data_32k.csv',[real(step4_abs_fftshift_fft_data_32k) imag(step4_abs_fftshift_fft_data_32k)])
csvwrite('freqshift39L_timeshift_100R_step5_fft_abs_fftshift_fft_data_32k.csv',[real(step5_fft_abs_fftshift_fft_data_32k) imag(step5_fft_abs_fftshift_fft_data_32k)])
csvwrite('freqshift39L_timeshift_100R_step6_multiply_fftfft_conjfftfft_32k.csv',[real(step6_multiply_fftfft_conjfftfft_32k) imag(step6_multiply_fftfft_conjfftfft_32k)])
csvwrite('freqshift39L_timeshift_100R_step7_ifft_multiply.csv',[real(step7_ifft_multiply_32k) imag(step7_ifft_multiply_32k)])
csvwrite('freqshift39L_timeshift_100R_step8_reshape_ifft.csv',[real(step8_reshape_freq_ifft_32k) imag(step8_reshape_freq_ifft_32k)])
csvwrite('precomputed1_conj_fft_abs_fftshift_fft_comb_32k.csv',[real(precomputed1_conj_fft_abs_fftshift_fft_comb_32k) imag(precomputed1_conj_fft_abs_fftshift_fft_comb_32k)])
csvwrite('freqshift39L_timeshift_100R_step9_padded_fft_data_32k.csv',[real(step9_padded_fft_data_32k) imag(step9_padded_fft_data_32k)])
csvwrite('freqshift39L_timeshift_100R_step10_circshift_fft_data_32k.csv',[real(step10_circshift_fft_data_32k) imag(step10_circshift_fft_data_32k)])
csvwrite('freqshift39L_timeshift_100R_step11_multiply_circshift_fft_conj_fft_comb_32k.csv',[real(step11_multiply_circshift_fft_conj_fft_comb_32k) imag(step11_multiply_circshift_fft_conj_fft_comb_32k)])
csvwrite('freqshift39L_timeshift_100R_step12_ifft_multiply_32k.csv',[real(step12_ifft_multiply_32k) imag(step12_ifft_multiply_32k)])
csvwrite('freqshift39L_timeshift_100R_step13_reshape_time_ifft_32k.csv',[real(step13_reshape_time_ifft_32k) imag(step13_reshape_time_ifft_32k)])
csvwrite('freqshift39L_timeshift_100R_step14_freq_aligned_data.csv',[real(step14_freq_aligned_data) imag(step14_freq_aligned_data)])
csvwrite('freqshift39L_timeshift_100R_step14_freq_aligned_data.csv',[real(step15_freq_time_aligned_data) imag(step14_freq_aligned_data)])
csvwrite('freqshift39L_timeshift_100R_step15_freq_time_aligned_data.csv',[real(step15_freq_time_aligned_data) imag(step15_freq_time_aligned_data)])
csvwrite('freqshift39L_timeshift_100R_step16_freq_time_phase_aligned_data.csv',[real(step16_freq_time_phase_aligned_data) imag(step16_freq_time_phase_aligned_data)])
csvwrite('precomputed2_conj_fft_comb_32k.csv',[real(precomputed2_conj_fft_comb_32k) imag(precomputed2_conj_fft_comb_32k)])

simdataraw1 = csvread('DavidDataStep4.csv');
simdataraw2 = csvread('DavidDataStep5.csv');

step4_sim = simdataraw1(:,2);
step5_sim = simdataraw2(:,3)+i*simdataraw2(:,4);

figure
subplot 311
plot(step4_abs_fftshift_fft_data_32k)
subplot 312
plot(step4_sim)
subplot 313
plot(step4_abs_fftshift_fft_data_32k-step4_sim/127.9767)



figure
subplot 221
plot(real(step5_fft_abs_fftshift_fft_data_32k))
subplot 223
plot(real(step5_sim))
subplot 222
plot(imag(step5_fft_abs_fftshift_fft_data_32k))
subplot 224
plot(imag(step5_sim))

