
function [ G, H ] = ldpcgengen( n, k )
%LDPCGEN Summary of this function goes here
%   Detailed explanation goes here

rndstate = [4113460544 4144164702 676943031 2084672537];

% width and height of A, the random area of generator matrix
width = n-k;
height = k;


A = zeros(height, width);

onecols = 100;

i = 1;
while i <= width
    
    
    [rndstate,col] = onesrow(2, onecols, i, height, rndstate);
    
    j = 1;
    [~,onespercol] = size(col);
    while j <= onespercol
        A(col(j),i) = 1;
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




end



function [ state, outputrow ] = onesrow( onerowmin, onesrowmax, row, width, state )
i = 0;
% use the row index to affect the rng by burning variables
while i < (mod(row,4)+1)
    [burn,state] = xor128(state);
    i = i + 1;
end

onespercol = mod(burn,onesrowmax-onerowmin) + onerowmin;

%      disp('row')

outputrow = [];
i = 0;
while i < onespercol
    [col,state] = xor128(state);
    col = mod(col, width)+1;
    
    outputrow(end+1)=col;
    %     disp(col);s
    i = i + 1;
    
end

% disp(sprintf('ones for row(%d): %d', row, r));



end








