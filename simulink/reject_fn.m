function [ vout ] = reject_fn( samples )

%tune
res1 = 0.1;
a1 = 0.13;

% initial timeseries
t1 = [samples/-2*res1:1*res1:samples/2*res1];


f1 = sin(t1*a1) ./ (t1*a1);
% fix limit as x approaches 0
f1(find(isnan(f1))) = 1;


% tune
a2 = 1;

% double sin(x)/x
f2 = sin(f1*a2) ./ (f1*a2);


% center amplitude, 0 means 0 gets through
cAmp = 0.22;

% subtract so reject goes to zero (or camp)
f2 = f2 - (1*sin(1/a2));

% divide up (normalize) so that top is at 1
f2 = f2 / (1-sin(1/a2)) * (1-cAmp);

f2 = f2 + cAmp;



% close all;
% hold on;
% plot([-3:(3/500):3],f1);
% plot([-3:(3/500):3],f2);
% hold off;

vout = f2;
end

