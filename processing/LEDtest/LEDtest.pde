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
  // Establish connection
  vjtag_client_connect();
  blank_leds(imgWidth*imgHeight);
  
  // Load the font
  font = loadFont("ArialNarrow-48.vlw");
  textFont(font, 12);
  
  // Setup the window
  size(imgWidth * imgScale, imgHeight * imgScale);
  background(0);
  
  // Don't repeat this
  noLoop();
}

void draw() {
  if(textImg == null) {
    // Render the text
    fill(0, 255, 0);
    text("Hello", 0, 15);
    fill(255, 0, 0);
    text("World!", 32, 15);
    textImg = get(0, 0, imgWidth, imgHeight);
  }
  
  scale(imgScale); // Resize image to meet scaling factor
  image(textImg, 0, 0); // Preview image data on computer display
  
  // Issue pixel data to the FPGA
  refresh(textImg);
}

