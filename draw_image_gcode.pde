/*
 Code by lingib
 Last update 28 August 2017

 ----------
 Theory
 ----------
 The image is sub-divided into cells.

 The image is then sampled at each cell location,  a "value" in the
 range [0..255] is assigned to that cell.

 The code "int(map(value,0,256,0,16));" produces a 16-step grayscale.

 This grayscale number is then used to select one of 16 patterns to
 represent the tonal "value" in each cell.

 Small cell sizes around 6*6 pixels provide most detail ...

 ----------
 Copyright
 ----------
 This code is free software: you can redistribute it and/or
 modify it under the terms of the GNU General Public License as published
 by the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This software is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License. If
 not, see <http://www.gnu.org/licenses/>.
 */

// -------------------------------------
// declarations
// -------------------------------------
PImage src;                                             //declare variables of type PImage
PrintWriter output;                                     //instantiate "output" for printing files

int
  cellWidth = 5, //cell width in pixels ... determines the detail
  cellHeight = cellWidth, //make cell square
  columns,
  rows;

boolean
  penUp=true;                                           //flag

// -------------------------------------
// setup
// -------------------------------------
void setup() {
  size(500, 500);                                       //image.jpg dimensions (cellWidth=5)

  background(255);                                      //screen image background white

  rows=height/cellHeight;                               //number of cell rows
  columns=width/cellWidth;                              //number of cell columns

  src = loadImage("image.jpg");                         //get image.jpg
  src.filter(GRAY);                                     //convert image to monochrome

  output = createWriter("DrawImage_Output.gcode");                   //open a file for storing the g-code

  noLoop();                                             //main loop only runs once
}

// -------------------------------------
// main loop
// -------------------------------------
void draw() {
  output.println("%");
  output.println("G0 F8000");
  output.println("G1 F5000");
  output.println("M106 S255");
  output.println("M18 S0");
  output.println("M117 Plotting");

  //image(src, 0, 0);                                   //superimpose image
  drawImage();                                          //draw the image

  // ----- close the g-code file
  output.println("G00 Z40");                          //home
  output.println("F117 Ready");
  output.println("%");
  output.flush();                                       //write the remaining data to the file
  output.close();                                       //finishes the file
  //exit();                                             //stop the program
}

// ------------------------------------
// drawImage
// ------------------------------------

/*
  The function map(value, 0, 256, 0, 16) produces a 16-step grayscale
 */
void drawImage() {

  float value;

  // ----- fill each cell with a pattern
  for (int row=0; row<rows; row++) {
    penUp=true;                                          //raise pen at the end of each row
    for (int column=0; column<columns; column++) {
      value=averageValue(column, row);
      drawPattern(column, row, 15-int(map(value, 0, 256, 0, 16)));
    }
  }
}

// ------------------------------------
// averageValue
// ------------------------------------
float averageValue(int column, int row) {

  float
    sum=0.0;

  int
    x=column*cellWidth,
    y=row*cellHeight,
    pixel,
    count=0;


  for (int j=0; j<cellHeight; j++) {                     //for each cell row
    for (int i=0; i<cellWidth; i++) {                    //add each cell column
      pixel=(x+i) + (y+j)*width;
      sum+=brightness(src.pixels[pixel]);
      count++;
    }
  }

  if (count<1) count=1;
  return sum/(count);                                    //average cell value
}

// ------------------------------------
// drawPattern
// ------------------------------------
void drawPattern(int column, int row, int value) {
  /*
    A grayscale is a bit like a staircase ... 16 steps requires 17 (i.e 0..16) risers
   */

  // ----- locals
  int x=(column*cellWidth);                          //horizontal pixel co-ordinate
  int y=(row*cellHeight);                            //vertical pixel co-ordinate

  switch (value) {
  case 0:
    drawSinewave(x, y, 1, 0.0);                    //step1 (white)
    break;
  case 1:
    drawSinewave(x, y, 1, 0.0);                    //step1
    break;
  case 2:
    drawSinewave(x, y, 1, 0.05);                   //step2
    break;
  case 3:
    drawSinewave(x, y, 1, 0.2);                    //step3
    break;
  case 4:
    drawSinewave(x, y, 1, 0.3);                    //step4
    break;
  case 5:
    drawSinewave(x, y, 1, 0.4);                    //step5
    break;
  case 6:
    drawSinewave(x, y, 1, 0.6);                    //step6
    break;
  case 7:
    drawSinewave(x, y, 1, 0.8);                    //step7
    break;
  case 8:
    drawSinewave(x, y, 1, 1.0);                    //step8 (mid-gray)
    break;
  case 9:
    drawSinewave(x, y, 2, 1.0);                    //step9
    break;
  case 10:
    drawSinewave(x, y, 3, 1.0);                    //step10
    break;
  case 11:
    drawSinewave(x, y, 4, 1.0);                    //step11
    break;
  case 12:
    drawSinewave(x, y, 5, 1.0);                   //step12
    break;
  case 13:
    drawSinewave(x, y, 6, 1.0);                   //step13
    break;
  case 14:
    drawSinewave(x, y, 7, 1.0);                   //step14
    break;
  case 15:
    drawSinewave(x, y, 8, 1.0);                   //step15 (black)
    break;
  case 16:
    drawSinewave(x, y, 8, 1.0);
    break;
  }
}

// ------------------------------------
// drawSinewave
// ------------------------------------
void drawSinewave(int X, int Y, int cycles, float amplitude) {

  // ----- preprocessing
  float x=(float)X;
  float y=(float)Y;
  amplitude*=cellHeight/2;

  // ----- locals
  int samples=cycles*12;                                //12 samples per cycle
  float angle=0.0;                                      //start angle
  float deltaAngle=-TWO_PI/12;                          //30 degree increments (clockwise)
  float deltaX=((float)cellWidth)/samples;              //sample interval along x axis
  float [] yValues;                                     //sample heights within each cell stored here
  float scale=0.3;
  float offset_x=80;
  float offset_y=50;

  //get yValues for each cell
  yValues=new float [samples+1];
  for (int i=0; i<yValues.length-1; i++) {
    yValues[i]=sin(angle)*amplitude;
    angle+=deltaAngle;
  }

  //draw sinewave(s) within each cell
  stroke(0);  //black line
  for (int i=0; i<yValues.length-1; i++) {
    line ((x*scale)+offset_x, ((y+cellHeight/2+yValues[i])*scale)+offset_y, ((x+deltaX)*scale)+offset_y, ((y+cellHeight/2+yValues[i+1])*scale)+offset_y);

    // ----- create g-code
    if (penUp) {
      output.println("G00 Z12");
      output.println("G00 X" + ((x*scale)+offset_x) + " Y" + ((height-(y+cellHeight/2+yValues[i]))*scale+offset_y));  //first row yValue
      output.println("G00 Z10");
      penUp=false;
    } else {
      output.println("G01 X" + ((x)*scale+offset_x) + " Y" + ((height-(y+cellHeight/2+yValues[i]))*scale+offset_y));  //remaining row yValues
    }

    x+=deltaX;
  }
}
