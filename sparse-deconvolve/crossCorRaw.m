function result = crossCorRaw(sparseComb, sparseData, display)

denseComb = toDense(sparseComb);
denseData = toDense(sparseData);


% shorter vector is 0 padded to make it the same size as larger
% result is 2N - 1 samples
c = xcorr(denseComb, denseData);

result = max(c);

% c = c ./ size(denseComb,2);
% c = c .* c;
% c = sqrt(c);
% 
% if display ~= 0
% 	figure
% 	plot(c);
% end
% 
% integral = sum(c) / size(denseComb,2);