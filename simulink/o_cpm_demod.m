% knobs
demoddata = idealdata;
patternVectorDialog = [1 1 0 2 1 0 2 2 1 0 0 1 1 1 0 2 2 0 2 2];
patternVectorRepeatDialog = 1;
demodSamplesPerSymbol = 100;
demodRotationsPerSymbol = 1;
fs = 125E3;


% fixed
srate = 1/fs;
% fixed packet length in seconds
packetLength = 0.4;
packetLenghtSamples = round(packetLength * fs);
demodPreviousBuffer = zeros(0);



% repeat the pattern vector as specificed by the dialog
patternVector = zeros(0);
for j = 1:patternVectorRepeatDialog
    patternVector = [patternVector patternVectorDialog];
end

% save the full size
[~,pvSize] = size(patternVector);


% working variables
demodAngleAdjust = 0;
bitsout = [];


for currentSampleIndex = 1:packetLenghtSamples
%     scaledTimeIndex = floor(((currentSampleIndex-2) / packetLenghtSamples) * pvSize);

    currentTime = (currentSampleIndex-1) * srate;
    scaledTimeIndex = floor((currentTime / packetLength) * pvSize);

    modee = patternVector(mod(scaledTimeIndex,pvSize)+1);
    
    sample = demoddata(currentSampleIndex);
    sampleAngle = angle(sample);
    
    if( currentSampleIndex == 1 )
        demodPreviousSample = sampleAngle;
        demodPreviousSampleAngle = sampleAngle;
    end
    
    thresh = pi;
    
    if(abs(sampleAngle-demodPreviousSample) > thresh)
        direction = 1;
        if( sampleAngle > demodPreviousSample )
            direction = -1;
        end
        demodAngleAdjust = demodAngleAdjust + 2*pi*direction;
    end
    
    
    % unrolled angle
    sampleAngle = sampleAngle + demodAngleAdjust;

    % diff(unrolled angle)
    sampleDiff = sampleAngle - demodPreviousSampleAngle;

    bufferIndex = mod(currentSampleIndex-1, demodSamplesPerSymbol) +1;

    demodPreviousBuffer(bufferIndex) = sampleDiff;
    
    
    
%     disp(sprintf('sam (%f %f) bufferIndex %d modee %d scaled %f', real(sample), imag(sample), bufferIndex, modee, scaledTimeIndex));
    
    if( bufferIndex == demodSamplesPerSymbol )
    
        % look at buffer and make our decision
        bit = -1;

        if( (sum(demodPreviousBuffer) / demodSamplesPerSymbol) > 0 )
            bit = 1;
        end

        % only output data if demodulating data
        if( modee == 0 )
%             block.OutputPort(1).Data = bit;
%             disp(bit);
            bitsout = [bitsout;bit];
%             figure;
%             plot(demodPreviousBuffer);
% disp(sum(demodPreviousBuffer));
        else
            % output an unrealstic number so we can remove this samples later
%             block.OutputPort(1).Data = -2;
%             disp(-2);
        end
    end
    
    
    
    % need to save angle of previous sample without adjustments that
    % have already been rolled into sampleAngle (aka dont use sampleAngle here)
    demodPreviousSample = angle(sample);

    demodPreviousSampleAngle = sampleAngle;
 
end
    
    
    


% scaledTimeIndex = floor((currentTime / packetLength) * pvSize);
% modee = patternVector(mod(scaledTimeIndex,pvSize)+1);

