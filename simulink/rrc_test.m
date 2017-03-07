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
msg_d = [1 1 1 1 1 0 0 1 0 1 1 0 1 1 0 1 0 0 0 1 1 0 0 1 1 0 1 1 0 1 1 0 1 1 1 1 0 1 1 1 1 1 0 0 0 0 0 1 0 0 0 0 1 0 1 0 0 1 1 1 0 0 1 0 0 0 0 1 1 1 0 1 1 0 0 0 0 1 1 1 1 1 1 1 0 1 1 0 0 0 1 0 1 0 0 0 1 1 1 1];
figure;
stem(msg_d(1:40),'b-','filled'); % plotting digital bit stream
title('Random Bits');
xlabel('Bit Index');
ylabel('Value'); 

% msg_a=modmap(msg_d,1,1,'qask',M); % Mapping I and Q 
msg_a=[-1 1;-1 1;-1 1;-1 1;-1 1;1 1;1 1;-1 1;1 1;-1 1;-1 1;1 1;-1 1;-1 1;1 1;-1 1;1 1;1 1;1 1;-1 1;-1 1;1 1;1 1;-1 1;-1 1;1 1;-1 1;-1 1;1 1;-1 1;-1 1;1 1;-1 1;-1 1;-1 1;-1 1;1 1;-1 1;-1 1;-1 1;-1 1;-1 1;1 1;1 1;1 1;1 1;1 1;-1 1;1 1;1 1;1 1;1 1;-1 1;1 1;-1 1;1 1;1 1;-1 1;-1 1;-1 1;1 1;1 1;-1 1;1 1;1 1;1 1;1 1;-1 1;-1 1;-1 1;1 1;-1 1;-1 1;1 1;1 1;1 1;1 1;-1 1;-1 1;-1 1;-1 1;-1 1;-1 1;-1 1;1 1;-1 1;-1 1;1 1;1 1;1 1;-1 1;1 1;-1 1;1 1;1 1;1 1;-1 1;-1 1;-1 1;-1 1];
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
% pulse = rcosine(1,over,'sqrt',rolloff); %basic raised-cosine pulseshape
pulse = [0.000757880681389975 -0.000574075075184937 -0.00191109473128678 -0.00313154714967902 -0.00411300683693988 -0.0047426217283228 -0.00492764744413622 -0.00460533156816589 -0.00375131798398794 -0.00238578896099966 -0.000576671725614586 0.0015605975852505 0.00386704507303347 0.00614790737313021 0.00818392876183618 0.00974570655963259 0.0106103295394597 0.0105793356224152 0.00949685040401532 0.00726667143497868 0.00386704507303346 -0.000638051420191638 -0.00609216010905161 -0.0122449346710257 -0.0187565899199397 -0.0252083788621056 -0.0311188928233004 -0.0359655988354323 -0.0392106651788268 -0.0403298051332098 -0.0388426130962011 -0.0343426953240514 -0.0265258238486492 -0.0152143749295502 -0.000376454387066892 0.0178616439035609 0.0392106651788269 0.0632219176852463 0.0892992469778191 0.116719134132271 0.144658117408138 0.172226298239291 0.198505316559523 0.222588891418874 0.243623839601108 0.260849420190217 0.273632912236456 0.281499513706922 0.284154943091895 0.281499513706922 0.273632912236456 0.260849420190217 0.243623839601108 0.222588891418874 0.198505316559523 0.172226298239291 0.144658117408138 0.116719134132271 0.0892992469778191 0.0632219176852463 0.0392106651788269 0.0178616439035609 -0.000376454387066892 -0.0152143749295502 -0.0265258238486492 -0.0343426953240514 -0.0388426130962011 -0.0403298051332098 -0.0392106651788268 -0.0359655988354323 -0.0311188928233004 -0.0252083788621056 -0.0187565899199397 -0.0122449346710257 -0.00609216010905161 -0.000638051420191638 0.00386704507303346 0.00726667143497868 0.00949685040401532 0.0105793356224152 0.0106103295394597 0.00974570655963259 0.00818392876183618 0.00614790737313021 0.00386704507303347 0.0015605975852505 -0.000576671725614586 -0.00238578896099966 -0.00375131798398794 -0.00460533156816589 -0.00492764744413622 -0.0047426217283228 -0.00411300683693988 -0.00313154714967902 -0.00191109473128678 -0.000574075075184937 0.000757880681389975];
[val,pos] = max(pulse);
% figure; impz(pulse,1);
title('Impulse Response');
sigI2 = filter(pulse,1,sigI); % signal after pulse shaping
sigI2 = sigI2(pos:length(sigI2)); % discard transient
sigQ2 = filter(pulse,1,sigQ); % signal after pulse shaping
sigQ2 = sigQ2(pos:length(sigQ2)); % discard transient 

