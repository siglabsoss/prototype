function [ dout ] = opti_comb4( )



global my_global_val;
global my_global_val2;


samples = 25000;


stsdiv = 500 - my_global_val/10;

sts = [samples/stsdiv/-2:1/stsdiv:samples/stsdiv/2];
% ss = sin(sts);


a1 = my_global_val2;

f1 = sts .* sts;

f1 = f1 * a1;



dout = cos(f1) + 1i*sin(f1);

dout = dout(1:25000);

dout = dout';




end

