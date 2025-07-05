class Device {
  static final int minTimeBetweenMovement = 250; // milliseconds
  static final int width = 
  
  boolean[][] electrodes = new boolean[14][8]; // ([x][y])
  
  Device() {
  }
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
}
