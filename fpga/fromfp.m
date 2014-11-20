function [ val ] = fromfp( bits )
%FROMFP Summary of this function goes here
%   Detailed explanation goes here

    % with this we can't go any bigger...FU MATLAB
    bits = uint32(bits);

% 	fixed point paramters
    Q = uint32(15);
    N = uint32(32);
    
    intbits = uint32(N-Q-1);
    fracbits = uint32(Q);
    
    fshift = 0;
    ishift = fracbits;
    sshift = N-1; % sign bit shift
    
    % mask and also max value
    fmask = bitsll(uint32(1),(fracbits))-1; % shift by pow then sub 1
    imask = bitsll(uint32(1),(intbits))-1;
    smask = uint32(1);
    
    sbit = bitand(bitsrl(bits,sshift),smask);
    ibits = bitand(bitsrl(bits,ishift),imask);
    fbits = bitand(bits,fmask);
    
    fval = double(fbits) / double(fmask);
    
    val = fval + double(ibits);
    
    if( sbit )
       val = val * -1; 
    end
    

end

