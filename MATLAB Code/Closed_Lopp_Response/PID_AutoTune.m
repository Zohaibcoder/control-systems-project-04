%% Auto Tune
K=1.282; tau=-1.0;
num = K*[tau 1];
den = [1 1.935 0.987 0.179];
G = tf(num,den);

C = pidtune(G,'PID')
T = feedback(C*G,1);
stepinfo(T)
step(5*T)
