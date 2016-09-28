clear all;
close all;

plot_imp_resp = 0; % set to 1 to plot analysis and synthesis filter impulse responses, 0 to run demo

m = 8; % number of channels
fs = 800; % input sample rate

assert(mod(fs, m) == 0);

%%

% PROTOTYPE FILTER (Mth Band)

% b = firpm(63, [0 0.2 0.8 m/2]/(m/2), [1 1 0 0]);
% sb = firpm(127, [0 0.8 1.2 m/2]/(m/2), [1 1 0 0]);

b  = sinc(-4+(1/m):1/m:4-(1/m)).*kaiser(63,8).';
b = [0 b]/m;

sb = firpm(94, [0 0.8 1.2 m/2]/(m/2), [1 1 0 0]);
sb = m*[0 sb];

% filter check
% figure;
% freqs = (-0.5:1/512:0.5-(1/512))*fs;
% plot(freqs, 20*log10(abs(fftshift(fft(b, 512)))), 'linewidth', 1.5);
% hold on;
% plot(freqs, 20*log10(abs(fftshift(fft(sb/m, 512)))), 'linewidth', 1.5);
% axis([min(freqs) max(freqs) -120 10]);
% grid on;
% title('Analysis & Synthesis Prototype Filters');
% xlabel('Frequency (Hz)');
% ylabel('Magnitude (dB)');
% legend('Analysis (Windowed Sinc, length = 64)', 'Synthesis (FIRPM, length = 96)', 'location', 'northwest');
% break;

bUpConv = zeros(m, length(b));
sbUpConv = zeros(m, length(sb));

for i = 1:m
    p1 = sqrt(-1)*2*pi*(i-1)*(1/m);
    p2 = (0:length(b)-1);
    p3 = p1 .* p2;
    bUpConv(i,:) = b .* exp(p3);
    sbUpConv(i,:) = (sb/m).*exp((sqrt(-1)*2*pi*(i-1)*(1/m)).*(0:length(sb)-1));
end;

% fvtool(b); fvtool(sb); break;

% partition filter
aPolyCoeffs = reshape(m*b, [m, length(b)/m]);
sPolyCoeffs = reshape(sb, [m, length(sb)/m]);


%% DATA GENERATION

% Generate a sequence of complex sinusoids that sweep across the full Nyquist bandwidth.
f = -fs/2:2:fs/2;
% n = 0:2047;
n = 0:1023;

if plot_imp_resp == 1
    data = zeros(1, length(n));
    data(1) = 1;
else
    data = zeros(1, length(f)*length(n));
    for i = 1:length(f)
        % data(i,:) = exp(sqrt(-1)*2*pi*(f(i)/fs).*n);
        head = (length(n)*(i-1)) + 1;
        tail = head + length(n) - 1;
        data(head:tail) = exp(sqrt(-1)*2*pi*(f(i)/fs).*n);
    end;
end;

%% CHANNELIZER

a1 = zeros(m, 1);
a2 = zeros(m, 1);
a3 = zeros(m, length(data)/(m/2));
aReg = zeros(m, 2*length(aPolyCoeffs(1,:)));
aclk = 1;

s2 = zeros(m,1);
s3 = zeros(m,1);
sReg = zeros(m, 2*length(sPolyCoeffs(1,:)));
synthData = zeros(1,length(data)); % holds synthesized signal

aflg = 0;
sflg = 0;
sclk = 1;

for i = 1:(m/2):length(data) % process each row in chunks of m/2
    
    % ANALYSIS
    
    % chunk
    a1(1:(m/2)) = fliplr(data(i:(i+(m/2)-1))).';
    a1((m/2)+1:m) = a1(1:(m/2));
    aReg = [a1 aReg(:, 1:end-1)];
    
    % filter
    for k = 1:(m/2)
        a2(k) = aReg(k, 1:2:end) * aPolyCoeffs(k,:).';
        a2(k+m/2) = aReg(k+(m/2), 2:2:end) * aPolyCoeffs(k+(m/2),:).';
    end;
    
    if aflg == 0
        aflg = 1;
    else
        a2 = [a2((m/2)+1:end); a2(1:(m/2))];
        aflg = 0;
    end;
    
%     a3(:, aclk) = m * ifft(a2, m);
    a3(:, aclk) = (m/2) * ifft(a2, m);
    
    % SYNTHESIS
    
%     s2 = (m/2) * ifft( m * a3(:, aclk), m);
        s2 = ifft(a3(:, aclk), m);

    
    if sflg == 0
        sflg = 1;
    else
        s2 = [s2((m/2)+1:end); s2(1:(m/2))];
        sflg = 0;
    end;
    
    sReg = [s2 sReg(:,1:end-1)];
    
    for k = 1:(m/2)
        p1 = sReg(k,1:2:end) * sPolyCoeffs(k,:).';
        p2 = sReg(k+(m/2),2:2:end) * sPolyCoeffs(k+(m/2),:).';
        synthData(sclk + (k-1)) = p1 + p2;
    end;
    
    aclk = aclk + 1;
    sclk = sclk + (m/2);
    
        
    
end;

%% PLOTTING

winIn = kaiser(length(n), 20).'; % input window for fft
winIn = winIn/sum(winIn);
freqsIn = (-0.5:1/length(winIn):0.5-(1/length(winIn))).*(fs/2);
freqsInMin = min(freqsIn);
freqsInMax = max(freqsIn);

