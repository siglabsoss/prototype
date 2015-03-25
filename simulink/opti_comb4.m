function [ dout ] = opti_comb4( )



% global my_global_val;
% global my_global_val2;

my_global_val = 1.230772e+01;
my_global_val2 = -1.666667e+01;


samples = 25000;


stsdiv = 500*(my_global_val+90)/100;

sts = [samples/stsdiv/-2:1/stsdiv:samples/stsdiv/2];
% ss = sin(sts);


a1 = my_global_val2;

f1 = sts .* sts;

f1 = f1 / a1;







sts2div = 500*15;

sts2 = [samples/sts2div/-2:1/sts2div:samples/sts2div/2];

% f1 is -1 to 1
ammod = sin(sts2) / 10;

ammod = ammod + 9/10;

f2 = f1 .* ammod;





ffinal = f1;

dout = cos(ffinal) + 1i*sin(ffinal);


dout = dout .* ammod;


dout = dout(1:25000);
dout = dout';




end

