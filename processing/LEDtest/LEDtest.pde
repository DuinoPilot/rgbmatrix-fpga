// Processing example sketch for the Adafruit RGB LED Matrix Display Driver project
// Copyright (c) 2012 Brian Nezvadovitz <http://nezzen.net>
// This software is distributed under the terms of the MIT License.

// Constants
static final int imgWidth  = 64, // Width of LED array (a multiple of 32)
                 imgHeight = 16, // Height of LED array (a multiple of 16)
                 imgScale  = 10; // Scale factor of displayed preview

// Global variables
PImage textImg;
PFont font;

void setup() {
  // Try to establish connection
  if(!vjtag_client_connect()) return;
  
  // Erase the display before starting
  blank_leds(imgWidth*imgHeight);
  
  // Load the font
  font = loadFont("ArialNarrow-48.vlw");
  textFont(font, 14);
  
  // Setup the window
  size(imgWidth * imgScale, imgHeight * imgScale);
  background(0);
  noLoop();
}

void draw() {
  // Render the text and rest of image...
  fill(0, 0, 255); // blue
  text("Hello,", 0, 13);
  fill(0, 255, 0); // green
  text("World!", 32, 13);
  fill(0, 255, 255); // cyan
  rect(0, 13, 24, 2);
  fill(255, 0, 0); // red
  rect(32, 13, 30, 2);
  fill(255, 0, 255); // magenta
  rect(0, 0, 24, 2);
  fill(255, 255, 0); // yellow
  rect(32, 0, 29, 2);
  fill(255, 255, 255); // white
  rect(25, 4, 6, 6);
  textImg = get(0, 0, imgWidth, imgHeight);
  
  scale(imgScale); // Resize image to meet scaling factor
  image(textImg, 0, 0); // Preview image data on computer display
  
  // Issue pixel data to the FPGA
  refresh(textImg);
}

