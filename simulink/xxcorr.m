clear all
close all
load rnoisydata.mat

fsearchwindow_low = -100; %frequency search window low, in Hz
fsearchwindow_hi = 100; %frequency search window high, in Hz
combwindow_low = -105; %clock comb freq-domain correlation window low, in Hz
combwindow_hi = 105; %clock comb freq-domain correlation window high, in Hz

downsample_rate = 40; %downsampling rate for signal search

xcorr_detect = 0.6/downsample_rate; %detection threshold for correlation search

fstep = 1; %frequency search step in Hz

srate = 1/125000;
srate_search = srate*downsample_rate;

timestamp = 0:srate:(size(rnoisydata,1)-1)*srate;
timestamp_search = downsample(timestamp,downsample_rate);

load('thursday.mat','clock_comb125k')

%COARSE SIGNAL SEARCH
%==========================================================================

freqshift = fsearchwindow_low:fstep:fsearchwindow_hi;
clock_comb_downsample = downsample(clock_comb125k,downsample_rate);
timestamp_comb_search = 0:srate_search:(length(clock_comb_downsample)-1)*srate_search;
for k = 1:1:length(freqshift)
    clock_comb_search(:,k) = clock_comb_downsample.*exp(i*2*pi*-freqshift(k)*timestamp_comb_search)';
end


for n = 1:1:size(rnoisydata,2)
    for k = 1:1:length(freqshift)
        xxcorr_data = xcorr(downsample(rnoisydata(:,n),downsample_rate),clock_comb_search(:,k));
        [val id] = max(xxcorr_data);
        fshift_max(k) = abs(val);
    end
    [val id] = max(fshift_max);
    fsearch_max(n) = val;
    fsearch_freq(n) = freqshift(id);
end



%REDUCE TO DETECTED DATASETS AND CENTER ON DETECTED FSHIFT
%==========================================================================
goodsets = find(fsearch_max > xcorr_detect);
number_of_good_datasets = length(goodsets) %print out the number of good datasets found
numdatasets = number_of_good_datasets;

figure
subplot 211
plot(fsearch_max,'bo-')
hold on
plot(goodsets,fsearch_max(goodsets),'mo')
title('Max Correlation Response Across Time and Frequency')
ylabel('Response')
xlabel('Data Chunk')
subplot 212
hist(fsearch_max)
title('Histogram of Max Correlation Response')

for k = 1:1:numdatasets
    freqaligneddataxcorr(:,k) = rnoisydata(:,goodsets(k)).*(exp(i*2*pi*fsearch_freq(goodsets(k))*timestamp)');
end

freqaligneddataxcorr = frequency_enhance(freqaligneddataxcorr,clock_comb125k,timestamp,0.1,20);




