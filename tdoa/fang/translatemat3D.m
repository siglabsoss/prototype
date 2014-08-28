function R = translatemat3D( M, vec )
%TRANSLATEMAT3D translate matrix M
%   See: http://en.wikipedia.org/wiki/Translation_(geometry)

    % tranlation matrix
    t = [eye(3) vec'; 0 0 0 1];

    % break cols out
    col1 = [M(1:3,1)' 1]';
    col2 = [M(1:3,2)' 1]';
    col3 = [M(1:3,3)' 1]';

    % apply transform
    col1 = t*col1;
    col2 = t*col2;
    col3 = t*col3;
    
    % reassemble
    R = [col1(1:3), col2(1:3), col3(1:3)];
    
end

