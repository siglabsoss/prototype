function slide_opti_comb()
close all

surfFig = figure;
surf([1 2; 3 4]);

hFig = figure;
title('Mixer Output')
hAx = axes('Parent',hFig);

global my_global_val;
my_global_val = 1;

vec = opti_comb();

do_plot();
uicontrol('Parent',hFig, 'Style','slider', 'Value',0, 'Min',0,'Max',10, 'SliderStep',[1 10]./360,'Position',[150 5 300 20], 'Callback',@slider_callback);


function do_plot
    ts = [1:1:25001];

    plot(ts, real(vec), 'Parent',hAx);
    
    figure(surfFig);
    surf(abs(xcorr3d_single(vec,vec,25000,60,4,32)),'EdgeColor','none','LineStyle','none');ylabel('freq'); xlabel('time');
%     view(0,90); % top
    view(90,0); % top
    
end

function slider_callback(hObj, eventdata)
        my_global_val = get(hObj,'Value');
        vec = opti_comb();
        par = peak_ave_power(vec);
        disp(sprintf('slider %d', my_global_val));
        disp(sprintf('par %s', mat2str(par)));
        
        
%         plot(vec, 'Parent',hAx);
do_plot();
end

end