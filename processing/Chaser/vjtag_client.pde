// TCP client connector for the (virtual) JTAG Interface
// Part of the Adafruit RGB LED Matrix Display Driver project
// For use with Processing sketches
// Copyright (c) 2012 Brian Nezvadovitz <http://nezzen.net>
// This software is distributed under the terms of the MIT License.

// Libraries
import processing.net.*;
import java.math.BigInteger;

// Constants
static final int pixelsWide = 32,
                 pixelsTall = 16;

// Global variables
Client jtagsrv;

boolean vjtag_client_connect() {
  // Connect to the Virtual JTAG server
  jtagsrv = new Client(this, "localhost", 1337);
  // Check if connection worked...
  try {
    println("* Connected to " + jtagsrv.ip());
    return true;
  } catch(NullPointerException e) {
    println("* Unable to connect client socket!");
    exit();
    return false;
  }
}

void refresh(PImage img) {
  // Electrically, all the panels are dasiy-chained together into one very long display
  // However in reality, we may have our panels in any arbitrary rectangular arrangement
  // This function slides a small "window" frame over the image in the correct order and
  // sends the data to the FPGA one panel's worth of pixels at a time.
  int regionsCopied = 0;
  PImage frame = new PImage(pixelsWide*panelsWide*panelsTall, pixelsTall);
  // For each panel in height of display...
  for(int y = 0; y < panelsTall*pixelsTall; y += pixelsTall) {
    // Rearrange region
    frame.copy(img, 0, y, pixelsWide*panelsWide, pixelsTall, pixelsWide*panelsWide*regionsCopied, 0, pixelsWide*panelsWide, pixelsTall);
    regionsCopied++;
  }
  // Send the frame over the wire
  push_frame(frame);
}

void push_frame(PImage frame) {
  // Convert the pixel data into a format that can be sent to the FPGA,
  // then send it over the connection to the virtual JTAG server
  final int middlePixel = (frame.width*frame.height)/2;
  frame.loadPixels();
  BigInteger bigint = BigInteger.valueOf(0);
  // Read in the frame, one pixel at a time
  for(int i = 0; i < middlePixel; i++) {
    // Get the upper and lower pixel's RGB data (mask off alpha)
    int upper = frame.pixels[i] & 0x00FFFFFF;
    int lower = frame.pixels[i+middlePixel] & 0x00FFFFFF;
    // Append this new data to the bitwise-least-significant-end of the "bigint" accumulator
    BigInteger shifted = BigInteger.valueOf(upper).shiftLeft(i*48+24);
    shifted = shifted.or(BigInteger.valueOf(lower).shiftLeft(i*48));
    bigint = bigint.or(shifted);
  }
  // Now, send completed data to the server as a hex string followed by a newline
  String hexStr = pad_string(bigint.toString(16), frame.width*frame.height*24/4);
  jtagsrv.write(hexStr + "\n");
}

void blank_leds() {
  // First, reset the design on the FPGA
  jtagsrv.write("RST\n");
  // Erase the LED panel by sending all "black" pixels
  PImage frame = new PImage(pixelsWide*panelsWide*panelsTall, pixelsTall);
  push_frame(frame);
  println("* Reset and erased LED matrix panels");
}

String pad_string(String s, int len) {
  // Left-pads a string with zeros until it meets the given length requirement
  // Does nothing if the string is already at the required length
  // Blows up if the string is too long
  if(s.length() > len) {
    System.err.println("Error: Cannot pad string to requested length because it is too long (" + s.length() + ")!");
    System.err.println("       The string is: " + s);
    exit();
  }
  while(s.length() < len) {
    s = "0" + s;
  }
  return s;
}

