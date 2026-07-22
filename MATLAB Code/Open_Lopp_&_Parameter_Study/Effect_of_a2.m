%% ----- Parameter Study  -----

K  = -1.282;
tau = -1.0;
a2 = 1.935;
a1 = 0.987;
a0 = 0.179;

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
