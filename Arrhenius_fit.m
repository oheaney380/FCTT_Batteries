function [R1] = Arrhenius_fit(params, T)

%R0_20 = params(1);
R1_20 = params(1);
R = 8.314;
E = params(2);

%R0 = R0_20*exp(-E/R.*(1./(T+273)-1/293));
R1 = R1_20*exp(-E/R.*(1./(T+273)-1/293));

%R0_real = evalin('base', '[R0_0C_60SOC R0_20C_60SOC R0_40C_60SOC]');
R1_real = evalin('base', '[R1_0C_60SOC R1_20C_60SOC R1_40C_60SOC]');

figure
plot(T, R1, 'b');
hold on
%plot(T, R0_real, 'r');
plot(T, R1_real, 'r');

title(['R1_20 =' num2str(R1_20) ' R = ' num2str(R) ' E = ' num2str(E)])

end

%1.3192e3
%2.7720e3
