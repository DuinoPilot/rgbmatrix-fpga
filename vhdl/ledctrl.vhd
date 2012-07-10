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
        data     : in  std_logic_vector(DATA_WIDTH-1 downto 0)
        );
end ledctrl;

architecture bhv of ledctrl is
    -- Internal signals
    signal clk : std_logic;
    
    -- Essential state machine signals
    type STATE_TYPE is (INIT, READ_PIXEL_DATA, INCR_RAM_ADDR, LATCH, INCR_LED_ADDR);
    signal state, next_state : STATE_TYPE;
    
    -- State machine signals
    signal col_count, next_col_count : unsigned(IMG_WIDTH_LOG2 downto 0);
    signal bpp_count, next_bpp_count : unsigned(PIXEL_DEPTH-1 downto 0);
    signal s_led_addr, next_led_addr : std_logic_vector(2 downto 0);
    signal s_ram_addr, next_ram_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal s_rgb1, next_rgb1, s_rgb2, next_rgb2 : std_logic_vector(2 downto 0);
    signal s_oe, s_lat, s_clk_out : std_logic;
begin
    
    -- A simple clock divider is used here to slow down this part of the circuit
    -- http://www.ladyada.net/wiki/tutorials/products/rgbledmatrix/index.html#how_the_matrix_works
    U_CLKDIV : entity work.clk_div
        generic map (
            clk_in_freq  => 50000000, -- 50MHz input clock
            clk_out_freq => 10000000  -- 10MHz output clock
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
            col_count <= (others => '0');
            bpp_count <= (others => '0');
            s_led_addr <= (others => '1'); -- this inits to 111 because the led_addr is actually used *after* the incoming data is latched by the panel (not while being shifted in), so by then it has been "incremented" to 000
            s_ram_addr <= (others => '0');
            s_rgb1 <= (others => '0');
            s_rgb2 <= (others => '0');
        elsif(rising_edge(clk)) then
            state <= next_state;
            col_count <= next_col_count;
            bpp_count <= next_bpp_count;
            s_led_addr <= next_led_addr;
            s_ram_addr <= next_ram_addr;
            s_rgb1 <= next_rgb1;
            s_rgb2 <= next_rgb2;
        end if;
    end process;
    
    -- Next-state logic
    process(state, col_count, bpp_count, s_led_addr, s_ram_addr, s_rgb1, s_rgb2, data) is
        -- Internal breakouts
        variable upper, lower : unsigned(DATA_WIDTH/2-1 downto 0);
        variable upper_r, upper_g, upper_b : unsigned(PIXEL_DEPTH-1 downto 0);
        variable lower_r, lower_g, lower_b : unsigned(PIXEL_DEPTH-1 downto 0);
        variable r1, g1, b1, r2, g2, b2 : std_logic;
    begin
        
        r1 := '0'; g1 := '0'; b1 := '0'; -- Defaults
        r2 := '0'; g2 := '0'; b2 := '0'; -- Defaults
        
        -- Default register next-state assignments
        next_col_count <= col_count;
        next_bpp_count <= bpp_count;
        next_led_addr <= s_led_addr;
        next_ram_addr <= s_ram_addr;
        next_rgb1 <= s_rgb1;
        next_rgb2 <= s_rgb2;
        
        -- Default signal assignments
        s_clk_out <= '0';
        s_lat <= '0';
        s_oe <= '1'; -- this signal is "active low"
        
        -- States
        case state is
            when INIT =>
                if(s_led_addr = "111") then
                    if(bpp_count = unsigned(to_signed(-2, PIXEL_DEPTH))) then
                        next_bpp_count <= (others => '0');
                    else
                        next_bpp_count <= bpp_count + 1;
                    end if;
                end if;
                next_state <= READ_PIXEL_DATA;
            when READ_PIXEL_DATA =>
                s_oe <= '0'; -- enable display
                -- Do parallel comparisons against BPP counter to gain multibit color
                if(upper_r > bpp_count) then
                    r1 := '1';
                end if;
                if(upper_g > bpp_count) then
                    g1 := '1';
                end if;
                if(upper_b > bpp_count) then
                    b1 := '1';
                end if;
                if(lower_r > bpp_count) then
                    r2 := '1';
                end if;
                if(lower_g > bpp_count) then
                    g2 := '1';
                end if;
                if(lower_b > bpp_count) then
                    b2 := '1';
                end if;
                next_col_count <= col_count + 1; -- update/increment column counter
                if(col_count < IMG_WIDTH) then -- check if at the rightmost side of the image
                    next_state <= INCR_RAM_ADDR;
                else
                    next_state <= INCR_LED_ADDR;
                end if;
            when INCR_RAM_ADDR =>
                s_clk_out <= '1'; -- pulse the output clock
                s_oe <= '0'; -- enable display
                next_ram_addr <= std_logic_vector( unsigned(s_ram_addr) + 1 );
                next_state <= READ_PIXEL_DATA;
            when INCR_LED_ADDR =>
                -- display is disabled during led_addr (select lines) update
                next_led_addr <= std_logic_vector( unsigned(s_led_addr) + 1 );
                next_col_count <= (others => '0'); -- reset the column counter
                next_state <= LATCH;
            when LATCH =>
                -- display is disabled during latching
                s_lat <= '1'; -- latch the data
                next_state <= INIT; -- restart state machine
            when others => null;
        end case;
        
        -- Pixel data is given as 2 combined words, with the upper half containing
        -- the upper pixel and the lower half containing the lower pixel. Inside
        -- each half the pixel data is encoded in RGB order with multiple repeated
        -- bits for each subpixel depending on the chosen color depth. For example,
        -- a PIXEL_DEPTH of 3 results in a 18-bit word arranged RRRGGGBBBrrrgggbbb.
        -- The following assignments break up this encoding into the human-readable
        -- signals used above, or reconstruct it into LED data signals.
        upper := unsigned(data(DATA_WIDTH-1 downto DATA_WIDTH/2));
        lower := unsigned(data(DATA_WIDTH/2-1 downto 0));
        upper_r := upper(3*PIXEL_DEPTH-1 downto 2*PIXEL_DEPTH);
        upper_g := upper(2*PIXEL_DEPTH-1 downto   PIXEL_DEPTH);
        upper_b := upper(  PIXEL_DEPTH-1 downto 0);
        lower_r := lower(3*PIXEL_DEPTH-1 downto 2*PIXEL_DEPTH);
        lower_g := lower(2*PIXEL_DEPTH-1 downto   PIXEL_DEPTH);
        lower_b := lower(  PIXEL_DEPTH-1 downto 0);
        next_rgb1 <= r1 & g1 & b1;
        next_rgb2 <= r2 & g2 & b2;
        
    end process;
    
end bhv;
