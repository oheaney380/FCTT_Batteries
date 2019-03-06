function [V] = ECN_model(params,I)
%ECN_MODEL Summary of this function goes here
%   Detailed explanation goes here

global OCV_prof
global SoC_prof

R0 = params(1);
R1 = params(2);
C1 = params(3);
SoC_init = params(4);

Q = 2.5;
SoC = zeros(length(I),1);
i_r1 = zeros(length(I),1);
V = zeros(length(I),1);

i_r1(1) = 0; %Assume steady state start
SoC(1) = SoC_init;
dt = 1;
V(1) = OCV_prof(find(SoC_prof<SoC(1), 1));
% V(1) = interp1(SoC_prof, OCV_prof, SoC(1)) - R0*I(1);

for i = 2:length(I)
    SoC(i) = SoC(i-1) + I(i-1)*(dt/3600)/Q;
    
    i_r1(i) = exp(-dt/(R1*C1))*i_r1(i-1) +...
        (1 - exp(-dt/(R1*C1)))*I(i-1);
%     OCV = interp1(SoC_prof, OCV_prof, SoC(i));
    OCV = OCV_prof(find(SoC_prof<SoC(i), 1));
    V(i) = OCV - R1*i_r1(i) - R0*I(i);
end