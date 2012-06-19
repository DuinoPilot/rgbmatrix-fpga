-- Adafruit RGB LED Matrix Display Driver
-- Video data controller
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
use ieee.numeric_std.all;

use work.rgbmatrix.all;

entity vidctrl is
    generic (
        DATA_WIDTH : positive;
        ADDR_WIDTH : positive
    );
    port (
        jtag_output : in std_logic_vector(DATA_WIDTH-1 downto 0); -- TODO debug
        jtag_udr : in std_logic; -- TODO debug
        
        clk : in std_logic;
        rst : in std_logic;
        reload : in std_logic;
        memory_sel : out std_logic;
        ram1_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        ram1_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
        ram1_wren : out std_logic;
        ram2_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        ram2_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
        ram2_wren : out std_logic
    );
end vidctrl;

architecture bhv of vidctrl is
    type STATE_TYPE is (START, FILL_RAM, DISPLAY);
    signal state, next_state : STATE_TYPE;
    signal next_ram1_addr, s_ram1_addr, next_ram2_addr, s_ram2_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal next_memory_sel, s_memory_sel : std_logic;
begin
    
    -- Breakout signals to output pins
    ram1_addr <= s_ram1_addr;
    ram2_addr <= s_ram2_addr;
    memory_sel <= s_memory_sel;
    
    -- State register
    process(clk, rst)
    begin
        if(rst = '1') then
            state <= START;
            s_ram1_addr <= (others => '0');
            s_ram2_addr <= (others => '0');
            s_memory_sel <= '0';
        elsif(rising_edge(clk)) then
            state <= next_state;
            s_ram1_addr <= next_ram1_addr;
            s_ram2_addr <= next_ram2_addr;
            s_memory_sel <= next_memory_sel;
        end if;
    end process;
    
    -- Next-state logic
    process(state, s_ram1_addr, s_ram2_addr, s_memory_sel, reload)
    begin
        -- Default register next-state assignments
        next_ram1_addr <= s_ram1_addr;
        next_ram2_addr <= s_ram2_addr;
        next_memory_sel <= s_memory_sel;
        
        -- Default signal assignments
        ram1_data <= (others => '0');
        ram2_data <= (others => '0');
        ram1_wren <= '0';
        ram2_wren <= '0';
        
        case state is
            when START =>
                next_memory_sel <= not s_memory_sel; -- Swap buffers
                next_state <= FILL_RAM;
            when FILL_RAM =>
                ram1_wren <= '1';
                ram2_wren <= '1';
                -- ram_data is given as red/blue/green
                -- TODO just a test
                ram1_data <= jtag_output;
                ram2_data <= "000";
                -- TODO end of test
                next_ram1_addr <= std_logic_vector( unsigned(s_ram1_addr) + 1 );
                next_ram2_addr <= std_logic_vector( unsigned(s_ram2_addr) + 1 );
                if(unsigned(s_ram1_addr) < 2**ADDR_WIDTH-1) then
                    next_state <= FILL_RAM;
                else
                    next_state <= DISPLAY;
                end if;
            when DISPLAY =>
                if(jtag_udr = '1') then --if(reload = '1') then
                    next_state <= START;
                else
                    next_state <= DISPLAY;
                end if;
            when others => null;
        end case;
    end process;
    
end bhv;