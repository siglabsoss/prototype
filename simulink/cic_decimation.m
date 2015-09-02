function [ dout ] = cic_decimation( din, factor )
%CIC_DECIMATION Summary of this function goes here
%   Detailed explanation goes here


integrators = zeros(factor,1);
derivator = zeros(factor,1);
sz = length(din);
switcher = 1;
switcher_prev = 0;
switcher_prev_prev = 0;

dout = zeros(floor(sz/factor),1);

% integrators

for j=1:sz
    samp = din(j);
    
    integrators(1) = integrators(1) + samp;
    for i = 2:factor
        integrators(i) = integrators(i-1) + integrators(i);
    end
    

    % only run derivator section when switch provides a sample
    if( mod(switcher,factor) == factor-1 )
    
        derivator(1) = integrators(factor) - switcher_prev;

%         switcher_prev_prev = switcher_prev;
        switcher_prev = integrators(factor);
        
        % iterate backwards because signal propigates forwards
        for i = 2:factor
            derivator(i) = derivator(i-1) - derivator(i);
        end
        
        sampout = derivator(factor);
        
        dout(floor(j/2)+1) = sampout; % pump into output
        
%         integrators
%         derivator
        
        
    end
    
    switcher = switcher + 1;
    
end

end

