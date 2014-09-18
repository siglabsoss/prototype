function [ G ] = ldpcpar2gen( H )
%LDPCPAR2GEN Summary of this function goes here
%   Detailed explanation goes here

% The generator matrix for a code with parity-check matrix H
% can be found by performing Gauss-Jordan elimination on H to obtain
% it in the form
% H = [A, I(n-k)],
% where A is a (n-k) * k binary matrix and I(n-k) is the size n - k identity
% matrix. The generator matrix is then
% G = [I(k),A^T].

% (m,n) size of the matrix
[height,width] = size(H);

% n is code word bits, k is message bits
n = width;
k = n - height;



% swap left and right
Hl = H(:,[1:n-height]);
Hr = H(:,[n-height+1:n]);

Hrl = [Hr,Hl];

Hrr = g2rref(Hrl);

% disp(mat2str(Hrr));


% The parity-check matrix is put into reduced row-echelon form
%Hrr = mod(rref(H),2);

% The generator matrix is then G = [I(k),A^T]
A = Hrr(:,[n-k+1:n]);

G = [eye(k),A'];





% Lastly, using "column permutations" we put the parity-check matrix into
% standard (cut and paste the identiry matrix from the left side to the
% right side)
% these calculate Hstd according to
% popwi-general\docs\resources\ldpc\introducing_low-density_parity_check_codes.pdf
%Hstd = Hrr(:,[n-k+1:n]);
%Hstd = [Hstd,eye(n-k)];


end

