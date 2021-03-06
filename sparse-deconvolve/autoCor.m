function integral = autoCor(sparseComb)

denseComb = toDense(sparseComb);


% shorter vector is 0 padded to make it the same size as larger
% result is 2N - 1 samples
c = xcorr(denseComb, denseComb);

c = c ./ size(denseComb,2);
c = c .* c;
c = sqrt(c);

integral = sum(c) / size(denseComb,2);