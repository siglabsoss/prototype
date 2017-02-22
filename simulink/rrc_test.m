% http://kom.aau.dk/group/05gr943/worksheets/worksheet2_qam.pdf
% QAM transmitter comprises of an encoder block, which allocates
% the 16 quantized levels of data to 4 levels of I and Q components
% each. Both I and Q are pulse shaped using Root Raised Cosine
% filter and then multiplied with sine and cosine respectively. The
% two streams are then added together. 

close all;
len=100; % Number of points in calculation
M=16; % M-ary number 


% Mapping to I and Q
% msg_d = randi(1,len,[0 1]); % Generating random bits
msg_d = randi(2,1,len)-1;
figure;
stem(msg_d(1:40),'b-','filled'); % plotting digital bit stream
title('Random Bits');
xlabel('Bit Index');
ylabel('Value'); 


msg_a=modmap(msg_d,1,1,'qask',M); % Mapping I and Q
sigI1=msg_a(:,1);
sigQ1=msg_a(:,2);

szsigi1 = size(sigI1);
fprintf('message modulated into %d samples\n', szsigi1(1));


over = 16; % oversampling factor

a=zeros(length(sigI1),over-1);
b=zeros(length(sigQ1),over-1);
sigI=([sigI1 a])';
sigI=sigI(:);
sigQ=([sigQ1 b])';
sigQ=sigQ(:);

sizesigI = size(sigI);
fprintf('zero padded to %d\n', sizesigI(1));


figure;
plot(sigI(1:800));
title('Inphase component');
figure;
plot(sigQ(1:800));
title('Quadrature component'); 

% A root raised cosine finite impulse response filter is used to filter
% the data streams before modulation onto the quadrature carriers.
% When passed through a band limited channel, rectangular pulses
% suffer from the effects of time dispersion and tend to smear into
% one another. There is always a danger of intersymbol interference
% between signals. So pulse shaping eliminates inter-symbol
% interference by ensuring that at a given symbol instance, the
% contribution to the response from all other symbols is zero. 


rolloff=.5;
pulse = rcosine(1,over,'sqrt',rolloff); %basic raised-cosine pulseshape
[val,pos] = max(pulse);
figure; impz(pulse,1);
title('Impulse Response');
sigI2 = filter(pulse,1,sigI); % signal after pulse shaping
sigI2 = sigI2(pos:length(sigI2)); % discard transient
sigQ2 = filter(pulse,1,sigQ); % signal after pulse shaping
sigQ2 = sigQ2(pos:length(sigQ2)); % discard transient 

sizesigI2 = size(sigI2);
fprintf('size of sigI2 is %d\n', sizesigI2(1));


n=1:length(sigI2);
c=cos(2*pi*n/10); % cosine signal
s=sin(2*pi*n/10); % sine signal
modsigI=sigI2.*c'; % Modulating with cosine
modsigQ=sigQ2.*s'; % Modulating with sine
modsig1 = modsigI+modsigQ;

% Addition of noise
noise=.07* randn(length(modsig1),1);
modsig=modsig1+noise; % Addition of noise to modulated signal 



% QAM Receiver
% Demodulation of the received signal is done by using coherent sine
% and cosine signals. The two streams are then passed through RRC
% filter. The signal is sampled and decision is taken by the Slicer.
% The original symbols are generated by decoding I and Q symbols. 

% Demodulation
recI = modsig.*c(1:length(modsig))'; % Demodulation of signal I
recQ =modsig.*s(1:length(modsig))'; % Demodulation of signal Q
% Root Raised Cosine Filtering
recI=filter(pulse,1,recI); % signal after RRC filter
recQ=filter(pulse,1,recQ); % signal after RRC filter
recI=recI(pos:end);
recQ=recQ(pos:end); 


% Low Pass Filtering
Num = remez(over,[0 0.2 0.3 1],[1 1 0 0]);
tailsize = (over/2)+1;
recI_filt=filter(Num,1,recI); % Passing received signal I through low pass filter
recI1=recI_filt(tailsize:end); %Truncatig response tail
recQ_filt=filter(Num,1,recQ); % Passing received I through LPF
recQ1=recQ_filt(tailsize:end); %Truncatig response tail

% Sampling
recI2=recI1(1:over:length(recI1));
recQ2=recQ1(1:over:length(recQ1)); 

% Slicer
 for i=1:length(recI2)
   if (recI2(i) >0)
     recI2(i)=1;
   elseif (recI2(i)<0)
     recI2(i)=-1;
   end
   if (recQ2(i)>0)
     recQ2(i)=1;
   elseif (recQ2(i)<0)
     recQ2(i)=-1;
   end
 end
 sig_rec = [recI2 recQ2]; % Received signal after detection
 sig_final=demodmap(sig_rec,1,1,'qask',M); % Final received signal

sizesigI2 = size(sigI2);
fprintf('len of sigI2 is %d\n', sizesigI2(1));
 
% Plotting figures
sizesigI2 = size(sigI2);
sizerecI1 = size(recI1);
commonlength = min(sizesigI2(1), sizerecI1(1));
figure;
plot(1.8*sigI2(1:commonlength),'r-'); % B4 modulation
hold;
plot(recI1(1:commonlength),'b-');grid on; % After Demodulation
title('Comparison b/w signals');
xlabel('Index');ylabel('Amplitude');
legend('Signal B4 Modulation' , 'Signal after Demodulation');
figure;
stem(msg_d(1:40),'r-');hold; % Original data
stem(sig_final(1:40),'.b-');grid on; % Recieved data
title('comparison b/w Original and Recieved Data');
xlabel('index'); ylabel('Integer value');
legend('Original Data' , 'Recieved Data') ; 

% Check Bits
total_bits = size(sig_final); % this example truncates some of the original bits
total_bits = total_bits(1);
res_vector = msg_d(1:total_bits) == sig_final.';
correct = sum(res_vector);
fprintf('correct: %d, fail: %d\n\n', correct, total_bits-correct);



