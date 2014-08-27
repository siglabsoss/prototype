function X = LSAlgorithm_d(BSN, MSP, R, MeaDist) 
%CHANALGORITHM_D ±¾º¯ÊýÓÃÓÚÊµÏÖÎÞÏß¶¨Î»ÖÐµÄCHANËã·¨ 
%               - BSN  Îª»ùÕ¾¸öÊý£¬3 < BSN <= 7£» 
%               - MSP  ÎªÒÆ¶¯Ì¨µÄ³õÊ¼Î»ÖÃ, MSx, MSy¾ùÎª[0,1]Ö®¼äµÄÊý£» 
%                      ÌØ±ðÒª×¢Òâ·þÎñÐ¡ÇøÓëMSÖ®¼äµÄ¹ØÏµ£¬MSµÄÎ»ÖÃ²»ÄÜÔ½½ç¡£ 
%               - MeaDist ²âÁ¿¾àÀë²î¡£ 
%               - R    ÎªÐ¡Çø°ë¾¶£¬µ¥Î»(meter)£» 
%               - X    ÎªÒÆ¶¯Ì¨¾­Ëã·¨´¦ÀíºóµÄÎ»ÖÃ. 
%See also: ChanAlgorithm_d.m 
 
 
%   ²ÎÊý¼ì²é£º 
if  nargout>1, 
    error('Too many output arguments.'); 
end 
if nargin ~= 4, 
    error('Wrong number of input arguments.'); 
end 
 
 
% Ëã·¨¿ªÊ¼£º 
BS = R*NetworkTop(BSN); 
MS = R*MSP; 
 
% ÔëÉù¹¦ÂÊ£º 
Q = 0.5*eye(BSN-1); % TDOA²âÁ¿Îó²îµÄÐ­·½²î¾ØÕó 
 
% LS£º 
% Ri,Ki 
K1 = 0; 
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
 
% Êä³ö: 
out = [Za0(1),Za0(2)]; 
 
if nargout == 1, 
    X = out; 
elseif nargout == 0, 
    disp(out); 
end