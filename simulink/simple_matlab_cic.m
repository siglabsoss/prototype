


% example chirp through the cic filter first chirp
% cccc = chirp(0:1/1E3:2,2,0.4);
% data_in = int32(cccc * 100).';
% data_in = data_in(1:data_in-1)

    channel_decimation_rate = 2;
    channelcic = dsp.CICDecimator(channel_decimation_rate);
    channelcic.NumSections = 2;
    
    % the final channel bits
    data_out = step(channelcic, data_in);
    
    release(channelcic); % free memory
    
