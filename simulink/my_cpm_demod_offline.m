function [ dataOut ] = my_cpm_demod_offline( data, sampleTime )
%MY_CPM_DEMOD_OFFLINE to change vector, repeat, rotations per symbol
%   Detailed explanation goes here

    % god awful way of loading custom variables into matlab simulink model
    variableInitString = sprintf('cpmDemodOfflineSampleTime = %d; cpmDemodOfflineTimeValues = [0:%d:.4]\''; cpmDemodOfflineData = %s;', sampleTime, sampleTime, mat2str(data));
    
   
    % matlab requires us to refer to both of these
    model = 'my_cpm_demod_offline_model';
    modelFile = strcat(model,'.slx');

    % load model (without displaying window)
    load_system(modelFile);
    
    % send in god awful string
    set_param(model, 'InitFcn', variableInitString);
    
    % run it
    sim(model);
    
    % explicity close without saving (0) cuz we changed stuff
    close_system(model, 0);
    
    
    disp(cpmDemodOfflineDataOut);
    
    
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
    