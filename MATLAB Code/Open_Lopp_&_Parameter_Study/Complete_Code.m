%% ------ Open Loop Step Response of Aircraft Pitch Control------
clc ; clear all ; close all ;

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

%% ----- Parameter Study  -----

K  = -1.282;
tau = -1.0;
a2 = 1.935;
a1 = 0.987;
a0 = 0.179;

%% Effect of a0 (static stability)

figure(3)
a0_values = [0.1, 0.179, 0.5,1];
for i = 1 : length (a0_values)
    a0 = a0_values(i);
    G_a0 = tf([K*tau K] , [1 a2 a1 a0]);
    step(-G_a0,100)
    hold on
    p = pole(G_a0);
    fprintf("Poles of system when a2 , a1 , K , tau are constant and a0 = %.3f :\n",a0)
    disp(p)
    info_a0 = stepinfo(G_a0);
    fprintf("System Performance when a2 , a1 , K , tau are constant and a0 = %.3f\n",a0)
    disp(info_a0)
end
legend("a0=0.1","a0=0.179","a0=0.5","a0=1",'Location','best')
title("Effect of Static Stability (a0) on Pitch Response")
grid on 


%% Effect of a2 (pitch damping)

figure(4)
a2_values = [0.5, 1.935, 3.0, 5];
for i = 1 : length (a2_values)
    a2 = a2_values(i);
    G_a2 = tf([K*tau K] , [1 a2 a1 a0]);
    step(-G_a2,100)
    hold on
    p = pole(G_a2);
    fprintf("Poles of system when a0 , a1 , K , tau are constant and a2 = %.3f :\n",a2)
    disp(p)
    info_a2 = stepinfo(G_a2);
    fprintf("System Performance when a0 , a1 , K , tau are constant and a2 = %.3f\n",a2)
    disp(info_a2)
end
legend("a2=0.5","a2=1.935","a2=3.0","a2=5.0")
title("Effect of Pitch Damping (a2) on Pitch Response")
grid on 


%% Effect of a1 (dynamic stability)

figure(5)
a1_values = [0.3, 0.987, 2.0, 4.0];
for i = 1 : length (a1_values)
    a1 = a1_values(i);
    G_a1 = tf([K*tau K] , [1 a2 a1 a0]);
    step(-G_a1,100)
    hold on
    p = pole(G_a1);
    fprintf("Poles of system when a0 , a2 , K , tau are constant and a1 = %.3f :\n",a1)
    disp(p)
    info_a1 = stepinfo(G_a1);
    fprintf("System Performance when a0 , a2 , K , tau are constant and a1 = %.3f\n",a1)
    disp(info_a1)
end
legend('a1=0.3','a1=0.987','a1=2.0','a1=4.0')
title("Effect of dynamic stability (a1) on Pitch Response")
grid on 