function [R1] = Gauss_R1(param,I)

R1_0A = param(1);
b = param(2);
c = param(3);


R1 = R1_0A*exp(-(I-b).^2/c);
R1_real = evalin('base', 'R1(4,:)');

figure
plot(I, R1, 'b')
title(['R1_0A =' num2str(R1_0A) ' b = ' num2str(b) ' c = ' num2str(c)])
hold on
plot(I, R1_real, 'r') 

end

