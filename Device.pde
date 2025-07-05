import processing.serial.*;

class Device {
  static final int width = 14;
  static final int height = 8;
  
  static final int minTimeBetweenMovement = 500; // milliseconds
  
  boolean[] buffer = new boolean[128]; 
  boolean[][] electrodes = new boolean[Device.width][Device.height]; // ([x][y])
  
  Reservoir tlRes = new Reservoir(0, 0, 1, this);
  Reservoir_reversed blRes = new Reservoir_reversed(4, 0, 6, this);
  Reservoir trRes = new Reservoir(120, 13, 1, this);
  Reservoir_reversed brRes = new Reservoir_reversed(124, 13, 6, this);
  
  Serial serialport;
  
  // Unused
  int[] control_data_in = new int[24];
  int[] control_data_out = new int[14];
  
  Device() {
    // Enable all reservoirs in case of liquid
    tlRes.bOn();
    blRes.bOn();
    trRes.bOn();
    brRes.bOn();
  }
  
  Device(Serial serialport) {
    this.serialport = serialport;
    // Enable all reservoirs in case of liquid
    tlRes.bOn();
    blRes.bOn();
    trRes.bOn();
    brRes.bOn();
  }
  
  // Advanced operations
  void clear_device() {
    // Sweeps the surface into the bottom right reservoir
    // Enables whole surface and bottom right reservoir,
    // then gradually reduces enabled area from left to right,
    // top to bottom, until only the bottom right reservoir is
    // enabled. Then retracts liquid into reservoir.
    
    this.fill(true); // Enable whole surface
    
    // Enable bottom right reservoir
    this.brRes.sOn();
    this.brRes.cOn();
    this.brRes.rOn();
    this.brRes.bOn();
    
    for (int i = 0; i < Device.width - 1; i++) {
      this.fillColumn(i, false);
      this.write();
      delay(minTimeBetweenMovement);
    }
    this.electrodes[13][7] = false; // disable electrode below reservoir entrance
    for (int i = 0; i < Device.height - 2; i++) {
      this.electrodes[13][i] = false;
      this.write();
      delay(minTimeBetweenMovement);
    }
    
    this.electrodes[13][6] = false;
    this.write();
    delay(minTimeBetweenMovement);
    this.brRes.sOff();
    this.write();
    delay(minTimeBetweenMovement);
    this.brRes.cOff();
    this.brRes.rOff();
    this.write();
    delay(minTimeBetweenMovement);
  }
  
  // Basic fill operations
  void fill(boolean state) {
    for (int x = 0; x < electrodes.length; x++) {
      for (int y = 0; y < electrodes[x].length; y++) {
        electrodes[x][y] = state;
      }
    }
  }
  void fillColumn(int column, boolean state) {
    for (int y = 0; y < electrodes[column].length; y++) {
      electrodes[column][y] = state;
    }
  }
  void fillRow(int row, boolean state) {
    for (int x = 0; x < electrodes.length; x++) {
      electrodes[x][row] = state;
    }
  }
  
  void write() {
    // Copy main section to buffer
    for (int x = 0; x < electrodes.length; x++) {
      for (int y = 0; y < electrodes[x].length; y++) {
        buffer[8 + y + (x * 8)] = electrodes[x][y];
      }
    }
    
    if (serialport != null) {
      // Communicate with device
      
      while (serialport.available() > 0) serialport.read(); // Clear recieving buffer
      
      // Send display channels
      byte toTransmit;
      for (int i = 0; i < buffer.length; i += 8) {
        toTransmit = byte(buffer[i + 0]);
        toTransmit += byte(buffer[i + 1]);
        toTransmit += byte(buffer[i + 2]);
        toTransmit += byte(buffer[i + 3]);
        toTransmit += byte(buffer[i + 4]);
        toTransmit += byte(buffer[i + 5]);
        toTransmit += byte(buffer[i + 6]);
        toTransmit += byte(buffer[i + 7]);
        
        serialport.write(toTransmit);
      }
      
      // Send control lines (unused)
      serialport.write(0);
      serialport.write(0);
      
      // Send control data
      for (int i = 0; i < control_data_out.length; i++) {
        serialport.write(control_data_out[i]);
      }
      
      // todo: read control data, currently discarded on next transmit
    }
  }
}
