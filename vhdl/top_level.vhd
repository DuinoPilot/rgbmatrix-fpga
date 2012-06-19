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
use ieee.math_real.log2;

use work.rgbmatrix.all; -- Constants & Config

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
    constant DATA_WIDTH : positive := 3; -- one bit for each subpixel
    constant ADDR_WIDTH : positive := positive(log2(real(NUM_PANELS_WIDE*NUM_PANELS_TALL*256)));
    signal rst, led_clk : std_logic;
    signal ram1a_raddr, ram1a_waddr, ram2a_raddr, ram2a_waddr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal ram1b_raddr, ram1b_waddr, ram2b_raddr, ram2b_waddr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal ram1a_din, ram1a_dout, ram2a_din, ram2a_dout : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal ram1b_din, ram1b_dout, ram2b_din, ram2b_dout, jtag_output : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal ram1a_wren, ram2a_wren : std_logic;
    signal ram1b_wren, ram2b_wren : std_logic;
    signal memory_sel : std_logic;
    signal jtag_tdo, jtag_tck, jtag_tdi, jtag_udr, jtag_sdr : std_logic;
    signal jtag_ir_in : std_logic_vector(0 downto 0);
begin
    
    -- Reset is an "active low" signal
    rst <= not rst_n;
    
    -- Simple clock divider
    U_CLKDIV : entity work.clk_div
        generic map (
            clk_in_freq => 2,
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
            IMG_HEIGHT => PANEL_HEIGHT*NUM_PANELS_TALL, -- TODO UNUSED
            IMG_WIDTH  => PANEL_WIDTH*NUM_PANELS_WIDE,
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        port map (
            clk_in => led_clk,
            rst => rst,
            clk_out => clk_out,
            rgb1(2) => r1,
            rgb1(1) => b1,
            rgb1(0) => g1,
            rgb2(2) => r2,
            rgb2(1) => b2,
            rgb2(0) => g2,
            led_addr(0) => a,
            led_addr(1) => b,
            led_addr(2) => c,
            lat => lat,
            oe  => oe,
            ram1_addr => ram1a_raddr,
            ram1_dout => ram1a_dout,
            ram2_addr => ram2a_raddr,
            ram2_dout => ram2a_dout
        );
    
    -- Video data controller
    U_VIDCTRL : entity work.vidctrl
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        port map (
            clk => clk_in,
            rst => rst,
            reload => '0', --reload, -- TODO debug
            jtag_output => jtag_output,
            jtag_udr => jtag_udr,
            memory_sel => memory_sel,
            ram1_data => ram1b_din,
            ram1_addr => ram1b_waddr,
            ram1_wren => ram1b_wren,
            ram2_data => ram2b_din,
            ram2_addr => ram2b_waddr,
            ram2_wren => ram2b_wren
        );
    
    -- Memory
    U_MEMORY : entity work.memory
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        port map (
            clk => clk_in,
            sel => memory_sel,
            rdata1a => ram1a_dout,
            raddr1a => ram1a_raddr,
            rdata2a => ram2a_dout,
            raddr2a => ram2a_raddr,
            wdata1b => ram1b_din,
            waddr1b => ram1b_waddr,
            wren1b  => ram1b_wren,
            wdata2b => ram2b_din,
            waddr2b => ram2b_waddr,
            wren2b  => ram2b_wren
        );
    
    -- Virtual JTAG
    U_JTAGIFACE : entity work.jtag_iface
        generic map (
            WORD_SIZE => DATA_WIDTH
        )
        port map (
            rst    => rst,
            tck    => jtag_tck,
            tdi    => jtag_tdi,
            ir_in  => jtag_ir_in,
            udr    => jtag_udr,
            sdr    => jtag_sdr,
            tdo    => jtag_tdo,
            output => jtag_output
        );
    
    U_vJTAG : entity work.megawizard_vjtag
        port map (
            ir_out => "0",
            tdo    => jtag_tdo,
            ir_in  => jtag_ir_in,
            tck    => jtag_tck,
            tdi    => jtag_tdi,
            virtual_state_cdr  => open,
            virtual_state_cir  => open,
            virtual_state_e1dr => open,
            virtual_state_e2dr => open,
            virtual_state_pdr  => open,
            virtual_state_sdr  => jtag_sdr,
            virtual_state_udr  => jtag_udr,
            virtual_state_uir  => open
        );
    
end str;
