% =========================================================================
% ENERGY SAVINGS ANALYSIS: VFD vs. VALVE THROTTLING
% =========================================================================
clear; clc; close all;

% 1. Define Fluid Properties and Range
rho = 1000; % Density of water (kg/m3)
g = 9.81;   % Gravity (m/s2)
Q = 0:1:100; % Flow rate range (L/s)
Q_m3s = Q / 1000; % Flow rate in m3/s for power calculation

% 2. Base Curves at 50 Hz
H_pump_50Hz = 50 - 0.002 * Q.^2; 
H_sys_base = 20 + 0.003 * Q.^2; 

% Find original operating point (100% Flow)
[~, idx_orig] = min(abs(H_pump_50Hz - H_sys_base));
Q_orig = Q(idx_orig);
H_orig = H_pump_50Hz(idx_orig);

% 3. The New Demand: Factory needs reduced flow (e.g., 75% of original)
Q_target = Q_orig * 0.75;

% =========================================================================
% SCENARIO A: VALVE THROTTLING (Constant 50 Hz, increased system resistance)
% =========================================================================
% Pump runs on original 50Hz curve. 
% We find the Head the pump produces at Q_target.
H_throttle = 50 - 0.002 * (Q_target)^2;

% Calculate Power (Assuming constant pump efficiency of 75% for simplicity)
eta = 0.75;
Power_Throttle_kW = (rho * g * (Q_target/1000) * H_throttle) / (eta * 1000);

% =========================================================================
% SCENARIO B: VFD FREQUENCY CONTROL (Affinity Laws applied)
% =========================================================================
% System curve remains unchanged. We find what Head the system needs at Q_target.
H_req_vfd = 20 + 0.003 * (Q_target)^2;

% Calculate required VFD Frequency using Affinity Laws
% N_ratio = sqrt(H_req_vfd / H_pump_at_target_if_50Hz_was_shifted)
% Mathematically: 50*n^2 - 0.002*Q_target^2 = H_req_vfd
n_ratio = sqrt((H_req_vfd + 0.002 * Q_target^2) / 50);
Hz_new = 50 * n_ratio;

% Generate the new VFD Pump Curve for plotting
H_pump_VFD = 50*(n_ratio^2) - 0.002 * Q.^2;

% Calculate Power with VFD
Power_VFD_kW = (rho * g * (Q_target/1000) * H_req_vfd) / (eta * 1000);

% =========================================================================
% PRINT ENGINEERING REPORT
% =========================================================================
fprintf('===================================================\n');
fprintf('       VFD ENERGY SAVINGS ANALYSIS REPORT          \n');
fprintf('===================================================\n');
fprintf(' Original Operation (50 Hz) : Q = %.1f L/s, H = %.1f m\n', Q_orig, H_orig);
fprintf(' Target Reduced Flow        : Q = %.1f L/s\n', Q_target);
fprintf('---------------------------------------------------\n');
fprintf(' [Scenario A: Valve Throttling]\n');
fprintf(' Pump Head Forced to        : %.1f m (Excess Pressure!)\n', H_throttle);
fprintf(' Power Consumed             : %.2f kW\n', Power_Throttle_kW);
fprintf('---------------------------------------------------\n');
fprintf(' [Scenario B: VFD Control]\n');
fprintf(' New Required Frequency     : %.1f Hz\n', Hz_new);
fprintf(' Pump Head Matched to System: %.1f m\n', H_req_vfd);
fprintf(' Power Consumed             : %.2f kW\n', Power_VFD_kW);
fprintf('---------------------------------------------------\n');
fprintf(' POWER SAVINGS              : %.2f kW (%.1f %% Reduction!)\n', ...
    (Power_Throttle_kW - Power_VFD_kW), ((Power_Throttle_kW - Power_VFD_kW)/Power_Throttle_kW)*100);
fprintf('===================================================\n');

% =========================================================================
% PLOT THE COMPARISON
% =========================================================================
figure('Name', 'VFD vs Throttling', 'Position', [100, 100, 800, 600]);

% Plot Curves
plot(Q, H_pump_50Hz, 'b-', 'LineWidth', 2); hold on;
plot(Q, H_sys_base, 'k--', 'LineWidth', 2);
plot(Q, H_pump_VFD, 'g-', 'LineWidth', 2);

% Mark Points
plot(Q_orig, H_orig, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); % Orig Point
plot(Q_target, H_throttle, 'bs', 'MarkerSize', 8, 'MarkerFaceColor', 'b'); % Throttled Point
plot(Q_target, H_req_vfd, 'gs', 'MarkerSize', 8, 'MarkerFaceColor', 'g'); % VFD Point

% Draw a line showing the "Wasted Head"
line([Q_target Q_target], [H_req_vfd H_throttle], 'Color', 'r', 'LineStyle', ':', 'LineWidth', 2);
text(Q_target + 2, (H_req_vfd + H_throttle)/2, 'Wasted Head (Friction)', 'Color', 'r', 'FontWeight', 'bold');

% Formatting
title('System Operating Point: Valve Throttling vs VFD', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Flow Rate Q (L/s)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Head H (m)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Base Pump Curve (50Hz)', 'System Resistance Curve', 'VFD Pump Curve (New Hz)', ...
    'Original Op Point', 'Throttled Op Point', 'VFD Op Point', 'Location', 'southwest');
grid on;
ylim([0 60]);