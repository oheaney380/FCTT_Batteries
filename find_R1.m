function [R1] = find_R1(I, T)

R1_0A_20C = 0.0154;
b = 0.6387;
c = 51.1105;
R = 8.314;
E = -2e4;

R1 = R1_0A_20C*exp(-(I-b)^2/c)*exp(-E/R*(1/(T+273)-1/293));

end

