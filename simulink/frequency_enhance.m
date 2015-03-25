%USAGE:
%   enhanced_data = frequency_enhance(freqaligneddataxcorr,clock_comb,timestamp,freqstep,numsteps)
%
%
%
function enhanced_data = frequency_enhance(freqaligneddataxcorr,clock_comb,timestamp,freqstep,numsteps)

for t = 1:1:size(freqaligneddataxcorr,2)
    for k = 1:1:numsteps
        freqshift(k) = (k-1)*freqstep-(numsteps-1)*freqstep/2;
        xcorr_timedomain_fshift = xcorr(freqaligneddataxcorr(:,t).*exp(i*2*pi*freqshift(k)*timestamp)',clock_comb);
        [val id] = max(xcorr_timedomain_fshift);
        corr_peakfind_max(k) = abs(val);
    end
    [val id] = max(corr_peakfind_max);
    freq_correction(t) = freqshift(id);
    enhanced_data(:,t) = freqaligneddataxcorr(:,t).*exp(2*pi*freq_correction(t)*timestamp)';
end


figure
plot(freq_correction, 'bo')
title('Time-domain Correlation Frequency correction')
xlabel('dataset')
ylabel('correction in Hz')
ylim([min(freqshift) max(freqshift)])