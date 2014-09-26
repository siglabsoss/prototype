
function [ G, H, valid ] = ldpcgengen( n, k, minonecols, maxonecols, rndstate, silent )
%LDPCGEN Summary of this function goes here
%   Detailed explanation goes here

% display(nargin);
if( nargin < 6 )
    silent = 0;
end

% width and height of A, the random area of generator matrix
width = n-k;
height = k;


A = zeros(height, width);


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

valid = 1;

gok = mod(G*H',2);
if( sum(sum(gok)) ~= 0 )
    if( ~silent )
        disp('Parity matrix H does not have valid generator G');
    end
    valid = 0;
    return
end


zerocol = sum(G,1);

if( min(zerocol) == 0 )
    if( ~silent )
        disp('Some columns have no ones');
    end
    valid = 0;
    return
%     sum(G,1)
end

return

disp('ldpccycle4check');

t = cputime();

cycle4s = ldpccycle4check(H);

e = cputime() - t

if( cycle4s )
%     if( ~silent )
        disp('4-cycles were found');
        cycle4s
%     end
%     valid = 0;
    return
end




end



function [ state, outputrow ] = onesvector( onerowmin, onesrowmax, row, width, state )

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








