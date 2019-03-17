function [Sloss] = fit_Sloss_cal(params, Time)

bc = params(1);
z = params(2);


T = 273+60;
R = 8.314;
Eac = 58000;

Sloss = bc*exp(-Eac/(R*T))*Time.^z;

end
