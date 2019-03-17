function [SoC, V, T] = ECN_model_4(I, time, T_init, T_env, Cap, SoC_init, r_inc)

load('OCV_data_rounded.mat');
load('C1_mean.mat');

SoC = zeros(length(I),1);
i_r1 = zeros(length(I),1);
V = zeros(length(I),1);
T = zeros(length(I),1);
Q = zeros(length(I),1);
P = zeros(length(I),1);

SoC(1) = SoC_init;
C1 = C1_mean;
V(1) = OCV_round(find(SoC_round>=SoC_init*100, 1));
T(1) = T_init;

m = 45e-3;
A = 64.85e-3*pi*18.33e-3;
C = 825;
h = 35;
% Cap = 2.5;

for i = 2:length(I)
    
    dt = time(i)-time(i-1);
    
    T(i) = T(i-1) + dt*(P(i-1)-h*A*(T(i-1)-T_env))/(m*C);
    
    R1 = find_R1(I(i), T(i))*(1+ r_inc/100);
    R0 = find_R0(T(i)) *(1+ r_inc/100);
    
    P(i) = I(i)^2*(R0+R1);
    
    SoC(i) = SoC(i-1) + I(i-1)*(dt/3600)/Cap;
    
    i_r1(i) = exp(-dt/(R1*C1))*i_r1(i-1) +...
        (1 - exp(-dt/(R1*C1)))*I(i-1);
    
    OCV = OCV_round(find(SoC_round>=SoC(i)*100, 1));
    V(i) = OCV + R1*i_r1(i) + R0*I(i);
    
end

end