function [ c ] = ldpcencode( G, u )
%LDPCENCODE takes Generator matrix and message and returns code word
% vector u is conventionally the message
% c is the code word to be transmitted

c1 = u*G;

c = mod(c1,2);

end

