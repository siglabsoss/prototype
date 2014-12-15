function [ combEdges ] = prnComb( maxLength, shortestEdge, longestEdge, rndstate )
%PRNCOMB Summary of this function goes here
%   Detailed explanation goes here

startVectorSize = floor(maxLength/shortestEdge);

combEdges = zeros(1,startVectorSize);

edge = 0;
edgeCount = 2; % starting at 2 instead of 1 gives leading 0

while(edge < maxLength)
    [r,rndstate] = xor128(rndstate);
    
    r = mod(r,(longestEdge-shortestEdge+1)) + shortestEdge;
    
    edge = edge + r;
    
    combEdges(edgeCount) = edge;
    
    edgeCount = edgeCount + 1;
end

% force comb to be requested size
combEdges(edgeCount-1) = maxLength-1;

% trim trailing zeros
% http://stackoverflow.com/questions/5488504/matlab-remove-leading-and-trailing-zeros-from-a-vector
combEdges = combEdges(1:find(combEdges,1,'last'));

end

