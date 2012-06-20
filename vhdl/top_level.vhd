-- Adafruit RGB LED Matrix Display Driver
-- Top Level Entity
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

use work.rgbmatrix.all; -- Constants & Configuration

entity top_level is
    port (
        clk_in  : in std_logic;
        rst_n   : in std_logic;
        clk_out : out std_logic;
        r1      : out std_logic;
        r2      : out std_logic;
        b1      : out std_logic;
        b2      : out std_logic;
        g1      : out std_logic;
        g2      : out std_logic;
        a       : out std_logic;
        b       : out std_logic;
        c       : out std_logic;
        lat     : out std_logic;
        oe      : out std_logic
    );
end top_level;

architecture str of top_level is
    -- Reset signal
    signal rst : std_logic;
    
    -- Memory signals
    signal addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal data_incoming, data_outgoing : std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- Flags
    signal data_valid : std_logic;

begin
    
    -- Reset is an "active low" input
    rst <= not rst_n;
    
    -- LED panel controller
    U_LEDCTRL : entity work.ledctrl
        port map (
            rst => rst,
            clk_in => clk_in,
            -- Connection to LED panel
            clk_out => clk_out,
            rgb1(2) => r1,
            rgb1(1) => b1,
            rgb1(0) => g1,
            rgb2(2) => r2,
            rgb2(1) => b2,
            rgb2(0) => g2,
            led_addr(2) => c,
            led_addr(1) => b,
            led_addr(0) => a,
            lat => lat,
            oe  => oe,
            -- Connection with framebuffer
            addr => addr,
            pixel => data_outgoing
        );
    
    -- Virtual JTAG interface
    U_JTAGIFACE : entity work.jtag_iface
        port map (
            rst    => rst,
            output => data_incoming,
            valid  => data_valid
        );
    
    -- Special memory for the framebuffer
    U_MEMORY : entity work.memory
        port map (
            rst => rst,
            -- Writing side
            clk_wr => data_valid,
            input  => data_incoming,
            -- Reading side
            clk_rd => clk_in,
            addr   => addr,
            output => data_outgoing
        );
    
end str;
