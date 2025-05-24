const int pressurePin = A1;  // Defining the analog input pin connected to the sensor
const int airflowPin = A0;
const int sensorMinValue = 204;  // Corresponds to 1V (1/5 * 1023)
const int sensorMaxValue = 1023;  // Corresponds to 5V (5/5 * 1023)
const float minPressure = 0.0;  // Minimum pressure (0 mPa)
const float maxPressure = 1.0;  // Maximum pressure (1 mPa)

void setup() {

  Serial.begin(9600);  // Initializing serial communication at 9600 baud

}

void loop() {

float airflowValue = analogRead(airflowPin);  // Reading the analog value from the sensor (0-1023)
float pressureValue = analogRead(pressurePin);  // Reading the analog value from the sensor (0-1023)

  // Mapping the sensor value to the pressure value

  float pressure = mapf(pressureValue, sensorMinValue, sensorMaxValue, 0, 10);
  float airflow = mapf(airflowValue, sensorMinValue, sensorMaxValue, 20, 200);

  // Printing the sensor value and pressure
  
  Serial.print("Pressure Sensor Value: ");
  Serial.print(pressureValue);
  Serial.print("  Pressure: ");
  Serial.print(pressure);
  Serial.print(" Bar ");

  Serial.print("airflowSensor Value: ");
  Serial.print(airflowValue);
  Serial.print("  airflow: ");
  Serial.print(airflow);
  Serial.println(" L/min");

  delay(500);  // Wait for 1 second before the next reading

}

float mapf(float x, float in_min, float in_max, float out_min, float out_max)
{

  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;

}