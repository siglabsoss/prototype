function [ output_args ] = ffttest( data )
%FFT Summary of this function goes here
%   Detailed explanation goes here

Fs = 100000;                    % Sampling frequency
% T = 1/Fs;                     % Sample time
% L = size(data,1);                     % Length of signal
% t = (0:L-1)*T;                % Time vector
% 
% NFFT = 2^nextpow2(L); % Next power of 2 from length of y
% Y = fftshift(fft(data,NFFT)/L);
% f = Fs/2*linspace(-1,1,NFFT-1);
% 
% % Plot single-sided amplitude spectrum.
% plot(f,2*abs(Y(1:NFFT-1))) 
% title('Single-Sided Amplitude Spectrum of y(t)')
% xlabel('Frequency (Hz)')
% ylabel('|Y(f)|')


% figure;
% 
% Y = fft(data,NFFT)/L;
% f = Fs/2*linspace(0,1,NFFT/2+1);
% 
% % Plot single-sided amplitude spectrum.
% plot(f,2*abs(Y(1:NFFT/2+1))) 
% title('Single-Sided Amplitude Spectrum of y(t)')
% xlabel('Frequency (Hz)')
% ylabel('|Y(f)|')



% figure;


dt = 1/Fs;                     % seconds per sample
N = size(data,1);
%% Fourier Transform:
X = fftshift(fft(data)/N);
%% Frequency specifications:
dF = Fs/N;                      % hertz
f = -Fs/2:dF:Fs/2-dF;           % hertz
%% Plot the spectrum:
figure;
plot(f,2*abs(X));
xlabel('Frequency (in hertz)');
title('Magnitude Response');


end

