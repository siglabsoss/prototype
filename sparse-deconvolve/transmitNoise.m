% input is an array of -1 and 1 values and a snr
function out = transmitNoise(dense, snr, oversample)



% this is a filter param to smooth out final answer
windowSize = oversample;



% w is raw
w = (dense + 1) ./ 2;  % convert from -1,1 to 0,1

w(end+1) = 0; % pad one bit

% set the second paramater to 1 to not do any oversampling 
x = mskmod(w,oversample,[],pi/2); % modulate chips

xnoisy = awgn(x,snr); % add channel white noise

xnoisy = filter(ones(1,windowSize)/windowSize,1,xnoisy);

y = mod(diff(atan2(real(xnoisy),imag(xnoisy))),2*pi) - pi; % CORDIC demodulate

out = sign(sign(y)+1); % normalize output

out = ( out .* 2 ) - 1; % convert back to -1,1

      
