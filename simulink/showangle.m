function [] = showangle( rad )


res = 300;
bounds = [];

for k = 1:res+1
    kk = k-1;
    ang = 2*pi*kk/res;
    sam = 1*exp(1j*ang);
    bounds(k) = sam;
end




figure;
hold on;
plot(bounds);



for m = 1:size(rad,1)
    vec = [0;1*exp(1j*rad(m))];
    plot(vec);
end
hold off;
