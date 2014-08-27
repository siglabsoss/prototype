function X = Chan_3BS(MSP,R,Noise) 
%   Chan Ëã·¨£¬ÀûÓÃ3BS¶ÔMS½øÐÐ¶¨Î»£» 
%   CHAN_3BS: 
%       ²ÎÊýËµÃ÷£º 
%       Noise:   ²â¾àÎó²î·½²î. 
%           R£º  Ð¡Çø°ë¾¶. 
%  Also see: Chan_3BS. 
 
 
%  ²ÎÊý¼ì²â: 
if nargout ~=1, 
    error('Too many output arguments!'); 
end  
if nargin ~= 3, 
    error('input arguments error!'); 
end 
 
%  Ëã·¨¿ªÊ¼ 
MS = R*MSP; 
BS = R*NetworkTop(3); 
 
% A¾ØÕó: 
X21 = BS(1,2) - BS(1,1); 
X31 = BS(1,3) - BS(1,1); 
Y21 = BS(2,2) - BS(2,1); 
Y31 = BS(2,3) - BS(2,1); 
A = inv([X21,Y21;X31,Y31]); 
 
% B¾ØÕó: 
R1 = sqrt((BS(1,1) - MS(1))^2 + (BS(2,1) - MS(2))^2); 
R2 = sqrt((BS(1,2) - MS(1))^2 + (BS(2,2) - MS(2))^2); 
R3 = sqrt((BS(1,3) - MS(1))^2 + (BS(2,3) - MS(2))^2); 
 
R21 = R2 - R1 + MeaNoise(Noise);  % ÐèÒª¼ÓÔëÉù 
R31 = R3 - R1 + MeaNoise(Noise); 
B = [R21;R31]; 
 
% C¾ØÕó: 
K1 = BS(1,1)^2 + BS(2,1)^2; 
K2 = BS(1,2)^2 + BS(2,2)^2; 
K3 = BS(1,3)^2 + BS(2,3)^2; 
C = 0.5*[R21^2 - K2 + K1; R31^2 - K3 + K1]; 
 
% Ò»Ôª¶þ´Î·½³ÌµÄÏµÊý£º 
a = B'*A'*A*B - 1; 
b = B'*A'*A*C + C'*A'*A*B; 
c = C'*A'*A*C; 
 
% ·½³ÌµÄÁ½¸ö¸ù£º 
root1 = abs((-b + sqrt(b^2 - 4*a*c))/(2*a)); 
root2 = abs((-b - sqrt(b^2 - 4*a*c))/(2*a)); 
 
% ¼ìÑé·½³ÌµÄ¸ù£º 
if root1 < R, 
    EMS = -A*(B*root1 + C); 
else 
    EMS = -A*(B*root2 + C); 
end 
 
% Êä³ö½á¹û£º 
if nargout == 1, 
    X = EMS; 
else 
    disp(EMS); 
end