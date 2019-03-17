tic

clear
close all

data = import_data([pwd '\FCTT 18-19 Data\Battery_Testing_Data.csv']);

SoC_init = 0.85;

[SoC_model, V_model] = ECN_model_2d(data.CurrentmA/1000, data.Times, data.Temperature, SoC_init);

Error = V_model - data.VoltageV;

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
plot(data.Times, SoC_model*100)
ylabel('SoC (%)')
xlabel('Time (s)')

ax3 = subplot(313);
plot(data.Times, Error)
ylabel('Error (V)')
xlabel('Time (s)')
linkaxes([ax1,ax2,ax3],'x')
toc