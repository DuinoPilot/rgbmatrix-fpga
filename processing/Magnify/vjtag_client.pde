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
long frameNum = 0; // count the number of frames sent

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
  // Convert the pixel data into a format that can be sent to the FPGA,
  // then send it over the connection to the virtual JTAG server
  int writeCount = 0;
  int middlePixel = pixelsWide*panelsWide*pixelsTall*panelsTall/2;
  int p = 7; // There are 8 bits per sub-pixel, but for now we only use the highest bit
  img.loadPixels(); // ensure that img.pixels[] is present and up-to-date
  // For each pair of horizontal lines in the image...
  for(int i = 0; i < middlePixel; i += pixelsWide*panelsWide) {
    // Split the lines into chunks of pixels exactly 1 panel-width long
    for(int j = i; j < i+pixelsWide*panelsWide; j += pixelsWide) {
      int shiftPosition = 0;
      BigInteger bigint = BigInteger.valueOf(0);
      // We want to get 8 "long" words and then combine them together later
      for(int k = 0; k < 8; k++) {
        long word = 0;
        // Get the first 24 bits of color data -- 12 bits for the top panel...
        word |= color_to_RGB_array(img.pixels[j+0+(4*k)])[p] << 3;
        word |= color_to_RGB_array(img.pixels[j+1+(4*k)])[p] << 9;
        word |= color_to_RGB_array(img.pixels[j+2+(4*k)])[p] << 15;
        word |= color_to_RGB_array(img.pixels[j+3+(4*k)])[p] << 21;
        // ... and 12 bits for the bottom panel
        word |= color_to_RGB_array(img.pixels[middlePixel+j+0+(4*k)])[p];
        word |= color_to_RGB_array(img.pixels[middlePixel+j+1+(4*k)])[p] << 6;
        word |= color_to_RGB_array(img.pixels[middlePixel+j+2+(4*k)])[p] << 12;
        word |= color_to_RGB_array(img.pixels[middlePixel+j+3+(4*k)])[p] << 18;
        // Add this new word-chunk to the "bigint" accumulator
        BigInteger shifted = BigInteger.valueOf(word).shiftLeft(shiftPosition);
        bigint = bigint.or(shifted);
        shiftPosition += 24; // get ready for the next word-chunk...
      }
      // Now, send completed data to the server as a hex string of 12 characters followed by a newline
      String hexStr = bigint.toString(16);
      jtagsrv.write(pad_string(hexStr, 48) + "\n");      
      // Increment the transmission counter
      writeCount++;
    }
  }
  // Increment the frame counter
  frameNum++;
  println("* Sent frame " + frameNum + " in " + writeCount + " writes");
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
    println(i);
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

PImage rearrange(PImage src) {
  // Electrically, all the panels are dasiy-chained together into one very long display
  // However in reality, we may have our panels in any arbitrary rectangular arrangement
  // This function rearranges the normal rectangular image into a very long rectangle
  // which will stream to the FPGA without it having to do any extra work
  int blocksCopied = 0;
  final int destWidth = panelsWide*pixelsWide*panelsTall;
  final int destHeight = pixelsTall;
  // Create a target for the copied image
  PImage dest = new PImage(destWidth, destHeight);
  // For each panel in height of display...
  for(int y = 0; y < panelsTall*pixelsTall; y += pixelsTall) {
    // For each panel in width of display...
    for(int x = 0; x < panelsWide*pixelsWide; x += pixelsWide) {
      // Copy the panel's pixels to the destination
      dest.copy(src, x, y, pixelsWide, pixelsTall, pixelsWide*blocksCopied, 0, pixelsWide, pixelsTall);
      blocksCopied++;
    }
  }
  return dest;
}

