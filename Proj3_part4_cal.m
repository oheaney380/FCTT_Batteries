clear
close all

load('params_degr.mat');

Q = 2.5;

time = 1:1:5000;
C = zeros(length(time),1);
C(1:2:end) = 1;
C(2:2:end) = -1;

I = C*Q;
h1 = figure(1);
hold on
h2 = figure(2);
hold on
for T = 10:10:60
    
    Capacity(T/10,1) = Q;
    Ah_thrput(T/10,1) = Q;
    
    for i = 2:length(time)
        if i/2 == round(i/2)
            Capacity(T/10,i) = Q - Sloss(params_S,Ah_thrput(T/10,i-1),T);
            Resistance(T/10,i) = Rinc(ar,Ah_thrput(T/10,i-1),T);
        else
            Capacity(T/10,i) = Capacity(T/10,i-1);
            Resistance(T/10,i) = Resistance(T/10,i-1);
        end
        dt = time(i)-time(i-1);
        Ah_thrput(T/10,i) = Ah_thrput(T/10,i-1) + dt*Capacity(T/10,i);
        
    end
    figure(h1)    
    plot(time,Q-Capacity(T/10, :))
    figure(h2)
    plot(time,Resistance(T/10, :))
%     keyboard
end
figure(h1) 
legend('10 C', '20 C', '30 C', '40 C', '50 C', '60 C','location','northwest')
figure(h2)
legend('10 C', '20 C', '30 C', '40 C', '50 C', '60 C','location','northwest')

function [SlossV] = Sloss(params, Ah,T)

ac = params(1);
z = params(2);


T = 273+T;
R = 8.314;
Eac = 22406;

SlossV = ac*exp(-Eac/(R*T))*Ah.^z;

end

function [RincV] = Rinc(ar, Ah,T)

T = 273+T;
R = 8.314;
Eac = 22406;

RincV = ar*exp(-Eac/(R*T))*Ah;

end