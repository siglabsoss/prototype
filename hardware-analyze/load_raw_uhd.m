%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Signal Laboratories, Inc.
% (c) 2017. Joel D. Brinton.
%
% Load .RAW file (from GNU Radio Companion)
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = load_raw_uhd(file_name)

f = dir(file_name);
len = f.bytes / 4;

fid = fopen(file_name, 'r');

fseek(fid, 0, 0);

b = fread(fid, len, 'single');

fclose(fid);

out = complex(b(1:2:end), b(2:2:end));

