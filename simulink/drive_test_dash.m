1;
more off
clear all
close all

accumulator_length = 20;

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
        
        BER_coherent
        BER_single

        
        %calc theoretical data rate
        num_antennas = 60;
        delta_f = 26e6; %ISM band
        bandwidth_factor_db = 10*log10(10e3/delta_f);
        theoretical_data_rate_single = delta_f*log2(1+10^((median(single_antenna_strength)+bandwidth_factor_db)/10));
        theoretical_data_rate_coherent = delta_f*log2(1+10^((coherent_antenna_strength+bandwidth_factor_db)/10));
		%calc capable bandwidth for equal SNR
		antenna_ratio = 1e4/num_antennas;
		delta_f_10k = delta_f*antenna_ratio;
		bandwidth_factor_db_10k = 10*log10(10e3/delta_f_10k);
        theoretical_data_rate_10k = delta_f_10k*log2(1+(antenna_ratio)*(10^((coherent_antenna_strength+bandwidth_factor_db_10k)/10)));
        
        %hoarder
        thistime = time-starttime;
        number_of_good_datasets = length(goodsets);
        BER_coherent_accumulator = [BER_coherent_accumulator;BER_coherent];
        BER_single_accumulator = [BER_single_accumulator;BER_single];
        time_accumulator = [time_accumulator;thistime];
        numgoodsets_accumulator = [numgoodsets_accumulator; number_of_good_datasets];
        if size(BER_coherent_accumulator,1) > accumulator_length
            BER_coherent_accumulator = BER_coherent_accumulator(end-accumulator_length+1:end,1);
        end
        
        if size(BER_single_accumulator,1) > accumulator_length
            BER_single_accumulator = BER_single_accumulator(end-accumulator_length+1:end,1);
        end
        
        if size(time_accumulator,1) > accumulator_length
            time_accumulator = time_accumulator(end-accumulator_length+1:end,1);
        end
        
        if size(numgoodsets_accumulator,1) > accumulator_length
            numgoodsets_accumulator = numgoodsets_accumulator(end-accumulator_length+1:end,1);
        end
        
        relative_time = time_accumulator - time_accumulator(1,1);
        
        %Bit Error Rate Plot
        figure(1)
        plot(relative_time,BER_coherent_accumulator,'bo-')
        hold on
        plot(relative_time,BER_single_accumulator,'rx-')
        hold off
        legend('Coherent','Single Antenna','Location','NorthWest')
        xlabel('Time [s]','FontSize',14)
        ylabel('Bit Error Rate (BER)','FontSize',14)
        ylim([0 0.6])
        grid on
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
        plot(fxcorrsnr,'o')
        xlabel('Data Chunk Index','FontSize',14)
        ylabel('Comb Correlation SNR','FontSize',14)
        subplot(2,1,2)
        hist(fxcorrsnr,20)
        xlabel('xcorr SNR value','FontSize',14)
    	ylabel('hit count','FontSize',14)
        subplot(2,1,1)
        title('Current: Plot and Histogram of SNR used for Signal Detection','FontSize',14)
        
        %corrections plot
        figure(4)
        subplot(3,1,1)
        plot(freqoffset,'o-')
        title('Current: Frequency Offset Correction Applied','FontSize',14)
        ylabel('Freq [Hz]','FontSize',14)
        xlabel('dataset','FontSize',14)
        subplot(3,1,2)
        plot(phaseoffset,'o-')
        title('Current: Phase Offset Correction Applied','FontSize',14)
        ylabel('Phase [rad]','FontSize',14)
        xlabel('dataset','FontSize',14)
        subplot(3,1,3)
        plot(samplesoffset,'o-')
        title('Current: Time Offset Correction Applied','FontSize',14)
        ylabel('Time [samples]','FontSize',14)
        xlabel('dataset','FontSize',14)
        
        %numgoodsets plot
        figure(5)
        plot(relative_time,numgoodsets_accumulator,'bo-')
        title('Time History: Number of Good Datasets','FontSize',14)
        ylabel('Number','FontSize',14)
        xlabel('Time [s]','FontSize',14)
        ylim([0 100])
        
        %text box of theoretical data rates
        figure(6)
        clf
        axis off
        text(0.1,0.85,'Theoretical Data Rate Single Antenna: ','FontSize',16);
        text(0.1,0.75,[num2str(theoretical_data_rate_single,3) ' bit/s'],'FontSize',18,'Color','r');
        text(0.1,0.60,'Theoretical Data Rate Coherent Antenna: ','FontSize',16);
        text(0.1,0.50,[num2str(theoretical_data_rate_coherent,3) ' bit/s'],'FontSize',18,'Color','b');
        text(0.1,0.35,'Theoretical Data Rate 10k Coherent Antennas: ','FontSize',16);
        text(0.1,0.25,[num2str(theoretical_data_rate_10k,3) ' bit/s'],'FontSize',18,'Color','g');
        title('Shannon-Hartley Data Rate for Antenna SNR','FontSize',18)
        text(0.1,0.05,'Single Antenna BER','FontSize',16)
        text(0.2,0.0,num2str(BER_single,3),'FontSize',18,'Color','r')
        text(0.5,0.05,'Coherent Antenna BER','FontSize',16)
        text(0.6,0.0,num2str(BER_coherent,3),'FontSize',18,'Color','b')
        
        
        
    end
    

    sleep(0.2);
    
end