function X = TaylorAlgorithm_d(BSN, MSP, Radius, Noise, MeaDist) 
% 
%TAYLORALGORITHM_D ±¾º¯ÊýÓÃÓÚÊµÏÖÎÞÏß¶¨Î»ÖÐµÄTAYLORËã·¨ 
%               - BSN  Îª»ùÕ¾¸öÊý£¬3 < BSN <= 7£» 
%               - MSP  ÎªÒÆ¶¯Ì¨µÄ³õÊ¼Î»ÖÃ, MSx, MSy¾ùÎª[0,1]Ö®¼äµÄÊý£» 
%                      ÌØ±ðÒª×¢Òâ·þÎñÐ¡ÇøÓëMSÖ®¼äµÄ¹ØÏµ£¬MSµÄÎ»ÖÃ²»ÄÜÔ½½ç¡£ 
%               - Noise ²â¾àÎó²î·½²î£® 
%               - R    ÎªÐ¡Çø°ë¾¶£¬µ¥Î»(meter)£» 
%               - MeaDist ²âÁ¿¾àÀë¡£ 
%               - X    ÎªÒÆ¶¯Ì¨¾­Ëã·¨´¦ÀíºóµÄÎ»ÖÃ. 
%See also: TaylorAlgorithm_d.m 
 
 
% ²ÎÊý¼ì²é£º 
if  nargout ~= 1 & nargout ~= 0, 
    error('Too many output arguments.'); 
end 
if nargin ~= 5, 
    error('Wrong number of input arguments.'); 
end 
 
% ³õÊ¼²ÎÊý£º 
BS = Radius*NetworkTop(BSN); 
MS = Radius*MSP; 
 
% TDOAÐ­·½²î¾ØÕóQ£º 
c = 3*10^8; % ÎÞÏßµç²¨´«²¥ËÙ¶È 
Q = 0.5*eye(BSN -1); % TDOA²âÁ¿Îó²îµÄÐ­·½²î¾ØÕó 
     
% ³õÊ¼¹À¼ÆÎ»ÖÃ£º 
iEP = MS; 
 
% h0: 
for i = 1: BSN-1, 
    h0(i) = MeaDist(i+1) - MeaDist(1); 
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
    delt = pinv(Gt'*pinv(Q)*Gt)*Gt'*pinv(Q)*ht; 
     
    EP = iEP + delt'; 
 
    iEP = EP; 
end 
 
% ½á¹ûÊä³ö: 
if nargout == 1, 
    X = EP; 
elseif nargout == 0, 
    disp(EP); 
end