function [ c ] = complex_mult16( a, b )
%COMPLEX_MULT16 multiply two complex int16
%   fu matlab

% float_scale = 32767;
float_scale_pow = 15;

a = int32(a);
b = int32(b);

% foil
%c = real(a)*real(b) + real(a)*imag(b)*1i + imag(a)*real(b)*1i + imag(a)*imag(b)*-1

cr = real(a)*real(b) - imag(a)*imag(b);
ci = real(a)*imag(b) + imag(a)*real(b);

% ben needs to cast to double here because no fixed point license for his matlab
cr = bitsra(double(cr),float_scale_pow);
ci = bitsra(double(ci),float_scale_pow);

c = int16(complex(cr,ci));

end

