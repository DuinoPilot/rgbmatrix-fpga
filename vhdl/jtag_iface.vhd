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

library ieee;
use ieee.std_logic_1164.all;

use work.rgbmatrix.all;

entity jtag_iface is
    port (
        tck    : in std_logic;
        tdi    : in std_logic;
        aclr   : in std_logic;
        ir_in  : in std_logic_vector(0 downto 0);
        v_sdr  : in std_logic;
        udr    : in std_logic;
        tdo    : out std_logic;
        output : out std_logic_vector(6 downto 0)
    );
end jtag_iface;

architecture bhv of jtag_iface is
    type STATE_TYPE is (START);
    signal state, next_state : STATE_TYPE;
begin
    
    -- Breakout signals to output pins
    
    -- State register
    -- process(clk, rst)
    -- begin
        -- if(rst = '1') then
            -- state <= START;
        -- elsif(rising_edge(clk)) then
            -- state <= next_state;
        -- end if;
    -- end process;
    
    -- Next-state logic
    --process(state)
    --begin
        -- Default register next-state assignments
        
        -- Default signal assignments
        
        -- case state is
            -- when START =>
                -- next_state <= START;
            -- when others => null;
        -- end case;
    -- end process;
    
end bhv;