NChan = length(winIn)/(m/2); % channel output window for fft
winChan = kaiser(NChan, 20).';
winChan = winChan/sum(winChan);
freqsOut = (-0.5:1/NChan:0.5-(1/NChan)).*(fs/(2*(m/2)));
freqsOutMin = min(freqsOut);
freqsOutMax = max(freqsOut);

bSpec = 20*log10(abs(fftshift(fft(b, length(n)/(m/2))))); % for plotting filters on individual channels

if plot_imp_resp == 1
    % plot system overall impulse response
       
    figure;
    
    spec = fftshift(20*log10(abs(fft(synthData))));
    freqs = (-0.5:1/length(synthData):0.5-(1/length(synthData))).*fs;
    subplot(2,1,1);
    plot(freqs, spec, 'linewidth', 1.5);
    grid on;
    title('System Full BW Impulse Response');
    xlabel('Frequency (Hz)', 'HandleVisibility', 'off');
    ylabel('|FFT|^2 (dB)', 'HandleVisibility', 'off');
    axis([min(freqs) max(freqs) -1 1]);
    subplot(2,1,2);
    plot(freqs, spec, 'linewidth', 1.5);
    grid on;
    title('System Full BW Impulse Response Blow Up');
    xlabel('Frequency (Hz)', 'HandleVisibility', 'off');
    ylabel('|FFT|^2 (dB)', 'HandleVisibility', 'off');
    axis([min(freqs) max(freqs) -0.001 0.001]);
    break;
    
else
    figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    
    numPlotRows = 4;
    
    subplot(numPlotRows, m/2, 1:m/2);
    xlabel('Frequency (Hz)', 'HandleVisibility', 'off');
    ylabel('|FFT|^2 (dB)', 'HandleVisibility', 'off');
    set(gca , 'NextPlot' , 'replacechildren');
    
    subplot(numPlotRows, m/2, 13:(13+(m/2)-1));
    xlabel('Frequency (Hz)', 'HandleVisibility', 'off');
    ylabel('|FFT|^2 (dB)', 'HandleVisibility', 'off');
    set(gca , 'NextPlot' , 'replacechildren');
    
    for i = 1:m/2
        
        % negative frequency channels
        subplot(numPlotRows, m/2, i+(m/2)); grid on;
        xlabel('Frequency (Hz)', 'HandleVisibility', 'off');
        ylabel('|FFT|^2 (dB)', 'HandleVisibility', 'off');
        title(sprintf('Channel %d', i-(m/2)-1), 'HandleVisibility', 'off');
        set(gca , 'NextPlot' , 'replacechildren');
        
        % positive frequency channels
        subplot(numPlotRows, m/2, i+m); grid on;
        xlabel('Frequency (Hz)', 'HandleVisibility', 'off');
        ylabel('|FFT|^2 (dB)', 'HandleVisibility', 'off');
        title(sprintf('Channel %d', i-1), 'HandleVisibility', 'off');
        set(gca , 'NextPlot' , 'replacechildren');
    end;
        
    for i = 1:length(n):length(data)
        
        dataTail = i + length(n) - 1;
        chanHead = (floor(i/length(n))*(length(n)/(m/2))) + 1;
        chanTail = chanHead + (length(n)/(m/2)) - 1;
        
        % input
        subplot(numPlotRows,m/2,1:(m/2));
        dataSpec = 20*log10(abs(fftshift(fft(data(i:dataTail).*winIn))));
        plot(freqsIn, dataSpec); grid on;
        hold on;
        for j = 1:m
            plot(freqsIn, 20*log10(abs(fftshift(fft(bUpConv(j,:), length(dataSpec))))), 'r', 'linewidth', 1.5);
        end;
        hold off;
        axis([freqsInMin freqsInMax -100 5]);
        
        % synth output
        subplot(numPlotRows, m/2, 13:(13+((m/2)-1)));
        dataSpec = 20*log10(abs(fftshift(fft(synthData(i:dataTail).*winIn))));
        plot(freqsIn, dataSpec); grid on;
        hold on;
        for j = 1:m
            plot(freqsIn, 20*log10(abs(fftshift(fft(bUpConv(j,:), length(dataSpec))))), 'r', 'linewidth', 1.5);
%             plot(freqsIn, 20*log10(abs(fftshift(fft(sbUpConv(j,:), length(dataSpec))))), 'r');
        end;
        hold off;
        axis([freqsInMin freqsInMax -100 5]);
        
        % channelizer output
        for k = 1:m/2
            subplot(numPlotRows, m/2, k+(m/2));
            chanData = a3(k+(m/2), chanHead:chanTail);
            chanSpec = 20*log10((2/m)*abs(fftshift(fft(chanData.*winChan))));
            plot(freqsOut, chanSpec); grid on;
            hold on;
            plot((m/2)*freqsOut, bSpec, 'r', 'linewidth', 1.5);
            hold off;
            axis([freqsOutMin freqsOutMax -100 5]);
            
            subplot(numPlotRows, m/2, k+m);
            chanData = a3(k,chanHead:chanTail);
            chanSpec = 20*log10((2/m)*abs(fftshift(fft(chanData.*winChan))));
            plot(freqsOut, chanSpec);grid on;
            hold on;
            plot((m/2)*freqsOut, bSpec, 'r', 'linewidth', 1.5);
            hold off;
            axis([freqsOutMin freqsOutMax -100 5]);
            
        end;
        
        pause(0.01);
        
    end;
end;
