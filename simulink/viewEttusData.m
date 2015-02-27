function [timestamp dataOut freq datfft] = viewEttusData(inputData,Fcenter,LO_offset,gain,decimation)
%
%USAGE:
%    [timestamp data freq fft] =
%    viewEttusData(inputData,Fcenter,LO_offset,gain,decimation);
%

timestamp = 0:decimation/1e8:(length(inputData)-1)*decimation/1e8;
dataOut = double(inputData);
datafft = fft(flattopwin(length(dataOut)).*dataOut);
freq = Fcenter+linspace(0,1e8/decimation,length(inputData))'; %these all need to be columns
freq(floor(length(inputData)/2):end) = freq(floor(length(inputData)/2):end) - 1e8/decimation;

figure
subplot 211
plot(timestamp,real(dataOut))
xlabel('time [s]')
title('Data in Time Domain')
subplot 212
plot(fftshift(freq), abs(fftshift(datafft)))
xlabel('freq [hz]')
title('Data in Frequency Domain')

end
