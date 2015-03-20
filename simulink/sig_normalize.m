function [ dout ] = sig_normalize( din )
%SIG_NORMALIZE 

val = max(abs(din));

dout = din / val;


end

