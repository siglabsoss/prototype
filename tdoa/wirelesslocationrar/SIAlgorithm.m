function X = SIAlgorithm(BSN, MSP, Radius, Noise) 
%SIALGORITHM ±¾º¯ÊýÓÃÓÚÊµÏÖÎÞÏß¶¨Î»ÖÐµÄSIËã·¨ 
%               - BSN  Îª»ùÕ¾¸öÊý£¬3 < BSN <= 7£» 
%               - MSP  ÎªÒÆ¶¯Ì¨µÄ³õÊ¼Î»ÖÃ, MSx, MSy¾ùÎª[0,1]Ö®¼äµÄÊý£» 
%                      ÌØ±ðÒª×¢Òâ·þÎñÐ¡ÇøÓëMSÖ®¼äµÄ¹ØÏµ£¬MSµÄÎ»ÖÃ²»ÄÜÔ½½ç¡£ 
%               - Noise ²â¾àÎó²î·½²î¡£ 
%               - R    ÎªÐ¡Çø°ë¾¶£¬µ¥Î»(meter)£» 
%               - X    ÎªÒÆ¶¯Ì¨¾­Ëã·¨´¦ÀíºóµÄÎ»ÖÃ. 
%See also: SIAlgorithm.m 
 
 
%   ²ÎÊý¼ì²é£º 
if  nargout>1, 
    error('Too many output arguments.'); 
end 
if nargin<2 | nargin>4, 
    error('Wrong number of input arguments.'); 
end 
if BSN < 3, 
    error('The number of BSs must be larger than 3 for this program.'); 
end 
flag = size(MSP); 
if flag(1)~=1 | flag(2)~=2, 
    error('Wrong position vector!'); 
end 
 
% ³õÊ¼²ÎÊý£º 
BS = Radius*NetworkTop(BSN); 
MS = Radius*MSP; 
 
% % TDOAÐ­·½²î¾ØÕóQ£º 
% c = 3*10^8; % ÎÞÏßµç²¨´«²¥ËÙ¶È 
% Dev = Noise/(c*c); % TDOA²âÁ¿Îó²î·½²î 
 
% Ri1 
R1 = sqrt(MS(1)^2 + MS(2)^2); 
for i = 1: BSN-1, 
    R(i) = sqrt((BS(1, i+1) - MS(1))^2 + (BS(2, i+1) - MS(2))^2); 
end 
for i = 1: BSN-1, 
    Ri1(i) = R(i) - R1 + Noise*randn(1); 
end 
     
% W 
W = eye(BSN-1); 
 
% delt 
for i = 1: BSN-1, 
    K(i) = BS(1, i+1)^2 + BS(2, i+1)^2; 
end 
for i = 1: BSN-1, 
    delt(i) = K(i) - Ri1(i)^2; 
end 
 
% Pd orthognol 
I = eye(BSN-1); 
coef = Ri1*Ri1'; 
Pd_o = I - (Ri1'*Ri1/coef); 
     
% S 
for i = 1: BSN-1, 
    S(i, 1) = BS(1, i+1); 
    S(i, 2) = BS(2, i+1); 
end 
 
% Êä³ö£º 
    Za = 0.5*inv(S'*Pd_o*W*Pd_o*S)*S'*Pd_o*W*Pd_o*delt'; 
if nargout == 1, 
    X = Za; 
elseif nargout == 0, 
    disp(Za); 
end