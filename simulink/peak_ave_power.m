function [ out ] = peak_ave_power( din )
%PEAK_AVE_POWER gives peak to average power in db


out = 10*log(max(abs(din)).^2/rms(din).^2)/log(10);


end

