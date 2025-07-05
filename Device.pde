class Device {
  static final int width = 14;
  static final int height = 8;
  
  static final int minTimeBetweenMovement = 500; // milliseconds
  
  boolean[] buffer = new boolean[128]; 
  boolean[][] electrodes = new boolean[Device.width][Device.height]; // ([x][y])
  
  Reservoir tlRes = new Reservoir(buffer, 0);
  Reservoir_reversed blRes = new Reservoir_reversed(buffer, 4);
  Reservoir trRes = new Reservoir(buffer, 120);
  Reservoir_reversed brRes = new Reservoir_reversed(buffer, 124);
  
  Device() {
  }
  
  // Advanced operations
  void clear_device() { // Sweeps the surface into the bottom right reservoir
    this.fill(true); // Enable whole surface
    
    for (int i = 0; i < Device.width - 1; i++) {
      this.fillRow(i, false);
      this.write();
      delay(minTimeBetweenMovement);
    }
    for (int i = 0; i < Device.height - 2; i++) {
      this.electrodes[13][i] = false;
      this.write();
      delay(minTimeBetweenMovement);
    }
    
    this.electrodes[13][7] = false;
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
    for (int x = 0; x < electrodes.length; x++) {
      for (int y = 0; y < electrodes[x].length; y++) {
        buffer[8 + y + (x * 8)] = electrodes[x][y];
      }
    }
  }
}
