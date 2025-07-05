class Reservoir {
  boolean[] buffer;
  int startI;
  int sOffset = 0;
  int cOffset = 1;
  int rOffset = 2;
  int bOffset = 3;
  Reservoir(boolean[] buffer, int startI) {
    this.buffer = buffer;
    this.startI = startI;
  }
  // Square
  void sOn() {
    buffer[startI + sOffset] = true;
  }
  void sOff() {
    buffer[startI + sOffset] = false;
  }
  // Colon
  void cOn() {
    buffer[startI + cOffset] = true;
  }
  void cOff() {
    buffer[startI + cOffset] = false;
  }
  // Rectangle
  void rOn() {
    buffer[startI + rOffset] = true;
  }
  void rOff() {
    buffer[startI + rOffset] = false;
  }
  // Big C
  void bOn() {
    buffer[startI + bOffset] = true;
  }
  void bOff() {
    buffer[startI + bOffset] = false;
  }
}
