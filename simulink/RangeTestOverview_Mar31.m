%wrapper of wrapper for generating a summary of the rangetest results
%clear all
close all

%DO IT FOR THE CLOCK COMB

%{
load('mar31a.mat','parkingclock')
RANGETEST_CLOCK_SUMMARY(1,:) = rangetest_summary_clock(parkingclock, 0, 0);
close all
clear parkingclock
load('mar31a.mat','movingclock')
RANGETEST_CLOCK_SUMMARY(2,:) = rangetest_summary_clock(movingclock, 0.5, 0);
close all
clear movingclock
load('mar31a.mat','sequoiaclock')
RANGETEST_CLOCK_SUMMARY(3,:) = rangetest_summary_clock(sequoiaclock, 1.97, 0);
close all
clear sequoiaclock
load('mar31b.mat','stcarlostrainclock')
RANGETEST_CLOCK_SUMMARY(4,:) = rangetest_summary_clock(stcarlostrainclock, 4.1, 0);
close all
clear stcarlostrainclock
load('mar31b.mat','oneilclock')
RANGETEST_CLOCK_SUMMARY(5,:) = rangetest_summary_clock(oneilclock, 5.14, 0);
close all
clear oneilclock
load('mar31d.mat','parkingclock2')
RANGETEST_CLOCK_SUMMARY(6,:) = rangetest_summary_clock(parkingclock2, 0, 0);
close all
clear parkingclock2
load('mar31d.mat','ruthandelcaminoclock2')
RANGETEST_CLOCK_SUMMARY(7,:) = rangetest_summary_clock(ruthandelcaminoclock2, 6.1, 0);
close all
clear ruthandelcaminoclock2
load('mar31e.mat','hillsdalecaltrainclock')
RANGETEST_CLOCK_SUMMARY(8,:) = rangetest_summary_clock(hillsdalecaltrainclock, 6.97, 0);
close all
clear hillsdalecaltrainclock
load('mar31e.mat','haywardcaltrainclock')
RANGETEST_CLOCK_SUMMARY(9,:) = rangetest_summary_clock(haywardcaltrainclock, 8.08, 0);
close all
clear haywardcaltrainclock
load('mar31f.mat','haywardcaltrainclockgain10')
RANGETEST_CLOCK_SUMMARY(10,:) = rangetest_summary_clock(haywardcaltrainclockgain10, 8.08, 10);
close all
clear haywardcaltrainclockgain10
load('mar31f.mat','haywardcaltrainclockgain20')
RANGETEST_CLOCK_SUMMARY(11,:) = rangetest_summary_clock(haywardcaltrainclockgain20, 8.08, 20);
close all

clear haywardcaltrainclockgain20
load('mar31g.mat','sanmateocaltrainclockgain20')
RANGETEST_CLOCK_SUMMARY(12,:) = rangetest_summary_clock(sanmateocaltrainclockgain20, 9.15, 20);
close all
clear sanmateocaltrainclockgain20
load('mar31g.mat','sanmateocaltrainclockgain10')
RANGETEST_CLOCK_SUMMARY(13,:) = rangetest_summary_clock(sanmateocaltrainclockgain10, 9.15, 10);
close all
clear sanmateocaltrainclockgain10
load('mar31h.mat','sanmateocaltrainclock')
RANGETEST_CLOCK_SUMMARY(14,:) = rangetest_summary_clock(sanmateocaltrainclock, 9.15, 0);
close all
clear sanmateocaltrainclock



%NOW DO IT FOR THE PRN COMB

load('mar31a.mat','parkingprn')
RANGETEST_PRN_SUMMARY(1,:) = rangetest_summary_prn(parkingprn, 0, 0);
close all
clear parkingprn
load('mar31a.mat','sequoiaprn')
RANGETEST_PRN_SUMMARY(2,:) = rangetest_summary_prn(sequoiaprn, 1.97, 0);
close all
clear sequoiaprn
load('mar31b.mat','movingaftersequoiaprn')
RANGETEST_PRN_SUMMARY(3,:) = rangetest_summary_prn(movingaftersequoiaprn, 2.5, 0);
close all
clear movingaftersequoiaprn
load('mar31b.mat','stcarlostrainprn')
RANGETEST_PRN_SUMMARY(4,:) = rangetest_summary_prn(stcarlostrainprn, 4.1, 0);
close all
clear stcarlostrainprn
load('mar31b.mat','oneilprn')
RANGETEST_PRN_SUMMARY(5,:) = rangetest_summary_prn(oneilprn, 5.14, 0);
close all
clear oneilprn
load('mar31c.mat','ruthandelcaminoprn')
RANGETEST_PRN_SUMMARY(6,:) = rangetest_summary_prn(ruthandelcaminoprn, 6.1, 0);
close all
clear ruthandelcaminoprn
load('mar31d.mat','parkingprn2')
RANGETEST_PRN_SUMMARY(7,:) = rangetest_summary_prn(parkingprn2, 0, 0);
close all
clear parkingprn2
load('mar31d.mat','ruthandelcaminoprn2')
RANGETEST_PRN_SUMMARY(8,:) = rangetest_summary_prn(ruthandelcaminoprn2, 6.1, 0);
close all
clear ruthandelcaminoprn2
load('mar31e.mat','hillsdalecaltrainprn')
RANGETEST_PRN_SUMMARY(9,:) = rangetest_summary_prn(hillsdalecaltrainprn, 6.97, 0);
close all
clear hillsdalecaltrainprn
load('mar31e.mat','haywardcaltrainprn')
RANGETEST_PRN_SUMMARY(10,:) = rangetest_summary_prn(haywardcaltrainprn, 8.08, 0);
close all
clear haywardcaltrainprn
load('mar31f.mat','haywardcaltrainprngain10')
RANGETEST_PRN_SUMMARY(11,:) = rangetest_summary_prn(haywardcaltrainprngain10, 8.08, 10);
close all
clear haywardcaltrainprngain10
load('mar31f.mat','haywardcaltrainprngain20')
RANGETEST_PRN_SUMMARY(12,:) = rangetest_summary_prn(haywardcaltrainprngain20, 8.08, 20);
close all
clear haywardcaltrainprngain20
load('mar31g.mat','sanmateocaltrainprngain20')
RANGETEST_PRN_SUMMARY(13,:) = rangetest_summary_prn(sanmateocaltrainprngain20, 9.15, 20);
close all
clear sanmateocaltrainprngain20
load('mar31g.mat','sanmateocaltrainprngain10')
RANGETEST_PRN_SUMMARY(14,:) = rangetest_summary_prn(sanmateocaltrainprngain10, 9.15, 10);
close all
clear sanmateocaltrainprngain10
load('mar31h.mat','sanmateocaltrainprn')
RANGETEST_PRN_SUMMARY(15,:) = rangetest_summary_prn(sanmateocaltrainprn, 9.15, 0);
close all
clear sanmateocaltrainprn
%}

