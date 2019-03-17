function [Rinc] = fit_Rinc_cal(br, Time)

T = 273+60;
R = 8.314;
Eac = 49800; %file://icnas1.cc.ic.ac.uk/ojh14/downloads/EVS27-2870281.pdf

Rinc = br*exp(-Eac/(R*T))*Time;

end