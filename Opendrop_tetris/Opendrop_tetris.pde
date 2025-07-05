Device d;
Serial serialport;

Electrode[] electrodeArray;

boolean gameRunning = false;

int lastFrame = 0;
final int timePerFrame = Device.minTimeBetweenMovement;

// shape of tetrominos, blockPos = [shapeIndex][blockIndex]
final int[][][] tetrominos = {
  // Line
  {{0, 0}, {1, 0},{2, 0},{3, 0}},
  // T
  {{0, 0}, {1, 0},{1, 1},{1, -1}},
  // L
  {{0, 0}, {1, 0},{2, 0},{2, -1}},
  // J
  {{0, 0}, {1, 0},{2, 0},{2, 1}}
};

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

  // Enable bottom line, supposed to always be on
  d.brRes.rOn();
  d.brRes.cOn();
  d.brRes.sOn();
  d.fillColumn(13, true);
  d.write();

  println("To clear screen, press space, to start game press enter");
}

void draw() {
  background(200);
  
  for (int i = 0; i < electrodeArray.length; i++) {
    electrodeArray[i].drawElectrode();
  }

  if (gameRunning && millis() - lastFrame > timePerFrame) {
    lastFrame = millis();
    thread("gameLoop");
  }
}

void gameLoop() {
  gameRunning = false;
  dispenseBlock();
}

void dispenseBlock() {
  Reservoir res = d.tlRes;

  // Open reservoir
  res.rOn();
  d.write();
  delay(timePerFrame);

  res.sOn();
  res.cOn();
  res.bOff();
  d.write();
  delay(timePerFrame);

  res.rOff();
  res.cOff();
  // Draw out 4 blocks
  d.electrodes[0][1] = true;
  d.write();
  delay(timePerFrame);

  d.electrodes[0][2] = true;
  d.write();
  delay(timePerFrame);

  d.electrodes[0][3] = true;
  d.write();
  delay(timePerFrame);

  d.electrodes[0][4] = true;
  d.write();
  delay(timePerFrame);

  // Close reservoir
  res.sOff();
  res.rOn();
  res.bOn();
  d.write();
  delay(timePerFrame);

  res.rOff();
  d.write();
  delay(timePerFrame);

  // select random tetromino
  int[][] tetromino = tetrominos[floor(random(4))];

  // Shape the 4 drops into tetromino
  d.electrodes[0][1] = false;
  d.electrodes[tetromino[0][0]][4 + tetromino[0][1]] = true;
  d.write();
  delay(timePerFrame);

  d.electrodes[0][2] = false;
  d.electrodes[tetromino[1][0]][4 + tetromino[1][1]] = true;
  d.write();
  delay(timePerFrame);

  d.electrodes[0][3] = false;
  d.electrodes[tetromino[2][0]][4 + tetromino[2][1]] = true;
  d.write();
  delay(timePerFrame);
}

void keyPressed() {
  thread("keyPressedThread");
}

// called by keyPressed
void keyPressedThread() {
  if (key == ' ') {
    println("Clearing screen, don't start game!");
    d.clear_device();
    // Enable bottom line, supposed to always be on
    d.brRes.rOn();
    d.brRes.cOn();
    d.brRes.sOn();
    d.fillColumn(13, true);
    d.write();
    println("Screen cleared, now you're allowed to start the game!");
  } else if (key == '\n') {
    println("Starting game...");
    gameRunning = true;
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
