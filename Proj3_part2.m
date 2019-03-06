tic
clear
close all

global OCV_prof
global SoC_prof
global I

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

R0_init = 8.2e-3;
R1_init = 15.8e-3;
C1_init = 38e3;

for i = 1:n_SoC
    SoC(i) = SoC_prof(find(OCV_prof < VoltageV1(pulse_locs(pulse_idx)-1), 1));
    %     SoC(i) = interp1(OCV_prof(1:end-5), SoC_prof(1:end-5), VoltageV1(pulse_locs(pulse_idx)-1));
    for j = 1:n_pulses
        disp(['Iteration: ' num2str(i) ', ' num2str(j)])
        
        if j == n_pulses
            
            I = CurrentA(pulse_locs(pulse_idx)-10:pulse_locs(pulse_idx)+10000);
            
            params{i,j} = lsqcurvefit(@ECN_model,[R0_init,R1_init,C1_init,SoC(i)],...
                1:1:10010,...
                VoltageV1(pulse_locs(pulse_idx)-10:pulse_locs(pulse_idx)+10000),...
                [10e-3,10e-3,1e3,SoC(i)],[100e-3,100e-3,inf,SoC(i)]);
        else
            
            I = VoltageV1(pulse_locs(pulse_idx)-10:pulse_locs(pulse_idx+1)-1);
            
            params{i,j} = lsqcurvefit(@ECN_model,[R0_init,R1_init,C1_init,SoC(i)],...
                1:1:length(VoltageV1(pulse_locs(pulse_idx)-10:pulse_locs(pulse_idx+1)-1)) ,...
                VoltageV1(pulse_locs(pulse_idx)-10:pulse_locs(pulse_idx+1)-1),...
                [10e-3,10e-3,1e3,SoC(i)],[100e-3,100e-3,inf,SoC(i)]);
        end
        
        %{
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
        
        %}
        pulse_idx = pulse_idx + 1;
        
    end
end

voltage_reconstruct = ECN_model(params{1,1},CurrentA(1:pulse_locs(9)));
toc