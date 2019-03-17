tic

clear
close all

data = import_data([pwd '\FCTT 18-19 Data\Battery_Testing_Data.csv']);

SoC_init = 0.85;

[SoC_model, V_model, T_model] = ECN_model_3(data.CurrentmA/1000, data.Times, data.Temperature(1), 20, SoC_init);

Error_V = V_model - data.VoltageV;
Error_T = T_model - data.Temperature;

%% Plotting
figure
ax1 = subplot(311);
plot(data.Times, data.VoltageV, 'b')
hold on
plot(data.Times, V_model, 'r')
ylabel('Voltage (V)')
xlabel('Time (s)')
legend('Test data', 'Model prediciton')

ax2 = subplot(312);
plot(data.Times, T_model)
hold on
plot(data.Times, data.Temperature)
ylabel('Temperature (C)')
xlabel('Time (s)')
legend('Test data','Model prediction')

ax3 = subplot(313);
plot(data.Times, Error_T)
ylabel('Error (C)')
xlabel('Time (s)')
linkaxes([ax1,ax2,ax3],'x')

%%Last question part 3

load('R1_3temps_3SoCs.mat');

figure
plot([0 20 40], [R1_0C_30pc R1_20C_30pc R1_40C_30pc])
hold on
plot([0 20 40], [R1_0C_60pc R1_20C_60pc R1_40C_60pc])
plot([0 20 40], [R1_0C_90pc R1_20C_90pc R1_40C_90pc])
xlabel('Temperature (C)')
ylabel('Resistance (\Omega)')
legend('30% SoC', '60% SoC', '90% SoC')

toc

