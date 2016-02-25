%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DESIGN PARAMETERS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% symbol rate (symbols per second)
sps = 2500;

% channel bandwidth in multiple of symbol rate
cb = 2;

% number of delay filters (integer divisible into channel bandwidth in Hz)
ndf = 40;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% MODULATE DATA AND PUT THROUGH RANDOM FILTER BANK
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% generate some random BPSK data
a = i*(((randi(2,sps,1)-1)*2)-1);

% up interpolate
b = interp(a,cb,1,0.1);

% calculate input PAPR (exclude artifacts at ends of vector)
papr_input = max(abs(b(1000:end-1000)))^2/mean(abs(b(1000:end-1000)))^2;
papr_input_db = 10 * log(papr_input)/log(10);

% channelize
c = fft(b);
d = reshape(c, [sps*cb/ndf, ndf]);
e = ifft(d);


% random delay
f = randi(1,ndf,1);
for z = 1:ndf
    % insert factional delay
    %fd = fdesign.fracdelay(randi(10)/20,'N',2);
    fd = fdesign.fracdelay(0,'N',2);
    hd = design(fd,'lagrange','filterstructure','farrowfd');
    g(:,z) =  filter(hd,e(:,z));
    
    % insert group delay
    hd = dfilt.delay(randi(1)*5);
    %hd = dfilt.delay(0);
    h(:,z) = filter(hd,g(:,z));
end


% unchannelize
k = fft(h);
m = reshape(k,[sps*cb,1]);
n = ifft(m);

% plot
plot([real(n) imag(n)]);
ylim([-5 5]);

% calculate output PAPR (exclude artifacts at ends of vector)
papr_output = max(abs(n(1000:end-1000)))^2/mean(abs(n(1000:end-1000)))^2;
papr_output_db = 10 * log(papr_output)/log(10);