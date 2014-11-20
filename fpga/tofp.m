function [ bits ] = tofp( val )
%TOFP converts to fixed point

% 	inputs
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
    
    ival = floor(abs(val));
    fval = abs(val)-ival;

    fbits = uint32(fval * fmask);
    ibits = uint32(ival);
    sbit = uint32(0);
    
    if( val < 0 )
        sbit = uint32(1);
    end
    
    bits = uint32(0);
    bits = bitor(bits,fbits);
    bits = bitor(bits,bitsll(ibits,ishift));
    bits = bitor(bits,bitsll(sbit,sshift));

end

