clear all;
close all;

m = 8; % number of channels
fs = 800; % input sample rate
fso = fs/m; % output sample rate

assert(mod(fs, m) == 0);

%%

% PROTOTYPE FILTER (Mth Band)

%  b = firpm(63, [0 0.2 0.8 m/2]/(m/2), [1 1 0 0]);
b  = sinc(-4+(1/m):1/m:4-(1/m)).*kaiser(63,8).';
b = [0 b]/m;

% filter check
% figure;
% freqs = (-0.5:1/512:0.5-(1/512))*fs;
% plot(freqs, 20*log10(abs(fftshift(fft(b, 512)))), 'linewidth', 1.5);
% axis([min(freqs) max(freqs) -120 10]);
% grid on;
% title('Analysis & Synthesis Prototype Filters');
% xlabel('Frequency (Hz)');
% ylabel('Magnitude (dB)');
% break;

bUpConv = zeros(m, length(b));

for i = 1:m
    bUpConv(i,:) = b.*exp((sqrt(-1)*2*pi*(i-1)*(1/m)).*(0:length(b)-1));
end;

%  fvtool(b); break;

% partition filter
polyCoeffs = reshape(m*b, [m, length(b)/m]);


%% DATA GENERATION

% Generate a sequence of complex sinusoids that sweep across the full Nyquist bandwidth.
f = -fs/2:2:fs/2;
n = 0:2047;
%data = zeros(length(f), length(n)); % each row holds a new sinusoid
data = zeros(1, length(f)*length(n));
for i = 1:length(f)
    %data(i,:) = exp(sqrt(-1)*2*pi*(f(i)/fs).*n);
    head = (length(n)*(i-1)) + 1;
    tail = head + length(n) - 1;
    data(head:tail) = exp(sqrt(-1)*2*pi*(f(i)/fs).*n);
end;


%% CHANNELIZER

aReg = zeros(m, length(b)/m);
a2 = zeros(m, 1);
a3 = zeros(m, length(data)/m);

aclk = 1;

