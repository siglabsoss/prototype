% Filters out spikes induced by ben's magic "tx/rx" sample switcher

vec;

i = 1;
spike_start = -1;

spike_thresh = 105; % anything over this is considered a tx/rx spike
spike_squelch = 25; % how many samples to squelch foward upon detection of a spike
spike_squelch_max = 90; % upper bound of how many samples to knock out
sig_thresh = 24;  % anything over this is considered a packet

while i <= length(vec)
%     disp(vec(i))
    
   
    if( abs(vec(i)) > sig_thresh-1 && spike_start == -1)
        spike_start = i;
    end
    
    % reset our trigger after the max samples
    if( i - spike_start > spike_squelch_max)
        spike_start = -1;
    end

%     find the tx/rx spikes
   if( abs(vec(i)) > spike_thresh && spike_start ~= -1)

       zs = i + spike_squelch - spike_start;
       zs = min(spike_squelch_max,zs)
%        disp(zs);
       
%        figure;
%        plot(vec(spike_squelch:spike_squelch+zs));
       vec(spike_start:spike_start+zs) = zeros(zs+1,1);
       i = i + spike_squelch;  % bump loop forward
       
       
       spike_start = -1;  % reset our detect
%        start = i;
%        
%        disp(vec(start));
%        ang = angle(vec(start))
%        disp(start);
%        break
   end
   
   i = i + 1;
end
