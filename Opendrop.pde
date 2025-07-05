Device d;
Serial serialport;

void setup() {
  size(500, 500);
  
  try {
    // Init serial port
    String[] portList = Serial.list();
    if (portList == null || portList.length == 0) {
      println("Error: No serial ports found.");
      exit();
      return;
    }
  
    // List available serial ports
    println("Available serial ports:");
    printArray(portList);
    
    String portName = portList[0]; // Change the index if needed
    println("Connecting to: " + portName);
    serialport = new Serial(this, portName, 115200);
    d = new Device(serialport);
    println("Connected to device");
  } catch (Exception e) {
    d = new Device();
    println("Unable to connect, running without connection to device");
  }
  
}

void draw() {
  background(0);
}
