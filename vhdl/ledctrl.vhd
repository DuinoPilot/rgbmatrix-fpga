-- Adafruit RGB LED Matrix Display Driver
-- Finite state machine to control the LED matrix hardware
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

-- For some great documentation on how the RGB LED panel works, see this page:
-- http://www.rayslogic.com/propeller/Programming/AdafruitRGB/AdafruitRGB.htm

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.rgbmatrix.all;

entity ledctrl is
    port (
        clk_in   : in  std_logic;
        rst      : in  std_logic;
        -- LED Panel IO
        clk_out  : out std_logic;
        rgb1     : out std_logic_vector(2 downto 0);
        rgb2     : out std_logic_vector(2 downto 0);
        led_addr : out std_logic_vector(2 downto 0);
        lat      : out std_logic;
        oe       : out std_logic;
        -- Memory IO
        addr     : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        pixel    : in  std_logic_vector(DATA_WIDTH-1 downto 0)
        );
end ledctrl;

architecture bhv of ledctrl is
    -- Internal signals
    signal clk : std_logic;
    
    -- Essential state machine signals
    type STATE_TYPE is (INIT, S1, S1Loop, S2, S3, S4);
    signal state, next_state : STATE_TYPE;
    
    -- State machine signals
    signal col_count, next_col_count : unsigned(IMG_WIDTH_LOG2 downto 0);
    signal s_led_addr, next_led_addr : std_logic_vector(2 downto 0);
    signal s_ram_addr, next_ram_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal s_rgb1, next_rgb1, s_rgb2, next_rgb2 : std_logic_vector(2 downto 0);
    signal s_oe, s_lat, s_clk_out : std_logic;
begin
    
    -- A simple clock divider is used here because the LED matrix should be run relatively slow
    U_CLKDIV : entity work.clk_div
        generic map (
            clk_in_freq => 25,
            clk_out_freq => 1
        )
        port map (
            rst => rst,
            clk_in => clk_in,
            clk_out => clk
        );
    
    -- Breakout internal signals to the output port
    led_addr <= s_led_addr;
    addr <= s_ram_addr;
    rgb1 <= s_rgb1;
    rgb2 <= s_rgb2;
    oe <= s_oe;
    lat <= s_lat;
    clk_out <= s_clk_out;
    
    -- State register
    process(rst, clk)
    begin
        if(rst = '1') then
            state <= INIT;
            s_led_addr <= (others => '1');
            s_ram_addr <= (others => '0');
            s_rgb1 <= (others => '0');
            s_rgb2 <= (others => '0');
            col_count <= (others => '0');
        elsif(rising_edge(clk)) then
            state <= next_state;
            col_count <= next_col_count;
            s_led_addr <= next_led_addr;
            s_ram_addr <= next_ram_addr;
            s_rgb1 <= next_rgb1;
            s_rgb2 <= next_rgb2;
        end if;
    end process;
    
    -- Next-state logic
    process(state, col_count, s_led_addr, s_ram_addr, s_rgb1, s_rgb2, pixel)
    begin
        -- Default register next-state assignments
        next_col_count <= col_count;
        next_led_addr <= s_led_addr;
        next_ram_addr <= s_ram_addr;
        next_rgb1 <= s_rgb1;
        next_rgb2 <= s_rgb2;
        
        -- Default signal assignments
        s_clk_out <= '0';
        s_lat <= '0';
        s_oe <= '0'; -- this signal is "active low"
        
        -- States
        case state is
            when INIT =>
                s_oe <= '1'; -- disable display during init phase
                next_state <= S1;
            when S1 =>
                -- Pixel data is given as a word of R1/G1/B1/R2/G2/B2 bits
                next_rgb1 <= pixel(5 downto 3);
                next_rgb2 <= pixel(2 downto 0);
                next_col_count <= col_count + 1;
                if(col_count < IMG_WIDTH) then
                    next_state <= S1Loop;
                else
                    next_state <= S2;
                end if;
            when S1Loop =>
                s_clk_out <= '1';
                next_ram_addr <= std_logic_vector( unsigned(s_ram_addr) + 1 );
                next_state <= S1;
            when S2 =>
                s_oe <= '1'; -- disable display while latching
                s_lat <= '1';
                next_col_count <= (others => '0');
                next_state <= S3;
            when S3 =>
                s_oe <= '1'; -- disable display while latching
                next_state <= S4;
            when S4 =>
                s_oe <= '1'; -- disable display during led_addr selection
                next_led_addr <= std_logic_vector( unsigned(s_led_addr) + 1 );
                next_state <= INIT;
            when others => null;
        end case;
    end process;
    
end bhv;
