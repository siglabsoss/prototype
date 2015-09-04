function [ c ] = complex_add32( a, b )
%COMPLEX_ADD16 add two complex int16
%   fu matlab


cr = int32(real(a))+int32(real(b));
ci = int32(imag(a))+int32(imag(b));

c = int32(complex(cr,ci));

end

