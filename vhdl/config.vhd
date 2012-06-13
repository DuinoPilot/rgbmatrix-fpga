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
use ieee.std_logic_1164.all;

package rgbmatrix is
    
    -- User configurable options
    constant NUM_PANELS_WIDE : integer := 2; -- Number of panels daisy-chained together side by side
    constant NUM_PANELS_TALL : integer := 1; -- Number of panels in the matrix top to bottom
    constant DEPTH_PER_PIXEL : integer := 1; -- Number of bits per subpixel (multiply by 3 to get BPP)
                                             -- Common values are: 1 => 3bpp, 4 => 12bpp, 8 => 24bpp
                                             -- TODO not implemented yet
    
    -- Special constants (change these at your own risk, stuff might break!)
    constant PANEL_WIDTH    : integer := 32;
    constant PANEL_HEIGHT   : integer := 16;
    
end rgbmatrix;
