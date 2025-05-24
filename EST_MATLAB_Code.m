%% Collecting & Storing Data

% Defining constants

V_tank = 1e-3; % Tank volume [m^3] (1 liter)
p_env = 101325; % Atmospheric pressure [Pa]

% Connecting to Arduino

s = serial('COM5', 'BaudRate', 9600);
fopen(s);

% Initializing data storage

pressureData = [];
airflowData = [];
timeData = [];

disp('Reading data from Arduino... Press Ctrl+C to stop when done.');

tic; % Starting time counter

try
    while true
        dataLine = fgetl(s);
        if isempty(dataLine)
            continue;
        end
        C = strsplit(dataLine, ',');
        if length(C) < 2
            continue;
        end
        p_raw = str2double(C{1});
        a_raw = str2double(C{2});

        % Time

        t = toc;
        timeData = [timeData; t];

        % Convert raw values to physical quantities
        % Your Arduino code maps these:
        % Pressure [bar] = map from 0-1023 to 0-10 bar --> Convert to Pa
        pressure_bar = p_raw * (10 / 1023); % Adjust if mapf is different
        pressure_Pa = pressure_bar * 1e5; % Convert bar to Pa

        % Airflow [L/min] = map from 0-1023 to 20-200 L/min --> Convert to m^3/s
        airflow_Lmin = a_raw * (180 / 819) + 20; % (200-20)/(1023-204) = ~0.22
        airflow_m3s = airflow_Lmin / 60000;

        % Storing data

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
efficiency = (Eout / Ein) * 100;

%% Plotting

figure;
yyaxis left;
plot(timeData, pressureData/1e5, 'b-', 'LineWidth', 1.5); % Pressure in bar
ylabel('Pressure [bar]');
yyaxis right;
plot(timeData, airflowData*60000, 'r--', 'LineWidth', 1.5); % Airflow in L/min
ylabel('Flow rate [L/min]');
xlabel('Time [s]');
title(sprintf('Discharge Efficiency: %.2f %%', efficiency));
grid on;

legend('Pressure', 'Airflow');

disp(['Efficiency: ', num2str(efficiency), ' %']);