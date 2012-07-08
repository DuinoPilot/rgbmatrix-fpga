// Processing example sketch for the Adafruit RGB LED Matrix Display Driver project
// Copyright (c) 2012 Brian Nezvadovitz <http://nezzen.net>
// This software is distributed under the terms of the MIT License.

// Constants
static final int panelsWide = 1, // How many panels wide is your display?
                 panelsTall = 1, // How many panels tall is your display?
                 imgScale   = 10; // Scale factor for displayed preview

// Global variables
int xPos = 0, yPos = 0, frameNum = 0;

final int imgWidth = pixelsWide*panelsWide;
final int imgHeight = pixelsTall*panelsTall;

void setup() {
  // Try to establish connection
  if(!vjtag_client_connect()) return;
  
  // Erase the display before starting
  blank_leds();
  
  // Setup the window
  size(imgWidth * imgScale, imgHeight * imgScale);
  frameRate(30); // max FPS
}

void draw() {
  // Erase
  background(0);
  
  // Draw the chasers
  set(xPos, yPos, #ff0000);
  set(xPos+imgWidth/2, yPos, #0000ff);
  set(xPos, yPos+imgHeight/2, #00ff00);
  set(xPos+imgWidth/2, yPos+imgHeight/2, #ffffff);
  
  // Update positions
  if(++xPos == imgWidth/2) {
    xPos = 0;
    if(++yPos == imgHeight/2)
      yPos = 0;
  }
  
  // Capture the image, rearrange it necessary for this panel configuration
  PImage img = get(0, 0, imgWidth, imgHeight);
  
  // Preview image data on computer display
  image(img, 0, 0, imgWidth*imgScale, imgHeight*imgScale);
  
  // Issue pixel data to the FPGA
  refresh(img);
  
  // Stop when the end is reached
  if(frameNum >= panelsTall*panelsWide*pixelsTall*pixelsWide/4-1) {
    exit();
  } else {
    frameNum++;
  }
  
}

