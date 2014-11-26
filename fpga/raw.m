function [ output ] = raw( samples )

s = serial('COM3');
set(s,'BaudRate',1250000);
set(s,'InputBufferSize',10000000);
fopen(s);

c = onCleanup(@()fclose(s));

% hold reset down and then launch this fn.  the first char is junk (oh
% well)

samples = 50000;
%samples = 1000;

output = zeros(1,samples);

charChunk = 25000;
bytesPerSample = 8;

for i=1:(samples/charChunk)
    A = fread(s,bytesPerSample*charChunk);
    % only works for uint32
    %number = A(1) + A(2)*256 + A(3)*65536 + A(4)*16777216; 
    numbers = typecast(uint8(A),'int64');
%     disp(number);

    output(((i-1)*charChunk)+1:i*charChunk) = numbers;

%     for j=1:charChunk
%         output(i+j-1) = number(j);
%     end
    
    

%     if( mod(number,1000) == 0 )
%         disp(sprintf('%d %s', numbers(1), mat2str(A(1:bytesPerSample))));
%     end

end

% disp(A);
% disp(count);

fclose(s);


end

