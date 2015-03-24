function slide_opti_comb()
close all

hFig = figure;
title('Mixer Output')
hAx = axes('Parent',hFig);

global my_global_val;
my_global_val = 1;

vec = opti_comb();

do_plot();
uicontrol('Parent',hFig, 'Style','slider', 'Value',0, 'Min',0,'Max',2, 'SliderStep',[1 10]./360,'Position',[150 5 300 20], 'Callback',@slider_callback);


function do_plot
    ts = [1:1:25001];
    plot(ts, vec, 'Parent',hAx);
%     figure;
%     surf(abs(xcorr3d_single(vec,vec,25000,60,3,32)),'EdgeColor','none','LineStyle','none');ylabel('freq'); xlabel('time');
    
end

function slider_callback(hObj, eventdata)
        my_global_val = get(hObj,'Value');
        vec = opti_comb();
        disp(get(hObj,'Value'));
        
%         plot(vec, 'Parent',hAx);
do_plot();
end

end