import processing.serial.*;     // import serial library

Serial arduinoport;             // declare a serial port
float x, y;                     // variable to store x and y co-ordinates for vertices   
int radius = 350;               // set the radius of objects
int w = 300;                    // set an arbitary width value
int degree = 0;                 // servo position in degrees
int value = 0;                  // value from sensor
int motion = 0;                 // value to store which way the servo is panning
int[] newValue = new int[181];  // create an array to store each new sensor value for each servo position
int[] oldValue = new int[181];  // create an array to store the previous values.
PFont myFont;                   // setup fonts in Processing
int radarDist = 0;              // set value to configure Radar distance labels
int firstRun = 0;               // value to ignore triggering motion on the first 2 servo sweeps


/* create background and serial buffer */
void setup(){
// setup the background size, colour and font.
size(750, 435);
background (0); // 0 = black
myFont = createFont("verdana", 12);
textFont(myFont);

// setup the serial port and buffer
//##############
arduinoport = new Serial(this,"COM3", 9600);
}
/* draw the screen */
void draw(){
  fill(0);                              // set the following shapes to be black
  noStroke();                           // set the following shapes to have no outline
  ellipse(radius, radius, 750, 750);    // draw a circle with a width/ height = 750 with its center position (x and y) set by the radius
  rectMode(CENTER);                     // set the following rectangle to be drawn around its center
  rect(350,402,800,100);                // draw rectangle (x, y, width, height)
  if (degree >= 179) {                  // if at the far right then set motion = 1/ true we're about to go right to left
  motion = 1;                         // this changes the animation to run right to left
  }
  if (degree <= 1) {                    // if servo at 0 degrees then we're about to go left to right
  motion = 0;                         // this sets the animation to run left to right
  }
/* setup the radar sweep */
setupSweep();
/* Setup the shapes made from the sensor values */
SetupShapes();
/* if after first 2 sweeps, highlight motion with red circle*/
drawObject();
/* set the radar distance rings and out put their values, 50, 100, 150 etc.. */
/* draw the grid lines on the radar every 30 degrees and write their values 180, 210, 240 etc.. */
drawRadar();
/* Write information text and values. */
drawText();

}
/* get values from serial port */
void serialEvent (Serial arduinoport) {
    String xString = arduinoport.readStringUntil('\n');  // read the serial port until a new line
    if (xString != null) {  // if theres data in between the new lines
    xString = trim(xString); // get rid of any whitespace just in case
    String getX = xString.substring(1, xString.indexOf("V")); // get the value of the servo position
    String getV = xString.substring(xString.indexOf("V")+1, xString.length()); // get the value of the sensor reading
    degree = Integer.parseInt(getX); // set the values to variables
    value = Integer.parseInt(getV);
    oldValue[degree] = newValue[degree]; // store the values in the arrays.
    newValue[degree] = value;  
    /* sets a counter to allow for the first 2 sweeps of the servo */
    firstRun++;
    if (firstRun > 360) {
    firstRun = 360; // keep the value at 360 
    }
    }
}

