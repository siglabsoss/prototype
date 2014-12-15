function [ rndsave ] = digrngsequence( length )
%DIGRNGSEQUENCE Summary of this function goes here
%   Detailed explanation goes here

sz = 0;

vec = zeros(1,length);

maxfound = 0;

while sz ~= length
    
    rndstate = randi(4294967295, 1, 4);  % uint32_t max in a 1 by 4 vector
    rndsave = rndstate;
    % disp(rndstate);
    
    
    
    for i=1:length
        [r,rndstate] = xor128(rndstate);
        
        r = mod(r,length);
        
        vec(i) = r;
        
    end
    
    % u = ;
    
    [~,sz] = size(unique(vec));
    
    if( sz > maxfound )
       sz
       maxfound = sz;
       disp(mat2str(rndsave));
    end
    
end


disp(mat2str(rndsave));
vec


end