load('RangeTestOverview_Mar31.mat')

figure
plot(RANGETEST_CLOCK_SUMMARY(:,1),RANGETEST_CLOCK_SUMMARY(:,[2 3 4 5]),'o')
xlabel('Range [mi]')
ylabel('Bit Error Rate')
legend('Freq Coherent','Time Coherent','Freq Single-Antenna', 'Time Single-Antenna')
title('Clock Comb Correlator Performance')

figure
plot(RANGETEST_PRN_SUMMARY(:,1),RANGETEST_PRN_SUMMARY(:,[2 3 4 5]),'o')
xlabel('Range [mi]')
ylabel('Bit Error Rate')
legend('Freq Coherent','Time Coherent','Freq Single-Antenna', 'Time Single-Antenna')
title('PRN Comb Correlator Performance')

%make plots for presentation
figure
plot(RANGETEST_CLOCK_SUMMARY([1 3 4 5 7 8 9 14],1),RANGETEST_CLOCK_SUMMARY([1 3 4 5 7 8 9 14],[2 3 4 5]),'o-')
xlabel('Range [mi]')
ylabel('Bit Error Rate')
legend('Freq Coherent','Time Coherent','Freq Single-Antenna', 'Time Single-Antenna')
title('Bit Error Rate of Freq- and Time-domain Coherent Receivers using Clock Comb by Range')

figure
plot(RANGETEST_PRN_SUMMARY([1 2 4 5 8 9 10 15],1),RANGETEST_PRN_SUMMARY([1 2 4 5 8 9 10 15],[2 3 4 5]),'o-')
xlabel('Range [mi]')
ylabel('Bit Error Rate')
legend('Freq Coherent','Time Coherent','Freq Single-Antenna', 'Time Single-Antenna')
title('Bit Error Rate of Freq- and Time-domain Coherent Receivers using PRN Comb by Range')

