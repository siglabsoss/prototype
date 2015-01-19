% http://www.mathworks.com/help/signal/examples/fir-gaussian-pulse-shaping-filter-design.html

% example 1:

Ts   = 1e-6; % Symbol time (sec)
span = 6;    % Filter span in symbols

a = Ts*[.5, .75, 1, 2];
B = sqrt(log(2)/2)./(a);

t = linspace(-span*Ts/2,span*Ts/2,1000)';
hg = zeros(length(t),length(a));
for k = 1:length(a),
  hg(:,k) = sqrt(pi)/a(k)*exp(-(pi*t/a(k)).^2);
end

plot(t/Ts,hg)
title({'Impulse response of a continuous-time Gaussian filter';...
  'for various bandwidths'});
xlabel('Normalized time (t/Ts)')
ylabel('Amplitude')
legend(sprintf('a = %g*Ts',a(1)/Ts),sprintf('a = %g*Ts',a(2)/Ts),...
  sprintf('a = %g*Ts',a(3)/Ts),sprintf('a = %g*Ts',a(4)/Ts))
grid on;


% example 2:

ovsf = 16; % Oversampling factor (samples/symbol)
h = zeros(97,4);
iz = zeros(97,4);
for k = 1:length(a)
  BT = B(k)*Ts;
  h(:,k) = gaussdesign(BT,span,ovsf);
  [iz(:,k),t] = impz(h(:,k));
end
figure('Color','white')
t = (t-t(end)/2)/Ts;
stem(t,iz)
title({'Impulse response of the Gaussian FIR filter for ';...
  'various bandwidths, OVSF=16'});
xlabel('Normalized time (t/Ts)')
ylabel('Amplitude')
legend(sprintf('a = %g*Ts',a(1)/Ts),sprintf('a = %g*Ts',a(2)/Ts),...
  sprintf('a = %g*Ts',a(3)/Ts),sprintf('a = %g*Ts',a(4)/Ts))
grid on;