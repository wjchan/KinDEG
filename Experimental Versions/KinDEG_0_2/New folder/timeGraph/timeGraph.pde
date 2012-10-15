float[] values = new float[20];
float plotX1, plotX2, plotY1, plotY2;
int leftMargin = 20;
int topMargin = 100;
int plotHeight = 250;
float timer = 0.0;
PFont helvetica;
 
void setup() {
  size(640, 480);
  smooth();
  helvetica = createFont("Helvetica-Bold", 14);
  textFont(helvetica);
   
  generateValues();
   
  // set plot size
  plotX1 = leftMargin;
  plotX2 = width - leftMargin;
  plotY1 = topMargin;
  plotY2 = height - topMargin;
}
 
void draw() {
  background(0);
   
  // draw plot bg
  fill(40);
  noStroke();
  rectMode(CORNERS);
  rect(plotX1, plotY1, plotX2, plotY2);
   
  //line(plotX1, height - topMargin, plotX2, height - topMargin);
  //line(plotX1, height - topMargin, plotX1, height - topMargin - plotHeight);
   
  noFill();
  stroke(255);
  strokeWeight(2); 
  beginShape();
   
  float x, y;
   
  /*
  // double curve vertext points
  x = map(0, 0, values.length-1, plotX1, plotX2);
  y = map(values[0], 0, 200, height - topMargin, height - topMargin - plotHeight);
  curveVertex(x, y);
  */
   
  for (int i = 0; i < values.length; i++) {
    x = map(i, 0, values.length-1, plotX1, plotX2);
    y = map(values[i], 0, 200, height - topMargin, height - topMargin - plotHeight);
    vertex(x, y);
  }
   
  /*
  // double curve vertext points
  x = map(values.length-1, 0, values.length-1, plotX1, plotX2);
  y = map(values[values.length-1], 0, 200, height - topMargin, height - topMargin - plotHeight);
  curveVertex(x, y);
  */
   
  endShape();
   
  // draw points on mouse over
  for (int i = 0; i < values.length; i++) {
    x = map(i, 0, values.length-1, plotX1, plotX2);
    y = map(values[i], 0, 200, height - topMargin, height - topMargin - plotHeight);
        
    // check mouse pos
    // float delta = dist(mouseX, mouseY, x, y);
    float delta = abs(mouseX - x);
    if ((delta < 15) && (y > plotY1) && (y < plotY2)) {
      stroke(255);
      fill(0);
      ellipse(x, y, 8, 8);
       
      int labelVal = round(values[i]);
      Label label = new Label("" + labelVal, x, y);
    }
  }
}
 
void keyPressed() {
  generateValues();
}
 
void generateValues() {
  for (int i = 0; i < values.length; i++) {
    //values[i] = (int) random(200);
    values[i] = noise(timer) * 200;
    timer += 0.7;
  }
   
  // get min/max range
  plotX1 = leftMargin;
  plotX2 = width - plotX1;
}

