function X = ChanAlgorithm_d(BSN, MSP, R, Noise, MeaDist) 
%CHANALGORITHM_D ±¾º¯ÊýÓÃÓÚÊµÏÖÎÞÏß¶¨Î»ÖÐµÄCHANËã·¨ 
%               - BSN  Îª»ùÕ¾¸öÊý£¬3 < BSN <= 7£» 
%               - MSP  ÎªÒÆ¶¯Ì¨µÄ³õÊ¼Î»ÖÃ, MSx, MSy¾ùÎª[0,1]Ö®¼äµÄÊý£» 
%                      ÌØ±ðÒª×¢Òâ·þÎñÐ¡ÇøÓëMSÖ®¼äµÄ¹ØÏµ£¬MSµÄÎ»ÖÃ²»ÄÜÔ½½ç¡£ 
%               - Noise ²â¾àÎó²î·½²î¡£ 
%               - MeaDist ²âÁ¿¾àÀë²î¡£ 
%               - R    ÎªÐ¡Çø°ë¾¶£¬µ¥Î»(meter)£» 
%               - X    ÎªÒÆ¶¯Ì¨¾­Ëã·¨´¦ÀíºóµÄÎ»ÖÃ. 
%See also: ChanAlgorithm_d.m 
 
 
%   ²ÎÊý¼ì²é£º 
if  nargout>1, 
    error('Too many output arguments.'); 
end 
if nargin ~= 5, 
    error('Wrong number of input arguments.'); 
end 
 
 
% Ëã·¨¿ªÊ¼£º 
BS = R*NetworkTop(BSN); 
MS = R*MSP; 
 
% ÔëÉù¹¦ÂÊ£º 
c = 3*10^8; % ÎÞÏßµç²¨´«²¥ËÙ¶È 
Q = 0.5*eye(BSN-1); % TDOA²âÁ¿Îó²îµÄÐ­·½²î¾ØÕó 
 
% µÚÒ»´ÎLS£º 
% Ri 
R1 = sqrt(MS(1)^2 + MS(2)^2); 
K1 = 0; 
for i = 1: BSN-1, 
    R0(i) = sqrt((BS(1,i+1) - MS(1))^2 + (BS(2,i+1) - MS(2))^2); 
end 
 
for i = 1: BSN-1, 
    R(i) = MeaDist(i+1) - MeaDist(1); 
    K(i) = BS(1,i+1)^2 + BS(2,i+1)^2; 
end 
 
% Ga 
for i = 1: BSN-1, 
    Ga(i,1) = -BS(1, i+1); 
    Ga(i,2) = -BS(2, i+1); 
    Ga(i,3) = -R(i); 
end 
 
% h 
for i = 1: BSN-1, 
    h(i) = 0.5*(R(i)^2 - K(i) + K1); 
end 
 
% ÓÉ£¨14b£©¸ø³öBµÄ¹À¼ÆÖµ£º 
Za0 = pinv(Ga'*pinv(Q)*Ga)*Ga'*pinv(Q)*h'; 
 
% ÀûÓÃÕâ¸ö´ÖÂÔ¹À¼ÆÖµ¼ÆËãB£º 
B = eye(BSN-1); 
for i = 1: BSN-1, 
    B(i,i) = sqrt((BS(1,i+1) - Za0(1))^2 + (BS(2,i+1) - Za0(2))^2); 
end 
 
% mFI: 
mFI = B*Q*B; 
 
% µÚÒ»´ÎLS½á¹û£º 
Za1 = pinv(Ga'*pinv(mFI)*Ga)*Ga'*pinv(mFI)*h'; 
 
if Za1(3) < 0, 
    Za1(3) = abs(Za1(3)); 
end 
 
%*************************************************************** 
 
% µÚ¶þ´ÎLS£º 
% µÚÒ»´ÎLS½á¹ûµÄÐ­·½²î£º 
CovZa = pinv(Ga'*pinv(mFI)*Ga); 
 
% sB£º 
sB = eye(3); 
for i = 1: 3, 
    sB(i,i) = Za1(i); 
end; 
 
% sFI£º 
sFI = 4*sB*CovZa*sB; 
 
% sGa£º 
sGa = [1, 0; 0, 1; 1, 1]; 
 
% sh 
sh  = [Za1(1)^2; Za1(2)^2; Za1(3)^2]; 
 
% µÚ¶þ´ÎLS½á¹û£º 
Za2 = pinv(sGa'*pinv(sFI)*sGa)*sGa'*pinv(sFI)*sh; 
 
% Êä³ö: 
Za = sqrt(abs(Za2)); 
 
out = Za; 
 
if nargout == 1, 
    X = out; 
elseif nargout == 0, 
    disp(out); 
end
