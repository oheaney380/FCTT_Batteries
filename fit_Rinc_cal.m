function [Rinc] = fit_Rinc_cal(br, Time)

T = 273+60;
R = 8.314;
Eac = 22406;

Rinc = br*exp(-Eac/(R*T))*Time;

end