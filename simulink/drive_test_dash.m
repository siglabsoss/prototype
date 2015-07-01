1;
more off
clear all
close all

BER_coherent_accumulator = [];
BER_single_accumulator = [];
time_accumulator = [];
numgoodsets_accumulator = [];

starttime = time;

% starting value for knobs
detect_threshold = 1.9;
fsearchwindow_low = -200;
fsearchwindow_hi = 200;
concat_mode = 0;   % 0 is both % 1 is 200 % 2 is 202

update_knobs = 0;


while 1
   
%     disp('checking');
    

    
    
    
    chars = kbhit (1);    
    if( size(chars) ~= [0 0] )
        disp('');
        switch(chars)
        
            case 'a'
                disp('low down');
                update_knobs = 1;
                fsearchwindow_low = fsearchwindow_low - 50;
                
            case 's'
                disp('low up');
                update_knobs = 1;
                fsearchwindow_low = fsearchwindow_low + 50;
                
            case 'd'
                disp('high down');
                update_knobs = 1;
                fsearchwindow_hi = fsearchwindow_hi - 50;
                
            case 'f'
                disp('high up');
                update_knobs = 1;
                fsearchwindow_hi = fsearchwindow_hi + 50;
                
            case 'g'
                disp('thresh down');
                update_knobs = 1;
                detect_threshold = detect_threshold - 0.1;
                
            case 'h'
                disp('thresh up');
                update_knobs = 1;
                detect_threshold = detect_threshold + 0.1;
                
            case 'c'
                disp('Concat Mode:');
                update_knobs = 1;
                concat_mode = concat_mode + 1;
                concat_mode = mod(concat_mode,3);
        end
        
        if( update_knobs == 1 )
            delete('correlator_knobs.mat');
            save('correlator_knobs.mat','detect_threshold', 'fsearchwindow_low', 'fsearchwindow_hi', 'concat_mode');
        end
        update_knobs = 0;
        [fsearchwindow_low fsearchwindow_hi detect_threshold concat_mode]
    end
    
    
    
    
    
 
    statval = stat('dashboard_lock');
    if( size(statval) == [0 0] )
%         disp('waiting');
    else
        disp('running');
        disp('');
        disp('');
        delete('dashboard_lock');
        
        % load data
        load('drive_dash_data.mat');

        
        %calc theoretical data rate
        num_antennas = 100;
        delta_f = 26e6; %ISM band
        theoretical_data_rate_single = delta_f*log2(1+10^(mean(single_antenna_strength)/10));
        theoretical_data_rate_coherent = delta_f*log2(1+10^(coherent_antenna_strength/10));
        theoretical_data_rate_10k = delta_f*log2(1+(1e4/num_antennas)*(10^(coherent_antenna_strength)/10));
        
        %hoarder
        thistime = time-starttime;
        number_of_good_datasets = length(goodsets);
        BER_coherent_accumulator = [BER_coherent_accumulator;BER_coherent];
        BER_single_accumulator = [BER_single_accumulator;BER_single];
        time_accumulator = [time_accumulator;thistime];
        numgoodsets_accumulator = [numgoodsets_accumulator; number_of_good_datasets];
        
        %Bit Error Rate Plot
        figure(1)
        plot(time_accumulator,BER_coherent_accumulator,'bo-')
        hold on
        plot(time_accumulator,BER_single_accumulator,'rx-')
        hold off
        legend('Coherent','Single Antenna','Location','NorthWest')
        xlabel('Time [s]','FontSize',14)
        ylabel('Bit Error Rate (BER)','FontSize',14)
        ylim([0 0.6])
        title('Time History: Bit Error Rate of Coherent and Single Antennas','FontSize',14)
        
        %Antenna Power Plot
        figure(2)
        bar([zeros(length(single_antenna_strength)+1,1);coherent_antenna_strength],'b')
        hold on
        bar([single_antenna_strength;0],'r')
        hold off
        legend('Coherent Epoch','Single Antenna Epoch','Location','NorthWest')
        xlabel('Antenna Epoch','FontSize',14)
        ylabel('Epoch Strength (dB)','FontSize',14)
        ylim([-20 100])
        title('Current: Antenna Strength (Signal / Thermal Energy) for Coherent and Single','FontSize',14)
        
        %Rank Plot
        figure(3)
        subplot(2,1,1)
        plot(noisyxcorrsnr,'o')
        xlabel('Data Chunk Index','FontSize',14)
        ylabel('Comb Correlation SNR','FontSize',14)
        subplot(2,1,2)
        hist(noisyxcorrsnr,20)
        xlabel('xcorr SNR value','FontSize',14)
    	ylabel('hit count','FontSize',14)
        subplot(2,1,1)
        title('Current: Plot and Histogram of SNR used for Signal Detection','FontSize',14)
        
        %corrections plot
        figure(4)
        subplot(3,1,1)
        plot(freqoffsetxcorr,'o-')
        title('Current: Frequency Offset Correction Applied','FontSize',14)
        ylabel('Freq [Hz]','FontSize',14)
        xlabel('dataset','FontSize',14)
        subplot(3,1,2)
        plot(recoveredphasexcorr,'o-')
        title('Current: Phase Offset Correction Applied','FontSize',14)
        ylabel('Phase [rad]','FontSize',14)
        xlabel('dataset','FontSize',14)
        subplot(3,1,3)
        plot(samplesoffsetxcorr,'o-')
        title('Current: Time Offset Correction Applied','FontSize',14)
        ylabel('Time [samples]','FontSize',14)
        xlabel('dataset','FontSize',14)
        
        %numgoodsets plot
        figure(5)
        plot(time_accumulator,numgoodsets_accumulator,'bo-')
        title('Time History: Number of Good Datasets','FontSize',14)
        ylabel('Number','FontSize',14)
        xlabel('Time [s]','FontSize',14)
        ylim([0 100])
        
        %text box of theoretical data rates
        figure(6)
        clf
        axis off
        text(0.1,0.75,'Theoretical Data Rate Single Antenna: ','FontSize',16);
        text(0.1,0.65,[num2str(theoretical_data_rate_single,3) ' bit/s'],'FontSize',18,'Color','r');
        text(0.1,0.50,'Theoretical Data Rate Coherent Antenna: ','FontSize',16);
        text(0.1,0.40,[num2str(theoretical_data_rate_coherent,3) ' bit/s'],'FontSize',18,'Color','b');
        text(0.1,0.25,'Theoretical Data Rate 10k Coherent Antennas: ','FontSize',16);
        text(0.1,0.15,[num2str(theoretical_data_rate_10k,3) ' bit/s'],'FontSize',18,'Color','g');
        
        
        
    end
    

    sleep(0.2);
    
end