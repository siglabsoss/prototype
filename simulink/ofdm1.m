function [ dout ] = ofdm1( din )

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

lag = 1024;

% horzcat(zeros(1,2),ben(3:end))

% size( zeros(1,lag) )

% size( bigclip(lag+1:end) )

bcdelay = vertcat(bigclip(lag+1:end), zeros(lag,1));

p1 = bigclip .* conj(bcdelay);


% f3 = figure(3);
% plot(abs(p1));
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

% this final abs term is not found in the paper
likely = abs(likely);

[maxval, maxidx] = max(abs(likely).')


[pks idx] = findpeaks(likely, 'MinPeakHeight', 0.0004, 'MinPeakDistance', 512)

pdiff = diff(idx)


a1 = angle(movingsum1(maxidx))
a2 = a1 - (1/(2*pi))

f1 = figure(1);
plot(abs(likely));
title('abs result');

% f2 = figure(2);
% plot(likely);

sz = size(idx)

% backouttweak = 0;
% backout = 512+1024 + backouttweak;
backout = 512+1024;

subcarrier = 624;

res = zeros(1,sz);
a2res = zeros(1,sz);

for k = 1:sz
  cidx = idx(k);
  % disp();

  a1 = angle(movingsum1(cidx));
  a2 = a1 - (1/(2*pi))

  a2res(k) = a2;

  cstart = cidx-backout;
  cend   = cstart+1024;

  if(cstart < 1)
    continue;
  endif

  chunk = din(cstart:cend);
  figure(100+k);
  plot(abs(fftshift(ifft(chunk))));
  % plot(fftshift(ifft(chunk)));
  % plot(abs(chunk));
  % tstr = sprintf('chunk %d %d-%d', k, cstart, cend);
  % title(tstr);

  cfft = fftshift(ifft(chunk));

  cfft = cfft * exp(-1j*2*pi*512*(0:1023)/1024);

  % rotwave = exp(1j*(2*pi)*(1:1024)/(1024/(-512-1024)));
  % cfft = cfft .* rotwave;

  % rotwave = exp(1j*(2*pi)*(1:1024)/(1024/(1+a2)));
  % chunk = chunk .* rotwave;
  
  % f5 = figure(5);
  % 
  % title('chunk');
  res(k) = cfft(subcarrier);

endfor



f7 = figure(7);
plot(a2res);
title('a2 result');


% res = res .* rotwave;

% plot(abs(filtered));

f6 = figure(6);
plot(res, '.');
title('result');

% maxfiltered = max(abs(filtered)) * 1000000


% dout = [maxidx, a2];

dout = res;
end