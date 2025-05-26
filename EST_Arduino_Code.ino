const int pressurePin = A1;  // Analog input pin for the pressure sensor
const int airflowPin = A0;   // Analog input pin for the airflow sensor

const float minPressure = 0.0;   // Minimum pressure (0 MPa)
const float maxPressure = 10.0;  // Maximum pressure (10 Bar)

const float minAirflow = 20.0;   // Minimum airflow (20 L/min)
const float maxAirflow = 200.0;  // Maximum airflow (200 L/min)

// Calibration offsets (measured raw ADC values at 0 pressure/flow)
int pressureZero = 0;
int airflowZero = 0;

const int sensorMaxValue = 1023; // 5V

void setup() {
  Serial.begin(9600);
  calibrateSensors();
}

void loop() {
  // Read raw sensor values
  int pressureRaw = analogRead(pressurePin);
  int airflowRaw = analogRead(airflowPin);

  // Apply calibration: shift raw values so zero point matches zero pressure/flow
  int pressureCorrected = pressureRaw - pressureZero;
  int airflowCorrected = airflowRaw - airflowZero;

  // Map corrected values to physical quantities
  float pressure = mapf(pressureCorrected, 0, sensorMaxValue - pressureZero, minPressure, maxPressure);
  float airflow = mapf(airflowCorrected, 0, sensorMaxValue - airflowZero, minAirflow, maxAirflow);

  // Print results
  Serial.print("Pressure Raw: ");
  Serial.print(pressureRaw);
  Serial.print(" | Pressure Corrected: ");
  Serial.print(pressureCorrected);
  Serial.print(" | Pressure: ");
  Serial.print(pressure);
  Serial.println(" Bar");

  Serial.print("Airflow Raw: ");
  Serial.print(airflowRaw);
  Serial.print(" | Airflow Corrected: ");
  Serial.print(airflowCorrected);
  Serial.print(" | Airflow: ");
  Serial.print(airflow);
  Serial.println(" L/min");

  delay(500);
}

// Floating-point map function
float mapf(float x, float in_min, float in_max, float out_min, float out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

// Calibration function
void calibrateSensors() {
  const int samples = 50;
  long pressureSum = 0;
  long airflowSum = 0;

  Serial.println("Calibrating sensors... Please keep the system at zero pressure and flow.");

  for (int i = 0; i < samples; i++) {
    pressureSum += analogRead(pressurePin);
    airflowSum += analogRead(airflowPin);
    delay(10);
  }

  pressureZero = pressureSum / samples;
  airflowZero = airflowSum / samples;

  Serial.println("Calibration complete:");
  Serial.print("Pressure Zero Point (ADC) = ");
  Serial.println(pressureZero);
  Serial.print("Airflow Zero Point (ADC) = ");
  Serial.println(airflowZero);
}
