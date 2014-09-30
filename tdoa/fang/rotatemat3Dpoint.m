function R = rotatemat3Dpoint( deg, axis, M, P )
%   Cool but unused

% translate to origin
trans = translatemat3D(M, -P);

% get rotation transform
r1 = rotationmat3D(deg,axis);

% apply rotation transform
trans = r1*trans;

% translate back
R = translatemat3D(trans, P);

end

