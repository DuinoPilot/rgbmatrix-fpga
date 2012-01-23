-- Adafruit RGB LED Matrix Display Driver
-- Testbench for simulation of the top level entity
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

entity testbench is
end testbench;

architecture tb of testbench is
    signal clk_in, rst : std_logic;
    signal clk_out, r1, r2, b1, b2, g1, g2, a, b, c, lat, oe : std_logic;
    constant clk_period : time := 10 ns;
begin
    
    -- Instantiate the Unit Under Test (UUT)
    UUT : entity work.top_level
        port map (
            clk_in => clk_in,
            rst => rst,
            clk_out => clk_out,
            r1 => r1,
            r2 => r2,
            b1 => b1,
            b2 => b2,
            g1 => g1,
            g2 => g2,
            a => a,
            b => b,
            c => c,
            lat => lat,
            oe => oe
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
        -- Hold reset state
        rst <= '1';
        wait for clk_period/4;
        rst <= '0';
        -- Perform the simulation
        wait for clk_period*10;
        -- Wait forever
        wait;
    end process;
    
end tb;
