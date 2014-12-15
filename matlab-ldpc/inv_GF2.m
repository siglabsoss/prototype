function [b]=inv_GF2(A)
%Ainv=inv_GF2(A)

dim=size(A);
rows=dim(1);
cols=dim(2);

for i=1:rows
   for j=1:rows
      unity(i,j)=0;
   end
   unity(i,i)=1;
end

for i=1:rows
   b(1:rows,i)=gflineq(A,unity(1:rows,i));
end


H=[h1 h2];
[m,n]=size(H);
 A(1:m,1:m)=H(1:m,1:m);
 B(1:m,1:m)=H(1:m,m+1:n);
 
d=mod(inv_GF2(B)*A,2); 
I=eye(m);
G=[ I d'];