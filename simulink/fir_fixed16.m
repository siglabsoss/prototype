function [ dout ] = fir_fixed16( din, coefficients )
%din and coefficients should be already multipled up to be int16
float_scale = 32768;

din = double(din) ./ float_scale;


dout = filter(double(coefficients),1,din);

dout = int16(dout);

end

% test with:
% din = int16((mod([0:40],16) / 16) * 32768)'
% coefficients = [1311;1638;983];
% dout = fir_fixed16(din,coefficients);
% disp('pass if this is 1:')
% sum(dout == [0 82 266 512 758 1004 1249 1495 1741 1987 2232 2478 2724 2970 3215 3461 2396 1004 266 512 758 1004 1249 1495 1741 1987 2232 2478 2724 2970 3215 3461 2396 1004 266 512 758 1004 1249 1495 1741]') == 41

