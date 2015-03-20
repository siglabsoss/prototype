function [ ] = find_comb_random()
%FIND_COMB_RANDOM Summary of this function goes here
%   Detailed explanation goes here

    
    % this test adds awgn for scoring, this is the snr of the test
    testDb = 9;


    bestScore = 1E10;


    while(1)

        seed = int32(rand() * 1000000);
        comb = comb_gen(seed, 1, 0);

    
        score = auto_cor(comb, testDb);
        
        if( score < bestScore )
            disp('New best comb:');
            disp(score);
           disp(sprintf('  best_comb = comb_gen(%d,1,0);', seed));
           bestScore = score;
        end
                

    end

end

