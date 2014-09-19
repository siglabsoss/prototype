% This is a modified version of matlab's building rref which calculates
% row-reduced echelon form in gf(2).  Useful for linear codes.
% Tolerance was removed because yolo, and because all values
% should only be 0 or 1.  @benathon

function [A] = g2rref(A)
%G2RREF   Reduced row echelon form in gf(2).
%   R = RREF(A) produces the reduced row echelon form of A in gf(2).
%
%   Class support for input A:
%      float: with values 0 or 1
%   Copyright 1984-2005 The MathWorks, Inc. 
%   $Revision: 5.9.4.3 $  $Date: 2006/01/18 21:58:54 $

[m,n] = size(A);

% Loop over the entire matrix.
i = 1;
j = 1;

while (i <= m) && (j <= n)
   % Find value and index of largest element in the remainder of column j.
   k = find(A(i:m,j),1) + i - 1;

   % Swap i-th and k-th rows.
   A([i k],j:n) = A([k i],j:n);
   
   % Save the right hand side of the Pivot row
   aijn = A(i,j:n);

   range = [];
   
   % Column we're looking at
   col = A(1:m,j);
   
   % Never run the 'k' loop on the pivot row
   col(i) = 0;
   
   % Find the remaining 1's in this column
   range = find(col)';
       
   % Subtract multiples of the pivot row from all the other rows.
   for k = range       
       A(k,j:n) = mod(A(k,j:n) - aijn,2);
   end
   
   i = i + 1;
   j = j + 1;
end