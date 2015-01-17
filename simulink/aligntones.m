close all

srate = 0.00001;
datalength = length(data);
timestamp = 0:srate:(datalength-1)*srate;

fa1 = findtones(data);
fa2 = findtones(data1);

subplot 411
plot(timestamp,real(data))
subplot 412
plot(timestamp,sin(2*pi*timestamp*(fa1(1,1)+fa1(2,1))+fa1(1,2)-fa1(2,2)))
subplot 413


plot(timestamp,real(data1))
subplot 414
plot(timestamp,sin(2*pi*timestamp*(fa2(1,1)+fa2(2,1))+fa2(1,2)-fa2(2,2)))