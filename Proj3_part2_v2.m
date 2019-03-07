clear
close all

[Times,CurrentA,VoltageV1] = import_training_data([pwd '\FCTT 18-19 Data\Model_Training_Data_20.csv']);

pulse_locs = find(diff(abs(CurrentA)) > 0.6); %Find indices of current peaks

for i = 1:length(pulse_locs)
    
    vinf_locs(i) = pulse_locs(i) + find(diff(VoltageV1(pulse_locs(i):end)) == 0, 1);

end