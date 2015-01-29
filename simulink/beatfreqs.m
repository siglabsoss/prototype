close all
timeseries = 0:0.00001:1;
f1 = 50;
f2 = 70;
a1 = 0;
a2 = 0;
freq1 = sin(2*pi*f1*timeseries+a1);
freq2 = sin(2*pi*f2*timeseries+a2);
beat1 = sin(2*pi*((f1+f2)/2)*timeseries-(a1+a2)/2);
beat2 = cos(2*pi*((f1-f2)/2)*timeseries-(a1-a2)/2);
subplot 311
plot(timeseries, freq1);
subplot 312
plot(timeseries, freq2);
subplot 313
plot(timeseries, freq1+freq2);
hold on
plot(timeseries, beat1, 'g')
plot(timeseries, beat2, 'm')


f3 = 60;
a3 = 0;
freq3 = sin(2*pi*f3*timeseries+a3);%+i*cos(2*pi*f3*timeseries+a3);
mfreq1 = freq3.*freq1;
mfreq2 = freq3.*freq2;
mfreq12 = freq3.*(freq1+freq2);
figure
subplot 321
plot(timeseries, real(mfreq1))
subplot 322
plot(abs(fftshift(fft(mfreq1))))
subplot 323
plot(timeseries, real(mfreq2))
subplot 324
plot(abs(fftshift(fft(mfreq2))))
subplot 325
plot(timeseries, real(mfreq12))
subplot 326
plot(abs(fftshift(fft(mfreq12))))
figure
plot(angle(fftshift(fft(mfreq12))))