% {"method":"packet_rx","params":["gravitinointel7 ",1409023496,5742]}
% {"method":"packet_rx","params":["gravitinointel10",1409023496,6082]}
% {"method":"packet_rx","params":["gravitinointel9 ",1409023496,6188]}
% b7 -2700357.8812868893, -4288635.0159764756, 3859538.9663173491
% b9 -2700305.5929534282, -4288650.7464387724, 3859553.6845385805
% b10 -2700386.426912501, -4288613.4509271001, 3859542.929867378

% for smaller numbers
% b7   57, 35, 38
% b9   05, 50, 53
% b10  86, 13, 42

SA = [57;35;38];
SB = [05;50;53];
SC = [86;13;42];

a0 = SA(1);
a1 = SA(2);
a2 = SA(3);
b0 = SB(1);
b1 = SB(2);
b2 = SB(3);
c0 = SC(1);
c1 = SC(2);
c2 = SC(3);

% Change of basis translation
CBT = -SA;

SA = CBT + SA;
SB = CBT + SB;
SC = CBT + SC;


% don't care values
% x = 1;
% y = 1;
% z = 1;
% first go
% c00 = -(a1*(b2*y-c2*x)+a2*(c1*x-b1*y))/(a0*(b2*c1-b1*c2)+a1*(b0*c2-b2*c0)+a2*(b1*c0-b0*c1));
% c01 = (a0*(b2*y-c2*x)+a2*(c0*x-b0*y))/(a0*(b2*c1-b1*c2)+a1*(b0*c2-b2*c0)+a2*(b1*c0-b0*c1));
% c02 = -(a0*(b1*y-c1*x)+a1*(c0*x-b0*y))/(a0*(b2*c1-b1*c2)+a1*(b0*c2-b2*c0)+a2*(b1*c0-b0*c1));
% c10 = (a2*b1*z-a1*b2*z)/(a0*(b2*c1-b1*c2)+a1*(b0*c2-b2*c0)+a2*(b1*c0-b0*c1));
% c11 = -(a2*b0*z-a0*b2*z)/(a0*(b2*c1-b1*c2)+a1*(b0*c2-b2*c0)+a2*(b1*c0-b0*c1));
% c12 = (a1*b0*z-a0*b1*z)/(a0*(b2*c1-b1*c2)+a1*(b0*c2-b2*c0)+a2*(b1*c0-b0*c1));
% c20 = 0;
% c21 = 0;
% c22 = 0;

% z must be 0
% x = 1;
% y = 1;
% z = 0;
% fail
% c00=-(a1*(b2*y-c2*x)+a2*(c1*x-b1*y))/(a0*(b2*c1-b1*c2)+a1*(b0*c2-b2*c0)+a2*(b1*c0-b0*c1));
% c01=(a0*(b2*y-c2*x)+a2*(c0*x-b0*y))/(a0*(b2*c1-b1*c2)+a1*(b0*c2-b2*c0)+a2*(b1*c0-b0*c1));
% c02=-(a0*(b1*y-c1*x)+a1*(c0*x-b0*y))/(a0*(b2*c1-b1*c2)+a1*(b0*c2-b2*c0)+a2*(b1*c0-b0*c1));
% c10=(a2*b1-a1*b2)/(a0*(b2*c1-b1*c2)+a1*(b0*c2-b2*c0)+a2*(b1*c0-b0*c1));
% c11=-(a2*b0-a0*b2)/(a0*(b2*c1-b1*c2)+a1*(b0*c2-b2*c0)+a2*(b1*c0-b0*c1));
% c12=(a1*b0-a0*b1)/(a0*(b2*c1-b1*c2)+a1*(b0*c2-b2*c0)+a2*(b1*c0-b0*c1));
% c20=(a2*b1*z-a1*b2*z)/(a0*(b2*c1-b1*c2)+a1*(b0*c2-b2*c0)+a2*(b1*c0-b0*c1));
% c21=-(a2*b0*z-a0*b2*z)/(a0*(b2*c1-b1*c2)+a1*(b0*c2-b2*c0)+a2*(b1*c0-b0*c1));
% c22=(a1*b0*z-a0*b1*z)/(a0*(b2*c1-b1*c2)+a1*(b0*c2-b2*c0)+a2*(b1*c0-b0*c1));



%CB = [[c00 c01 c02];[c10 c11 c12];[c20 c21 c22]]


%cb = [[1 0 0];[0 1 0];[0 0 1]];
%c1 = [[57 0 0];[0 35 0];[0 0 38]];
%c2 = inv(c1);

% great, c3*SA = 0,0,0
% c3 = [[1 (-57/35) 0];[ (-73/57) 1  1];[0 (-38/35) 1]];
c3 = eye(3);

% check where SB lands
sb_xy = c3*SB;

% first rotate
r1deg = atan(sb_xy(2)/sb_xy(1));

% rotate about z so that the y component of SB will be 0
r1 = rotationmat3D(-r1deg,[0 0 1]);
c4 = r1 * c3;

% check where SB lands again
sb_xz = c4*SB;

% second rotate
r2deg = atan(sb_xz(3)/sb_xz(1));
% (sb was ending up negative, so this fixes)
r2deg = r2deg + pi;

r2 = rotationmat3D(r2deg,[0 1 0]);
c5 = r2 * c4;

% check where SC lands
sc_z = c5*SC;

% 3rd rotate
r3deg = atan(sc_z(3)/sc_z(2));
r3 = rotationmat3D(-r3deg,[1 0 0]);
c6 = r3 * c5;



