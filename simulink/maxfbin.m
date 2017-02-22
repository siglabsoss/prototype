function [  ] = maxfbin( data, Fs )
%FFT Summary of this function goes here
%   Detailed explanation goes here



dt = 1/Fs;                     % seconds per sample
N = size(data,1);
%% Fourier Transform:
X = fftshift(fft(data)/N);
%% Frequency specifications:
dF = Fs/N;                      % hertz
f = -Fs/2:dF:Fs/2-dF;           % hertz
%% Plot the spectrum:
%figure;
%plot(f,2*abs(X));
%xlabel('Frequency (in hertz)');
%title('Magnitude Response');
disp('Each bin is ');
disp(dF);
disp('')


[argvalue, argmax] = max(abs(X));

disp('Max bin is ');
disp(mat2str(f(argmax)));


end

