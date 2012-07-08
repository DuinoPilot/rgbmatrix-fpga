// "Magnify" example sketch for the Adafruit RGB LED Matrix Display Driver project

// Libraries
import java.awt.*;
import java.awt.image.*;
import java.awt.MouseInfo;

// Constants
static final int panelsWide = 1, // How many panels wide is your display?
                 panelsTall = 1, // How many panels tall is your display?
                 imgScale   = 10; // Scale factor for displayed preview

// Global variables
PImage img;
Robot bot; // For screen capture

final int imgWidth = pixelsWide*panelsWide;
final int imgHeight = pixelsTall*panelsTall;

void setup() {
  // Try to establish connection
  if(!vjtag_client_connect()) return;
  
  // Erase the display before starting
  blank_leds();
  
  // Initialize capture code
  GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
  GraphicsDevice[]    gd = ge.getScreenDevices();
  try {
    bot = new Robot(gd[0]);
  }
  catch(AWTException e) {
    System.err.println("new Robot() failed.");
  }
  
  // Setup the window
  size(imgWidth * imgScale, imgHeight * imgScale);
  background(0);
  frameRate(30); // max FPS
}

void draw() {
  int       x, y;
  Rectangle r;
  PImage    img;

  // Get absolute mouse coordinates on screen, offset to center on LED array,
  // and constrain result so it doesn't extend offscreen in any direction.
  x = constrain(MouseInfo.getPointerInfo().getLocation().x - imgWidth  / 2,
      0, screen.width  - imgWidth);
  y = constrain(MouseInfo.getPointerInfo().getLocation().y - imgHeight / 2,
      0, screen.height - imgHeight);
  r = new Rectangle(x, y, imgWidth, imgHeight);

  // Capture rectangle from screen, convert BufferedImage to PImage
  img = new PImage(bot.createScreenCapture(r));
  img.loadPixels(); // Make pixel array readable
  
  // Display captured image
  scale(imgScale);
  image(img, 0, 0);
  
  // Issue to LED array
  refresh(img);
}

