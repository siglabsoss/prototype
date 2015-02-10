function [ wave, peaks, wave2, peaks2 ] = padding_phase_shift(  )

% 360 different phase angles
xin = linspace(0,360-1,360);
x = xin*(pi/180);


peaks = zeros(0);
for phase = x

wavereal =    cos(phase+linspace(0,20*pi,10000));
wavecomplex = sin(phase+linspace(0,20*pi,10000));

% wavereal = wavereal(345:end);
% wavecomplex = wavecomplex(345:end);

% wavereal = [complex(zeros(1,312)) wavereal];
% wavecomplex = [complex(zeros(1,312)) wavecomplex];

wave = wavereal + (wavecomplex .* i);

fft1 = fft(wave);

[pk1,ipk1] = max(fft1);

peaks(end+1) = pk1;

end



peaks2 = zeros(0);
for phase = x

wavereal =    cos(phase+linspace(0,20*pi,10000));
wavecomplex = sin(phase+linspace(0,20*pi,10000));

% wavereal = wavereal(345:end);
% wavecomplex = wavecomplex(345:end);

wavereal = [complex(zeros(1,312)) wavereal];
wavecomplex = [complex(zeros(1,312)) wavecomplex];

wave2 = wavereal + (wavecomplex .* i);

fft2 = fft(wave2);

[pk2,ipk2] = max(fft2);

peaks2(end+1) = pk2;

end

% splot(wave1');
% figure
% splot(wave2');

subplot 211
plot(angle(peaks));
subplot 212
plot(angle(peaks2));

figure
splot(wave');
figure
splot(wave2');


end

