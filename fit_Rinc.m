function [Rinc] = fit_Rinc(ar, Ah)

T = 273+45;
R = 8.314;
Eac = 51800;

Rinc = ar*exp(-Eac/(R*T))*Ah;

end

