1;
more off



while 1
   
%     disp('checking');
    statval = stat('dashboard_lock');
    if( size(statval) == [0 0] )
%         disp('waiting');
    else
        disp('running');
        clock
        disp('');
        disp('');
        delete('dashboard_lock');
        
        % load data
        load('drive_dash_data.mat');
        
        disp(BER_coherent);
        disp(BER_single);
        
    end
    

    sleep(2);
    
end