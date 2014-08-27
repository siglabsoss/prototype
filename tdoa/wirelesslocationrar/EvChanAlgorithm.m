function X = EvChanAlgorithm(BSN, MSP, R, Noise) 
%EvChanAlgorithm ÊµÏÖ¸Ä½øChanËã·¨ 
%EVCHANALGORITHM ±¾º¯ÊýÓÃÓÚÊµÏÖÎÞÏß¶¨Î»ÖÐµÄCHANËã·¨ 
%               - BSN  Îª»ùÕ¾¸öÊý£¬3 < BSN <= 7£» 
%               - MSP  ÎªÒÆ¶¯Ì¨µÄ³õÊ¼Î»ÖÃ, MSx, MSy¾ùÎª[0,1]Ö®¼äµÄÊý£» 
%                      ÌØ±ðÒª×¢Òâ·þÎñÐ¡ÇøÓëMSÖ®¼äµÄ¹ØÏµ£¬MSµÄÎ»ÖÃ²»ÄÜÔ½½ç¡£ 
%               - Noise ²â¾àÎó²î·½²î¡£ 
%               - R    ÎªÐ¡Çø°ë¾¶£¬µ¥Î»(meter)£» 
%               - X    ÎªÒÆ¶¯Ì¨¾­Ëã·¨´¦ÀíºóµÄÎ»ÖÃ. 
%See also: EvChanAlgorithm.m 
 
 
%   ²ÎÊý¼ì²é£º 
if  nargout>1, 
    error('Too many output arguments.'); 
end 
if nargin ~= 4, 
    error('Wrong number of input arguments.'); 
end 
 
% Ëã·¨¿ªÊ¼ 
MS = R*MSP; 
BS = R*NetworkTop(BSN); 
 
% MeaDist 
for i = 1: BSN, 
    MeaDist(i) = sqrt((MS(1) - BS(1,i))^2 + (MS(2) - BS(2,i))^2) + MeaNoise(Noise); 
end 
 
% Chan¡¢Taylor¹À¼ÆÎ»ÖÃ 
EMSC = ChanAlgorithm_d(BSN, MSP, R, Noise,MeaDist); 
EMSTC = TaylorAlgorithm_d(BSN, EMSC'/R, R, Noise, MeaDist); 
EMSTC = EMSTC'; 
 
% ²Ð²î 
ResC = Residual(MeaDist,EMSC,BSN,R); 
ResTC = Residual(MeaDist,EMSTC,BSN,R); 
 
% ¹À¼ÆÎ»ÖÃ 
EMS = (EMSC/ResC + EMSTC/ResTC)/(1/ResC + 1/ResTC); 
 
% ½á¹ûÊä³ö 
if nargout == 1, 
    X = EMS; 
elseif nargout == 0, 
    disp(EMS); 
end