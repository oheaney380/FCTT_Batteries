 %function [V] = ECN_model(params,time)
 function [V] = ECN_model(R0, C1, SoC_init, I, time)
%ECN_MODEL Summary of this function goes here
%   Detailed explanation goes here

%global OCV_prof
%global SoC_prof
% global I

load('OCV_data.mat');
load('R1_table.mat')

R1_curr = 0.01;

Q = 2.5;
SoC = zeros(length(I),1);
i_r1 = zeros(length(I),1);
V = zeros(length(I),1);


i_r1(1) = 0; %Assume steady state start
SoC(1) = SoC_init;

V(1) = OCV_prof(find(SoC_prof<SoC(1), 1));
% V(1) = interp1(SoC_prof, OCV_prof, SoC(1)) - R0*I(1);

for i = 2:length(I)
    
    dt = time(i)-time(i-1);
    
    SoC(i) = SoC(i-1) + I(i-1)*(dt/3600)/Q;
    
    if abs(I(i)) ~= 0
        
        R1_curr = interp2(curr_table, SoC_table, R1, I(i), SoC(i),'spline');
    end
    
    i_r1(i) = exp(-dt/(R1_curr*C1))*i_r1(i-1) +...
        (1 - exp(-dt/(R1_curr*C1)))*I(i-1);
    
%     OCV = interp1(SoC_prof, OCV_prof, SoC(i));
    OCV = OCV_prof(find(SoC_prof<SoC(i), 1));
    V(i) = OCV + R1_curr*i_r1(i) + R0*I(i);
end

save('SoC.mat', 'SoC');