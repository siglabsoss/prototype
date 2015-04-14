function [ dataOut ] = prep_tx_udp( data, sampleTime )
%PREP_TX_UDP run this before running udp_send simulink
%   Data should be TDC.  First sample of 'data' must be first sample of
%   packet
%     - data: raw input data
%     - sampleTime: time per sample

    if( sampleTime > 1 )
        error(sprintf('sample time looks pretty big, maybe try (1/%d)?', sampleTime));
    end

    % Only send in single variable configs here! any vectors should use file based
    % method!
%     variableInitString = sprintf('cpmDemodOfflineSampleTime = %d;', sampleTime);
    
    [sz,~] = size(data);
    
    timeSeries = 0:sampleTime:sz*sampleTime-sampleTime;
    
    udpTxReal = [timeSeries; real(data)'];
    udpTxImag = [timeSeries; imag(data)'];
    
    % save large data vectors to disk
    save('_udpTxReal.mat', 'udpTxReal');
    save('_udpTxImag.mat', 'udpTxImag');
    
    disp('done writing _udpTxReal.mat and _udpTxImag.mat files');
    
end

