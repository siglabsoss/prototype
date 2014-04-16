%maxLen = 3548160;
maxLen = 100000;


test = [];
bestComb = [];

bestScore = .5;

%p = 0.06;

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
	if size(test,2) ~= 0
		score = autoCor(test);

		if score < bestScore
			disp(sprintf('Best Score: %f', score));
			disp(sprintf('P used was: %f', p));
			disp('With values:');
			disp(test);
			bestScore = score;
			bestComb = test;
		end
	end

end


