%% System Parameters
K  = -1.282;
tau = -1.0;
a2 = 1.935;
a1 = 0.987;
a0 = 0.179;
%% Transfer Function 
num = [K*tau K];
den = [1 a2 a1 a0];
G = tf(num,den);
%% Analysis

disp("----Poles----")
P = pole(G)

disp("----Zeros----")
Z = zero(G)

disp("----System Performance----")
S = stepinfo(G)

%% Plots

figure(1)
step(-G,[1 100])
title("Aircraft Pitch Open Loop Step Response")
xlabel("Time (s)");
ylabel("Pitch Angle θ (degrees)")
grid on 

figure(2)
pzmap(G)
title("Pole Zero Map")
grid on 
