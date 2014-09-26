function [ cycles4 ] = ldpccycle4check( H )
% 4-Cycles

% If there is a check matrix H , row number is m ,
% column number is n .

[mm, nn] = size(H);


iterations = mm*(mm-1) / 2

% rowcombinations = zeros(iterations,2);
ri = 1;

% final count
cycles4 = 0;

for i = mm-1:-1:0
    
    ind1 = mm-i-1 + 1;
%     r1 = H(ind1,:);
    
    [~, r1ones] = find(H(ind1,:));
    
    for j = 0:i-1
        ind2 = j  + mm-i + 1;
        
        
        rowthrees = nnz(H(ind2,r1ones));
        
        if( rowthrees > 1 )
            cycles4 = cycles4 + (rowthrees*(rowthrees-1)/2);
        end
        
        if( mod(ri,100000) == 0 )
            disp(iterations - ri)
        end
        
        
        % build permutations of row combinations with 0 counting
        %         rowcombinations(ri,:) = [m, m2];
        ri = ri+1;
    end
end

return
    
% for i = 1:iterations 
%     % pick each index and convert to 1 counting
% %     [ind1,ind2] = split(rowcombinations(i,:) + [1 1]);
%     ind1 = rowcombinations(i,1) + 1;
%     ind2 = rowcombinations(i,2) + 1;
% %     r1 = H(ind1,:);
% %     r2 = H(ind2,:);
%     
%     % a vector where any 3's added with another 3 is a cycle
%     rowsum = and(H(ind1,:), H(ind2,:));
%     
%     % a vector where any 3's in 'sum' are now a 1.
% %     threes = (ones(1,nn)*3 == rowsum);
%     
%     rowthrees = sum(rowsum);
%     
%     cycles4 = cycles4 + (rowthrees*(rowthrees-1)/2);
%     
%     if( mod(i,100) == 0 )
%         disp(iterations - i)
%     end
% end

% return cycles4

end

