%todo:
%remember to try this with sliding phase, live sliders if possible.
function beatfreqsmix ()
close all
timeseries = 0:0.00001:1;
f1 = 50;
f2 = 70;
a1 = 0;
a2 = 0;
freq1 = sin(2*pi*f1*timeseries+a1);
freq2 = sin(2*pi*f2*timeseries+a2);
beat1 = sin(2*pi*((f1+f2)/2)*timeseries-(a1+a2)/2);
beat2 = cos(2*pi*((f1-f2)/2)*timeseries-(a1-a2)/2);
subplot 311
plot(timeseries, freq1);
title('freq1')
subplot 312
plot(timeseries, freq2);
title('freq2')
subplot 313
plot(timeseries, freq1+freq2);
title('baseband sum')
hold on
plot(timeseries, beat1, 'g:')
plot(timeseries, beat2, 'm:')

freqbb=freq1+freq2;


f3 = 60;
a3 = 0;
freq3 = sin(2*pi*f3*timeseries + a3);


mfreq1 = freq3.*freq1;
mfreq2 = freq3.*freq2;
mfreq12 = freq3.*(freq1+freq2);
%mfreqcalc = 0.5*(cos(2*pi*timeseries*(f1-f3)+a1-a3) - cos(2*pi*timeseries*(f1+f3)+a1+a3) + cos(2*pi*timeseries*(f2-f3)+a2-a3) - cos(2*pi*timeseries*(f2+f3)+a2+a3));
mfreqcalc = cos(2*pi*timeseries*(f1+f2-2*f3)/2 + (a1+a2-2*a3)/2).*cos(2*pi*timeseries*(f1-f2)/2 + (a1-a2)/2)-cos(2*pi*timeseries*(f1+f2+2*f3)/2 + (a1+a2+2*a3)/2).*cos(2*pi*timeseries*(f1-f2)/2 + (a1-a2)/2);

%freq3 = sin(2*pi*f3*timeseries+a3).*freqbb;

figure
subplot 211
plot(timeseries, freq3.*freq1)
title('1st mix')
subplot 212
plot(timeseries, 0.5*(cos(2*pi*timeseries*(f1-f3)+a1-a3) - cos(2*pi*timeseries*(f1+f3)+a1+a3)))
title('calc 1st mix')

figure
subplot 211
plot(timeseries, freq3.*freq2)
title('2nd mix')
subplot 212
plot(timeseries, 0.5*(cos(2*pi*timeseries*(f3-f2)+a2-a3) - cos(2*pi*timeseries*(f3+f2)+a2+a3)))
title('calc 2nd mix')

figure
plot(timeseries, 0.5*(cos(2*pi*timeseries*(f1-f3)+a1-a3) - cos(2*pi*timeseries*(f1+f3)+a1+a3))+0.5*(cos(2*pi*timeseries*(f3-f2)+a2-a3) - cos(2*pi*timeseries*(f3+f2)+a2+a3)))

figure
subplot 311
plot(timeseries,mfreq1+mfreq2)
title('sum of mixes')
subplot 312
plot(timeseries,mfreq12)
title('mix of sums')
subplot 313
plot(timeseries,mfreqcalc)
title('calculated mix')

figure
subplot 411
a3=0;
mfreqcalc2 = cos(2*pi*timeseries*(f1+f2-2*f3)/2 + (a1+a2-2*a3)/2).*cos(2*pi*timeseries*(f1-f2)/2 + (a1-a2)/2)-cos(2*pi*timeseries*(f1+f2+2*f3)/2 + (a1+a2+2*a3)/2).*cos(2*pi*timeseries*(f1-f2)/2 + (a1-a2)/2);
title('phase3=0')
plot(timeseries, mfreqcalc2)
hold on
plot(timeseries, cos(2*pi*timeseries*(f1-f2)/2 + (a1-a2)/2),'m:')
title('phase3=0')
subplot 412
a3=pi/2;
mfreqcalc2 = cos(2*pi*timeseries*(f1+f2-2*f3)/2 + (a1+a2-2*a3)/2).*cos(2*pi*timeseries*(f1-f2)/2 + (a1-a2)/2)-cos(2*pi*timeseries*(f1+f2+2*f3)/2 + (a1+a2+2*a3)/2).*cos(2*pi*timeseries*(f1-f2)/2 + (a1-a2)/2);
plot(timeseries, mfreqcalc2)
hold on
plot(timeseries, cos(2*pi*timeseries*(f1-f2)/2 + (a1-a2)/2),'m:')
title('phase3=pi/2')
subplot 413
a3=pi;
mfreqcalc2 = cos(2*pi*timeseries*(f1+f2-2*f3)/2 + (a1+a2-2*a3)/2).*cos(2*pi*timeseries*(f1-f2)/2 + (a1-a2)/2)-cos(2*pi*timeseries*(f1+f2+2*f3)/2 + (a1+a2+2*a3)/2).*cos(2*pi*timeseries*(f1-f2)/2 + (a1-a2)/2);
plot(timeseries, mfreqcalc2)
hold on
plot(timeseries, cos(2*pi*timeseries*(f1-f2)/2 + (a1-a2)/2),'m:')
title('phase3=pi')
subplot 414
a3=3*pi/4;
mfreqcalc2 = cos(2*pi*timeseries*(f1+f2-2*f3)/2 + (a1+a2-2*a3)/2).*cos(2*pi*timeseries*(f1-f2)/2 + (a1-a2)/2)-cos(2*pi*timeseries*(f1+f2+2*f3)/2 + (a1+a2+2*a3)/2).*cos(2*pi*timeseries*(f1-f2)/2 + (a1-a2)/2);
plot(timeseries, mfreqcalc2)
hold on
plot(timeseries, cos(2*pi*timeseries*(f1-f2)/2 + (a1-a2)/2),'m:')
title('phase3=3pi/4')

