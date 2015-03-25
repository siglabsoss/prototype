function [timestamp dataOut freq datfft] = viewEttusDataSrate(inputData,Fcenter,LO_offset,gain,srate)
%
%USAGE:
%    [timestamp data freq fft] =
%    viewEttusData(inputData,Fcenter,LO_offset,gain,srate);
%

timestamp = 0:srate:(length(inputData)-1)*srate;
dataOut = double(inputData);
datafft = fft(flattopwin(length(dataOut)).*dataOut);
%freq = Fcenter+linspace(0,1/srate,length(inputData))'; %these all need to be columns
freq = linspace(0,1/srate,length(inputData))'; %these all need to be columns
freq(floor(length(inputData)/2):end) = freq(floor(length(inputData)/2):end) - 1/srate;

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
