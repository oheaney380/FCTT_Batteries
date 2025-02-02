function [SoC, V] = ECN_model_2d(I, time, T, SoC_init)

load('OCV_data_rounded.mat');
load('C1_mean.mat');

SoC = zeros(length(I),1);
i_r1 = zeros(length(I),1);
V = zeros(length(I),1);

SoC(1) = SoC_init;
C1 = C1_mean;
V(1) = OCV_round(find(SoC_round>SoC_init*100, 1));

Q = 2.5;

for i = 2:length(I)
    
    dt = time(i)-time(i-1);
    
    SoC(i) = SoC(i-1) + I(i-1)*(dt/3600)/Q;
    
    R1 = find_R1(I(i), T(i));
    R0 = find_R0(T(i));
    
    i_r1(i) = exp(-dt/(R1*C1))*i_r1(i-1) +...
        (1 - exp(-dt/(R1*C1)))*I(i-1);
    
    OCV = OCV_round(find(SoC_round>SoC(i)*100, 1));
    V(i) = OCV + R1*i_r1(i) + R0*I(i);
    
end

end

