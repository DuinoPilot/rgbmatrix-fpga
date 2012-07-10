-- Testbench for simulation of the special memory for the framebuffer
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

entity memory_tb is
end memory_tb;

architecture tb of memory_tb is
    signal rst, clk_wr, clk_rd : std_logic;
    signal input, output : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    constant clk_period : time := 20 ns; -- for a 50MHz clock
    constant num_cycles : positive := 50; -- change this to your liking
begin
    
    -- Instantiate the Unit Under Test (UUT)
    UUT : entity work.memory
        port map (
            rst    => rst,
            clk_wr => clk_wr,
            input  => input,
            clk_rd => clk_rd,
            addr   => addr,
            output => output
        );
    
    -- Clock process
    process
    begin
        clk_rd <= '0';
        wait for clk_period/2;
        clk_rd <= '1';
        wait for clk_period/2;
    end process;
    
    -- Stimulus process
    process
    begin
        -- Hold reset state
        rst <= '1';
        clk_wr <= '0';
        input <= "000000";
        addr <= (others => '0');
        wait for clk_period;
        rst <= '0';
        -- Perform the simulation
        wait for clk_period;
        input <= "000111";
        clk_wr <= '1';
        wait for clk_period;
        input <= "111000";
        wait for clk_period;
        clk_wr <= '0';
        wait for clk_period;
        input <= "010101";
        clk_wr <= '1';
        wait for clk_period;
        clk_wr <= '0';
        wait for clk_period*3;
        -- Wait forever
        wait;
    end process;
    
end tb;
