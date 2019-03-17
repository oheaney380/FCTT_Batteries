tic
clear
close all

load('params_degr.mat');
load_profile = import_data([pwd '\FCTT 18-19 Data\Battery_Testing_Data.csv']);
prof_start_idx = 18000;

Q = 2.5;

I = load_profile.CurrentmA(prof_start_idx:end)/1000;
time_profile = load_profile.Times(prof_start_idx:end) - load_profile.Times(prof_start_idx);
Ah_thrput_profile = -sum(I(I<0))/3600;

scale_factor = 60*60/length(time_profile);
time_profile = scale_factor*time_profile;
Ah_thrput_profile = scale_factor*Ah_thrput_profile;

max_cycles = 7300;
for T = 10:10:50
    
    Capacity(T/10,1) = Q;
    T_init(T/10,1) = T;
    Resistance(T/10,1) = 0;
    Ah_thrput(T/10,1) = 0;
    SoC_init(T/10,1) = 0.85;
    time_cal(T/10,1) = 0;
    
    for i = 2:max_cycles
        [SoC_prof, V_prof, Temp_prof] = ECN_model_4(I, time_profile,...
            T_init(T/10,i-1), T, Capacity(T/10,i-1), SoC_init(T/10,i-1),Resistance(T/10,i-1));
        Ah_thrput(T/10,i) = Ah_thrput(T/10,i-1) + Ah_thrput_profile;
        SoC_min(T/10,i) = min(SoC_prof);
        V_min(T/10,i) = min(V_prof);
        T_run(T/10,i) = Temp_prof(end);
        T_max(T/10,i) = max(Temp_prof);
        
        if max(Temp_prof) > 60
            warning('Maximum Temperature Exceeded')
            Capacity(T/10,i:end) = NaN*ones(1,max_cycles-i+1);
            Resistance(T/10,i:end) = NaN*ones(1,max_cycles-i+1);
            T_max(T/10,i:end) = NaN*ones(1,max_cycles-i+1);
            SoC_min(T/10,i:end) = NaN*ones(1,max_cycles-i+1);
            V_min(T/10,i:end) = NaN*ones(1,max_cycles-i+1);
            break
        elseif min(V_prof) < 2.5
            warning('Minimum Voltage Exceeded')
            Capacity(T/10,i:end) = NaN*ones(max_cycles-1,1);
            Resistance(T/10,i:end) = NaN*ones(max_cycles-1,1);
            T_max(T/10,i:end) = NaN*ones(max_cycles-1,1);
            SoC_min(T/10,i:end) = NaN*ones(max_cycles-1,1);
            V_min(T/10,i:end) = NaN*ones(max_cycles-1,1);
            break
        elseif min(SoC_prof) < 0.1
            warning('Minimum SoC Exceeded')
            Capacity(T/10,i:end) = NaN*ones(max_cycles-1,1);
            Resistance(T/10,i:end) = NaN*ones(max_cycles-1,1);
            T_max(T/10,i:end) = NaN*ones(max_cycles-1,1);
            SoC_min(T/10,i:end) = NaN*ones(max_cycles-1,1);
            V_min(T/10,i:end) = NaN*ones(max_cycles-1,1);
            break
        end
        
        Cap_loss_prof(T/10,i) = Sloss(params_S,Ah_thrput(T/10,i),mean(T_run(T/10,:)));
        Res_inc_prof(T/10,i) = Rinc(ar, Ah_thrput(T/10,i),T_run(T/10,i));
        SoC = SoC_prof(end);
        time_charge = linspace(0,7200*(0.85-SoC),5000);
        I_charge = 0.5*Capacity(T/10,i-1)*ones(length(time_charge),1);
        [SoC_charge, V_charge, Temp_charge] = ECN_model_4(I_charge, time_charge,...
            T_run(T/10,i-1), T, Capacity(T/10,i-1), SoC, Resistance(T/10,i-1));
        T_init(T/10,i) = T;
        SoC_init(T/10,i) = SoC_charge(end);
        if max(Temp_charge) > 60
            disp('Maximum Temperature Exceeded during charge')
            Capacity(T/10,i:end) = NaN*ones(max_cycles-1,1);
            Resistance(T/10,i:end) = NaN*ones(max_cycles-1,1);
            T_max(T/10,i:end) = NaN*ones(max_cycles-1,1);
            SoC_min(T/10,i:end) = NaN*ones(max_cycles-1,1);
            V_min(T/10,i:end) = NaN*ones(max_cycles-1,1);
            break
        end
        time_cal(T/10,i) = time_cal(T/10,i-1) + 11; %Hours
        Cap_loss_cal(T/10,i) = Sloss_cal(params_S_cal,time_cal(T/10,i),T);
        Res_inc_cal(T/10,i) = Rinc_cal(br,time_cal(T/10,i),T);
        Capacity(T/10,i) = Q - (Cap_loss_prof(T/10,i) + Cap_loss_cal(T/10,i));
        Resistance(T/10,i) = Res_inc_prof(T/10,i) + Res_inc_cal(T/10,i);
    end
    
end

time_years = [1:max_cycles;1:max_cycles;1:max_cycles;1:max_cycles;1:max_cycles]*0.5/365;
fig1 = figure(1);
h1 = subplot(211);
hold on
plot(time_years',Q-Capacity')
plot([0 10], [0.75 0.75],'--k')
legend('10 C', '20 C', '30 C', '40 C','50 C','End-of-Life Limit','location','northwest')
xlabel('Time [Years]')
ylabel('Capacity Loss [Ah]')
ylim([0 0.8])
grid on

h2 = subplot(212);
hold on
plot(time_years',Resistance')
plot([0 10], [100 100],'--k')
legend('10 C', '20 C', '30 C', '40 C','50 C','End-of-Life Limit','location','northwest')
xlabel('Time [Years]')
ylabel('Resistance Increase [%]')
grid on

linkaxes([h1 h2],'x')


fig2 = figure(2);
h3 = subplot(311);
hold on
plot(time_years(:,2:end)',T_max(:,2:end)')
plot([0 10], [60 60],'--k')
legend('10 C', '20 C', '30 C', '40 C','50 C','Temperature Limit','location','northwest')
xlabel('Time [Years]')
ylabel('Max Temperature [C]')
ylim([10 70])
grid on

h4 = subplot(312);
hold on
plot(time_years(:,2:end)',SoC_min(:,2:end)')
plot([0 10], [0.1 0.1],'--k')
legend('10 C', '20 C', '30 C', '40 C','50 C','Minimum SoC Limit','location','southwest')
xlabel('Time [Years]')
ylabel('Minimum SoC')
ylim([0 0.5])
grid on

h5 = subplot(313);
hold on
plot(time_years(:,2:end)',V_min(:,2:end)')
plot([0 10], [2.5 2.5],'--k')
legend('10 C', '20 C', '30 C', '40 C', '50 C','Minimum Voltage Limit','location','southwest')
xlabel('Time [Years]')
ylabel('Minimum Voltage [V]')
ylim([2 3.6])
grid on

linkaxes([h3 h4 h5],'x')
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
Eac = 22406;

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