vec;


for i = 1:length(vec)
%    disp(vec(i));

%     find where the mag peaks
   if( abs(vec(i)) > 60 )
      
       start = i-1;
       
       disp(vec(start));
       ang = angle(vec(start))
       disp(start);
       break
   end
end

ang = -1 * ang;

vec2 = vec .* exp(ang*pi*1j);

% no do a single xcorr to find the rotation