function [ c ] = complex_add16( a, b )
%COMPLEX_ADD16 add two complex int16
%   fu matlab

% float_scale = 32767;
% float_scale_pow = 15;

% a = int32(a);
% b = int32(b);


cr = real(a)+real(b);
ci = imag(a)+imag(b);

c = int16(complex(cr,ci));

end

