// === Calibration Script ===

const int pressurePin = A1;  // Pressure sensor pin
const int airflowPin = A0;   // Airflow sensor pin

void setup() {
  Serial.begin(9600);
  delay(1000);  // Give time to open serial monitor

  const int samples = 50;
  long pressureSum = 0;
  long airflowSum = 0;

  Serial.println("Starting calibration...");
  Serial.println("Ensure ZERO pressure and airflow during this process.");

  for (int i = 0; i < samples; i++) {
    int p = analogRead(pressurePin);
    int a = analogRead(airflowPin);

    pressureSum += p;
    airflowSum += a;

    Serial.print("Sample ");
    Serial.print(i + 1);
    Serial.print(" - Pressure ADC: ");
    Serial.print(p);
    Serial.print(" | Airflow ADC: ");
    Serial.println(a);

    delay(100);  // 0.1s between samples
  }

  int pressureZero = pressureSum / samples;
  int airflowZero = airflowSum / samples;

  Serial.println("\n=== Calibration Complete ===");
  Serial.print("Pressure Offset (ADC) = ");
  Serial.println(pressureZero);
  Serial.print("Airflow Offset (ADC) = ");
  Serial.println(airflowZero);
}

void loop() {
  // Nothing to do here
}
