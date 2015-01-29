function tones = findtones(data)

datalength = length(data);
dcreject = 10;

datafft = fft(data);

srate = 0.00001;
timestamp = 0:srate:(datalength-1)*srate;

mask1 = [zeros([dcreject 1]); ones([round(datalength/2)-dcreject 1]); zeros([round(datalength/2)-dcreject 1]); zeros([dcreject 1])];
mask2 = [zeros([dcreject 1]); zeros([round(datalength/2)-dcreject 1]); ones([round(datalength/2)-dcreject 1]); zeros([dcreject 1])];

datafft1 = datafft.*mask1;
datafft2 = datafft.*mask2;

%{
subplot 211
plot(abs(datafft1))

subplot 212
plot(abs(datafft2))
%}

[pk1,ipk1] = max(datafft1);
[pk2,ipk2] = max(datafft2);

fpk1 = (ipk1)*(1/srate)/datalength;
fpk2 = (1/srate)*(ipk2/datalength-1);

tones = [fpk1 angle(pk1); fpk2 angle(pk2)];

%{
figure

subplot 511
plot(timestamp,real(data))
subplot 512
plot(timestamp,sin(2*pi*timestamp*fpk1+angle(pk1)))
subplot 513
plot(timestamp,sin(2*pi*timestamp*fpk2+angle(pk2)))
subplot 514
plot(timestamp,sin(2*pi*timestamp*fpk1+angle(pk1))+sin(2*pi*timestamp*fpk2+angle(pk2)))
subplot 515
plot(timestamp,sin(2*pi*timestamp*(fpk1+fpk2)+(angle(pk1)+angle(pk2))))
%}


