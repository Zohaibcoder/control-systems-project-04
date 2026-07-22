%%  ----- Closed Loop System Performance Anlysis of Aircraft Pitch Control System----
clc
%% ------ Closed Loop  Aircraft Pitch Control System  with only PI controller----

ki_value = [0.1,0.3,0.5,1.0];
for i = 1:length(ki_value)
    signal = out.(sprintf('Pitch_Angle%d',i));
    info = stepinfo(signal.Data, signal.Time);
    fprintf("System Performance when Kp = 0.1 and Ki = %.1f is :\n",ki_value(i))
    disp(info)
end