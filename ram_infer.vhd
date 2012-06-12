-- Adafruit RGB LED Matrix Display Driver
-- RAM (inferred)
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

-- For more information on how to infer RAMs on Altera devices see this page:
-- http://quartushelp.altera.com/current/mergedProjects/hdl/vhdl/vhdl_pro_ram_inferred.htm

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ram_infer is
    generic (
        ADDR_WIDTH   : positive := 8;
        DATA_WIDTH   : positive := 3
    );
    port (
        clk   : in  std_logic;
        wren  : in  std_logic;
        waddr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        raddr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        wdata : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        rdata : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end ram_infer;

architecture bhv of ram_infer is
    type MEM_TYPE is array (0 to (DATA_WIDTH*2**ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mem : MEM_TYPE;
begin
    
    process(clk)
    begin
        if(rising_edge(clk)) then
            if(wren = '1') then
                mem(conv_integer(waddr)) <= wdata;
            else
                rdata <= mem(conv_integer(raddr));
            end if;
        end if;
    end process;
    
end bhv;
