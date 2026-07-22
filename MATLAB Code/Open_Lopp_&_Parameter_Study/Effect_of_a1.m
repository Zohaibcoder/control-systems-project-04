%% ----- Parameter Study  -----

K  = -1.282;
tau = -1.0;
a2 = 1.935;
a1 = 0.987;
a0 = 0.179;

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