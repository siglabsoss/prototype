1;
o_util;

function [] = service_all()
end

pipe_type = 'uint8';

filename200='../gnuradio/drive_test_200_previous.raw';
filename202='../gnuradio/drive_test_202_previous.raw';

fid200 = fopen(filename200, 'r'); 

[rrrawdata, rdcount] = fread(fid200, 9E99, pipe_type);
fclose(fid200);
rawdata200 = raw_to_complex(rrrawdata');
clear rrrawdata;

fid202 = fopen(filename202, 'r'); 
[rrrawdata, rdcount] = fread(fid202, 9E99, pipe_type);
fclose(fid202);
rawdata202 = raw_to_complex(rrrawdata');
clear rrrawdata;







% default value for knobs (used incase correlator_knobs.mat is missing)
detect_threshold = 2.4;
fsearchwindow_low = -200;
fsearchwindow_hi = 200;
concat_mode = 0;

% optionally load settings from dashboard hotkeys
statval = stat('correlator_knobs.mat');
if( size(statval) == [0 0] )
   disp('warning no dash settings found');
else
    load('correlator_knobs.mat');
    disp('updated to');
    detect_threshold
    fsearchwindow_low
    fsearchwindow_hi
    concat_mode
end


% concat
switch(concat_mode)
    case 0
        rawdata = [rawdata200;rawdata202];
    case 1
        rawdata = rawdata200;
    case 2
        rawdata = rawdata202;
end

%overwrite rawdata test block
%==============================
clear rawdata;
filename200='./300_el_cerrito_ave_hillsborough.raw';
fid200 = fopen(filename200, 'r'); 
[rrrawdata, rdcount] = fread(fid200, 9E99, pipe_type);
fclose(fid200);
rawdata200 = raw_to_complex(rrrawdata');
clear rrrawdata;
rawdata = double(rawdata200(end/2:end));
detect_threshold = 1.6;
%==============================






% pretty much fixed
fs = 1e8/512;
srate = 1/fs;
samples_per_bit_at_fs = 156.25;  % (ratio of rx radio's fs to tx radio's fs times 100)



load('clock_comb195k.mat','clock_comb195k','patternvec','ideal_bits');
clock_comb = clock_comb195k;






%chunk the data
windowsize = 0.8; % size of chunked data
timestep = 0.3; %time stepping of data chunks.  should be < windowsize - time length of rf packet
rawtime = 0:srate:(length(rawdata)-1)*srate;
clear rnoisydata;

timestepsteps = round(windowsize/srate);
for k = 0:floor(rawtime(end)/timestep)-ceil(windowsize/timestep)-1
    rnoisydata(:,k+1) = rawdata(round(k*timestep/srate)+1:round(k*timestep/srate)+timestepsteps);
end




starttime = time; %datetime doesn't work in octave

%matrix version
reply_data = clock_comb;
weighting_factor = 0;
retro_go = 1;
diag = 0;
[aligned_data retro_data retrostart retroend fxcorrsnr goodsets freqoffset phaseoffset samplesoffset] = retrocorrelator_octave(double(rnoisydata),srate,clock_comb,detect_threshold,reply_data,fsearchwindow_low,fsearchwindow_hi,retro_go,weighting_factor);

%calculated stats
cal_const = 1.18e-12; %calculated from thermal noise measurements
E_te = 1.04e-16; %thermal energy for 10kHz band for windowsize of time.
single_antenna_strength = 10*log10(cal_const*(((abs(aligned_data).').^2)*ones(size(aligned_data,1),1)./windowsize)./(E_te/windowsize));
coherent_antenna_strength = 10*log10(cal_const*(sum(abs((aligned_data*ones([size(aligned_data,2) 1]))).^2)/windowsize)/(E_te/windowsize));



Correlation_completed_in = time-starttime

number_of_good_datasets = size(aligned_data,2)


%get BER
BER_coherent = 1-sum(o_cpm_demod(aligned_data*ones([size(aligned_data,2) 1]),srate,samples_per_bit_at_fs,patternvec,1) == ideal_bits)/length(ideal_bits)

%get BER of single antenna
BER_single = 1-sum(o_cpm_demod(aligned_data(:,1),srate,samples_per_bit_at_fs,patternvec,1) == ideal_bits)/length(ideal_bits)

% save any calculated data to dashboard
save('drive_dash_data.mat', 'BER_coherent', 'BER_single', 'fxcorrsnr', 'goodsets', 'single_antenna_strength', 'coherent_antenna_strength', 'freqoffset', 'phaseoffset', 'samplesoffset');

% touch lock file which lets dashboard know we are done
lockfid = fopen('dashboard_lock', 'a+'); 
pipe_type = 'uint8';
wrcount = fwrite(lockfid, [0], pipe_type);
fclose(lockfid);





