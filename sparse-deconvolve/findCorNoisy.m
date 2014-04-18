%dc = toDense(bestComb);
%dcNoisy = transmitNoise(dc, 5)
%nc = toSparse(dcNoisy)


% another way to do this
% a = randperm(2000)
% b = a(1:500)
% c = sort(b)

%maxLen = 3548160;
maxLen = 2000;


test = [];
bestComb = [];

bestScore = .5;

% snr used for all tests
snr = 0;
oversample = 2;

% how many noise iterations to try
testIterations = 5

pMin = 0.000000001;
pMax = 0.05;

while 1
	
	% reset array
	test = [];

	% choose new probability required
	p = (pMax-pMin).*rand(1)+pMin;

	for i = 0:maxLen
		if rand() < p 
			%display('yes')
			test(size(test,2)+1) = i;
		end
	end

	% if we have at least one edge
	if size(test,2) > 1

		% oversample original comb to match and avoid rounding issues
		test  = test .* oversample;

		score = 0;

		% run test a few times to make sure freak accident noise doesnt give us a really good score
		for j = 1:testIterations
			% now we have a dense, noisy test comb that is oversampled
			testNoisyDense = transmitNoise(toDense(test), snr, oversample);

			testNoisySparse = toSparse(testNoisyDense);

			% xcor original comb against noisy one
			score = score + crossCor(test, testNoisySparse, 0);
		end

		% average score
		score = score / testIterations;

		if score < bestScore
			disp(sprintf('Best Score: %f', score));
			disp(sprintf('P used was: %f', p));
			disp('With values:');
			disp(test);
			bestScore = score;
			bestComb = test;

			% display it
			%crossCor(test, testNoisySparse, 1);
		end
	end

end


