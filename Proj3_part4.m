clear
close all

load('degr_60C_cal.mat')
load('degr_45C_1C.mat')

Q = 2.5;

Ah_thrput = zeros(length(Cycle), 1);

Ah_thrput(1) = Q*Capacity(1)*Cycle(1)/100;
Sloss = Q*(100-Capacity)/100;

%% Sloss cycle

for i = 2:length(Cycle)
    
    Ah_thrput(i) = Ah_thrput(i-1) + Q*Capacity(i)*(Cycle(i)-Cycle(i-1))/100;

end

params_S = lsqcurvefit(@fit_Sloss, [1 1], Ah_thrput, Sloss);


plot(Ah_thrput,fit_Sloss(params_S,Ah_thrput))
hold on
plot(Ah_thrput,Sloss)

%% Rinc cycling

Ah_r = interp1(Cycle(Cycle~=558),Ah_thrput(Cycle~=558),CycleR, 'spline');
ar = lsqcurvefit(@fit_Rinc, 1, Ah_r , Resistance);

figure
plot(Ah_r,fit_Rinc(ar,Ah_r))
hold on
plot(Ah_r,Resistance)

%% Sloss calendar

params_S_cal = lsqcurvefit(@fit_Sloss_cal, [1 1], TimehS, Capacity_cal*Q/100);

figure
plot(TimehS,fit_Sloss_cal(params_S_cal,TimehS))
hold on
plot(TimehS, Capacity_cal*Q/100)

%% Rinc calendar

br = lsqcurvefit(@fit_Rinc_cal, 89.3744, TimehR, Resistance_cal);%,optimoptions('FunctionTolerance',1e8));

figure
plot(TimehR,fit_Rinc_cal(br, TimehR))
hold on
plot(TimehR, Resistance_cal)

