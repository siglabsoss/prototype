% Count number of bits in each element of X 
function PC = popcount(X, bits)

PC = 0;
for i=1:bits
    PC = PC + bitget(X,i);
end
