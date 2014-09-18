function [ o1, o2, o3, o4, o5, o6, o7, o8 ] = split( v )
%SPLIT Splits a vector of bounded length into individual return variables.
% Split() can handle arbitrarily long input vectors, but only a fixed
% number of output variables.  @benathon
%
% Usage:
%  vec = [1 2 3 4 5];
%  [a,b,c,d,e] = split(vec);
%  [f,g]       = split(vec);

% If you would like to upgrade split() to handle more output variables,
% simply add more output variables to the function definition and
% then change this variable
maxout = 8;

[~,n] = size(v);

if n < nargout
    error('input vector too short for number of output arguments');
end

% we only need to assign this many output variables
iterations = min(n,nargout);


% Matlab catches "Too many output arguments." before we can
%if( iterations > maxout )
%    error('Too many output, edit split.m to easily upgrade');
%end


i = 1;
while i <= iterations
    expression = sprintf('o%d=v(%d);', i, i);
    eval(expression);
    i = i + 1;
end
