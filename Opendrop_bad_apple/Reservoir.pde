class Reservoir {
  int startI;
  int dispenseX; // X coordinate of electrode just outside reservoir
  int dispenseY; // Y coordinate of electrode just outside reservoir
  int sOffset = 0;
  int cOffset = 1;
  int rOffset = 2;
  int bOffset = 3;
  Device d;
  Reservoir(int startI, int dispenseX, int dispenseY, Device d) {
    this.startI = startI;
    this.dispenseX = dispenseX;
    this.dispenseY = dispenseY;
    this.d = d;
  }
  void dispense() {
    // Initial state (frame 1)
    bOn();
    rOff();
    cOff();
    sOff();
    d.electrodes[dispenseX][dispenseY] = false;
    // No need to write, as reservoir should already be in this state
    //d.write();
    //delay(Device.minTimeBetweenMovement);
    // Frame 2
    rOn();
    d.write();
    delay(Device.minTimeBetweenMovement);
    // Frame 3
    cOn();
    sOn();
    bOff();
    d.write();
    delay(Device.minTimeBetweenMovement);
    // Frame 4
    rOff();
    cOff();
    d.electrodes[dispenseX][dispenseY] = true;
    d.write();
    delay(Device.minTimeBetweenMovement);
    // Frame 5
    sOff();
    rOn();
    bOn();
    d.write();
    delay(Device.minTimeBetweenMovement);
    // Frame 6
    rOff();
    d.write();
    delay(Device.minTimeBetweenMovement);
  }
  
  // Square
  void sOn() {
    d.buffer[startI + sOffset] = true;
  }
  void sOff() {
    d.buffer[startI + sOffset] = false;
  }
  // Colon
  void cOn() {
    d.buffer[startI + cOffset] = true;
  }
  void cOff() {
    d.buffer[startI + cOffset] = false;
  }
  // Rectangle
  void rOn() {
    d.buffer[startI + rOffset] = true;
  }
  void rOff() {
    d.buffer[startI + rOffset] = false;
  }
  // Big C
  void bOn() {
    d.buffer[startI + bOffset] = true;
  }
  void bOff() {
    d.buffer[startI + bOffset] = false;
  }
}
