function [  ] = findCorNoisyPrn( )

test = [];
bestComb = [];

bestScore = .5;

% snr used for all tests
snr = 0.0001;  % smaller is worse
oversample = 1;

% how many noise iterations to try
testIterations = 2;

longestEdge = 30; % in bits
shortestEdge = 1; % in bits
maxLen = 800*10;  % in bits

% bookkeeping variables
iterations = 0;
startVectorSize = floor(maxLen/shortestEdge);
while 1
	
    % dig a state
    rndstate = randi(4294967295, 1, 4);  % uint32_t max in a 1 by 4 vector
    rndstateStart = rndstate;
    
    % generate a comb
    test = prnComb(maxLen, shortestEdge, longestEdge, rndstate);
    
    score = 0;

	% if we have at least one edge
	if size(test,2) > 1

		% oversample original comb to match and avoid rounding issues
% 		test  = test .* oversample;

		score = 0;
        
        denseTest = toDense(test);

		% run test a few times to make sure freak accident noise doesnt give us a really good score
		for j = 1:testIterations
			% now we have a dense, noisy test comb that is oversampled
			testNoisyDense = transmitNoise(denseTest, snr, oversample);

			testNoisySparse = toSparse(testNoisyDense);

			% xcor original comb against noisy one
			score = score + crossCor(test, testNoisySparse, 0);
		end

		% average score
		score = score / testIterations;

		if score < bestScore
            dispstat('','timestamp');
            
			disp(sprintf('Best Score: %f', score));
            disp(sprintf('with prnComb(%d, %d, %d, %s)', maxLen, shortestEdge, longestEdge, mat2str(rndstateStart)));
 			disp('With values:');
 			disp(mat2str(test));
			bestScore = score;
			bestComb = test;

			% display it
			%crossCor(test, testNoisySparse, 1);
            
            dispstat('','init'); % One time only initialization

		end
    end
    
    if( mod(iterations,100) == 0 )
           dispstat(sprintf('Iteration %d score:%f',iterations, score),'timestamp');
    end
    
 
    
    iterations = iterations + 1;

end




























end

