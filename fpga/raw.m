function [ ] = raw( samples )

s = serial('COM3');
set(s,'BaudRate',115200);
fopen(s);

c = onCleanup(@()fclose(s));

% hold reset down and then launch this fn.  the first char is junk (oh
% well)

while(1)
A = fread(s,4);
number = A(4) + A(3)*255 + A(2)*65280 + A(1)*16711680;
disp(number);

if( A(4) == 254 )
    disp('ok');
end

end

disp(A);
% disp(count);

fclose(s);


end

