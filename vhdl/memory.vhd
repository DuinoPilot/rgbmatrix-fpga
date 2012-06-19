-- Adafruit RGB LED Matrix Display Driver
-- Contains the 4 memories used for graphics data and a mux to switch between them
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

entity memory is
    generic (
        DATA_WIDTH : positive;
        ADDR_WIDTH : positive
    );
    port (
        clk     : in std_logic;
        sel     : in std_logic;
        rdata1a : out std_logic_vector(DATA_WIDTH-1 downto 0);
        raddr1a : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        rdata2a : out std_logic_vector(DATA_WIDTH-1 downto 0);
        raddr2a : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        wdata1b : in std_logic_vector(DATA_WIDTH-1 downto 0);
        waddr1b : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        wren1b  : in std_logic;
        wdata2b : in std_logic_vector(DATA_WIDTH-1 downto 0);
        waddr2b : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        wren2b  : in std_logic
    );
end memory;

architecture str of memory is
    signal s_wren1a, s_wren2a, s_wren1b, s_wren2b : std_logic;
    signal s_rdata1a : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_wdata1a : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_rdata2a : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_wdata2a : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_rdata1b : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_wdata1b : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_rdata2b : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_wdata2b : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal s_raddr1a : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal s_waddr1a : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal s_raddr2a : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal s_waddr2a : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal s_raddr1b : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal s_waddr1b : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal s_raddr2b : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal s_waddr2b : std_logic_vector(ADDR_WIDTH-1 downto 0);
begin
    
    -- Higher 8 lines, first buffer
    U_RAM1A : entity work.ram_infer
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        port map (
            clk   => clk,
            rdata => s_rdata1a,
            wdata => s_wdata1a,
            raddr => s_raddr1a,
            waddr => s_waddr1a,
            wren  => s_wren1a
        );
    
    -- Higher 8 lines, second buffer
    U_RAM1B : entity work.ram_infer
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        port map (
            clk   => clk,
            rdata => s_rdata1b,
            wdata => s_wdata1b,
            raddr => s_raddr1b,
            waddr => s_waddr1b,
            wren  => s_wren1b
        );
    
    -- Lower 8 lines, first buffer
    U_RAM2A : entity work.ram_infer
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        port map (
            clk   => clk,
            rdata => s_rdata2a,
            wdata => s_wdata2a,
            raddr => s_raddr2a,
            waddr => s_waddr2a,
            wren  => s_wren2a
        );
    
    -- Lower 8 lines, second buffer
    U_RAM2B : entity work.ram_infer
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ADDR_WIDTH => ADDR_WIDTH
        )
        port map (
            clk   => clk,
            rdata => s_rdata2b,
            wdata => s_wdata2b,
            raddr => s_raddr2b,
            waddr => s_waddr2b,
            wren  => s_wren2b
        );
    
    -- Muxes to switch between buffers
    
    rdata1a <= s_rdata1a WHEN sel = '0' ELSE s_rdata1b;
    s_wdata1a <= (others => 'X') WHEN sel = '0' ELSE wdata1b;
    s_raddr1a <= raddr1a WHEN sel = '0' ELSE (others => 'X');
    s_waddr1a <= (others => 'X') WHEN sel = '0' ELSE waddr1b;
    s_wren1a  <= '0' WHEN sel = '0' ELSE wren1b;
    
    rdata2a <= s_rdata2a WHEN sel = '0' ELSE s_rdata2b;
    s_wdata2a <= (others => 'X') WHEN sel = '0' ELSE wdata2b;
    s_raddr2a <= raddr2a WHEN sel = '0' ELSE (others => 'X');
    s_waddr2a <= (others => 'X') WHEN sel = '0' ELSE waddr2b;
    s_wren2a  <= '0' WHEN sel = '0' ELSE wren2b;
    
    s_wdata1b <= wdata1b WHEN sel = '0' ELSE (others => 'X');
    s_raddr1b <= (others => 'X') WHEN sel = '0' ELSE raddr1a;
    s_waddr1b <= waddr1b WHEN sel = '0' ELSE (others => 'X');
    s_wren1b  <= wren1b  WHEN sel = '0' ELSE '0';
    
    s_wdata2b <= wdata2b WHEN sel = '0' ELSE (others => 'X');
    s_raddr2b <= (others => 'X') WHEN sel = '0' ELSE raddr2a;
    s_waddr2b <= waddr2b WHEN sel = '0' ELSE (others => 'X');
    s_wren2b  <= wren2b  WHEN sel = '0' ELSE '0';
    
end str;