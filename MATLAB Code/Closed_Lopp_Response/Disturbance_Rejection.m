%% ---- Disturbance Rejection Case ---

kp = 0.264 ; ki = 0.0372 ; kd = 0.455 ;


% Step Disturbance of value 2 degrees at t = 50s
info1 = stepinfo(out.Pitch_Angle1.Data, out.Pitch_Angle1.Time);
fprintf("System Performance when Disturbance of 2 degrees is involved:\n")
disp(info1)

info2 = stepinfo(out.Pitch_Angle2.Data, out.Pitch_Angle2.Time);
fprintf("System Performance without the Disturbanceis :\n")
disp(info2)
