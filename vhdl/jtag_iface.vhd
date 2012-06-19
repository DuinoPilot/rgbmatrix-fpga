-- Adafruit RGB LED Matrix Display Driver
-- Interface between the virtual JTAG port and the video data controller
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

-- For information on how the Altera Virtual JTAG works, see this document:
-- http://www.altera.com/literature/ug/ug_virtualjtag.pdf

library ieee;
use ieee.std_logic_1164.all;

use work.rgbmatrix.all;

entity jtag_iface is
    generic (
        WORD_SIZE : positive
    );
    port (
        rst    : in std_logic;
        tck    : in std_logic;
        tdi    : in std_logic;
        ir_in  : in std_logic_vector(0 downto 0);
        udr    : in std_logic;
        sdr    : in std_logic;
        tdo    : out std_logic;
        output : out std_logic_vector(WORD_SIZE-1 downto 0)
    );
end jtag_iface;

architecture bhv of jtag_iface is
    signal dr1_select : std_logic;
    signal dr0 : std_logic_vector(0 downto 0);
    signal dr1, out_reg : std_logic_vector(WORD_SIZE-1 downto 0);
begin
    
    -- Break out the instruction register which is used to select the destination register
    dr1_select <= ir_in(0);
    
    -- Clocked process to shift in data
    process(tck, rst)
    begin
        if(rst = '1') then
            dr0 <= (others => '0');
            dr1 <= (others => '0');
        elsif(rising_edge(tck)) then
            dr0(0) <= tdi;
            if(sdr = '1' and dr1_select = '1') then -- JTAG is in Shift DR state and data register 1 is selected
                dr1 <= (tdi & dr1(WORD_SIZE-1 downto 1)); -- shift in the new MSB, drop the LSB
            end if;
        end if;
    end process;
    
    -- Maintain the TDO continuity
    process(dr1_select, dr0, dr1)
    begin
        if(dr1_select = '1') then
            tdo <= dr1(0);
        else
            tdo <= dr0(0);
        end if;
    end process;
    
    -- The udr signal will assert when the data has been transmitted and it's time to update the output
    -- Note that connecting it directly will cause an unwanted behavior as data is shifted through it
    process(udr)
    begin
        if(rising_edge(udr)) then
            out_reg <= dr1;
        end if;
    end process;
    output <= out_reg;
    
end bhv;