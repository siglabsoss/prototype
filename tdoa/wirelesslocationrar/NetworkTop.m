function X = NetworkTop(BSN) 
%  ±¾³ÌÐòÉú³ÉÍøÂçÍØÆË£¬¼ÙÉèÍøÂç°ë¾¶Îª1 
%  NetworkTop 
%    ²ÎÊýËµÃ÷£º 
%        BSN:   ·äÎÑÍøÂçÖÐ»ùÕ¾ÊýÄ¿ 3<=BSN<=7 
%  Also see: NetworkTop. 
 
 
%  ²ÎÊý¼ì²â: 
if nargout>1, 
    error('Too many output arguments!'); 
end  
if nargin ~= 1 
    error('input arguments error!'); 
end 
if BSN > 7 | BSN < 3, 
    error('Overflow!'); 
end 
 
% 7Ð¡ÇøÍøÂçÍØÆË£º 
BS = [0, sqrt(3), 0.5*sqrt(3), -0.5*sqrt(3), -sqrt(3), -0.5*sqrt(3), 0.5*sqrt(3); 
      0,        0,         1.5,          1.5,        0,         -1.5,        -1.5]; 
 
% BSN¸öÐ¡ÇøÍøÂçÍØÆË£º 
for i = 1 : BSN, 
    X(1,i) = BS(1,i); 
    X(2,i) = BS(2,i); 
end 
 
% ½á¹ûÊä³ö£º 
if nargout == 1, 
    X; 
else 
    disp(X); 
end 