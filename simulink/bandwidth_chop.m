function [ dout ] = bandwidth_chop( data, Fs, startHz, endHz )
%FFT Summary of this function goes here
%   Detailed explanation goes here

if( startHz >= endHz )
    error 'startHz must be strictly less than endHz'
end

if nargin < 2
    Fs = 100000;                    % Sampling frequency
end


dt = 1/Fs;                     % seconds per sample
N = size(data,1);
%% Fourier Transform:
X = fftshift(fft(data)/N);
%% Frequency specifications:
dF = Fs/N;                      % hertz
f = -Fs/2:dF:Fs/2-dF;           % hertz

[~,sz] = size(f);

% loop through bins and chop
for index = 1:sz
   fbin = f(index);
   if( fbin < startHz || fbin > endHz )
       X(index) = 0;
   end
end

% ifft for the win
dout = ifft(fftshift(X));

end

