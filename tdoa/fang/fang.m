% {"method":"packet_rx","params":["gravitinointel7 ",1409023496,5742]}
% {"method":"packet_rx","params":["gravitinointel9 ",1409023496,6188]}
% {"method":"packet_rx","params":["gravitinointel10",1409023496,6082]}
% b7 -2700357.8812868893, -4288635.0159764756, 3859538.9663173491
% b9 -2700305.5929534282, -4288650.7464387724, 3859553.6845385805
% b10 -2700386.426912501, -4288613.4509271001, 3859542.929867378

% for smaller numbers
% b7   57, 35, 38
% b9   05, 50, 53
% b10  86, 13, 42

% BS positions
% SA = [05;50;53];
% SB = [57;35;38];
% SC = [86;13;42];

%
SA = [-2700305.5929534282;-4288650.7464387724;3859553.6845385805];  %b9
SB = [-2700357.8812868893;-4288635.0159764756;3859538.9663173491];  %b7
SC = [-2700386.426912501;-4288613.4509271001;3859542.929867378];    %b10


% BS arrival times
Ta = 6188 / 48000000; %b9
Tb = 5742 / 48000000; %b7
Tc = 6082 / 48000000; %b10

% Change of basis translation
CBT = -SA;

% apply translation transform
SA = CBT + SA;
SB = CBT + SB;
SC = CBT + SC;

% Calculate rotation matrix, also known as a change of basis matrix,
%  starting with identiy
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
CB = r3 * c5;
%%%%  Finish calculate rotation

% apply CB

SA = CB*SA;
SB = CB*SB;
SC = CB*SC;

% force
SB(2) = 0;
SB(3) = 0;
SC(3) = 0;



% constants
% speedo light
V = 299792458.0;


% shortcuts
b = SB(1);   % distance of SB to SA
cx = SC(1);
cy = SC(2);

% some basics
c = sqrt(cx^2 + cy^2);  % distance of SC to SA
Tab = Ta - Tb;
Tac = Ta - Tc;
Rab = V * Tab;
Rac = V * Tac;




% from the PDF, calculate d,e,f,g,h

g = (Rac * (b / Rab) - cx) / cy;
h = (c^2 - Rac^2 + Rac*Rab*(1-(b/Rab)^2))/(2*cy);
d = -(1-(b/Rab)^2+g^2) ;
e = b*(1-(b/Rab)^2)-2*g*h;
f = (Rab^2/4) * (1-(b/Rab)^2)^2 - h^2;


% use (20) to calculate coefficients for quartic

% altitude above station plane
altitude = 10; % best guess (meters)

z = altitude;


x1 = -(sqrt(4*d*z^2-4*d*f+e^2)+e)/(2*d);
x2 = (sqrt(4*d*z^2-4*d*f+e^2)-e)/(2*d);

% choice
x = x2;

y = g * x + h;
z1 = sqrt(d*x^2+e*x+f);
z2 = -z1;

% choice
z = z1;








% wgs84

% meters
wa = 6378137.0;
wb = 6356752.3142451794975639665996337;
% focal length
wf = sqrt(wa^2-wb^2);






