clear 
close all
tic

load('OCV_data.mat')
data = import_data([pwd '\FCTT 18-19 Data\Battery_Testing_Data.csv']);
t = data.Times;
I = data.CurrentmA/1000;
VoltageV = data.VoltageV;
temperature = data.Temperature;

%% ---------------------MODEL PARAMS----------------------

Q = 2.5; %Capacity in Ah

OCV_50SoC = 3.6872377;
Curr_disch = [2.496 5 10 15 20 25];
Volt_disch = [3.60 3.53 3.45 3.36 3.29 3.19];
R0 = abs(mean(diff(Volt_disch)./diff(Curr_disch)));

SoC_init = 0.85;
dt = 1;

%% ------------------------Part 1-------------------------

%dz/dt = -i/Q

%z(t) = z_init - 1/Q(integral(i dt))

%discrete:
%z(k+1) = z(k) - i(k)*dt/Q

%with efficiency:
%z(k+1) = z(k) - i(k)*eta*dt/Q

%v = OCV - i*R0

%initial state

SoC = zeros(length(I),1);
V  = zeros(length(I),1);

SoC(1) = SoC_init;
V(1) = interp1(SoC_prof, OCV_prof, SoC(1))+I(1)*R0;

for i = 2:length(I)
    
    SoC(i) = SoC(i-1) + I(i-1)*(dt/3600)/Q;
    V(i) = interp1(SoC_prof, OCV_prof, SoC(i)) + I(i)*R0;
    
end

figure
subplot(211)
plot(V)
hold on
plot(VoltageV)

subplot(212)
plot(SoC)

toc