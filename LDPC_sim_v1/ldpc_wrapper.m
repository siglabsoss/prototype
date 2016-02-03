
TxRx.Decoder.LDPC.Scheduling = 'Layered'; % 'Layered' and 'Flooding'
TxRx.Decoder.LDPC.Type = 'OMS'; % 'MPA' and 'SPA' (optimal)
TxRx.Decoder.LDPC.Iterations = 5;
  
load('codes/LDPC_11nD2_648b_R12.mat'); % load code
LDPC.H = double(LDPC.H.x);
LDPC.G = double(LDPC.G.x);



# just for now
bits = round(rand(1,LDPC.inf_bits));
x = bits*LDPC.G;
s = sign((x==0)-0.5); % mapping: 1 to -1.0 and 0 to +1.0 s is CW
% -- AWGN channel
DB = 0;
sigma2 = 10^(-DB/10);      
disable_noise = 0;
noise = randn(1,length(s)); 
y = s + noise*sqrt(sigma2)*disable_noise;

% -- compute LLRs & decode    
LLR_A2 =  2*y/sigma2; 
      
[bit_output,LLR_D2,NumC,NumV] = decLDPC_layered(TxRx,LDPC,LLR_A2);
ref_output = (bits==1);
tmp = sum(abs(ref_output-bit_output))/LDPC.inf_bits;

tmp