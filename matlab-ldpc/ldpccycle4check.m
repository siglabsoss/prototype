function [ cycles4 ] = ldpccycle4check( H )
% 4-Cycles

% If there is a check matrix H , row number is m ,
% column number is n .

[mm, nn] = size(H);


iterations = mm*(mm-1) / 2;

rowcombinations = zeros(iterations,2);
ri = 1;

for i = mm-1:-1:0
    for j = 0:i-1

        m = mm-i-1;
        m2 = j  + mm-i;
%             disp(sprintf('%d %d', m, m2));
        
        % build permutations of row combinations with 0 counting
        rowcombinations(ri,:) = [m, m2]; 
        ri = ri+1;
    end
end

% final count
cycles4 = 0;
    
for i = 1:iterations 
    % pick each index and convert to 1 counting
    [ind1,ind2] = split(rowcombinations(i,:) + [1 1]);
    r1 = H(ind1,:);
    r2 = H(ind2,:) * 2;
    
    % a vector where any 3's added with another 3 is a cycle
    rowsum = r1 + r2;
    
    % a vector where any 3's in 'sum' are now a 1.
    threes = (ones(1,nn)*3 == rowsum);
    
    rowthrees = sum(threes);
    
    cycles4 = cycles4 + (rowthrees*(rowthrees-1)/2);
end

cycles4

end
