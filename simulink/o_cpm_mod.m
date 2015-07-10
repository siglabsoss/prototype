function [ dataout, clock_comb ] = o_cpm_mod( bits, bitsrate, srate, samplesPerSymbol, rotationsPerSymbol, vector, vectorRepeat )
%O_CPM_MOD Summary of this function goes here
%   Detailed explanation goes here


rateRatio = bitsrate/srate; 
patternVectorDialog = vector; %[1 1 0 2 1 0 2 2 1 0 0 1 1 1 0 2 2 0 2 2];
patternVectorRepeatDialog = vectorRepeat;
demodSamplesPerSymbol = samplesPerSymbol;
outSampleTime = srate;

clockFrequency = 100;
dinFilterLength = 3;

dataout = [];
clock_comb = [];


% init
totalSamples = 0;
dataInt = 0;
clockUpInt = 0;
clockDownInt = 0; 


% more init

fs = 1/srate;
% fixed packet length in seconds
packetLength = 0.4;


% repeat the pattern vector as specificed by the dialog
patternVector = zeros(0);
for j = 1:patternVectorRepeatDialog
    patternVector = [patternVector patternVectorDialog];
end

% save the full size
[~,pvSize] = size(patternVector);


% prepare buffer "filter"
dinFilterr = zeros(dinFilterLength,1);


[sz,~] = size(bits);

bitVector = [];

% multiply up like simulink does
for j = [1:sz]
    bitVector = [bitVector; ones(round(rateRatio),1) .* bits(j)];
end


[sz,~] = size(bitVector);

j = 1;

for currentTime = [0:srate:packetLength]

%% these three lines filter the data only       
%     din = sum(dinFilterr)/dinFilterLength;
%     filterIndex = mod(totalSamples, dinFilterLength) + 1;
%     dinFilterr(filterIndex) = bitVector(j); % fill into filter

%% for now turn filter off, seems to be more clean this way
    din = bitVector(j);
    
%     currentTime = (currentSampleIndex-1) * srate;
%     mat2str(currentTime)
    scaledTimeIndex = floor((currentTime / packetLength) * pvSize);
    
    
    % gives us a ms index
    tms = floor(currentTime*10000);

    % 0 1 2
    modee = patternVector(mod(scaledTimeIndex,pvSize)+1);

    
    % 1/rotations per bit.
    % each bit is 10 data points (when samplesPerSymbol is 10)
    % so a clock with 1000 points for rotation would be 1/100
    df = rotationsPerSymbol;
    % cdf = 1/100;

    cdf = outSampleTime * clockFrequency * samplesPerSymbol;


    % always run clock "movies"
    clockUpInt   = clockUpInt   + 1 / samplesPerSymbol;
    clockDownInt = clockDownInt - 1 / samplesPerSymbol;
    ddt = din / samplesPerSymbol;
    dataInt = dataInt + ddt;

    % Clock output port
    % Switch between movies (even if discontinuous)
    % Output 0 when in data mode
    switch modee
        case 0
            crout = 0;
            ciout = 0;
        case 1
            crout = cos(cdf * 2 * pi * clockUpInt);
            ciout = sin(cdf * 2 * pi * clockUpInt);
        case 2
            crout = cos(cdf * 2 * pi * clockDownInt);
            ciout = sin(cdf * 2 * pi * clockDownInt);
    end

    % Data only output port (mostly useless)
    rout = cos(df * 2 * pi * dataInt);
    iout = sin(df * 2 * pi * dataInt);

    % modulation output port ('t' stands for 3rd)
    trout = crout;
    tiout = ciout;

    % 0 is data, 1 is clock up, 2 is clock down 
    if( modee == 0 )
        % mode 0 so put in data
        trout = rout;
        tiout = iout;
    end

    if( currentTime > packetLength )
        trout = 0; % end packet
        tiout = 0;
        crout = 0;
        ciout = 0;
    end



    % write to block
%     block.OutputPort(1).Data = complex(rout,iout);   % ?
%     block.OutputPort(2).Data = complex(crout,ciout); % clock comb
%     block.OutputPort(3).Data = complex(trout,tiout); % ideal data
    
    
    
     dataout = [dataout; complex(trout,tiout)];
     clock_comb = [clock_comb; complex(crout,ciout)];


    totalSamples = totalSamples + 1;

    % only advance bit pattern when in the right mode
    if( modee == 0 )
        j = j + 1;
    end

end






end

