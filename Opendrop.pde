Device d;
Serial serialport;

Electrode[] electrodeArray;

void setup() {
  size(420, 160);
  
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
    delay(100); // Ensure connection is stable
    d = new Device(serialport);
    println("Connected to device");
  } catch (Exception e) {
    println(e);
    
    d = new Device();
    println("Unable to connect, running without connection to device");
  }
  
  electrodesLoad();
}

void draw() {
  background(200);
  
  for (int i = 0; i < electrodeArray.length; i++) {
    electrodeArray[i].drawElectrode();
  }
}

void keyPressed() {
  thread("keyPressedThread");
}

// called by keyPressed
void keyPressedThread() {
  if (key == ' ') {
    println("clear");
    d.clear_device();
  } else if (key == 't') {
    println("tl");
    d.tlRes.dispense();
  } else if (key == 'g') {
    println("bl");
    d.blRes.dispense();
  } else if (key == 'y') {
    println("tr");
    d.trRes.dispense();
  } else if (key == 'h') {
    println("br");
    d.brRes.dispense();
  }
}

// Originates from official controller source code, modified
void electrodesLoad() {
  JSONArray electrodeJSON;
  electrodeJSON = loadJSONArray("electrodes.json");
  
  int electrodes_loaded=electrodeJSON.size();
  electrodeArray = new Electrode[electrodes_loaded];
  
  println("electrodes loaded " + electrodes_loaded);
  
  for (int i = 0; i < electrodes_loaded; i++) {
    JSONObject item = electrodeJSON.getJSONObject(i); 
    electrodeArray[i] = new Electrode();

    electrodeArray[i].x = item.getFloat("x") + 21;
    electrodeArray[i].y = item.getFloat("y") + 8;
    electrodeArray[i].w = item.getFloat("w");
    electrodeArray[i].h = item.getFloat("h");
    electrodeArray[i].i = item.getInt("i"); 
  }
}

// Originates from official controller source code, modified
class Electrode {
  float x;
  float y;
  float h;
  float w;
  int i;
  
  Electrode() {}
  
  void drawElectrode() {
    fill(d.buffer[i] ? 127 : 255);
    rect(x * 10, y * 10, w * 10, h * 10);
  }
}
