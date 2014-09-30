function [ combEdges ] = prnComb( maxLength, longestEdge, rndstate )
%PRNCOMB Summary of this function goes here
%   Detailed explanation goes here

    combEdges = [0];
    
    edge = 0;
    
    while(edge < maxLength)
        [r,rndstate] = xor128(rndstate);
        
        r = mod(r,longestEdge);
        
        edge = edge + r;
        
        combEdges(size(combEdges,2)+1) = edge;
    end

end

