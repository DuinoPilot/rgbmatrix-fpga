// TCP client connector for the (virtual) JTAG Interface
// Part of the Adafruit RGB LED Matrix Display Driver project
// For use with Processing sketches
// Copyright (c) 2012 Brian Nezvadovitz <http://nezzen.net>
// This software is distributed under the terms of the MIT License.

// Libraries
import processing.net.*;
import java.math.BigInteger;

// Globals
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
  int wordCount = 0;
  int middlePixel = (img.width*img.height)/2;
  int p = 7; // There are 8 bits per sub-pixel, but for now we only use the highest bit
  // For each pair of horizontal lines in the image...
  for(int i = 0; i < middlePixel; i += img.width) {
    // Split the lines into chunks of 32 pixels
    for(int j = i; j < i+img.width; j += 32) {
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
        // Add this new word to the "bigint" accumulator
        BigInteger shifted = BigInteger.valueOf(word).shiftLeft(shiftPosition);
        bigint = bigint.or(shifted);
        shiftPosition += 24;
      }
      // Now, send the color data to the server as a hex string of 12 characters followed by a newline
      String hexStr = bigint.toString(16);
      jtagsrv.write(pad_string(hexStr, 48) + "\n");      
      // Increment transmission counter
      wordCount++;
    }
  }
  // Increment frame counter
  frameNum++;
  println("* Sent frame " + frameNum + " in " + wordCount + " words");
}

byte[] color_to_RGB_array(color c) {
  // Returns an array of 8 bytes of color data (a byte contains 8 bits) where
  // result[7] is the most significant byte, result[0] is the least significant byte.
  // Bytes are zero packed with Blue as least significant bit, then Red, then Green.
  byte r = (byte)(c >> 16);
  byte g = (byte)(c >> 8);
  byte b = (byte)(c);
  byte[] result = new byte[8];
  for(int i = 0; i < 8; i++) {
    result[i] = 0;
    result[i] += (r & 1) << 2;
    result[i] += (g & 1) << 1;
    result[i] += (b & 1);
    r = (byte)(r >> 1);
    g = (byte)(g >> 1);
    b = (byte)(b >> 1);
  }
  return result;
}

void blank_leds(int number_of_leds) {
  // Erase the LED panel by sending all "black" pixels
  for(int i = 0; i < number_of_leds/64; i++) {
    jtagsrv.write("000000000000000000000000000000000000000000000000\n");
  }
  println("* Erased " + number_of_leds + " LEDs in " + number_of_leds/64 + " words");
}

String pad_string(String s, int len) {
  // Left-pads a string with zeros until it meets the given length requirement
  // Does nothing if the string is already at the required length
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
