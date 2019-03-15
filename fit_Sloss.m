function [Sloss] = fit_Sloss(params, Ah)

ac = params(1);
z = params(2);


T = 273+45;
R = 8.314;
Eac = 22406;

Sloss = ac*exp(-Eac/(R*T))*Ah.^z;

end

