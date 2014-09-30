function dense = toDense(sparse)

[~,A]=size(sparse);
B = sparse(A)-sparse(1);
dense = zeros(1,B);
sig = -1;
j = 1;

for i = sparse(1):sparse(A)-1

	if i == sparse(j)
   		sig = sig * -1;
   		j = j + 1;
	end

	dense(i-sparse(1)+1) = sig;
end
