function [ dout ] = ofdm0( din, sstart )

fftsize = 1024;
fsbaseband = 31.25E6;
fsair = 8*fsbaseband;
fspluto = 20E6;

expectedfft = 310; %round(fftsize * (1/fsbaseband) * fspluto)

% clip = din(sstart:sstart+expectedfft);

f4 = figure(4);
plot(abs(din));
title('abs of din');

% f2 = figure(1);
% plot(abs(fftshift(fft(clip))));


bigclip = din;
% din(sstart:sstart+expectedfft*10);
% plot(abs(bigclip));

lag = 1024 

% horzcat(zeros(1,2),ben(3:end))

% size( zeros(1,lag) )

% size( bigclip(lag+1:end) )

bcdelay = vertcat(bigclip(lag+1:end), zeros(lag,1));

p1 = bigclip .* conj(bcdelay);


f3 = figure(3);
plot(abs(p1));
% plot(abs(conj(bigclip(1:800))));
% hold on;
% plot(abs(bcdelay(1:800)), 'r');
% hold off;

% f4 = figure(4);

wwindow = 1024;

movingsum1 = filter(ones(wwindow,1)/wwindow, 1, p1);

dub = 2.*abs(movingsum1);

bcsq1 = abs(bigclip).^2;

delaysq2 = abs(bcdelay).^2;

sqsum = bcsq1 + delaysq2;

movingsum2 = filter(ones(wwindow,1)/wwindow, 1, sqsum);

likely = dub - movingsum2;

[maxval, maxidx] = max(abs(likely).')

a1 = angle(movingsum1(maxidx))

a2 = a1 - (1/(2*pi))

f1 = figure(1);
plot(abs(likely));
title('abs result');

f2 = figure(2);
plot(likely);

% plot(abs(filtered));

% maxfiltered = max(abs(filtered)) * 1000000


dout = [maxidx, a2];

end