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
  {{0, 0}, {1, 0},{2, 0},{2, 1}},
  // Square
  {{0, 0}, {1, 0},{0, 1},{1, 1}},
  // Zigzag 1
  {{0, 0}, {1, 0},{1, 1},{0, -1}},
  // Zigzag 2
  {{0, 0}, {1, 0},{1, -1},{0, 1}}
};

TetrominoPiece currPiece;

int nextDir;

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
  if (currPiece == null) {
    // Dispense block
    gameRunning = false; // pause game
    dispenseBlock();
    gameRunning = true; // unpause and wait for next frame
    return;
  }
  if (nextDir >= 37) {
    currPiece.off();
    switch (nextDir) {
      case RIGHT:
        currPiece.originPos[1]--;
        // Check collision,
        // if trying to move out of bounds, index out of bounds will be thrown
        try {
          if (currPiece.checkOn()) throw new Exception();
        } catch (Exception e) {
          currPiece.originPos[1]++;
        }
        break;
      case LEFT:
        currPiece.originPos[1]++;
        // Check collision,
        // if trying to move out of bounds, index out of bounds will be thrown
        try {
          if (currPiece.checkOn()) throw new Exception();
        } catch (Exception e) {
          currPiece.originPos[1]--;
        }
        break;
    }
    currPiece.on();
    nextDir = 0;
  }

  boolean couldFall = currPiece.tryFall();
  d.write();
  if (!couldFall) {
    // Piece has landed, forget this piece
    currPiece = null;
  }
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
  int i = floor(random(tetrominos.length));
  println("Creating tetromino " + i);
  int[][] tetromino = tetrominos[i];

  // Shape the 4 drops into tetromino
  d.electrodes[0][1] = false;
  d.electrodes[tetromino[1][0]][4 + tetromino[1][1]] = true;
  d.write();
  delay(timePerFrame);

  d.electrodes[0][2] = false;
  d.electrodes[tetromino[2][0]][4 + tetromino[2][1]] = true;
  d.write();
  delay(timePerFrame);

  d.electrodes[0][3] = false;
  d.electrodes[tetromino[3][0]][4 + tetromino[3][1]] = true;
  d.write();
  delay(timePerFrame);

  int[] originPos = {0, 4};
  currPiece = new TetrominoPiece(d, tetromino, originPos);
}

class TetrominoPiece {
  int[][] tetromino;
  int[] originPos;
  Device d;

  TetrominoPiece(Device device, int[][] tetromino, int[] originPos) {
    this.tetromino = tetromino;
    this.originPos = originPos;
    this.d = device;
  }

  boolean tryFall() {
    this.off(); // disable at curr pos
    originPos[0]++; // fall 1 block
    if (this.checkOn()) {
      // if any of the blocks are on, theres overlap. This tetromino has now reached the bottom.
      originPos[0]--; // raise back up
      this.on(); // reenable
      return false; // unable to fall further
    }
    this.on(); // reenable at new pos
    return true; // hasn't collided yet
  }

  boolean checkOn() {
    return
      d.electrodes[originPos[0] + tetromino[0][0]][originPos[1] + tetromino[0][1]] ||
      d.electrodes[originPos[0] + tetromino[1][0]][originPos[1] + tetromino[1][1]] ||
      d.electrodes[originPos[0] + tetromino[2][0]][originPos[1] + tetromino[2][1]] ||
      d.electrodes[originPos[0] + tetromino[3][0]][originPos[1] + tetromino[3][1]];
  }

  void on() {
    d.electrodes[originPos[0] + tetromino[0][0]][originPos[1] + tetromino[0][1]] = true;
    d.electrodes[originPos[0] + tetromino[1][0]][originPos[1] + tetromino[1][1]] = true;
    d.electrodes[originPos[0] + tetromino[2][0]][originPos[1] + tetromino[2][1]] = true;
    d.electrodes[originPos[0] + tetromino[3][0]][originPos[1] + tetromino[3][1]] = true;
  }
  
  void off() {
    d.electrodes[originPos[0] + tetromino[0][0]][originPos[1] + tetromino[0][1]] = false;
    d.electrodes[originPos[0] + tetromino[1][0]][originPos[1] + tetromino[1][1]] = false;
    d.electrodes[originPos[0] + tetromino[2][0]][originPos[1] + tetromino[2][1]] = false;
    d.electrodes[originPos[0] + tetromino[3][0]][originPos[1] + tetromino[3][1]] = false;
  }
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
  } else if (keyCode >= 37 && keyCode <= 40) { // arrow keys are 37-40
    nextDir = keyCode;
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
