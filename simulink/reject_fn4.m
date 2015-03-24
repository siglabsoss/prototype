function [ vout ] = reject_fn4( samples )

%tune
res1 = 0.01;

% global my_global_val;

% smaller is wider
a1 = 0.01 - 0.001 - 2.0278 / 100 + 8.333333e-02 / 500;

b1 = 1;


b1 = 1;

% initial timeseries
t1 = [samples/-2*res1:1*res1:samples/2*res1];


f1 = 1 ./ sin((t1.*a1 + (pi/2) )*b1);

% plot(f1);




vout = f1;
end

