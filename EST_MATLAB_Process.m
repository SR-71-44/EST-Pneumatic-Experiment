%% Data Processing Script

% Load data
load('simulated_sensor_data.mat');  % Replace with correct .mat file if needed

% Constants
V_tank = 1e-3;       % [m^3]
p_env = 101325;      % [Pa]
theoretical_efficiency = 99.5;  % Replace with real value

% Sensor error values
pressure_error_bar = 0.1;        % ±0.25 bar
airflow_error_Lmin = 3.6;         % ±3.6 L/min

% === Step 1: Filter Out Constant Plateaus ===
dp = abs(diff(pressureData));
df = abs(diff(airflowData));
dp = [dp; dp(end)];
df = [df; df(end)];

tolerance_p = 5;       % Pa
tolerance_f = 1e-6;    % m³/s

validIndices = (dp > tolerance_p) | (df > tolerance_f);

% Apply filter
pressureData = pressureData(validIndices);
airflowData = airflowData(validIndices);
timeData = timeData(validIndices);

% === Step 2: Efficiency Calculation ===
p0 = pressureData(1);
Ein = p0 * V_tank * log(p0 / p_env);

Edot = pressureData .* airflowData .* log(pressureData / p_env);  % W
Eout = trapz(timeData, Edot);  % J

calculated_efficiency = (Eout / Ein) * 100;

% === Step 3: Plotting ===

% --- Plot 1: Pressure over time ---
figure;
errorbar(timeData, pressureData / 1e5, ...
         pressure_error_bar * ones(size(pressureData)), ...
         'b-', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Pressure [bar]');
title(sprintf('Pressure [bar] vs Time [s] | Calculated Efficiency: %.2f %% | Theoretical Efficiency: %.2f %%', ...
    calculated_efficiency, theoretical_efficiency));
grid on;
legend('Pressure');

% --- Plot 2: Airflow over time ---
figure;
errorbar(timeData, airflowData * 60000, ...
         airflow_error_Lmin * ones(size(airflowData)), ...
         'r--', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Flow rate [L/min]');
title(sprintf('Flow rate [L/min] vs Time [s] | Calculated Efficiency: %.2f %% | Theoretical Efficiency: %.2f %%', ...
    calculated_efficiency, theoretical_efficiency));
grid on;
legend('Airflow');

% === Step 4: Console Output ===
fprintf('Calculated Efficiency: %.2f %%\n', calculated_efficiency);
fprintf('Theoretical Efficiency: %.2f %%\n', theoretical_efficiency);
