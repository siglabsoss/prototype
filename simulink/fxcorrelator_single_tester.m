clear all
close all
load('mar17pt2.mat','ruthandelcamino')
rawdata = ruthandelcamino;
load('thursday.mat','clock_comb125k','idealdata','patternvec')
clock_comb = clock_comb125k;

%settings
srate = 1/125000;
detect_threshold = 2.5;

%chunk the data
windowsize = 0.8; % size of chunked data
timestep = 0.3; %time stepping of data chunks.  should be < windowsize - time length of rf packet
rawtime = 0:srate:(length(rawdata)-1)*srate;
for k = 0:floor(rawtime(end)/timestep)-ceil(windowsize/timestep)
    rnoisydata(:,k+1) = rawdata(round(k*timestep/srate)+1:round(k*timestep/srate+windowsize/srate));
end


%plot incoherent sum
datalength = length(rnoisydata(:,1));
timestamp = 0:srate:(datalength-1)*srate;
figure
plot(timestamp,real(rnoisydata*ones([size(rnoisydata,2) 1])))
xlabel('time [s]')
title('Incoherent Sum')

starttime = datetime;

%matrix version
%aligned_data = fxcorrelator_single(rnoisydata,srate,clock_comb,detect_threshold);

%single version
aligned_data = [];
for k=1:1:size(rnoisydata,2)
    aligned_data_single = fxcorrelator_single(rnoisydata(:,k),srate,clock_comb,detect_threshold);
    if ~isnan(aligned_data_single)
        aligned_data = [aligned_data, aligned_data_single];
    end
end

Correlation_completed_in = datetime-starttime

number_of_good_datasets = size(aligned_data,2)

figure
plot(timestamp,real(aligned_data*ones([size(aligned_data,2) 1])))
xlabel('time [s]')
title('Coherent Sum')

expected_data = my_cpm_demod_offline(idealdata,srate,100,patternvec,1);
BER_coherent = 1-sum(my_cpm_demod_offline(aligned_data*ones([size(aligned_data,2) 1]),srate,100,patternvec,1) == expected_data)/length(expected_data)
