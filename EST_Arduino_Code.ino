const int pressurePin = A1;  // Analog input pin for the pressure sensor
const int airflowPin = A0;   // Analog input pin for the airflow sensor

const int sensorMinValue = 204;  // Corresponds to 1V (1/5 * 1023)
const int sensorMaxValue = 1023; // Corresponds to 5V (5/5 * 1023)

const float minPressure = 0.0;   // Minimum pressure (0 MPa)
const float maxPressure = 1.0;   // Maximum pressure (1 MPa)

int pressureOffset = 0;  // Offset for pressure sensor
int airflowOffset = 0;   // Offset for airflow sensor

void setup() {

  Serial.begin(9600);     // Start serial communication
  calibrateSensors();     // Calibrate sensors at startup

}

void loop() {

  // Read raw sensor values

  float airflowValue = analogRead(airflowPin);
  float pressureValue = analogRead(pressurePin);

  // Apply calibration offsets

  airflowValue -= airflowOffset;
  pressureValue -= pressureOffset;

  // Map raw values to physical quantities

  float pressure = mapf(pressureValue, sensorMinValue, sensorMaxValue, 0, 10);   // Pressure in Bar
  float airflow = mapf(airflowValue, sensorMinValue, sensorMaxValue, 20, 200);   // Airflow in L/min

  // Print values

  Serial.print("Pressure Sensor Value: ");
  Serial.print(pressureValue);
  Serial.print("  Pressure: ");
  Serial.print(pressure);
  Serial.print(" Bar   ");

  Serial.print("Airflow Sensor Value: ");
  Serial.print(airflowValue);
  Serial.print("  Airflow: ");
  Serial.print(airflow);
  Serial.println(" L/min");

  delay(500);  // Read every 0.5 seconds
}

// Floating-point map function

float mapf(float x, float in_min, float in_max, float out_min, float out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

// Calibration function

void calibrateSensors() {
  const int samples = 50;    // Number of samples for calibration
  long pressureSum = 0;
  long airflowSum = 0;

  Serial.println("Calibrating sensors...");

  for (int i = 0; i < samples; i++) {
    pressureSum += analogRead(pressurePin);
    airflowSum += analogRead(airflowPin);
    delay(10);  // Small delay between samples
  }

  int pressureAverage = pressureSum / samples;
  int airflowAverage = airflowSum / samples;

  pressureOffset = pressureAverage - sensorMinValue;
  airflowOffset = airflowAverage - sensorMinValue;

  Serial.println("Calibration complete:");
  Serial.print("Pressure Offset = ");
  Serial.println(pressureOffset);
  Serial.print("Airflow Offset = ");
  Serial.println(airflowOffset);
  
}
