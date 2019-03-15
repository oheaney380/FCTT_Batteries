function [R0] = find_R0(T)


R0_20C = 0.02;
R = 8.314;
E = -24e3;

R0 = R0_20C*exp(-E/R*(1/(T+273)-1/293));

end