void setupSweep(){
  strokeWeight(7);                      // set the thickness of the lines
  if (motion == 0) {                    // if going left to right
  for (int i = 0; i <= 20; i++) {     // draw 20 lines with fading colour each 1 degree further round than the last
  stroke(0, (10*i), 0);             // set the stroke colour (Red, Green, Blue) base it on the the value of i
  line(radius, radius, radius + cos(radians(degree+(180+i)))*w, radius + sin(radians(degree+(180+i)))*w); // line(start x, start y, end x, end y)
  }
  } else {                              // if going right to left
  for (int i = 20; i >= 0; i--) {     // draw 20 lines with fading colour
  stroke(0,200-(10*i), 0);          // using standard RGB values, each between 0 and 255
  line(radius, radius, radius + cos(radians(degree+(180+i)))*w, radius + sin(radians(degree+(180+i)))*w);
  }
  }   
}
void SetupShapes(){
  noStroke();                           // no outline
  /* first sweep */
  fill(0,50,0);                         // set the fill colour of the shape (Red, Green, Blue)
  beginShape();                         // start drawing shape
  for (int i = 0; i < 180; i++) {     // for each degree in the array
  x = radius + cos(radians((180+i)))*((oldValue[i])); // create x coordinate
  y = radius + sin(radians((180+i)))*((oldValue[i])); // create y coordinate
  vertex(x, y);                     // plot vertices
  }
  endShape();                           // end shape
  /* second sweep */
  fill(0,110,0);
  beginShape();
  for (int i = 0; i < 180; i++) {
  x = radius + cos(radians((180+i)))*(newValue[i]);
  y = radius + sin(radians((180+i)))*(newValue[i]);
  vertex(x, y);
  }
  endShape();
  /* average */
  fill(0,170,0);
  beginShape();
  for (int i = 0; i < 180; i++) {
  x = radius + cos(radians((180+i)))*((newValue[i]+oldValue[i])/2); // create average
  y = radius + sin(radians((180+i)))*((newValue[i]+oldValue[i])/2);
  vertex(x, y);
  }
  endShape();
}
void drawObject() {
  if (firstRun >= 360) {
  stroke(250,103,0);
  strokeWeight(1);
  noFill();
  for (int i = 0; i < 180; i++) {
  if (oldValue[i] - newValue[i] > 35 || newValue[i] - oldValue[i] > 35) {
  x = radius + cos(radians((180+i)))*(newValue[i]);
  y = radius + sin(radians((180+i)))*(newValue[i]);
  ellipse(x, y, 10, 10); 
  }
  }
  } 
}
void drawRadar() {
  for (int i = 0; i <=6; i++){
    noFill();
    strokeWeight(1);
    stroke(0, 255-(30*i), 0);
    arc(radius, radius, (100*i), (100*i),PI,TWO_PI); 
    fill(250, 103, 0);
    noStroke();
    text(Integer.toString(radarDist+50), 380, (305-radarDist), 50, 50);
    radarDist+=50;
    }
  radarDist = 0;
  
  for (int i = 0; i <= 6; i++) {
    strokeWeight(1);
    stroke(0, 55, 0);
    line(radius, radius, radius + cos(radians(180+(30*i)))*w, radius + sin(radians(180+(30*i)))*w);
    fill(153, 153, 153);
    noStroke();
    if (180+(30*i) >= 300) {
    text(Integer.toString(180+(30*i)), (radius+10) + cos(radians(180+(30*i)))*(w+10), (radius+10) + sin(radians(180+(30*i)))*(w+10), 25,50);
    } else {
    text(Integer.toString(180+(30*i)), radius + cos(radians(180+(30*i)))*w, radius + sin(radians(180+(30*i)))*w, 60,40);
    }
  }
  
}

 void drawText(){
  noStroke();
  fill(0);
  rect(350,402,900,100);
  fill(0, 100, 0);
  text("Degrees: "+Integer.toString(degree), 100, 380, 100, 50);         // use Integet.toString to convert numeric to string as text() only outputs strings
  text("Distance: "+Integer.toString(value), 100, 400, 100, 50);         // text(string, x, y, width, height)
  if (value < 300)
    text("Object: "+"In Range", 390, 380, 200, 50);
  else
    text("Object: "+"Out Of Range", 390, 380, 200, 50);
  fill(250,103,0);
  rect(30,420,2000,30);
  fill(255, 255, 255);
  text("GeeksValley.com ", 100, 427, 103, 30);
  text("@GeeksValley", 350, 427, 100, 30);
  text("+Geeksvalleycom", 600, 427, 108, 30);
  fill(0);
  rect(70,60,150,100);
  fill(0, 100, 0); 
  text("Screen Key:", 100, 50, 150, 50);
  fill(0,50,0);
  rect(30,53,10,10);
  text("First sweep", 115, 70, 150, 50);
  fill(0,110,0);
  rect(30,73,10,10);
  text("Second sweep", 115, 90, 150, 50);
  fill(0,170,0);
  rect(30,93,10,10);
  text("Average", 115, 110, 150, 50);
  noFill();
  stroke(250,103,0);
  strokeWeight(1);
  ellipse(29, 113, 10, 10); 
  fill(250,103,0);
  text("Motion", 115, 130, 150, 50);
  
 }
 
