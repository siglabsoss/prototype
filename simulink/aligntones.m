close all

srate = 0.00001;
datalength = length(data);
timestamp = 0:srate:(datalength-1)*srate;

data2 = [zeros([2435 1]); data(1:end-2435,1)];

fa1 = findtones(data);
fa2 = findtones(data1);
fa3 = findtones(data2);




subplot 411
plot(timestamp,real(data))
subplot 412
plot(timestamp,sin(2*pi*timestamp*(fa1(1,1)+fa1(2,1))/2+(fa1(1,2)+fa1(2,2))/2))
subplot 413
plot(timestamp,real(data1))
subplot 414
plot(timestamp,sin(2*pi*timestamp*(fa2(1,1)+fa2(2,1))/2+(fa2(1,2)+fa2(2,2))/2))


%{
subplot 411
plot(timestamp,real(data))
subplot 412
plot(timestamp,sin(2*pi*timestamp*(fa1(1,1)+fa1(2,1))+fa1(1,2)+fa1(2,2)))
subplot 413
plot(timestamp,real(data2))
subplot 414
plot(timestamp,sin(2*pi*timestamp*(fa3(1,1)+fa3(2,1))+fa3(1,2)+fa3(2,2)))
%}

figure
subplot 411
plot(timestamp,real(data))
subplot 412
plot(timestamp, sin(2*pi*timestamp*fa1(1,1)+fa1(1,2)))
subplot 413
plot(timestamp, sin(2*pi*timestamp*fa1(2,1)+fa1(2,2)))
subplot 414
plot(timestamp, sin(2*pi*timestamp*fa1(1,1)+fa1(1,2))+sin(2*pi*timestamp*fa1(2,1)+fa1(2,2)))

figure
subplot 411
plot(timestamp,real(data1))
subplot 412
plot(timestamp, sin(2*pi*timestamp*fa2(1,1)+fa2(1,2)))
subplot 413
plot(timestamp, sin(2*pi*timestamp*fa2(2,1)+fa2(2,2)))
subplot 414
plot(timestamp, sin(2*pi*timestamp*fa2(1,1)+fa2(1,2))+sin(2*pi*timestamp*fa2(2,1)+fa2(2,2)))

figure
plot(timestamp,real(data))
hold on
plot(timestamp,imag(data),'m')
plot(timestamp, sin(2*pi*fa1(1,1)*timestamp+fa1(1,2)),'b--')
plot(timestamp, sin(2*pi*fa1(2,1)*timestamp+fa1(2,2)),'m--')