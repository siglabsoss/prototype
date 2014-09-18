function [ w, state ] = xor128( state )
%XOR128 implementation of Xorshift
%   https://en.wikipedia.org/wiki/Xorshift
%   A starting state might be [123456789, 362436069, 521288629, 88675123]

  x = state(1);
  y = state(2);
  z = state(3);
  w = state(4);
  
  % t1 = (x << 11)
  t1 = bitand(bitshift(x,11),hex2dec('ffffffff'));
  
  % t = x ^ (x << 11)
  t = bitxor(x,t1);
  
  x = y;
  y = z;
  z = w;
  
  % t2 = (t ^ (t >> 8))
  t2 = bitxor(t, bitshift(t,-8));
  
  % t3 = w ^ (w >> 19)
  t3 = bitxor(w, bitshift(w,-19));
  
  % w = w ^ (w >> 19) ^ (t ^ (t >> 8))
  w = bitxor(t3, t2);

  state = [x y z w];
end

