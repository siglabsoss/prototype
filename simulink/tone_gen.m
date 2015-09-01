function [ dout ] = tone_gen( sz, fs, hz )
%TONE_GEN makes pure complex sin waves
%   sz is the number of output samples
%   fs is the samples per second
%   hz is the positive or negative frequency of the tone
%
%   Usage:
%     tone_gen(40000, 100000, 10)
%   will generate a .4 second long vector at 100k samples per second with
%   a +10 hz tone



sampleInc = 1/fs * 2 * pi * hz;
endSample = double(sz)/fs * 2 * pi * hz - sampleInc;
tvec = 0:sampleInc:endSample;
shiftTone = complex(sin(tvec),cos(tvec))';

dout = shiftTone;

end