figure
plot(RANGETEST_CLOCK_SUMMARY([1 3 4 5 7 8 9 14],1),RANGETEST_CLOCK_SUMMARY([1 3 4 5 7 8 9 14],[2]),'o-')
hold on
plot(RANGETEST_CLOCK_SUMMARY([10 13],1),RANGETEST_CLOCK_SUMMARY([10 13],[2]),'o-')
plot(RANGETEST_CLOCK_SUMMARY([11 12],1),RANGETEST_CLOCK_SUMMARY([11 12],[2]),'o-')
xlabel('Range [mi]')
ylabel('Bit Error Rate')
legend('Freq Coherent','Freq Coherent, Gain 10','Freq Coherent, Gain 20')
title('Effect of Gain on BER of Freq-domain Coherent Receivers using Clock Comb')

figure
plot(RANGETEST_CLOCK_SUMMARY([1 3 4 5 7 8 9 14],1),RANGETEST_CLOCK_SUMMARY([1 3 4 5 7 8 9 14],[3]),'o-')
hold on
plot(RANGETEST_CLOCK_SUMMARY([10 13],1),RANGETEST_CLOCK_SUMMARY([10 13],[3]),'o-')
plot(RANGETEST_CLOCK_SUMMARY([11 12],1),RANGETEST_CLOCK_SUMMARY([11 12],[3]),'o-')
xlabel('Range [mi]')
ylabel('Bit Error Rate')
legend('Time Coherent','Time Cohernet, Gain 10','Time Cohernet, Gain 20')
title('Effect of Gain on BER of Time-domain Coherent Receivers using Clock Comb')

figure
plot(RANGETEST_PRN_SUMMARY([1 2 4 5 8 9 10 15],1),RANGETEST_PRN_SUMMARY([1 2 4 5 8 9 10 15],[2]),'o-')
hold on
plot(RANGETEST_PRN_SUMMARY([11 14],1),RANGETEST_PRN_SUMMARY([11 14],[2]),'o-')
plot(RANGETEST_PRN_SUMMARY([12 13],1),RANGETEST_PRN_SUMMARY([11 13],[2]),'o-')
xlabel('Range [mi]')
ylabel('Bit Error Rate')
legend('Freq Coherent','Freq Coherent, Gain 10','Freq Coherent, Gain 20')
title('Effect of Gain on BER of Freq-domain Coherent Receivers using PRN Comb')

figure
plot(RANGETEST_PRN_SUMMARY([1 2 4 5 8 9 10 15],1),RANGETEST_PRN_SUMMARY([1 2 4 5 8 9 10 15],[3]),'o-')
hold on
plot(RANGETEST_PRN_SUMMARY([11 14],1),RANGETEST_PRN_SUMMARY([11 14],[3]),'o-')
plot(RANGETEST_PRN_SUMMARY([12 13],1),RANGETEST_PRN_SUMMARY([12 13],[3]),'o-')
xlabel('Range [mi]')
ylabel('Bit Error Rate')
legend('Time Coherent','Time Cohernet, Gain 10','Time Cohernet, Gain 20')
title('Effect of Gain on BER of Time-domain Coherent Receivers using PRN Comb')
hold off

%plot comparison with last test
load('RangeTestOverview_Mar17.mat')

figure
plot(RANGETEST_CLOCK_SUMMARY([1 3 4 5 7 8 9 14],1),RANGETEST_CLOCK_SUMMARY([1 3 4 5 7 8 9 14],[2 3]),'o-')
hold on
plot(RANGETEST_PRN_SUMMARY([1 2 4 5 8 9 10 15],1),RANGETEST_PRN_SUMMARY([1 2 4 5 8 9 10 15],[2 3]),'o-')
plot(range,BER_coherent,'o-')
xlabel('Range [mi]')
ylabel('Bit Error Rate')
legend('Freq-Domain Clock','Time-Domain Clock','Freq-Domain PRN','Time-Domain PRN','Mar 17 Freq-Domain Clock')
title('Bit Error Rate Comparison of Mar 31st and Mar 17th Test')

