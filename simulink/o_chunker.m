
1;

clear rnoisydata
clear chunkstarts
close all

function [] = service_all()

end

o_util;

 fid = fopen('1434756135-log-radio0.dat','r');
% fid = fopen('1434756135-log-radio1.dat','r');

% fid = fopen('r0_gnuradio_dump.raw','r');
% fid = fopen('r1_gnuradio_dump.raw','r');

[rawdata, rdcount] = fread(fid, 9E40, 'uint8');

data = double(raw_to_complex(rawdata'));

load('clock_comb195k.mat','clock_comb195k','idealdata','patternvec');
clock_comb = double(clock_comb195k);

%START REAL DATA LOAD BLOCK
%========================
% load('mar31e.mat', 'haywardcaltrainclock')
% rawdata = haywardcaltrainclock;
% load('thursday.mat','clock_comb125k','idealdata','patternvec')
% clock_comb = resample(clock_comb125k,1e8,512*125000);


%settings
srate = 512/1e8;
detect_threshold = 2.5;

fsearchcenter = 20E3;
fsearchwindow_low = -200 + fsearchcenter; %frequency search window low, in Hz
fsearchwindow_hi = 200 + fsearchcenter;   %frequency search window high, in Hz


%chunk the data
windowsize = 1; % size of chunked data
timestart = 1.2; %start of the first chunk
samplestart = round(timestart/srate);
timestep = 6.4; %time stepping of data chunks.  should be < windowsize - time length of rf packet
rawtime = 0:srate:(length(data)-1)*srate;
samplesteps = round(windowsize/srate);
for k = 0:floor((rawtime(end)-timestart)/timestep)-ceil(windowsize/timestep)
    rnoisydata(:,k+1) = data(round(samplestart+k*timestep/srate)+1:round(samplestart+k*timestep/srate)+samplesteps);
    chunkstarts(k+1) = round(samplestart+k*timestep/srate)+1;
end
%END REAL DATA LOAD
%=======================

% figure
% plot(0:srate:(length(data)-1)*srate,data)
% title('Raw Data In')

[aligned_data, retro_single, numdatasets, retrostart, retroend, samplesoffset] = retrocorrelator_octave(double(rnoisydata),srate,clock_comb,clock_comb,detect_threshold, fsearchwindow_low, fsearchwindow_hi);

absolute_samples_offset = chunkstarts + samplesoffset

disp('delta between sample offsets:');

diff(absolute_samples_offset)

disp('delta delta:');

diff(diff(absolute_samples_offset))


% figure
% plot(0:srate:(size(aligned_data,1)-1)*srate,real(aligned_data*ones([size(aligned_data,2) 1])))
% xlabel('time [s]')
% title('Coherent Sum Out')










