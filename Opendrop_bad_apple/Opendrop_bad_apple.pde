import processing.video.*;
Movie myMovie;

Device d;
Serial serialport;

Electrode[] electrodeArray;

final boolean wipeBeforeDraw = false;

boolean captureEnabled = false;
Capture cap;
int capFrameI = 0;

boolean playing = true;
int lastFrame;
int timePerFrame = 500;
int timeTilWipe = 800;

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

  if (captureEnabled) {
    try {
      // Init capture
      String[] cameras = Capture.list();
      if (cameras == null || cameras.length == 0) {
        println("Error: No capture devices found.");
        exit();
        return;
      }
      
      println("Available capture devices:");
      printArray(cameras);
      
      String camName = cameras[0]; // Change the index if needed
      println("Connecting to: " + camName);
      cap = new Capture(this, camName);
      cap.start();
      println("Connected to camera");
    } catch (Exception e) {
      println(e);
      
      println("Unable to connect to camera, running without frame capture");
      captureEnabled = false;
    }
  }

  
  
  electrodesLoad();
  myMovie = new Movie(this, "./apple.mp4");
  myMovie.play();
  myMovie.speed(1);
  myMovie.jump(1);

  // enable all reservoirs for max liquid availability
  d.tlRes.rOn();
  d.tlRes.sOn();
  d.tlRes.cOn();
  d.blRes.rOn();
  d.blRes.sOn();
  d.blRes.cOn();
  d.trRes.rOn();
  d.trRes.sOn();
  d.trRes.cOn();
  d.brRes.rOn();
  d.brRes.sOn();
  d.brRes.cOn();

  frameRate(60);
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}
void captureEvent(Capture c) {
  c.read();
}

void draw() {
  background(200);

  if (playing && millis() - lastFrame > timePerFrame) {
    lastFrame = millis();
    playing = false;
    thread("animate");
  }
  
  for (int i = 0; i < electrodeArray.length; i++) {
    electrodeArray[i].drawElectrode();
  }
  image(myMovie, 0, 0);

  
}

void animate() {
  myMovie.loadPixels();

  d.fill(true);
  
  if (wipeBeforeDraw) {
    myMovie.pause();
    d.write();
    delay(timeTilWipe);
    for (int i = 0; i < 5; i++) {
      // d.fillColumn(6 - i, false);
      // d.fillColumn(7 + i, false);
      for (int j = 0; j < 8; j++) {
        d.electrodes[6 - i][j] = (myMovie.get(4 - i, j) & 0xff) > 127;
        d.electrodes[7 + i][j] = (myMovie.get(5 + i, j) & 0xff) > 127;
      }
      d.write();
      delay(timePerFrame);
    }
    myMovie.play();
    delay(timePerFrame);
    if (captureEnabled) {
      // PGraphics pg;
      // pg = createGraphics(cap.width, cap.height, JAVA2D);
      // pg.beginDraw(); // Start drawing to the PGraphics object  
      // pg.set(0, 0, cap)
      // pg.endDraw(); // Start drawing to the PGraphics object  
      // pg.save("a.png");
      cap.save("frames/" + String.format("%05d", capFrameI) + ".jpg");
      capFrameI++;
    }
  } else {
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 8; j++) {
        d.electrodes[i+2][j] = (myMovie.get(i, j) & 0xff) > 127;
      }
    }
    d.write();
    if (captureEnabled) {
      delay(timePerFrame/2);
      cap.save("frames/" + String.format("%05d", capFrameI) + ".jpg");
      capFrameI++;
    }
  }
  playing = true;
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
