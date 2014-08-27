function X = MeaNoise(Noise) 
%  ±¾³ÌÐòÉú³É²â¾àÔëÉù£¬·þ´Ó¸ßË¹·Ö²¼ 
%  MeaNoise 
%    ²ÎÊýËµÃ÷£º 
%        Noise:   ¸ßË¹·Ö²¼·½²î³ËÒÔ¹âËÙÆ½·½µÄ½á¹û 
%  Also see: MeaNoise. 
 
 
%  ²ÎÊý¼ì²â: 
if nargout>1, 
    error('Too many output arguments!'); 
end  
if nargin ~= 1 
    error('input arguments error!'); 
end 
 
% ²â¾àÎó²î·½²î£º 
Dev = Noise; 
 
% ²â¾àÎó²î£º 
X = sqrt(Dev)*randn(1); 
 
% ½á¹ûÊä³ö£º 
if nargout == 1, 
    X; 
else 
    disp(X); 
end 