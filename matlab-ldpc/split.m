function [ varargout  ] = split( v )
%SPLIT Splits a vector of bounded length into individual return variables.
% Split() can handle arbitrarily long input vectors @benathon
%
% http://stackoverflow.com/questions/25906833/matlab-multiple-variable-assignments
%
% Usage:
%  vec = [1 2 3 4 5];
%  [a,b,c,d,e] = split(vec);
%  [f,g]       = split(vec);

varargout = num2cell( v );