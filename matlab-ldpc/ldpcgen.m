function [ H ] = ldpcgen( n, k )
%LDPCGEN Summary of this function goes here
%   Detailed explanation goes here

rndstate = [4112460541 4144164702 676943031 2084672537];

width = n;
height = n-k;
elements = width*height;

H = zeros(height, width);

onerows = 6;
onecols = 6;

totalones = onerows*width + onecols*height;

%totalones = 22;

maxretry = 35;

retry = 0;
i = 1;
while i <= totalones
    [r,rndstate] = xor128(rndstate);
    r = mod(r, elements);
    
    
    % calculate x and y of picked location
    % this is tricky because it's 0 based
    x = mod(r,width) + 1;
    y = floor(r/(width)) + 1;
    
    %     disp(sprintf('r: %d x: %d y: %d',r,x, y));
    
    if( retry > maxretry )
        disp('Error: too many retries');
        i = totalones+1;
        continue;
    end
    
    if(sum(H(:,x)) >= onecols)
        retry = retry + 1;
        disp(sprintf('bump by col (%d)', i));
        continue;
    end
    
            % if there are too many ones on this row, try again
    if(sum(H(y,:)) >= onerows)
        retry = retry + 1;
        disp(sprintf('bump by row (%d)', i));
        continue;
    end
    

    

    
    
    
    retry = 0;
    H(y,x) = 1;
    i = i + 1;
end

% checks
% 
% Hrr = g2rref(H);
% Hl = Hrr(:,[1:height]);
% if( sum(sum(Hl ~= eye(height))) )
%     disp('Parity matrix H cannot be rrefd correctly');
% end
% 
% 
% G = ldpcpar2gen(H);
% gok = mod(G*H',2);
% if( sum(gok) ~= 0 )
%     disp('Parity matrix H does not have valid generator G');
% end







end

