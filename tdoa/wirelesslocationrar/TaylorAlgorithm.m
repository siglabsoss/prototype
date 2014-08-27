function X = TaylorAlgorithm(BSN, MSP, Radius, Noise) 
% 
%TAYLORALGORITHM ±¾º¯ÊýÓÃÓÚÊµÏÖÎÞÏß¶¨Î»ÖÐµÄTAYLORËã·¨ 
%               - BSN  Îª»ùÕ¾¸öÊý£¬3 < BSN <= 7£» 
%               - MSP  ÎªÒÆ¶¯Ì¨µÄ³õÊ¼Î»ÖÃ, MSx, MSy¾ùÎª[0,1]Ö®¼äµÄÊý£» 
%                      ÌØ±ðÒª×¢Òâ·þÎñÐ¡ÇøÓëMSÖ®¼äµÄ¹ØÏµ£¬MSµÄÎ»ÖÃ²»ÄÜÔ½½ç¡£ 
%               - Noise ²â¾àÎó²î·½²î£® 
%               - R    ÎªÐ¡Çø°ë¾¶£¬µ¥Î»(meter)£» 
%               - X    ÎªÒÆ¶¯Ì¨¾­Ëã·¨´¦ÀíºóµÄÎ»ÖÃ. 
%See also: TaylorAlgorithm.m 
 
 
% ²ÎÊý¼ì²é£º 
if  nargout ~= 1 & nargout ~= 0, 
    error('Too many output arguments.'); 
end 
if nargin ~= 4, 
    error('Wrong number of input arguments.'); 
end 
 
% ³õÊ¼²ÎÊý£º 
BS = Radius*NetworkTop(BSN); 
MS = Radius*MSP; 
 
% TDOAÐ­·½²î¾ØÕóQ£º 
Q = eye(BSN-1); 
     
% ³õÊ¼¹À¼ÆÎ»ÖÃ£º 
iEP = MS; 
 
% h0: 
for i = 1: BSN, 
    MeaDist(i) = sqrt((MS(1) - BS(1,i))^2 + (MS(2) - BS(2,i))^2); 
end 
for i = 1: BSN-1, 
    h0(i) = MeaDist(i+1) - MeaDist(1) + Noise*randn(1);   %TDOA²âÁ¿Öµ 
end 
 
% Ëã·¨¿ªÊ¼£º 
for n = 1: 10, 
    % Rn: 
    R1 = sqrt(iEP(1)^2 + iEP(2)^2); 
    for i =1: BSN-1, 
        R(i) = sqrt((iEP(1) - BS(1,i+1))^2 + (iEP(2) - BS(2,i+1))^2);         
    end 
     
    % ht: 
    for i = 1: BSN-1, 
        h(i) = h0(i) - (R(i) - R1); 
    end 
    ht = h'; 
     
    % Gt: 
    for i = 1: BSN-1, 
        Gt(i, 1) = -iEP(1)/R1 - (BS(1, i+1) - iEP(2))/R(i); 
        Gt(i, 2) = -iEP(2)/R1 - (BS(2, i+1) - iEP(2))/R(i); 
    end 
     
    % delt: 
    delt = inv(Gt'*inv(Q)*Gt)*Gt'*inv(Q)*ht; 
     
    EP = iEP + delt'; 
 
    iEP = EP; 
end 
 
% ½á¹ûÊä³ö: 
if nargout == 1, 
    X = EP; 
elseif nargout == 0, 
    disp(EP); 
end