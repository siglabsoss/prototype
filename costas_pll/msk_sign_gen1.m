%MSK signal generation
clc; close all; clear all;

data_bits_i(1,(1:2:2000)) = zeros(1,1000)+1;
data_bits_i(1,(2:2:2000)) = ones(1,1000);

data_bits_q(1,(1:2:2000)) = zeros(1,1000)+1;
data_bits_q(1,(2:2:2000)) = ones(1,1000);

f = 20;
Fs = 32*f;
t = 0:1/Fs:15/Fs;
x = sin(2*pi*f*t);
y = -x;

I_Signal = [];
Q_Signal = [];
for ii = 1:1:2000
    I_Signal = [I_Signal data_bits_i(ii)*x];
end

for ii = 1:1:2000
    Q_Signal = [Q_Signal data_bits_q(ii)*x];
end

Q_Signal = [Q_Signal(1,9:end) Q_Signal(1,end-7:end)]; % I_Signal(1,1:4)];

x_lenth = 1:1:200;
figure; plot(x_lenth,I_Signal(1,1:200),x_lenth,Q_Signal(1,1:200));

IQ_Signal = I_Signal + Q_Signal;


% tc = gauspuls('cutoff',50E3,.6,[],-40);
% t  = -tc : 1E-6 : tc;
% yi = gauspuls(t,50E3,.6); plot(t,yi)



