% =========================================================================
%  Production-Ready Aircraft Pitch Animation & Video Recorder
% Features: Window-close protection, automatic export to MP4 video file
% =========================================================================
clear; clc; close all;

%% 1. Load and Extract Real Simulink Data Robustly
if exist('out','var')
    t_sim = out.tout;
    pitch_raw = out.pitch_angle;
    
    if isa(pitch_raw, 'timeseries')
        theta_deg = pitch_raw.Data; 
    elseif isa(pitch_raw, 'struct') && isfield(pitch_raw, 'signals')
        theta_deg = pitch_raw.signals.values;
    elseif isa(pitch_raw, 'Simulink.SimulationData.Signal')
        theta_deg = pitch_raw.Values.Data;
    else
        theta_deg = pitch_raw; 
    end
    
    t_sim = squeeze(double(t_sim));
    theta_deg = squeeze(double(theta_deg));
else
    % FALLBACK: Now updated to emulate the 50s disturbance response!
    t_sim = linspace(0, 100, 1500)';
    % Base response tracking to 5 degrees
    theta_deg = 5 * (1 - 1.2*exp(-0.25*t_sim) + 0.2*exp(-0.8*t_sim)); 
    theta_deg(t_sim < 1.5) = -0.15 * t_sim(t_sim < 1.5); 
    
    % Add emulated 2-degree step disturbance at t = 50s with PID recovery
    idx_dist = t_sim >= 50;
    t_dist = t_sim(idx_dist) - 50;
    % Disturbance spike that recovers over time due to integral action
    disturbance_response = 2 * exp(-0.3 * t_dist) .* cos(0.4 * t_dist);
    theta_deg(idx_dist) = theta_deg(idx_dist) + disturbance_response;
end

theta_rad = deg2rad(theta_deg);

%% 2. Setup Video Writer Object
video_filename = 'Aircraft_Pitch_Controller_Response.mp4';
v = VideoWriter(video_filename, 'MPEG-4');
v.FrameRate = 30; % Set playback to 30 FPS
v.Quality = 95;   % High visual quality for portfolio presentation
open(v);          % Open file streaming pointer

%% 3. Setup the Animation Window
fig = figure('Name', 'Aircraft Pitch Closed-Loop Animation', ...
             'Color', [1 1 1], 'Position', [100, 100, 900, 550]);
hold on; grid on; axis equal;
xlim([-12, 12]); ylim([-8, 8]);
xlabel('X Distance (m)', 'FontSize', 11);
ylabel('Vertical Translation (m)', 'FontSize', 11);

% Draw static horizon line
plot([-15, 15], [0, 0], 'k:', 'LineWidth', 1, 'Color', [0.6 0.6 0.6], 'HandleVisibility', 'off');

% Draw the 5-degree Target Pitch Line
plot([-15, 15], [-15*tan(deg2rad(5)), 15*tan(deg2rad(5))], 'g--', ...
     'LineWidth', 1.5, 'DisplayName', '5° Target Pitch Reference');

% Initialize Animated Graphic Elements
h_fuselage = plot([0,0], [0,0], 'b-', 'LineWidth', 5, 'DisplayName', 'Fuselage');
h_tail     = plot([0,0], [0,0], 'r-', 'LineWidth', 3, 'DisplayName', 'Tail Vertical Fin');
h_cg       = plot(0, 0, 'ko', 'MarkerFaceColor', 'y', 'MarkerSize', 8, 'DisplayName', 'Center of Gravity');

legend('Location', 'northwest');
h_title = title('Aircraft Pitch: 0.00s | Pitch: 0.00°', 'FontSize', 12);

%% 4. Scale Geometry
L_fuse = 12;      
W_tail = 3.5;     

%% 5. Execution & Recording Loop
fps = 30;
t_animation = 0:(1/fps):t_sim(end);

for k = 1:length(t_animation)
    current_t = t_animation(k);
    
    % Safe escape check if window is closed manually
    if ~isvalid(fig)
        disp('Animation window closed early. Saving partial video.');
        break; 
    end
    
    current_theta_deg = interp1(t_sim, theta_deg, current_t, 'linear', 'extrap');
    current_theta_rad = interp1(t_sim, theta_rad, current_t, 'linear', 'extrap');
    
    % Calculate coordinates
    x_nose = (L_fuse / 2) * cos(current_theta_rad);
    y_nose = (L_fuse / 2) * sin(current_theta_rad);
    x_tail = -(L_fuse / 2) * cos(current_theta_rad);
    y_tail = -(L_fuse / 2) * sin(current_theta_rad);
    x_tail_tip = x_tail - W_tail * sin(current_theta_rad);
    y_tail_tip = y_tail + W_tail * cos(current_theta_rad);
    
    % Update plot handles
    set(h_fuselage, 'XData', [x_tail, x_nose], 'YData', [y_tail, y_nose]);
    set(h_tail, 'XData', [x_tail, x_tail_tip], 'YData', [y_tail, y_tail_tip]);
    
    % Check if we are in the disturbance phase to dynamically color-code title
    if current_t >= 50 && current_t < 65
        set(h_title, 'String', sprintf('Time: %.2fs / 100.00s | Pitch Angle: %.2f° (Disturbance Rejection Active)', ...
            current_t, current_theta_deg), 'Color', [0.8 0 0]);
    else
        set(h_title, 'String', sprintf('Time: %.2fs / 100.00s | Pitch Angle: %.2f°', ...
            current_t, current_theta_deg), 'Color', [0 0 0]);
    end
    
    drawnow;
    
    % --- CAPTURE FRAME FOR VIDEO ---
    frame = getframe(fig);
    writeVideo(v, frame);
    
    pause(1/fps); 
end

% Clean up and finalize movie file
close(v);
fprintf('Success! Video saved as: %s\\%s\n', pwd, video_filename);