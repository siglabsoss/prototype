function [ dout ] = change_fs( din, fsold, fsnew )
% CHANGE_FS resamples din from fsold to fsnew

if( iscolumn(din) )
   [szold,~] = size(din);
elseif( isrow(din) )
   din = din';
   disp 'changing your data into column vector'
   [szold,~] = size(din);
else
    error 'din must be a vector, not a matrix'
end

% length in seconds at old fs
lengthold = szold/fsold;
sznew = lengthold*fsnew;

szolddec = szold - 1;
sznewdec = sznew - 1;

dout = interp1(1:szold,din, [1 : szolddec/sznewdec : szold] )';


end

