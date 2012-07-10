-- Adafruit RGB LED Matrix Display Driver
-- User-editable configuration and constants package
-- 
-- Copyright (c) 2012 Brian Nezvadovitz <http://nezzen.net>
-- This software is distributed under the terms of the MIT License shown below.
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to
-- deal in the Software without restriction, including without limitation the
-- rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
-- sell copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
-- IN THE SOFTWARE.

library ieee;
use ieee.math_real.log2;
use ieee.math_real.ceil;

package rgbmatrix is
    
    -- User configurable constants
    constant NUM_PANELS   : integer := 2; -- total number of LED matrix panels
    constant PIXEL_DEPTH  : integer := 8; -- number of bits per pixel
    
    -- Special constants (change these at your own risk, stuff might break!)
    constant PANEL_WIDTH  : integer := 32; -- width of the panel in pixels
    constant PANEL_HEIGHT : integer := 16; -- height of the panel in pixels
    constant DATA_WIDTH   : positive := PIXEL_DEPTH*6;
                                         -- one bit for each subpixel (3), times
                                         -- the number of simultaneous lines (2)
    
    -- Derived constants
    constant ADDR_WIDTH     : positive := positive(log2(real(NUM_PANELS*PANEL_WIDTH*PANEL_HEIGHT/2)));
    constant IMG_WIDTH      : positive := PANEL_WIDTH*NUM_PANELS;
    constant IMG_WIDTH_LOG2 : positive := positive(log2(real(IMG_WIDTH)));
    
end rgbmatrix;
