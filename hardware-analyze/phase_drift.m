%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Signal Laboratories, Inc.
% (c) 2016. Joel D. Brinton.
%
% Compute phase drift between two radios
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
close;

fs = 100e3; % sample rate

cfo_len = 100e3; % samples

thresh = 0.2; % detection threshold;

a = load_raw_uhd('graviton_dual_cap0.out');
b = load_raw_uhd('graviton_dual_cap1.out');




% fast forward to packet start
aidx = find(abs(a)>thresh);
bidx = find(abs(b)>thresh);
a = a(aidx(1):end);
b = b(bidx(1):end);

% length match packets
len = min(length(a),length(b));
a = a(1:len);
b = b(1:len);

% crop packets
clip = 0.025; % seconds
a = a(clip*fs:end-clip*fs);
b = b(clip*fs:end-clip*fs);

% mix frequencies
c = a .* (conj(b));

% unwrap
d = unwrap(angle(c));
d = d - d(1); % when you unwrap it doesn't always start at zero degrees



%%%%%%%%%%%%%%%%%%%%%%%
% measure CFO
%%%%%%%%%%%%%%%%%%%%%%%

% frequency error in radians
f = d(end);

%%%%%%%%%%%%%%%%%%%%%%%
% correct CFO
%%%%%%%%%%%%%%%%%%%%%%%

% mix with DSO
g = exp(i*(1:length(c))/length(c)*f)';
h = c .* g;

% unwrap phase
k = unwrap(angle(h));
k = k - k(1); % when you unwrap it doesn't always start at zero degrees

% generate x-axis
t = (1:length(k))/fs;

%%%%%%%%%%%%%%%%%%%%%%%
% plot phase drift
%%%%%%%%%%%%%%%%%%%%%%%

figure;
plot(t,k);
xlabel('seconds');
ylabel('radians');
set(gca,'GridLineStyle','-');
xlim([min(t) max(t)]);
grid on;
title('Two Relay Phase Drift');

%%%%%%%%%%%%%%%%%%%%%%%
% measure MTIE
%%%%%%%%%%%%%%%%%%%%%%%


% choose set of tau to compute
tau = 10.^((-40:0.2:10)/10);

% preallocate vector
mtie_est(length(tau)) = 0;

% filter (not necessary, but smooths out plot a bit)
filter_window = 10;
af = 1;
bf = (1/filter_window)*ones(1,filter_window);
m = filter(bf,af,k);

% sliding window
for idx = 1:length(tau)
    n = floor(tau(idx) * fs);
    mtie_est(idx) = max(m(n+1:end) - m(1:end-n));
end

%%%%%%%%%%%%%%%%%%%%%%%
% plot MTIE
%%%%%%%%%%%%%%%%%%%%%%%

figure;
semilogx(tau,mtie_est);
xlabel('\tau seconds');
ylabel('\theta radians (degrees)');
title('Maximum Time Interval Error (MTIE)');

ylim([0 pi])
set(gca,'YTick', [0 1/6*pi 2/6*pi 3/6*pi 4/6*pi 5/6*pi pi])
set(gca,'YTickLabels', {'0', '2\pi/6(30°)', '3\pi/6(60°)', '4\pi/6(90°)',...
                        '5\pi/6(120°)', '6\pi/6(150°)','\pi(180°)'})

grid on

xlim([min(tau) max(tau)]);







