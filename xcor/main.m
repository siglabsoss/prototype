% distribution of values in the input trace
pkg load signal;

addpath('../simulink');
o_util;

fig1 = figure(1);

% raw time domain sequance
% t0 = rawfile_to_complex('x310_dump2_33.(3).raw');
% t0 = rawfile_to_complex('x310_dump_tone.raw');
t0 = rawfile_to_complex('x310_wide_fft_2.raw');

% offset = 558000;

% offset = 2.5e6;
% wsize = 2**19;

offset = 1000000;
wsize = 2**16;
delay = 1092;  % ~ 33.(3) / 31.25 * 1024

% small part of raw data
t1 = t0(offset:offset + wsize);
t2 = t0((offset + delay):(offset + delay + wsize));


% t1 = t0(1001:2024);
% t2 = t0(4001:5024);

% phi = 42;

% t11 = t1 * exp(-1j * 2 * pi * phi * (1:400000))

subplot(3, 1, 1);
% plot(abs(t1), '-');
plot(real(t1), '-', real(t2), '-');
xlabel('time [samples]');
ylabel('amplitude [.]');
title('raw data');

% Frequency domain of the input signal
% f1 = fft(t1);
% f2 = fft(t2);

wwindow = 10;

t3 = t1 .* conj(t2);
t4 = filter(ones(wwindow,1)/wwindow, 1, t3);

subplot(3, 1, 2);
plot(angle(t4), '-');
xlabel('amplitude [Hz]');
ylabel('amplitude [.]');
title('xcor data');

f1 = fft(t1);

subplot(3, 1, 3);
plot(abs(f1), '-');
xlabel('frequncy [Hz]');
ylabel('amplitude [.]');
title('spectrum data');
