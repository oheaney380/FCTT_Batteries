clear
%close all

[Times,CurrentA,VoltageV1] = import_training_data([pwd '\FCTT 18-19 Data\Model_Training_Data_20.csv']);


n_SoC = 8;
n_pulses = 8;
pulse_idx = 1;

load('OCV_data.mat');
pulse_onoff = find(abs(diff(CurrentA)) > 0.6); %Find indices of current peaks

pulse_on = pulse_onoff(1:2:end);
pulse_off = pulse_onoff(2:2:end);

vinf_locs = zeros(64, 1);

for i = 1:length(pulse_on)
    
    v_inf(i) = VoltageV1(pulse_on(i) + 5000);
    vinf_locs(i) = pulse_on(i) + find(VoltageV1(pulse_on(i)+20:end) == v_inf(i), 1);
   
end

for i = 1:n_SoC
    
    SoC(i) = SoC_prof(find(OCV_prof < VoltageV1(pulse_on(pulse_idx)-1), 1));
       
    for j = 1:n_pulses
        
        curr_loc_on = pulse_on(pulse_idx);
        curr_loc_off = pulse_off(pulse_idx);
        
        dI(i, j) = CurrentA(curr_loc_on) - CurrentA(curr_loc_on+1);
        
        dv0(i, j) =  VoltageV1(curr_loc_off+1) - VoltageV1(curr_loc_off);
                    
        R0(i, j) = dv0(i, j)/dI(i,j);
        
        dvinf(i, j) = VoltageV1(curr_loc_off) - v_inf(pulse_idx);
               
        R1(i, j) = abs(dvinf(i, j)/dI(i, j)) - R0(i, j);
        
        dT_inf(i, j) = (Times(vinf_locs(pulse_idx)) - Times(curr_loc_off));
                
        C1(i, j) = dT_inf(i, j)/(4*R1(i, j));
        
        pulse_idx = pulse_idx + 1;
                
    end
end


R0_mean = mean(mean(R0));
C1_mean = mean(mean(C1));


[curr_table, curr_order] = sort(-dI(1, 1:7));
SoC_table = fliplr(SoC);
R1 = flipud(R1);
R1 = R1(:,curr_order);

save('R1_table.mat', 'R1', 'SoC_table', 'curr_table')

