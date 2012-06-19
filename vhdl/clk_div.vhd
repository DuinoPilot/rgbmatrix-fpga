-- Simple parameterized clock divider that uses a counter
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
use ieee.math_real.all; -- don't use for synthesis, but OK for static numbers

entity clk_div is
    generic (
        clk_in_freq : natural;
        clk_out_freq : natural
    );
    port (
        clk_in : in std_logic;
        clk_out : out std_logic; 
        rst : in std_logic
    );
end clk_div;

architecture bhv of clk_div is
    constant OUT_PERIOD_COUNT : integer := (clk_in_freq/clk_out_freq)-1;
begin
    process(clk_in, rst)
        variable count : integer range 0 to OUT_PERIOD_COUNT; -- note: integer type defaults to 32-bits wide unless you specify the range yourself
    begin
        if(rst = '1') then
            count := 0;
            clk_out <= '0';
        elsif(rising_edge(clk_in)) then
            if(count = OUT_PERIOD_COUNT) then
                count := 0;
            else
                count := count + 1;
            end if;
            if(count > OUT_PERIOD_COUNT/2) then
                clk_out <= '1';
            else
                clk_out <= '0';
            end if;
        end if;
    end process;
end bhv;
