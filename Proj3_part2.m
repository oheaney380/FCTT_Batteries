tic
clear
close all

global OCV_prof
global SoC_prof

load('OCV_data.mat')

%Take subset to improve execution times
OCV_prof = OCV_prof(1:10:end);
SoC_prof = SoC_prof(1:10:end);

[Times,CurrentA,VoltageV1] = import_training_data([pwd '\FCTT 18-19 Data\Model_Training_Data_20.csv']);

% plot(Times,CurrentA)
% figure
% plot(Times,VoltageV1)

pulse_locs = find(diff(abs(CurrentA)) > 0.6); %Find indices of current peaks

n_SoC = 8;
n_pulses = 8;
pulse_idx = 1;

for i = 1:n_SoC
    SoC(i) = SoC_prof(find(OCV_prof < VoltageV1(pulse_locs(pulse_idx)-1), 1));
    %     SoC(i) = interp1(OCV_prof(1:end-5), SoC_prof(1:end-5), VoltageV1(pulse_locs(pulse_idx)-1));
    for j = 1:n_pulses
        disp(['Iteration: ' num2str(i) ', ' num2str(j)])
        if j == n_pulses
            params{i,j} = lsqcurvefit(@ECN_model,[0.01,0.01,1e-7,SoC(i)],...
                CurrentA(pulse_locs(pulse_idx)-1:pulse_locs(pulse_idx)+10000) ,...
                VoltageV1(pulse_locs(pulse_idx)-1:pulse_locs(pulse_idx)+10000),...
                [0,0,0,SoC(i)],[inf,inf,inf,SoC(i)]);
        else
            params{i,j} = lsqcurvefit(@ECN_model,[0.01,0.01,1e-7,SoC(i)],...
                CurrentA(pulse_locs(pulse_idx)-1:pulse_locs(pulse_idx+1)-1) ,...
                VoltageV1(pulse_locs(pulse_idx)-1:pulse_locs(pulse_idx+1)-1),...
                [0,0,0,SoC(i)],[inf,inf,inf,SoC(i)]);
        end
        pulse_idx = pulse_idx + 1;
        
    end
end

voltage_reconstruct = ECN_model(params{1,1},CurrentA(1:pulse_locs(9)));
toc