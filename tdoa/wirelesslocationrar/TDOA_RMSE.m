function X = TDOA_RMSE(MS, EMS) 
% 
%TDOA_RMSE ±¾º¯ÊýÓÃÓÚÊµÏÖÎÞÏß¶¨Î»¾«¶ÈRMSEµÄ¼ÆËã 
%               - MS  ÎªÒÆ¶¯Ì¨µÄÕæÊµÎ»ÖÃ£» 
%               - EMS ÎªÒÆ¶¯Ì¨µÄ¹À¼ÆÎ»ÖÃ¡£ 
%See also: TDOA_RMSE.m 
 
 
% ²ÎÊý¼ì²é£º 
if  nargout ~= 1 & nargout ~= 0, 
    error('Too many output arguments.'); 
end 
if nargin ~= 2, 
    error('Wrong number of input arguments.'); 
end 
 
% Ëã·¨¿ªÊ¼£º 
[n,m] = size(MS); 
 
% ¼ÆËã¾ù·½Îó²î×ÜºÍ£º 
sum = 0; 
for i = 1:n, 
    sum = (MS(i,1) - EMS(i,1))^2 + (MS(i,2) - EMS(i,2))^2 + sum; 
end 
 
% RMSE: 
RMSE = sqrt(sum/n); 
 
% ½á¹ûÊä³ö£º 
if nargout == 1, 
    X = RMSE; 
else 
    disp(RMSE); 
end 