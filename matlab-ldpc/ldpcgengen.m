
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


A = spalloc(height, width, maxonecols*width);


i = 1;
while i <= width
    
    
    [rndstate,col] = onesvector(minonecols, maxonecols, i, height, rndstate);

    % the vector returned by onesvector is non sorted and may contain dupes
    % if duplicated are present, all even number of duplicates should be
    % removed
    
    col = sort(col + 1);
    
    [~,onespercol] = size(col);
    
    prev = col(1);

    j = 2;
    while j <= onespercol
        if( col(j) == prev )
            
            col(j) = [];
            col(j-1) = [];
            onespercol = onespercol - 2;
            j = j - 1; % going BACKWARDS here
            
            % special case when col looks like [3 3 3]
            % this prevents underindex
            if( j <= 1 )
                break;
            end
            
            prev = col(j-1); % grab prev with the decrimented j
            continue;
        end
        prev = col(j); % grab j before inc
        j = j + 1;
    end
    
    % allocate vertical vector
    column = spalloc(height, 1, onespercol);
    
    % using the sparce indices stored in col, set those entries to 1
    column(col) = 1;
    
    % replace A with the column
    A(:,i) = column;

    i = i + 1;
end

G = [speye(k) A];

H = [];

% checks
% 
% Hrr = g2rref(H);
% Hl = Hrr(:,[1:height]);
% if( sum(sum(Hl ~= eye(height))) )
%     disp('Parity matrix H cannot be rrefd correctly');
% end

valid = 1;


zerocol = sum(G,1);

if( min(zerocol) == 0 )
    if( ~silent )
        disp('Some columns have no ones');
    end
    valid = 0;
    return
%     sum(G,1)
end
 

H = gen2par(G);



% since gok is sparse
gok = mod(G*H',2);

% this nnz should be faster than sum(sum()) (untested)
if( nnz(gok) ~= 0 )
    if( ~silent )
        disp('Parity matrix H does not have valid generator G');
    end
    valid = 0;
    return
end




return

% disp('ldpccycle4check');

% t = cputime();

% cycle4s = ldpccycle4check(H);

% e = cputime() - t

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

outputrow = zeros(1,onespercol);
i = 0;
while i < onespercol
    [col,state] = xor128(state);
    col = mod(col, width);
    
    outputrow(i+1)=col;
    %     disp(col);s
    i = i + 1;
    
end

% disp(sprintf('ones for row(%d): %d', row, r));



end








