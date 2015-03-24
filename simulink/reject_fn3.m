function [ vout ] = reject_fn3( samples )

%tune
res1 = 0.1;

% smaller is wider
a1 = 0.0025;

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
cAmp = -1.1;

% subtract so reject goes to zero (or camp)
f2 = f2 - (1*sin(1/a2));

% divide up (normalize) so that top is at 1
f2 = f2 / (1-sin(1/a2)) * (1-cAmp);

f2 =  (f2 + cAmp);



% forceCutoff = 2020;
% f2(1:forceCutoff) = 1;
% f2(samples-forceCutoff:samples+1) = 1;


f2 = 1 - f2 + 1;

f3 = [f2(12501:25001) f2(1:12500)];

% hold on;
% plot(f2);
% plot(f3);
% hold off;


vout = f3;
end

