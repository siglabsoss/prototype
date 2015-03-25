% note you should run rawdata_correlator_rangetest.m once before this to
% generate the required data.


clear freqshift
clear xcorr_timedomain_fshift
clear corr_peakfind_max

freqstep = 0.025; %frequency step per correlation attempt
numsets = 21;
1; % number of correlations to perform
useset = 3; %which set to use from the noisydata (downselected) set


%recreate original correlation
%figure
%plot(xcorrfreqstamp,abs(xcorr(abs(noisyfft(:,useset)),abs(comb_fft))))
freqoffsetxcorr(useset)

estimated_freq_aligned_data = noisydata(:,useset).*(exp(i*2*pi*freqoffsetxcorr(useset)*timestamp)');

%multiple time-domain correlations with stepped frequency 
figure
for k = 1:1:numsets
    subplot(numsets,1,k)
    freqshift(k) = (k-1)*freqstep-(numsets-1)*freqstep/2;
    xcorr_timedomain_fshift(:,k) = xcorr(estimated_freq_aligned_data.*exp(i*2*pi*freqshift(k)*timestamp)',clock_comb);
    plot(xcorrtimestamp,abs(xcorr_timedomain_fshift(:,k)))
    title(sprintf('Time Domain Correlation w/ estimated data %s Hz freq shifted',num2str(freqshift(k))))
    ylim([0 0.3])
    [val id] = max(xcorr_timedomain_fshift(:,k));
    corr_peakfind_max(k) = abs(val);
end

%plot the correlation strength of each attempt
figure
plot(freqshift,corr_peakfind_max)
xlabel('Frequency Shift')
ylabel('Correlation Strength')


%interesting questions
%by taking the abs max peak of the xcorr, we might be selecting the
%negative (-180deg) shifted offset.  should we not do that?