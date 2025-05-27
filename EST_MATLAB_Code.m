%% Collecting & Storing Data

% Defining constants
V_tank = 1e-3; % Tank volume [m^3] (1 liter)
p_env = 101325; % Atmospheric pressure [Pa]

% Error bar placeholders
pressure_error = 25e3;    % Pressure sensor error [Pa]
airflow_error = 6e-5;     % Airflow sensor error [m^3/s]

% Theoretical efficiency placeholder (Replace 69 with real value)
theoretical_efficiency = 69;

% Connecting to Arduino
s = serial('COM5', 'BaudRate', 9600);
fopen(s);

% Initialize data storage
pressureData = [];
airflowData = [];
timeData = [];

disp('Reading data from Arduino... Press Ctrl+C to stop when done.');

tic; % Start time counter

try
    while true
        dataLine = fgetl(s);
        if isempty(dataLine)
            continue;
        end
        C = strsplit(strtrim(dataLine), ','); % Remove extra spaces
        if length(C) < 2
            continue;
        end

        % Read values directly from Arduino (pressure in Bar, airflow in L/min)
        pressure_bar = str2double(C{1});
        airflow_Lmin = str2double(C{2});

        % Time
        t = toc;
        timeData = [timeData; t];

        % Convert units
        pressure_Pa = pressure_bar * 1e5; % Bar to Pa
        airflow_m3s = airflow_Lmin / 60000; % L/min to m^3/s

        % Store data
        pressureData = [pressureData; pressure_Pa];
        airflowData = [airflowData; airflow_m3s];

        % Display
        fprintf('Time: %.2f s | Pressure: %.2f bar | Flow: %.4f m^3/s\n', ...
            t, pressure_bar, airflow_m3s);
    end
catch
    disp('Data collection stopped.');
    fclose(s);
end

% Close serial connection
fclose(s);

% Save data
save('sensor_data.mat', 'pressureData', 'airflowData', 'timeData');

%% Calculate Efficiency

% Energy input (constant p0 at start)
p0 = pressureData(1); % Assuming initial pressure
Ein = p0 * V_tank * log(p0 / p_env);

% Energy output (numerical integration)
Edot = pressureData .* airflowData .* log(pressureData / p_env); % Instantaneous power [W]
Eout = trapz(timeData, Edot); % Energy output [J]

% Efficiency
calculated_efficiency = (Eout / Ein) * 100;

%% Plotting

figure;

% Error bars for pressure
yyaxis left;
errorbar(timeData, pressureData/1e5, pressure_error/1e5 * ones(size(pressureData)), ...
    'b-', 'LineWidth', 1.5);
ylabel('Pressure [bar]');

% Error bars for airflow
yyaxis right;
errorbar(timeData, airflowData*60000, airflow_error*60000 * ones(size(airflowData)), ...
    'r--', 'LineWidth', 1.5);
ylabel('Flow rate [L/min]');

xlabel('Time [s]');
title(sprintf('Calculated Efficiency: %.2f %% | Theoretical Efficiency: %.2f %%', ...
    calculated_efficiency, theoretical_efficiency));
grid on;
legend('Pressure', 'Airflow');

% Display efficiencies
fprintf('Calculated Efficiency: %.2f %%\n', calculated_efficiency);
fprintf('Theoretical Efficiency (placeholder): %.2f %%\n', theoretical_efficiency);
