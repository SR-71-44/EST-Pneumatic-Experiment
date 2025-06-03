// === Data Acquisition Script ===

const int pressurePin = A1;  // Pressure sensor pin
const int airflowPin = A0;   // Airflow sensor pin

const float minPressure = 0.0;   // Pressure in Bar
const float maxPressure = 10.0;  // Max range of sensor in Bar

const float minAirflow = 20.0;   // Airflow in L/min
const float maxAirflow = 200.0;

const int sensorMaxValue = 1023; // 10-bit ADC resolution

// === Insert your calibrated offsets here ===
const int pressureZero = 69;  // <-- Replace with value from calibration script
const int airflowZero = 69;   // <-- Replace with value from calibration script

void setup() {
  Serial.begin(9600);
  delay(1000);  // Give time for Serial connection
  Serial.println("Pressure,Airflow");
}

void loop() {
  int pressureRaw = analogRead(pressurePin);
  int airflowRaw = analogRead(airflowPin);

  int pressureCorrected = pressureRaw - pressureZero;
  int airflowCorrected = airflowRaw - airflowZero;

  float pressure = mapf(pressureCorrected, 0, sensorMaxValue - pressureZero, minPressure, maxPressure);
  float airflow = mapf(airflowCorrected, 0, sensorMaxValue - airflowZero, minAirflow, maxAirflow);

  Serial.print(pressure);
  Serial.print(",");
  Serial.println(airflow);

  delay(100);  // 10Hz sample rate
}

// Floating-point map function
float mapf(float x, float in_min, float in_max, float out_min, float out_max) {
  if (abs(in_max - in_min) < 0.0001) return out_min;
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}