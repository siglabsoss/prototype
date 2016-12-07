function [] = showangle( rad )


res = 300;
bounds = [];

for k = 1:res+1
    kk = k-1;
    ang = 2*pi*kk/res;
    sam = 1*exp(1j*ang);
    bounds(k) = sam;
end


vec = [0;1*exp(1j*rad)];

figure;
hold on;
plot(bounds);
plot(vec);
hold off;
