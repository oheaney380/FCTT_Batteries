clear
close all

load('params_degr.mat');

Q = 2.5;

time_h = 1:1:5000;
time_cal = 1:1:10*365*24;
C = zeros(length(time_h),1);
C(1:2:end) = 1;
C(2:2:end) = -1;

I = C*Q;

for T = 10:10:60
    
    Capacity(T/10,1) = Q;
    Ah_thrput(T/10,1) = Q;
    Resistance(T/10,1) = 0;
    T_run(T/10,1) = T;
    
    for i = 2:length(time_h)
        time_s = 1:3600;
        I = C(i) .* Capacity(T/10,i-1).*ones(length(time_s),1);
        
        if C(i) > 0 
            Ah_thrput(T/10,i) = Ah_thrput(T/10,i-1) + Capacity(T/10,i-1);
        else
            Ah_thrput(T/10,i) = Ah_thrput(T/10,i-1);
        end
        
        if C(i ) < 0 
            [SoC, V, Temp] = ECN_model_4(I, time_s, T_run(T/10,i-1), T, Capacity(T/10,i-1), 1,Resistance(T/10,i-1));
        else
            [SoC, V, Temp] = ECN_model_4(I, time_s, T_run(T/10,i-1), T, Capacity(T/10,i-1), 0,Resistance(T/10,i-1));
        end
        T_run(T/10,i) = Temp(end);
        Capacity(T/10,i) = Q - Sloss(params_S,Ah_thrput(T/10,i),T_run(T/10,i));
        Resistance(T/10,i) = Rinc(ar, Ah_thrput(T/10,i),T_run(T/10,i));
    end
    
    Capacity_cal(T/10,1) = Q;
    Ah_thrput_cal(T/10,1) = Q;
    
    for i = 2:length(time_cal)
        Capacity_cal(T/10,i) = Q - Sloss_cal(params_S_cal,i,T);
        Resistance_cal(T/10,i) = Rinc_cal(br,i,T);
    end

end

fig1 = figure(1);
h1 = subplot(211);
hold on
plot(Ah_thrput',Q-Capacity')
plot([0 max(max(Ah_thrput))], [0.75 0.75],'--k')
legend('10 C', '20 C', '30 C', '40 C', '50 C', '60 C','End-of-Life Limit','location','northwest')
xlabel('Current Throughput [Ah]')
ylabel('Capacity Loss [Ah]')
grid on

h2 = subplot(212);
hold on
plot(Ah_thrput',Resistance')
plot([0 max(max(Ah_thrput))], [100 100],'--k')
legend('10 C', '20 C', '30 C', '40 C', '50 C', '60 C','End-of-Life Limit','location','northwest')
xlabel('Current Throughput [Ah]')
ylabel('Resistance Increase [%]')
grid on

linkaxes([h1 h2],'x')

time_cal_mat = (1/(365*24))*[time_cal; time_cal; time_cal; time_cal; time_cal; time_cal];
fig2 = figure(2);
h3 = subplot(211);
hold on
plot(time_cal_mat',Q-Capacity_cal')
plot([0 10], [0.75 0.75],'--k')
legend('10 C', '20 C', '30 C', '40 C', '50 C', '60 C','End-of-Life Limit','location','northwest')
xlabel('Time [Years]')
ylabel('Capacity Loss [Ah]')
grid on

h4 = subplot(212);
hold on
plot(time_cal_mat',Resistance_cal')
plot([0 10], [100 100],'--k')
legend('10 C', '20 C', '30 C', '40 C', '50 C', '60 C','End-of-Life Limit','location','northwest')
xlabel('Time [Years]')
ylabel('Resistance Increase [%]')
grid on

linkaxes([h3 h4],'x')

%% Functions

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
Eac = 51800;

RincV = ar*exp(-Eac/(R*T))*Ah;
end

function [Sloss_calV] = Sloss_cal(params, Time, T)
bc = params(1);
z = params(2);

T = 273+T;
R = 8.314;
Eac = 58000;

Sloss_calV = bc*exp(-Eac/(R*T))*Time.^z;
end

function [Rinc_calV] = Rinc_cal(br, Time, T)
T = 273+T;
R = 8.314;
Eac = 49800;

Rinc_calV = br*exp(-Eac/(R*T))*Time;
end