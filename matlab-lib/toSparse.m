function sparse = toSparse(dense)

sparse = [0];

[~,A]=size(dense);

sig = dense(1);

for i = 1:A

	if sig ~= dense(i)
        sparse(end+1) = i - 1;
        sig = dense(i);
    end
end

% due to convention (or possibly a bug in toDense)
% we require a final entry in the sparse vector to represent the end.  this
% also means that all dense representaions will always end with a final
% streak that is 1 long and the opposite of what came before it
if (i-1) ~= sparse(end)
    sparse(end+1) = i;
end