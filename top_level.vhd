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

entity top_level is
    port (
        clk_in  : in std_logic;
        rst     : in std_logic;
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
    constant DATA_WIDTH : positive := 3;
    constant ADDR_WIDTH : positive := 8;
    signal led_clk, led_rst : std_logic;
    signal ram1_raddr, ram1_waddr, ram2_raddr, ram2_waddr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal ram1_din, ram1_dout, ram2_din, ram2_dout : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal ram1_wren, ram2_wren : std_logic;
begin
    
    -- Simple clock divider
    U_CLKDIV : entity work.clk_div
        generic map (
            clk_in_freq => 10,
            clk_out_freq => 1
        )
        port map (
            rst => rst,
            clk_in => clk_in,
            clk_out => led_clk
        );
    
    -- LED panel controller
    U_LEDCTRL : entity work.ledctrl
        generic map (
            IMG_HEIGHT => 16, -- TODO UNUSED
            IMG_WIDTH => 32,--64, -- one panel is 32, two panels is 64 [ TODO improve ]
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        port map (
            clk_in => led_clk,
            rst => led_rst,
            clk_out => clk_out,
            rgb1(2)  => r1,
            rgb1(1)  => b1,
            rgb1(0)  => g1,
            rgb2(2)  => r2,
            rgb2(1)  => b2,
            rgb2(0)  => g2,
            led_addr(0) => a,
            led_addr(1) => b,
            led_addr(2) => c,
            lat => lat,
            oe  => oe,
            ram1_addr => ram1_raddr,
            ram1_dout => ram1_dout,
            ram2_addr => ram2_raddr,
            ram2_dout => ram2_dout
        );
    
    -- Video data controller
    U_VIDCTRL : entity work.vidctrl
        port map (
            clk => clk_in,
            rst => rst,
            rst_out => led_rst,
            ram1_data => ram1_din,
            ram1_addr => ram1_waddr,
            ram1_wren => ram1_wren,
            ram2_data => ram2_din,
            ram2_addr => ram2_waddr,
            ram2_wren => ram2_wren
        );
    
    -- Memory
    U_RAM1 : entity work.ram_infer
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        port map (
            clk   => clk_in,
            rdata => ram1_dout,
            wdata => ram1_din,
            raddr => ram1_raddr,
            waddr => ram1_waddr,
            wren  => ram1_wren
        );
    
    U_RAM2 : entity work.ram_infer
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        port map (
            clk   => clk_in,
            rdata => ram2_dout,
            wdata => ram2_din,
            raddr => ram2_raddr,
            waddr => ram2_waddr,
            wren  => ram2_wren
        );
    
end str;
