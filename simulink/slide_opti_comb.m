function slide_opti_comb()
close all

surfFig = figure;
surf([1 2; 3 4]);

toneSurfFig = figure;
surf([1 2; 3 4]);


hFig = figure;
title('Mixer Output')
hAx = axes('Parent',hFig);

global my_global_val;
global my_global_val2;
my_global_val = 1;
my_global_val2 = 1;

vec = opti_comb5();

global slide_comb_length;
slide_comb_length = 2500;

fs = 1000;



do_plot();
uicontrol('Parent',hFig, 'Style','slider', 'Value',0, 'Min',-100,'Max',100, 'SliderStep',[1 10]./360,'Position',[150 25 300 20], 'Callback',@slider_callback);
uicontrol('Parent',hFig, 'Style','slider', 'Value',0, 'Min',-100,'Max',100, 'SliderStep',[1 10]./360,'Position',[150 5 300 20], 'Callback',@slider_callback2);


function do_plot
    
    ts = [1:1:slide_comb_length];

    plot(ts, real(vec), 'Parent',hAx);
    
%   make a pure tone
    pureTone = freq_shift(ones(1,slide_comb_length)', fs, 1);
    
    % slide against pure tone
%     figure(toneSurfFig);
     toneXcr = xcorr3d_single(vec,pureTone,fs,100,1,200);
%     surf(abs(toneXcr),'EdgeColor','none','LineStyle','none');ylabel('freq'); xlabel('time');
%     view(-160,58);
    
    
    % slide against self
    figure(surfFig);
    autoXcr = xcorr3d_single(vec,vec,fs,10,0.1,10);
    surf(abs(autoXcr),'EdgeColor','none','LineStyle','none');ylabel('freq'); xlabel('time');
%     view(114,40); % side ish view
%    view(91,68);
%      view(0,90); % top
     view(90,0); % freq view
%     view(-130,35) % side ish view
    
    disp(sprintf('max auto %d max tone %d', max(max(abs(autoXcr))), max(max(abs(toneXcr)))));
    disp(sprintf('delta performance over sin %d', int32(max(max(abs(autoXcr))) - max(max(abs(toneXcr))))));
    
    
    % break here, rotate surf, then run [az,el] = view; to save good view
    az = 0;
    el = 0;
    
    save('slide_comb.mat','vec');
%     fplot(vec);
    
end

function slider_callback(hObj, eventdata)
    my_global_val = get(hObj,'Value');
    vec = opti_comb5();
    par = peak_ave_power(vec)
    disp(sprintf('slider1 %d', my_global_val));
    do_plot();
end

function slider_callback2(hObj, eventdata)
    my_global_val2 = get(hObj,'Value');
    vec = opti_comb5();
    par = peak_ave_power(vec)
    disp(sprintf('slider2 %d', my_global_val2));
    do_plot();
end

end