function [ ] = find_comb_random()
%FIND_COMB_RANDOM Summary of this function goes here
%   Detailed explanation goes here

    bestScore = 1E10;


    while(1)

        seed = int32(rand() * 1000000);
        comb = comb_gen(seed, 1, 0);

    
        score = auto_cor(comb);
        
        if( score < bestScore )
            disp('New best comb:');
            disp(score);
           disp(sprintf('  best_comb = comb_gen(%d,1,0);', seed));
           bestScore = score;
        end
                

    end

end

