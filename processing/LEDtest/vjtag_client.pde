// TCP client connector for the (virtual) JTAG Interface
// Part of the Adafruit RGB LED Matrix Display Driver project
// For use with Processing sketches
// Copyright (c) 2012 Brian Nezvadovitz <http://nezzen.net>
// This software is distributed under the terms of the MIT License.

// Libraries
import processing.net.*;

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
  // For each pair of horizontal lines in the image...
  for(int i = 0; i < middlePixel; i += img.width) {
    // Split the lines into chunks of 4 pixels
    for(int j = i; j < i+img.width; j += 4) {
      long word = 0;
      // Get 24 bits of color data -- 12 bits from the top ...
      word |= color_to_RGB_array(img.pixels[j+0])[7] << 2;
      word |= color_to_RGB_array(img.pixels[j+1])[7] << 8;
      word |= color_to_RGB_array(img.pixels[j+2])[7] << 14;
      word |= color_to_RGB_array(img.pixels[j+3])[7] << 20;
      // ... and 12 bits from the bottom
      word |= color_to_RGB_array(img.pixels[middlePixel+j+0])[7] >> 1;
      word |= color_to_RGB_array(img.pixels[middlePixel+j+1])[7] << 5;
      word |= color_to_RGB_array(img.pixels[middlePixel+j+2])[7] << 11;
      word |= color_to_RGB_array(img.pixels[middlePixel+j+3])[7] << 17;
      // TODO - I am losing the least significant bit when transferring data
      // which results in the inability to control the blue subpixel of the
      // bottom half of the display. Right now it looks like this:
      //  msb 00000000000 lsb  (RGB = upper, rgb = lower)
      //      RGBrgbRGBrg
      // Now, send the color data to the server as a hex string of 6 characters followed by a newline
      jtagsrv.write(pad_string(Long.toHexString(word), 6) + "\n");
      wordCount++;
    }
  }
  println("* Sent frame " + ++frameNum + " containing " + wordCount + " words");
}

byte[] color_to_RGB_array(color c) {
  // returns an array of 8 bytes (a byte contains 8 bits)
  // result[7] is the most significant byte... result[0] is the least significant byte
  // bytes are zero packed with Blue as least significant bit, then Red, then Green
  // swap green/red
  byte r = (byte)(c >> 16);
  byte g = (byte)(c >> 8);
  byte b = (byte)(c >> 0);
  byte[] result = new byte[8];
  for(int i = 0; i < 8; i++) {
    result[i] = 0;
    result[i] += (r & 1) << 2;
    result[i] += (g & 1) << 1;
    result[i] += (b & 1) << 0;
    r = (byte)(r >> 1);
    g = (byte)(g >> 1);
    b = (byte)(b >> 1);
  }
  return result;
}

void blank_leds(int number_of_leds) {
  // erase the LED panel by sending all black pixels
  for(int i = 0; i < number_of_leds/8; i++) {
    jtagsrv.write("000000\n");
  }
  println("* Erased " + number_of_leds + " LEDs");
}

String pad_string(String s, int len) {
  if(s.length() > len) {
    println("Error: Cannot pad string to requested length because it is too long!");
  }
  while(s.length() < len) {
    s = "0" + s;
  }
  return s;
}