hFig = figure;
title('Mixer Output')
hAx = axes('Parent',hFig);
axis(hAx,[0 1 -2 2])
timeshift = 0;
freq1 = sin(2*pi*f1*(timeseries+timeshift)+a1);
freq2 = sin(2*pi*f2*(timeseries+timeshift)+a2);
freq3 = sin(2*pi*f3*timeseries+a3);
outputmix = (freq3.*(freq1+freq2));
%outputmix = cos(2*pi*timeseries*(f1+f2-2*f3)/2 + (a1+a2-2*a3)/2).*cos(2*pi*timeseries*(f1-f2)/2 + (a1-a2)/2)-cos(2*pi*timeseries*(f1+f2+2*f3)/2 + (a1+a2+2*a3)/2).*cos(2*pi*timeseries*(f1-f2)/2 + (a1-a2)/2);
plot(timeseries, outputmix, 'Parent',hAx)
uicontrol('Parent',hFig, 'Style','slider', 'Value',0, 'Min',0,'Max',360, 'SliderStep',[1 10]./360,'Position',[150 5 300 20], 'Callback',@slider_callback);
uicontrol('Parent',hFig, 'Style','slider', 'Value',0, 'Min',0,'Max',1, 'SliderStep',[1 10]./1000,'Position',[150 30 300 20], 'Callback',@slider_callback2); 
hTxt = uicontrol('Style','text', 'Position',[500 28 20 15], 'String','0°');
hTxt2 = uicontrol('Style','text', 'Position',[500 48 40 20], 'String','0s');


function slider_callback(hObj, eventdata)
        angle = round(get(hObj,'Value'));        %# get rotation angle in degrees
        a3 = 2*pi*angle/360; %radians
        freq1 = sin(2*pi*f1*(timeseries+timeshift)+a1);
        freq2 = sin(2*pi*f2*(timeseries+timeshift)+a2);
        freq3 = sin(2*pi*f3*timeseries+a3);
        outputmix = (freq3.*(freq1+freq2));
        plot(timeseries, outputmix, 'Parent',hAx)  %# replot image
        hold on
        %plot(timeseries, cos(2*pi*timeseries*(f1-f2)/2 + (a1-a2)/2),'m:')
        hold off
        axis(hAx,[0 1 -2 2])
        set(hTxt, 'String',[num2str(angle) '°'])       %# update text
end


function slider_callback2(hObj, eventdata)
        timeshift = get(hObj,'Value');        %# get rotation angle in degrees
        freq1 = sin(2*pi*f1*(timeseries+timeshift)+a1);
        freq2 = sin(2*pi*f2*(timeseries+timeshift)+a2);
        freq3 = sin(2*pi*f3*timeseries+a3);
        outputmix = (freq3.*(freq1+freq2));
        plot(timeseries, outputmix, 'Parent',hAx)  %# replot image
        hold on
        %plot(timeseries, cos(2*pi*timeseries*(f1-f2)/2 + (a1-a2)/2),'m:')
        hold off
        axis(hAx,[0 1 -2 2])
        set(hTxt2, 'String',[num2str(timeshift) 's'])       %# update text
end

end

      


%{
mfreq1 = freq3.*freq1;
mfreq2 = freq3.*freq2;
mfreq12 = freq3.*(freq1+freq2);
figure
subplot 321
plot(timeseries, real(mfreq1))
subplot 322
plot(abs(fftshift(fft(mfreq1))))
subplot 323
plot(timeseries, real(mfreq2))
subplot 324
plot(abs(fftshift(fft(mfreq2))))
subplot 325
plot(timeseries, real(mfreq12))
subplot 326
plot(abs(fftshift(fft(mfreq12))))
figure
plot(angle(fftshift(fft(mfreq12))))
%}