sizesigI2 = size(sigI2);
fprintf('size of sigI2 is %d\n', sizesigI2(1));

sigtx = sigI2 + sigQ2*1j;

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
% Num = [1.43973947975579e-06 -5.3951762897698e-06 -9.94867085701845e-06 -1.00780191433225e-05 2.96950393551084e-08 1.93070008458448e-05 3.63729466378132e-05 3.36356961647335e-05 -7.58916142272223e-08 -5.52606078784295e-05 -9.80676630989527e-05 -8.61087664811657e-05 1.38449210541375e-07 0.00012963669975684 0.000221824725480566 0.000188438540421716 -2.33086598574349e-07 -0.000267540314042156 -0.000446248553775273 -0.000370209735810514 3.64927796801817e-07 0.000503407806521742 0.000823645866217566 0.000671053441121798 -5.35728748092922e-07 -0.000882477323779427 -0.00142220229395167 -0.00114229323573643 7.49880926541593e-07 0.00146282149002399 0.00232928051836924 0.00184969551172567 -1.00129277050685e-06 -0.00231928677879143 -0.00365820460306975 -0.00287932885442247 1.28299393919145e-06 0.00355241820279999 0.00556386830846196 0.00435125886358253 -1.58290728706027e-06 -0.00530957278436887 -0.00828001399456078 -0.00645250511656117 1.88465477711088e-06 0.00783719668861798 0.012212964582155 0.00952171476915492 -2.16880860794811e-06 -0.0116223753509157 -0.0182045411147906 -0.0142963103600685 2.4142533703145e-06 0.01784982427966 0.0284352315211708 0.0228252261990455 -2.60624655387783e-06 -0.0304315684660474 -0.0509475412594876 -0.0437671404945185 2.72811847751427e-06 0.0742741660764829 0.158442135572915 0.224824724388928 0.249997230722697 0.224824724388928 0.158442135572915 0.0742741660764829 2.72811847751427e-06 -0.0437671404945185 -0.0509475412594876 -0.0304315684660474 -2.60624655387783e-06 0.0228252261990455 0.0284352315211708 0.01784982427966 2.4142533703145e-06 -0.0142963103600685 -0.0182045411147906 -0.0116223753509157 -2.16880860794811e-06 0.00952171476915492 0.012212964582155 0.00783719668861798 1.88465477711088e-06 -0.00645250511656117 -0.00828001399456078 -0.00530957278436887 -1.58290728706027e-06 0.00435125886358253 0.00556386830846196 0.00355241820279999 1.28299393919145e-06 -0.00287932885442247 -0.00365820460306975 -0.00231928677879143 -1.00129277050685e-06 0.00184969551172567 0.00232928051836924 0.00146282149002399 7.49880926541593e-07 -0.00114229323573643 -0.00142220229395167 -0.000882477323779427 -5.35728748092922e-07 0.000671053441121798 0.000823645866217566 0.000503407806521742 3.64927796801817e-07 -0.000370209735810514 -0.000446248553775273 -0.000267540314042156 -2.33086598574349e-07 0.000188438540421716 0.000221824725480566 0.00012963669975684 1.38449210541375e-07 -8.61087664811657e-05 -9.80676630989527e-05 -5.52606078784295e-05 -7.58916142272223e-08 3.36356961647335e-05 3.63729466378132e-05 1.93070008458448e-05 2.96950393551084e-08 -1.00780191433225e-05 -9.94867085701845e-06 -5.3951762897698e-06 1.43973947975579e-06];
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



