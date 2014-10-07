function [  ] = findCorNoisyPrn( )

test = [];
bestComb = [];

bestScore = .5;

% snr used for all tests
snr = 0.0001;  % smaller is worse
oversample = 1;

% how many noise iterations to try
testIterations = 2;

longestEdge = 500; % in bits
shortestEdge = 2; % in bits
maxLen = 800*10;  % in bits

% bookkeeping variables
iterations = 0;
startVectorSize = floor(maxLen/shortestEdge);
while 1
	
	% reset array
	test = zeros(1,startVectorSize);

    % dig a state
    rndstate = randi(4294967295, 1, 4);  % uint32_t max in a 1 by 4 vector
    
    rndstateStart = rndstate;
    
    edge = 0;
    edgeCount = 2; % starting at 2 instead of 1 gives leading 0
    while(edge < maxLen)
        [r,rndstate] = xor128(rndstate);
        
        r = mod(r,(longestEdge-shortestEdge+1)) + shortestEdge;
        
        edge = edge + r;
        
        test(edgeCount) = edge;
        
        edgeCount = edgeCount + 1;
    end
  
    % trim trailing zeros
    % http://stackoverflow.com/questions/5488504/matlab-remove-leading-and-trailing-zeros-from-a-vector
    test = test(1:find(test,1,'last'));
  
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
            disp(sprintf('rndstate %s)', mat2str(rndstateStart)));
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

