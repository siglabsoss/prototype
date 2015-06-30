1;
o_util;

function [] = service_all()
end

filename='../gnuradio/drive_test.raw';

fid = fopen(filename, 'r'); 
pipe_type = 'uint8';    
[rrrawdata, rdcount] = fread(fid, 9E99, pipe_type);
rawdata = raw_to_complex(rrrawdata');
clear rrrawdata;


fs = 1e8/512;
srate = 1/fs;
detect_threshold = 2.5;
samples_per_bit_at_fs = 156.25;  % (ratio of rx radio's fs to tx radio's fs times 100)



load('clock_comb195k.mat','clock_comb195k','idealdata','patternvec');
clock_comb = clock_comb195k;






%chunk the data
windowsize = 0.8; % size of chunked data
timestep = 0.4; %time stepping of data chunks.  should be < windowsize - time length of rf packet
rawtime = 0:srate:(length(rawdata)-1)*srate;
clear rnoisydata;

for k = 0:floor(rawtime(end)/timestep)-ceil(windowsize/timestep)-1
    rnoisydata(:,k+1) = rawdata(round(k*timestep/srate)+1:round(k*timestep/srate+windowsize/srate));
end



%plot incoherent sum
datalength = length(rnoisydata(:,1));
timestamp = 0:srate:(datalength-1)*srate;
figure
plot(timestamp,real(rnoisydata*ones([size(rnoisydata,2) 1])))
xlabel('time [s]')
title('Incoherent Sum')

starttime = time; %datetime doesn't work in octave

%matrix version
reply_data = clock_comb;
fsearchwindow_low = -100;
fsearchwindow_hi = 400;
retro_go = 1;
diag = 1;
[aligned_data retro_data numdatasets retrostart retroend samplesoffset] = retrocorrelator_octave(double(rnoisydata),srate,clock_comb,reply_data,detect_threshold,fsearchwindow_low,fsearchwindow_hi,retro_go,diag);


Correlation_completed_in = time-starttime

number_of_good_datasets = size(aligned_data,2)


figure
plot(timestamp,real(aligned_data*ones([size(aligned_data,2) 1])))
xlabel('time [s]')
title('Coherent Sum')

%get BER
expected_data = o_cpm_demod(idealdata,1/125E3,100,patternvec,1);
BER_coherent = 1-sum(o_cpm_demod(aligned_data*ones([size(aligned_data,2) 1]),srate,samples_per_bit_at_fs,patternvec,1) == expected_data)/length(expected_data)

%get BER of single antenna
BER_single = 1-sum(o_cpm_demod(aligned_data(:,1),srate,samples_per_bit_at_fs,patternvec,1) == expected_data)/length(expected_data)





