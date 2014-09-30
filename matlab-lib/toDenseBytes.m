function [] = toDenseBytes(sparse)

countsPerBit = 2640;

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

[~,C]=size(dense);
i = countsPerBit+1;

str = '';
while i <= C+1
%     disp(i);
    
    summ = sum(dense(i-countsPerBit:i-1));
    if( summ > 0 )
        str = strcat(str,'1');
%         str = '1';
    else
        str = strcat(str,'0');
%         str = '0';
    end
    
%     disp(summ);
    
    i = i + countsPerBit;
end

% str = strcat(['lol '], [' '], [str]);
disp(' ');
disp(' ');
disp('0b');
disp(str);
