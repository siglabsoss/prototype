function [ cluster ] = rollingfft( data, comb )

% data = data(1:190000);


[dataSize,~] = size(data);

packetSize = 4000;
%packetSize = 30;

endingStartSample = dataSize - packetSize;


cft = fftshift(fft(comb));


cluster = zeros(0);

for index = 1:900:endingStartSample
    endSample = index+packetSize-1;
    ft = fftshift(fft(data(index:endSample)));
%     cluster = [cluster abs(ft)];

    xcr = xcorr(ft, cft);

    cluster = [cluster, xcr];

%     size(data(index:endSample))
end





end

