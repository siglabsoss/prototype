close all

power_padding = 4;

srate = 0.00001;
datalength = length(idealdata);
fftlength = 2^(nextpow2(datalength)+power_padding);
timestamp = 0:srate:(datalength-1)*srate;

delaydata1 = 2500;
idealdata1 = [zeros([delaydata1 1]); idealdata(1:end-delaydata1,1)];

%data2 = [zeros([2435 1]); data(1:end-2435,1)];

fa1 = findtones([idealdata;zeros([fftlength-datalength,1])]);
fa2 = findtones([idealdata1;zeros([fftlength-datalength,1])]);
%fa3 = findtones([data;zeros([fftlength-datalength,1])]);




subplot 411
plot(timestamp,real(idealdata))
title('Data 0 Real')
subplot 412
plot(timestamp,cos(2*pi*timestamp*(fa1(1,1)-fa1(2,1))/2+(fa1(1,2)-fa1(2,2))/2))
title('Data 0 Beat Tone')
subplot 413
plot(timestamp,real(idealdata1))
title('Data 1 Real')
subplot 414
plot(timestamp,cos(2*pi*timestamp*(fa2(1,1)-fa2(2,1))/2+(fa2(1,2)-fa2(2,2))/2))
title('Data 1 Beat Tone')


%{
subplot 411
plot(timestamp,real(data))
subplot 412
plot(timestamp,sin(2*pi*timestamp*(fa1(1,1)+fa1(2,1))+fa1(1,2)+fa1(2,2)))
subplot 413
plot(timestamp,real(data2))
subplot 414
plot(timestamp,sin(2*pi*timestamp*(fa3(1,1)+fa3(2,1))+fa3(1,2)+fa3(2,2)))


figure
subplot 411
plot(timestamp,real(idealdata))
title('Data 0 Real')
subplot 412
plot(timestamp, sin(2*pi*timestamp*fa1(1,1)+fa1(1,2)))
subplot 413
plot(timestamp, sin(2*pi*timestamp*fa1(2,1)+fa1(2,2)))
subplot 414
plot(timestamp, sin(2*pi*timestamp*fa1(1,1)-fa1(1,2))+sin(2*pi*timestamp*fa1(2,1)-fa1(2,2)))

figure
subplot 411
plot(timestamp,real(data1))
subplot 412
plot(timestamp, sin(2*pi*timestamp*fa2(1,1)+fa2(1,2)))
subplot 413
plot(timestamp, sin(2*pi*timestamp*fa2(2,1)+fa2(2,2)))
subplot 414
plot(timestamp, sin(2*pi*timestamp*fa2(1,1)-fa2(1,2))+sin(2*pi*timestamp*fa2(2,1)-fa2(2,2)))
%}

figure
subplot 311
plot(timestamp,real(idealdata),'b')
hold on
plot(timestamp, cos(2*pi*fa1(1,1)*timestamp+fa1(1,2)),'c:')
plot(timestamp, cos(2*pi*fa1(2,1)*timestamp+fa1(2,2)),'g:')
title('Real: Data 0 and Recreated Tones')
subplot 312
plot(timestamp,imag(idealdata),'r')
hold on
plot(timestamp, sin(2*pi*fa1(1,1)*timestamp+fa1(1,2)),'m:')
plot(timestamp, sin(2*pi*fa1(2,1)*timestamp+fa1(2,2)),'g:')
title('Imaginary: Data 0 and Recreated Tones')
subplot 313
plot(timestamp,cos(2*pi*timestamp*(fa2(1,1)-fa2(2,1))/2+(fa2(1,2)-fa2(2,2))/2))
title('Real and Imaginary Beat Tones')

figure
plot(timestamp,real(data1))
hold on
plot(timestamp,imag(data1),'m')
plot(timestamp, cos(2*pi*fa2(1,1)*timestamp+fa2(1,2)),'b:')
plot(timestamp, sin(2*pi*fa2(1,1)*timestamp+fa2(1,2)),'m:')

figure
subplot 211
plot(timestamp, cos(2*pi*fa1(1,1)*timestamp+fa1(1,2)),'b')
hold on
plot(timestamp, cos(2*pi*fa1(2,1)*timestamp+fa1(2,2)),'m')
plot(timestamp, sin(2*pi*(fa1(1,1)+fa1(2,1))*timestamp+(fa1(1,2)+fa1(2,2))),'r:')
subplot 212
plot(timestamp, sin(2*pi*fa1(1,1)*timestamp+fa1(1,2)),'g')
hold on
plot(timestamp, sin(2*pi*fa1(2,1)*timestamp+fa1(2,2)),'c')
plot(timestamp, cos(2*pi*(fa1(1,1)+fa1(2,1))*timestamp+(fa1(1,2)+fa1(2,2))),'b:')

figure
subplot 211
plot(timestamp, cos(2*pi*fa2(1,1)*timestamp+fa2(1,2)),'b')
hold on
plot(timestamp, cos(2*pi*fa2(2,1)*timestamp+fa2(2,2)),'m')
plot(timestamp, sin(2*pi*(fa2(1,1)+fa2(2,1))*timestamp+(fa2(1,2)+fa2(2,2))),'r:')
subplot 212
plot(timestamp, sin(2*pi*fa2(1,1)*timestamp+fa2(1,2)),'g')
hold on
plot(timestamp, sin(2*pi*fa2(2,1)*timestamp+fa2(2,2)),'c')
plot(timestamp, cos(2*pi*(fa2(1,1)+fa2(2,1))*timestamp+(fa2(1,2)+fa2(2,2))),'b:')