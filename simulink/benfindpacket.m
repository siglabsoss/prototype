% size(data)
% size(data1)
% size(clock_comb)


sampleTime = 1/(10000*10);

[packet, startSample] = findpacket(clock_comb, data);
[packet1, startSample1] = findpacket(clock_comb, data1);


[startSample, startSample1]


[combLength,~] = size(clock_comb);

packetData = zeros(0);
packetData1 = zeros(0);
originalDataPacked = zeros(0);

for index = 1:combLength
    if( clock_comb(index) == complex(0,0) )
        packetData(end+1) = packet(index);
        packetData1(end+1) = packet1(index);
        originalDataPacked(end+1) = original_data(index);
    end
    
    
end


[~,packetDataSize] = size(packetData);

packetDataTimeValues = linspace(0,packetDataSize*sampleTime,packetDataSize)';

packetData = packetData';
packetData1 = packetData1';
originalDataPacked = originalDataPacked';


% xc1 = 