clear all
close all

%{
%===========
%start 915Mhz block
%===========
%global time for 915Mhz w/ 1 THz sampling
srate = 1/1e12;
timelength = 1000/1e9;
timestamp = 0:srate:timelength-srate;

%interrogator signal settings. 
f0 = 915e6;

%plot settings
plotlength = 10/1e9; 
%===========
%end 915Mhz block
%===========
%}

%===========
%start 30Khz block
%===========
%global time for 125khz global sampling
srate = 1/500000;
timelength = 0.8; %in seconds
timestamp = 0:srate:timelength-srate;
timestamp = timestamp.';

%interrogator signal settings. 
f0 = 10e3; %30kHz to make it computationally easier.

%plot settings
plotlength = 10/f0;
%===========
%end 30kHz block
%===========

%interrogator signal.  the interrogator is a real signal.  use the real
%part of this signal
p0 = 0;
interrogator = exp(i*2*pi*f0*timestamp);%sin(2*pi*f0*timestamp+p0);


%try using clock comb as the interrogator.
load('thursday.mat','clock_comb125k');
comb_srate = 1/125000;
interrogator = [interp(clock_comb125k,4); zeros([length(timestamp)-length(interp(clock_comb125k,4)) 1])].*exp(i*2*pi*f0*timestamp);


%station phases
ps1 = 50*2*pi/360;
ps2 = 100*2*pi/360;

%station receive signals
scr1 = interrogator*exp(i*ps1);
scr2 = interrogator*exp(i*ps2);

figure
subplot 311
plot(timestamp,real(interrogator))
%xlim([0 plotlength]) %just the first 10 cycles
title('interrogating signal')
subplot 312
plot(timestamp,real(scr1))
%xlim([0 plotlength]) %just the first 10 cycles
title('station 1 received signal')
subplot 313
plot(timestamp,real(scr2))
%xlim([0 plotlength]) %just the first 10 cycles
title('station 2 received signal')

%classical retrodirectivity
fc1 = f0*2;
fc2 = f0*2;
pc1 = 27*2*pi/360; %some arbitrary phase
pc2 = 27*2*pi/360; %these are the same for distributed LO

filter_order = 4;
wn = 1.3*f0*srate*2;  %set the cutoff frequency
[B,A] = butter(filter_order,wn);
figure
freqz(B,A,5000,1/srate)

sct1 = filter(B,A,real(scr1).*real(exp(i*2*pi*fc1*timestamp+i*pc1)));
sct2 = filter(B,A,real(scr2).*real(exp(i*2*pi*fc2*timestamp+i*pc2)));


figure
subplot 211
plot(timestamp, sct1)
xlim([plotlength 2*plotlength])
title('Classic R/D: Retro Tx Signal, Station 1')
subplot 212
plot(timestamp, sct2)
xlim([plotlength 2*plotlength])
title('Classic R/D: Retro Tx Signal, Station 2')

figure
subplot 211
plot(timestamp,real(scr1))
hold on
plot(timestamp,real(scr2),'r')
xlim([plotlength 2*plotlength])
title('Station 1/2 Input RX')
subplot 212
plot(timestamp,real(sct1))
hold on
plot(timestamp,real(sct2),'r')
xlim([plotlength 2*plotlength])
title('Classic R/D: Station 1/2 Return TX')
hold off

%================
%correlator retrodirectivity
%================

%downconvert
f_rd_lo(1) = f0; %station 1 LO frequency
f_rd_lo(2) = f0; %station 2 LO frequency
p_rd_lo(1) = 302*2*pi/360; %station 1 LO phase
p_rd_lo(2) = 173*2*pi/360; %station 2 LO phase
scr(:,1) = scr1;
scr(:,2) = scr2;

%IF filter
filter_order_if = 4;
wn_if = 12.5e3*srate*2; %fitler cutoff, same for both stations
[B_if,A_if] = butter(filter_order_if,wn_if); %coefficients for filter, same for both stations

numstations = 2;

for k = 1:1:numstations
    s_rd_lo(:,k) = exp(i*2*pi*-f_rd_lo(k)*timestamp + i*p_rd_lo(k)); %generate the LO
    s_rd_r_mix(:,k) = real(scr(:,k)).* s_rd_lo(:,k); % radio only observes the real part, then IQ downmixer to complex data
    s_rd_r_if(:,k) = filter(B_if,A_if,s_rd_r_mix(:,k)); %filter out the lower component
    s_rd_r_data(:,k) = downsample(s_rd_r_if(:,k),4); %downsample from 500k to 125k
    [aligned_data(:,k), retro(:,k)] = retrocorrelator(s_rd_r_data(:,k),comb_srate,clock_comb125k,2.5); %run the correlator
    s_rd_t_data(:,k) = interp(retro(:,k),4); %convert back to 500k data
    s_rd_t_if(:,k) = s_rd_t_data(1/srate:1/srate+length(timestamp)-1,k); %truncate leading 1.5s.
    s_rd_t_mix(:,k) = real(s_rd_t_if(:,k)) .* real(s_rd_lo(:,k)); %upmixing
    s_rd_t_mix(:,k) = filter(B_if,A_if,s_rd_t_mix(:,k)); %filter
    srdt(:,k) = real(s_rd_t_mix(:,k))+imag(s_rd_t_mix(:,k)); %make real
end

figure
%plot(abs(fftshift(fft(s_rd_t_if(:,1)))))
hold on
plot(abs(fftshift(fft(s_rd_t_mix(:,1)))),'r')
%plot(abs(fftshift(fft(srdt(:,1)))),'m')
legend('IQ IF', 'IQ Upmix', 'Real')
title('Epoch R/D: Station 1 Freq-Domain')
hold off

figure
subplot 211
plot(timestamp,real(scr))
%xlim([plotlength 2*plotlength])
title('Station 1/2 Input RX')
subplot 212
plot(timestamp,srdt)
%xlim([plotlength 2*plotlength])
title('Epoch R/D: Station 1/2 Return TX')

%taking a look at alternate make-real
figure
subplot 411
plot(timestamp,real(scr))
xlim([0 plotlength])
title('Station 1/2 Input RX')
subplot 412
plot(timestamp,real(s_rd_t_mix)+imag(s_rd_t_mix))
xlim([0 plotlength])
title('Epoch R/D: Station 1/2 Return TX Summed')
subplot 413
plot(timestamp,real(s_rd_t_mix))
xlim([0 plotlength])
title('Epoch R/D: Station 1/2 Return TX Real')
subplot 414
plot(timestamp,imag(s_rd_t_mix))
xlim([0 plotlength])
title('Epoch R/D: Station 1/2 Return TX Imag')

%diag: plot the two retro signals at if
figure
subplot 211
plot(real(s_rd_r_data))
%xlim([plotlength 2*plotlength])
title('Station 1/2 Downmixed RX input to retrocorrelator')
subplot 212
plot(real(retro))
%xlim([plotlength 2*plotlength])
title('Epoch R/D: Station 1/2 Retro IF')



