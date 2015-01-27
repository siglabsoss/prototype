function [ beat, clockUp, clockDown ] = bentones(  )
%MYTONES Summary of this function goes here
%   Detailed explanation goes here

samplesPerSymbol = 10;
cdt = 1 / samplesPerSymbol;
cdfUp = 50/100;
cdfDown = 52/100;
cdfMixer = 1/200;
cdfBeatDown = (cdfUp - cdfDown);


clockUp = zeros(0);
clockDown = zeros(0);
mixer = zeros(0);
beatDown = zeros(0);

clockUpInt = 0;
clockDownInt = 0;
mixerInt = 0;
beatDownInt = 0;

for i = 1:1000

clockUp(i)   = complex(cos(cdfUp * 2 * pi * clockUpInt),sin(cdfUp * 2 * pi * clockUpInt));
clockDown(i) = complex(cos(cdfDown * 2 * pi * clockDownInt),sin(cdfDown * 2 * pi * clockDownInt));
mixer(i)     = complex(cos(cdfMixer * 2 * pi * mixerInt),sin(cdfMixer * 2 * pi * mixerInt));
beatDown(i)  = complex(cos(cdfBeatDown * 2 * pi * beatDownInt),sin(cdfBeatDown * 2 * pi * beatDownInt));

clockUpInt   = clockUpInt + cdt;
clockDownInt = clockDownInt + cdt;
mixerInt     = mixerInt + cdt;
beatDownInt  = beatDownInt + cdt;

end



beat = clockUp + clockDown;
% beat = clockUp;

% beat = beat(1:8901) .* clockUp(100:9000)
% beat = beat .* mixer;

subplot 411
plot(imag(clockUp)');
subplot 412
plot(imag(clockDown)');
subplot 413
plot(imag(beat)');
subplot 414
plot(imag(beatDown)');



end

