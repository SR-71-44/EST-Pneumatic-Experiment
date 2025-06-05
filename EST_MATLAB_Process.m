%% Data Processing with Efficiency Uncertainty

% --- Load Data ---
load('simulated_sensor_data.mat');  % Replace with your actual .mat file

% --- Constants ---
V_tank = 1e-3;            % [m^3]
p_env = 101325;           % [Pa]
theoretical_efficiency = 99.51;  % Example theoretical value [%]

% --- Sensor Errors ---
pressure_error_Pa = 1e4;             % ±0.1 bar = 10,000 Pa
airflow_error_m3s = 3.6 / 60 / 1000; % ±3.6 L/min → m^3/s

% --- Filter Plateaus ---
dp = abs(diff(pressureData));
df = abs(diff(airflowData));
dp = [dp; dp(end)];
df = [df; df(end)];

tolerance_p = 5;        % Pa
tolerance_f = 1e-6;     % m³/s
validIndices = (dp > tolerance_p) | (df > tolerance_f);

% Apply Filter
pressureData = pressureData(validIndices);
airflowData = airflowData(validIndices);
timeData = timeData(validIndices);

% --- Efficiency Calculation ---
p0 = pressureData(1);  % Initial pressure
Ein = p0 * V_tank * log(p0 / p_env);  % Ideal isothermal stored energy

% Calculate instantaneous power
log_term = log(pressureData / p_env);
Edot = pressureData .* airflowData .* log_term;

% Partial derivatives for uncertainty
dE_dp = airflowData .* (log_term + 1);
dE_dV = pressureData .* log_term;

% Variance of instantaneous power
var_Edot = (dE_dp.^2) * pressure_error_Pa^2 + (dE_dV.^2) * airflow_error_m3s^2;

% Integrate to get total energy output and its uncertainty
Eout = trapz(timeData, Edot);
var_Eout = trapz(timeData, var_Edot);  % Total variance
std_Eout = sqrt(var_Eout);            % Standard deviation

% Efficiency and its uncertainty
calculated_efficiency = (Eout / Ein) * 100;
efficiency_error = (std_Eout / Ein) * 100;

% --- Plot Pressure with Error Bars ---
figure;
errorbar(timeData, pressureData / 1e5, ...
         0.1 * ones(size(pressureData)), 'b-', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Pressure [bar]');
title(sprintf('Pressure [bar] vs Time [s] | Calculated Efficiency: %.2f ± %.2f %% | Theoretical Efficiency: %.2f %%', ...
    calculated_efficiency, efficiency_error, theoretical_efficiency));
grid on;
legend('Pressure');

% --- Plot Airflow with Error Bars ---
figure;
errorbar(timeData, airflowData * 60000, ...
         3.6 * ones(size(airflowData)), 'r--', 'LineWidth', 1.5);
xlabel('Time [s]');
ylabel('Flow Rate [L/min]');
title(sprintf('Flow Rate [L/min] vs Time [s] | Calculated Efficiency: %.2f ± %.2f %% | Theoretical Efficiency: %.2f %%', ...
    calculated_efficiency, efficiency_error, theoretical_efficiency));
grid on;
legend('Airflow');

% --- Console Output ---
fprintf('Calculated Efficiency: %.2f ± %.2f %%\n', ...
    calculated_efficiency, efficiency_error);
fprintf('Theoretical Efficiency: %.2f %%\n', theoretical_efficiency);
