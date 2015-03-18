function [ tvector ] = comb_gen( seed )
%COMB_GEN Summary of this function goes here
%   Detailed explanation goes here

% this is mostly usefull for calling this fn like  comb_gen(rand());
if( seed < 1 )
    seed = seed * 1000000;
    disp('multiplying seed cuz less than 1');
end

% type convert seed
seed = int32(seed);

% seed generator
rng(seed);

disp(sprintf('using %s for rand seed', mat2str(seed)));

fs = 25000;

% bandwidth = 10000;
length = 0.4;


vector = zeros(length*fs,1);

[sz,~] = size(vector);


% min and max bins of fft within our bandwith
deltaBin = 100;
bandMin = sz/2 - deltaBin;
bandMax = sz/2 + deltaBin;



lines = 10;



% vector(5050) = 1+0.5*i;


% vector(

randtune = 0.2;

for bin = bandMin:bandMax
%     vector(bin) = 1;% + bin*i;
%     vector(bin) = 1 + 2*i*rand();
%     vector(bin) = 1 + pi/2;
    if( rand() < randtune )
        vector(bin) = rand() + 2*i*rand();
    end

      
% disp(rand())
end


tvector = ifft(fftshift(vector));


% re-seed number generator just for now, so we can use comb_gen(rand())
newSeed = mod(now * 10E9, 2^32);
rng(newSeed);

% because why not
tvector = fftshift(tvector);

figure;
plot(real(tvector));
figure;
plot(real(vector));


end

