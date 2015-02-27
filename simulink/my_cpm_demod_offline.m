function [ dataOut ] = my_cpm_demod_offline( data, sampleTime, samplesPerSymbol, vector, vectorRepeat )
%MY_CPM_DEMOD_OFFLINE pull bits out of raw data.
%   Data should be TDC.  First sample of 'data' must be first sample of
%   packet
%     - data: raw input data
%     - sampleTime: time per sample
%     - samplesPerSymbol: copy from my cpm mod block
%     - vector: copy from my cpm mod block
%     - vectorRepeat: copy from my cpm mod block

    if( sampleTime > 1 )
        error(sprintf('sample time looks pretty big, maybe try (1/%d)?', sampleTime));
    end

    % Only send in single variable configs here! any vectors should use file based
    % method!
    variableInitString = sprintf('cpmDemodOfflineSampleTime = %d;', sampleTime);
    
    [sz,~] = size(data);
    
    timeSeries = 0:sampleTime:sz*sampleTime-sampleTime;
    
    cpmDemodOfflineDataReal = [timeSeries; real(data)'];
    cpmDemodOfflineDataImag = [timeSeries; imag(data)'];
    
    % save large data vectors to disk
    save('_cpmDemodOfflineDataReal.mat', 'cpmDemodOfflineDataReal');
    save('_cpmDemodOfflineDataImag.mat', 'cpmDemodOfflineDataImag');
    
    % matlab requires us to refer to both of these
    model = 'my_cpm_demod_offline_model';
    modelFile = strcat(model,'.slx');

    % load model (without displaying window)
    load_system(modelFile);
    
%      close_system(model, 1);
    
    % send in configs string (this creates autosave file)
    set_param(model, 'InitFcn', variableInitString);
    
    % apply params to demod block
    set_param('my_cpm_demod_offline_model/My CPM Demod','PatternVectorDialog', mat2str(vector));
    set_param('my_cpm_demod_offline_model/My CPM Demod','PatternVectorRepeatDialog', mat2str(vectorRepeat));
    set_param('my_cpm_demod_offline_model/My CPM Demod','SampsPerSym', mat2str(samplesPerSymbol));
    
    
    % run it
    sim(model);
    
    % explicity close without saving (0) cuz we changed stuff
    close_system(model, 0);
    
    % trash the files
    delete('_cpmDemodOfflineDataReal.mat');
    delete('_cpmDemodOfflineDataImag.mat');
    
%     disp(cpmDemodOfflineDataOut);
    
    
    dataOut = cpmDemodOfflineDataOut;
    
    dataOut(find(dataOut==-2)) = [];
end





    
    
%     ModelParameterNames = get_param('my_cpm_demod_offline_model','ObjectParameters');
%     disp(ModelParameterNames);
    
    % when missing first parameter, finds blocks in ALL simulink files in
    % current path
%     BlockPaths = find_system('Type','Block');
%     disp(BlockPaths);
    
%     BlockParameterValue = get_param('my_cpm_demod_offline_model/Constant', 'SampleTime')
    