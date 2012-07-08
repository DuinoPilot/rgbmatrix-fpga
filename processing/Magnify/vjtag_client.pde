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
  final int hexChars = (frame.width*frame.height*3)/4;
  int p = 7; // we only support 3bpp, so just want the color's MSB
  BigInteger bigint = BigInteger.valueOf(0);
  frame.loadPixels();
  // Read in the frame, 6 bits at a time
  for(int i = 0; i < middlePixel; i++) {
    byte hi_lo = 0;
    hi_lo |= color_to_RGB_array(frame.pixels[i])[p] << 3;
    hi_lo |= color_to_RGB_array(frame.pixels[middlePixel+i])[p];    
    // Add this new data to the "bigint" accumulator
    BigInteger shifted = BigInteger.valueOf(hi_lo).shiftLeft(i*6);
    bigint = bigint.or(shifted);
  }
  // Now, send completed data to the server as a hex string followed by a newline
  String hexStr = pad_string(bigint.toString(16), hexChars);
  jtagsrv.write(hexStr + "\n");
}

byte[] color_to_RGB_array(color c) {
  // Returns an array of 8 bytes of color data (a byte contains 8 bits) where
  // result[7] is the most significant byte, result[0] is the least significant byte.
  // Bytes are zero packed with Blue as least significant bit, then Red, then Green.
  byte[] result = new byte[8];
  // Extract the 8-bit R/G/B subpixels from the 24-bit pixel
  byte r = (byte)(c >> 16);
  byte g = (byte)(c >> 8);
  byte b = (byte)(c);
  // For each bit in a subpixel...
  for(int i = 0; i < 8; i++) {
    result[i] = 0;
    // get the LSB of each R/G/B value and then shift it into the correct place
    result[i] |= (r & 1) << 2;
    result[i] |= (g & 1) << 1;
    result[i] |= (b & 1);
    // shift the R/G/B values over 1 bit to prepare for the next round
    r = (byte)(r >> 1);
    g = (byte)(g >> 1);
    b = (byte)(b >> 1);
  }
  return result;
}

void blank_leds() {
  // First, reset the design on the FPGA
  jtagsrv.write("RST\n");
  // Erase the LED panel by sending all "black" pixels
  for(int i = 0; i < panelsTall*pixelsTall*panelsWide/2; i++) {
    jtagsrv.write("000000000000000000000000000000000000000000000000\n");
  }
  println("* Reset and erased LED matrix panels");
}

String pad_string(String s, int len) {
  // Left-pads a string with zeros until it meets the given length requirement
  // Does nothing if the string is already at the required length
  // Blows up if the string is too long
  if(s.length() > len) {
    System.err.println("Error: Cannot pad string to requested length because it is too long!");
    System.err.println("       The string is: " + s);
    exit();
  }
  while(s.length() < len) {
    s = "0" + s;
  }
  return s;
}

