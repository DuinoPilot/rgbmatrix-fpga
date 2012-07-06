// Processing example sketch for the Adafruit RGB LED Matrix Display Driver project
// Copyright (c) 2012 Brian Nezvadovitz <http://nezzen.net>
// This software is distributed under the terms of the MIT License.

// Constants
static final int panelsWide = 1, // How many panels wide is your display?
                 panelsTall = 1, // How many panels tall is your display?
                 imgScale   = 10; // Scale factor for displayed preview

// Global variables
int xPos = 0, yPos = 0;

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
  
  // Update positions
  if(++xPos == imgWidth/2) {
    xPos = 0;
    if(++yPos == imgHeight)
      yPos = 0;
  }
  
  // Draw the chasers
  set(xPos, yPos, #ff0000);
  set(xPos+imgWidth/2, yPos, #0000ff);
  
  // Capture the image, rearrange it necessary for this panel configuration
  PImage img = get(0, 0, imgWidth, imgHeight);
  PImage rearrangedImg = rearrange(img);
  
  scale(imgScale); // Resize image to meet scaling factor
  image(img, 0, 0); // Preview image data on computer display
  
  refresh(rearrangedImg); // Issue pixel data to the FPGA
  
  // Stop when the end is reached
  if(frameNum >= panelsTall*panelsWide*pixelsTall*pixelsWide/2-1) {
    exit();
  }
  
}

