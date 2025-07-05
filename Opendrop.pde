import processing.serial.*;

Device d = new Device();

void setup() {
  size(500, 500);
  printArray(Serial.list());
}

void draw() {
  background(0);
}
