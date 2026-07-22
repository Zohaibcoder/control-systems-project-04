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