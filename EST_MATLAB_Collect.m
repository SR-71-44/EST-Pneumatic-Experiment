%% Data Collection Script

% Setup
serialPort = 'COM4';  % Adjust if needed
baudRate = 9600;
timeLimit = 10;       % Duration of data collection in seconds

% Initialize serial connection
s = serial(serialPort, 'BaudRate', baudRate);
fopen(s);

% Initialize storage
pressureData = [];
airflowData = [];
timeData = [];

disp('Starting data collection from Arduino...');

tic;
try
    while toc < timeLimit
        dataLine = fgetl(s);
        if isempty(dataLine)
            continue;
        end

        % Parse line (expected format: "pressure,airflow")
        C = strsplit(strtrim(dataLine), ',');
        if length(C) < 2
            continue;
        end

        % Convert to numeric
        pressure_bar = str2double(C{1});
        airflow_Lmin = str2double(C{2});
        t = toc;

        % Unit conversion
        pressure_Pa = pressure_bar * 1e5;       % bar → Pa
        airflow_m3s = airflow_Lmin / 60000;     % L/min → m³/s

        % Store
        pressureData = [pressureData; pressure_Pa];
        airflowData = [airflowData; airflow_m3s];
        timeData = [timeData; t];

        % Console display
        fprintf('Time: %.2f s | Pressure: %.2f bar | Flow: %.4f m³/s\n', ...
            t, pressure_bar, airflow_m3s);
    end
    disp('Data collection complete.');
catch
    disp('Error during data collection.');
end

% Cleanup
fclose(s);

% Save to file
save('sensor_data.mat', 'pressureData', 'airflowData', 'timeData');
disp('Data saved to sensor_data.mat');