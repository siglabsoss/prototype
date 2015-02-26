function [ dataOut ] = run_simulink( dataIn )

    % Convert data to a string (this is the part I would like to avoid)
    variableInitString = sprintf('simin = %s;', mat2str(dataIn));
    
    % we need both the name and the filename
    modelName = 'programatic_simulink';
    modelFileName = strcat(modelName,'.slx');

    % load model (without displaying window)
    load_system(modelFileName);
    
    % Set the InitFcn to the god awful string
    % this is how the dataIn actually gets into the model
    set_param(modelName, 'InitFcn', variableInitString);
    
    % run it
    sim(modelName);
    
    % explicity close without saving (0) because changing InitFcn
    % counts as changing the model.  Note that set_param also
    % creates a .autosave file (which is deleted after close_system)
    close_system(modelName, 0);
    
    % return data from simOut that is created by simulink
    dataOut = simout;
end

