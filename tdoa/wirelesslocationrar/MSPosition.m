function X = MSPosition() 
%  ±¾³ÌÐòÔÚ1/12Ð¡ÇøÄÚËæ»ú²úÉúMSµÄÎ»ÖÃ£¬¼ÙÉèÐ¡Çø°ë¾¶Îª1 
%  MSPosition 
%    ²ÎÊýËµÃ÷£º 
%       ÎÞ²ÎÊý¡£ 
%  Also see: MSPosition. 
 
 
%  ²ÎÊý¼ì²â: 
 if  nargout>1, 
        error('Too many output arguments.'); 
 end 
 
% Ëæ»ú²úÉúÒÆ¶¯Ì¨Î»ÖÃ£º 
x = sqrt(3)*rand(1)/2; 
y = sqrt(3)*x*rand(1)/3; 
 
% ½á¹ûÊä³ö£º 
if nargout == 1, 
    X = [x, y]; 
else 
    disp([x, y]); 
end 