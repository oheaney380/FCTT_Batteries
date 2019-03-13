function [R1] = Gauss_R1(param,I)

R1_0A = param(1);
b = param(2);
c = param(3);


R1 = R1_0A*exp(-(I-b).^2/c);

end

