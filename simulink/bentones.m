function [ beat, clockUp, clockDown, beatDown ] = bentones(  )
%MYTONES Summary of this function goes here
%   Detailed explanation goes here

% simulation stuff carried over from simulink
samplesPerSymbol = 10;
cdt = 1 / samplesPerSymbol;

% frequency stuff
cdfUp       = 1/100    + 1;
cdfDown     = -1/100   + 1;
cdfMixer    = 1/200;
cdfBeatDown = (cdfUp + cdfDown);


clockUpPhase   = (90 / 360)   / cdfUp;
clockDownPhase = (90 / 360)   / cdfDown;
mixerPhase     = (0 / 360)   / cdfMixer;
beatDownPhase  = (((clockUpPhase*cdfUp*360) + (clockDownPhase*cdfDown*360)) / 360)   / cdfBeatDown;
% beatDownPhase   = (50 / 360)   / cdfBeatDown;


totalSamples = 1000;


clockUp   = oneWeirdWave(cdfUp,   cdt, clockUpPhase, totalSamples);
clockDown = oneWeirdWave(cdfDown, cdt, clockDownPhase, totalSamples);
mixer     = oneWeirdWave(cdfMixer, cdt, mixerPhase, totalSamples);
beatDown  = oneWeirdWave(cdfBeatDown, cdt, beatDownPhase, totalSamples);


beat = clockUp + clockDown;
% beat = clockUp;

% beat = beat .* mixer;



beatDownZC = zeroCross(imag(beatDown));

plotTime = 0:(totalSamples-1);
plotTime = plotTime';

subplot 511
plot(imag(clockUp)');
subplot 512
plot(imag(clockDown)');
subplot 513
plot(imag(beat)');
subplot 514
plot(plotTime,imag(beatDown)', plotTime, beatDownZC);
% subplot 515
% plot(plotTime);
% plot(beatDownZC);

end


function points = oneWeirdWave(df, dt, phase, total)
int = phase;
points = zeros(1,total);
for i = 1:total
    points(i)   = complex(cos(df * 2 * pi * int),sin(df * 2 * pi * int));
    int = int + dt;
end
end


function points = zeroCross(vec)
[~,sz] = size(vec);

output = 1;

points = ones(1,sz);

for i = 3:sz
    if( (vec(i-2) < 0) && (abs(vec(i-1)) < 10E-2) && (vec(i) > 0) )
        output = output * -1;
    end
    
    points(i-1) = output;
end

end
