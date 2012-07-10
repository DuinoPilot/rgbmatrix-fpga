-- Adafruit RGB LED Matrix Display Driver
-- Testbench for simulation of the LED matrix finite state machine
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

use work.rgbmatrix.all;

entity ledctrl_tb is
end ledctrl_tb;

architecture tb of ledctrl_tb is
    constant clk_period : time := 20 ns; -- for a 50MHz clock
    constant num_cycles : positive := 10; -- change this to your liking
    --
    signal clk_in, rst, clk_out, lat, oe : std_logic;
    signal rgb1     : std_logic_vector(2 downto 0);
    signal rgb2     : std_logic_vector(2 downto 0);
    signal led_addr : std_logic_vector(2 downto 0);
    signal addr     : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal data     : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
    
    -- Instantiate the Unit Under Test (UUT)
    UUT : entity work.ledctrl
        port map (
            clk_in   => clk_in,
            rst      => rst,
            clk_out  => clk_out,
            rgb1     => rgb1,
            rgb2     => rgb2,
            led_addr => led_addr,
            lat      => lat,
            oe       => oe,
            addr     => addr,
            data     => data
        );
    
    -- Clock process
    process
    begin
        clk_in <= '0';
        wait for clk_period/2;
        clk_in <= '1';
        wait for clk_period/2;
    end process;
    
    -- Stimulus process
    process
    begin
        data <= (others => '0');
        -- Hold reset state
        rst <= '1';
        wait for clk_period/2;
        rst <= '0';
        -- Perform the simulation
        wait for clk_period*num_cycles;
        -- Wait forever
        wait;
    end process;
    
end tb;