for i = 1:m:length(data) % process each row in chunks of m
    
    % ANALYSIS
    
    % chunk
    aReg = [fliplr(data(i:(i+m-1))).' aReg(:,1:end-1)];
    
    % filter
    for j = 1:m
        a2(j) = aReg(j,:) * polyCoeffs(j,:).'; % inner product
    end;
    
    a3(:, aclk) = m * ifft(a2, m);
    
    aclk = aclk + 1;
end;
    

%% PLOTTING

winIn = kaiser(length(n), 20).'; % input window for fft
winIn = winIn/sum(winIn);
freqsIn = (-0.5:1/length(winIn):0.5-(1/length(winIn))).*(fs/2);
freqsInMin = min(freqsIn);
freqsInMax = max(freqsIn);

NChan = length(winIn)/m; % channel output window for fft
winChan = kaiser(NChan, 20).';
winChan = winChan/sum(winChan);
freqsOut = (-0.5:1/NChan:0.5-(1/NChan)).*(fs/(2*(m/2)));
freqsOutMin = min(freqsOut);
freqsOutMax = max(freqsOut);

bSpec = 20*log10(abs(fftshift(fft(b, length(n)/m)))); % for plotting filters on individual channels
bSpecFold = [bSpec(1:length(bSpec)/4) -80*ones(1, length(bSpec) - length(bSpec)/4)];

figure('units', 'normalized', 'outerposition', [0 0 1 1]);

numPlotRows = 3;

subplot(numPlotRows, m/2, 1:m/2);
xlabel('Frequency (Hz)', 'HandleVisibility', 'off');
ylabel('|FFT|^2 (dB)', 'HandleVisibility', 'off');
set(gca , 'NextPlot' , 'replacechildren');
hold on;
for j = 1:m
    plot(freqsIn, 20*log10(abs(fftshift(fft(bUpConv(j,:), length(freqsIn))))), 'r', 'linewidth', 1.5);
end;
hold off;
grid on;
axis([freqsInMin freqsInMax -80 5]);


for i = 1:m/2
    
    % negative frequency channels
    subplot(numPlotRows, m/2, i+(m/2)); grid on;
    xlabel('Frequency (Hz)', 'HandleVisibility', 'off');
    ylabel('|FFT|^2 (dB)', 'HandleVisibility', 'off');
    title(sprintf('Channel %d', i-(m/2)-1), 'HandleVisibility', 'off');
    set(gca , 'NextPlot' , 'replacechildren');
    hold on;
    plot(m*freqsOut, bSpec, 'r', 'linewidth', 1.5);
    plot(m*freqsOut(113:129), bSpec(145:161), 'g', 'linewidth', 1.5);
    plot(m*freqsOut(129:145), bSpec(97:113), 'k', 'linewidth', 1.5);
    hold off;
    grid on;
    axis([freqsOutMin freqsOutMax -80 5]);
    
    % positive frequency channels
    subplot(numPlotRows, m/2, i+m); grid on;
    xlabel('Frequency (Hz)', 'HandleVisibility', 'off');
    ylabel('|FFT|^2 (dB)', 'HandleVisibility', 'off');
    title(sprintf('Channel %d', i-1), 'HandleVisibility', 'off');
    set(gca , 'NextPlot' , 'replacechildren');
    hold on;
    plot(m*freqsOut, bSpec, 'r', 'linewidth', 1.5);
    plot(m*freqsOut(113:129), bSpec(145:161), 'g', 'linewidth', 1.5);
    plot(m*freqsOut(129:145), bSpec(97:113), 'k', 'linewidth', 1.5);
    hold off;
    grid on;
    axis([freqsOutMin freqsOutMax -80 5]);
end;

for i = 1:length(n):length(data)
    
    dataTail = i + length(n) - 1;
    chanHead = (floor(i/length(n))*(length(n)/m)) + 1;
    chanTail = chanHead + (length(n)/m) - 1;
    
    % input
    subplot(numPlotRows,m/2,1:(m/2));
    dataSpec = 20*log10(abs(fftshift(fft(data(i:dataTail).*winIn))));
    plot(freqsIn, dataSpec); 
    hold on;
    for j = 1:m
        plot(freqsIn, 20*log10(abs(fftshift(fft(bUpConv(j,:), length(dataSpec))))), 'r', 'linewidth', 1.5);
    end;
    hold off;
    grid on;
    axis([freqsInMin freqsInMax -80 5]);
        
    % channelizer output
    for k = 1:m/2
        subplot(numPlotRows, m/2, k+(m/2));
        chanData = a3(k+(m/2), chanHead:chanTail);
        chanSpec = 20*log10((1/m)*abs(fftshift(fft(chanData.*winChan))));
        plot(freqsOut, chanSpec);
        hold on;
        plot(m*freqsOut, bSpec, 'r', 'linewidth', 1.5);
        plot(m*freqsOut(113:129), bSpec(145:161), 'g', 'linewidth', 1.5);
        plot(m*freqsOut(129:145), bSpec(97:113), 'k', 'linewidth', 1.5);
        hold off;
        grid on;
        axis([freqsOutMin freqsOutMax -80 5]);
        
        subplot(numPlotRows, m/2, k+m);
        chanData = a3(k,chanHead:chanTail);
        chanSpec = 20*log10((1/m)*abs(fftshift(fft(chanData.*winChan))));
        plot(freqsOut, chanSpec);
        hold on;
        plot(m*freqsOut, bSpec, 'r', 'linewidth', 1.5);
        plot(m*freqsOut(113:129), bSpec(145:161), 'g', 'linewidth', 1.5);
        plot(m*freqsOut(129:145), bSpec(97:113), 'k', 'linewidth', 1.5);
        hold off;
        grid on;
        axis([freqsOutMin freqsOutMax -80 5]);       
        
    end;
    
    pause(0.1);
    
end;
    
    
