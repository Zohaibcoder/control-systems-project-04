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