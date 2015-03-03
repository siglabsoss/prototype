h = UsrpMaskMapiT('192.168.10.2', BoardIdCapiEnumT.MboardId,1e7)
h.setClockConfig(CannedClockConfigCapiEnumT.External);
 
% c = ClockConfigCapiT
% c.refSource = RefSourceCapiEnumT.External
% c.ppsSource = PPSSourceCapiEnumT.External
% c.ppsPolarity = PPSPolarityCapiEnumT.Positive
% h.setClockConfigFull(c);


% taken from: http://www.mathworks.com/matlabcentral/answers/102467-how-do-i-set-the-clock-and-time-references-of-usrp-to-external-reference-or-to-mimo-cable-for-the-sl
