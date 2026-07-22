%%  ----- Closed Loop System Performance Anlysis of Aircraft Pitch Control System----
clc

%% ------ Closed Loop  Aircraft Pitch Control System  with only P controller----

kp_value = [0.1,0.2,0.3,0.4,0.5];
for i = 1:length(kp_value)
    signal = out.(sprintf('Pitch_Angle%d',i));
    info = stepinfo(signal.Data, signal.Time);
    fprintf("System Performance when Kp = %.1f is :\n",kp_value(i))
    disp(info)
end


%% ------ Closed Loop  Aircraft Pitch Control System  with only PI controller----

ki_value = [0.1,0.3,0.5,1.0];
for i = 1:length(ki_value)
    signal = out.(sprintf('Pitch_Angle%d',i));
    info = stepinfo(signal.Data, signal.Time);
    fprintf("System Performance when Kp = 0.1 and Ki = %.1f is :\n",ki_value(i))
    disp(info)
end
%% Auto Tune
K=1.282; tau=-1.0;
num = K*[tau 1];
den = [1 1.935 0.987 0.179];
G = tf(num,den);

C = pidtune(G,'PID')
T = feedback(C*G,1);
stepinfo(T)
step(5*T)

%% ---- Disturbance Rejection Case ---

kp = 0.264 ; ki = 0.0372 ; kd = 0.455 ;


% Step Disturbance of value 2 degrees at t = 50s
info1 = stepinfo(out.Pitch_Angle1.Data, out.Pitch_Angle1.Time);
fprintf("System Performance when Disturbance of 2 degrees is involved:\n")
disp(info1)

info2 = stepinfo(out.Pitch_Angle2.Data, out.Pitch_Angle2.Time);
fprintf("System Performance without the Disturbanceis :\n")
disp(info2)
