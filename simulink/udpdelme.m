function [ floats ] = udpdelme(  )
%UDPDELME Summary of this function goes here
%   Detailed explanation goes here



hudpr = dsp.UDPReceiver('LocalIPPort', 1235, 'MaximumMessageLength', 8*4*1000);

bytesReceived = 0;

bytes = [];



for drain = 1:10000
    dataReceived = step(hudpr);
end

disp('end drain')

datetime

while bytesReceived < 10000*8
   dataReceived = step(hudpr);
   bytesReceivedLen = length(dataReceived);
   
   
   if( bytesReceivedLen ~= 0 )
       bytesReceived = bytesReceived + bytesReceivedLen;
       bytes = [bytes; dataReceived];
   end
end

datetime


release(hudpr);
fprintf('Bytes received: %d\n', bytesReceived);

[sz,~] = size(bytes);

floats = [];

for k = 1:8:floor(size(bytes)/4)*4
    v1 = bytes(k:k+3);
    v2 = bytes(k+4:k+7);
    
    f1 = typecast(uint8(v1),'single');
    f2 = typecast(uint8(v2),'single');
    floats = [floats; complex(f1,f2)];
    
end


end

