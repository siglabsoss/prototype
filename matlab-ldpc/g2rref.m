function [A,jb] = g2rref(A)
%RREF   Reduced row echelon form.
%   R = RREF(A) produces the reduced row echelon form of A.
%
%   [R,jb] = RREF(A) also returns a vector, jb, so that:
%       r = length(jb) is this algorithm's idea of the rank of A,
%       x(jb) are the bound variables in a linear system, Ax = b,
%       A(:,jb) is a basis for the range of A,
%       R(1:r,jb) is the r-by-r identity matrix.
%
%   [R,jb] = RREF(A,TOL) uses the given tolerance in the rank tests.
%
%   Roundoff errors may cause this algorithm to compute a different
%   value for the rank than RANK, ORTH and NULL.
%
%   Class support for input A:
%      float: double, single
%
%   See also RANK, ORTH, NULL, QR, SVD.

%   Copyright 1984-2005 The MathWorks, Inc. 
%   $Revision: 5.9.4.3 $  $Date: 2006/01/18 21:58:54 $

[m,n] = size(A);

% Loop over the entire matrix.
i = 1;
j = 1;
jb = [];
while (i <= m) && (j <= n)
   % Find value and index of largest element in the remainder of column j.
   [p,k] = max(abs(A(i:m,j))); k = k+i-1;

   % Remember column index
   jb = [jb j];
   % Swap i-th and k-th rows.
   disp('Swap i-th and k-th rows.');
   A([i k],j:n) = A([k i],j:n);
   disp(A);
   % Divide the pivot row by the pivot element.
   A(i,j:n) = A(i,j:n)/A(i,j);
   % Subtract multiples of the pivot row from all the other rows.
   for k = [1:i-1 i+1:m]
       A(k,j:n) = A(k,j:n) - A(k,j)*A(i,j:n);
       disp(A);
   end
   i = i + 1;
   j = j + 1;

end

