function [ c ] = complex_sub16( a, b )
%COMPLEX_SUB16
%   fu matlab

cr = real(a)-real(b);
ci = imag(a)-imag(b);

c = int16(complex(cr,ci));
end

