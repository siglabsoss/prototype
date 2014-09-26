
function [ G, H ] = ldpcgengen( n, k )
%LDPCGEN Summary of this function goes here
%   Detailed explanation goes here

rndstate = [4113462644 4144164702 676943035 2064672539];

% width and height of A, the random area of generator matrix
width = n-k;
height = k;


A = zeros(height, width);

maxonecols = 3;
minonecols = 2;

i = 1;
while i <= width
    
    
    [rndstate,col] = onesvector(minonecols, maxonecols, i, height, rndstate);
    
    j = 1;
    [~,onespercol] = size(col);
    while j <= onespercol
        A((col(j)+1),i) = xor(  A((col(j)+1),i), 1);  % returned indices don't force a 1, they xor
        j = j + 1;
    end

    i = i + 1;
end

G = [eye(k) A];

H = [];

% checks
% 
% Hrr = g2rref(H);
% Hl = Hrr(:,[1:height]);
% if( sum(sum(Hl ~= eye(height))) )
%     disp('Parity matrix H cannot be rrefd correctly');
% end
 

H = gen2par(G);

gok = mod(G*H',2);
if( sum(sum(gok)) ~= 0 )
    disp('Parity matrix H does not have valid generator G');
end


zerocol = sum(G,1);

if( min(zerocol) == 0 )
    disp('Some columns have no ones');
    sum(G,1)
end




end



function [ state, outputrow ] = onesvector( onerowmin, onesrowmax, row, width, state )
i = 0;

[burn,state] = xor128(state);

onespercol = mod(burn,(onesrowmax-onerowmin+1)) + onerowmin;

%      disp('row')

outputrow = [];
i = 0;
while i < onespercol
    [col,state] = xor128(state);
    col = mod(col, width);
    
    outputrow(end+1)=col;
    %     disp(col);s
    i = i + 1;
    
end

% disp(sprintf('ones for row(%d): %d', row, r));



end








