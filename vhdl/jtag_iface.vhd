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
use ieee.numeric_std.all;

use work.rgbmatrix.all;

entity jtag_iface is
    port (
        rst     : in  std_logic;
        rst_out : out std_logic;
        output  : out std_logic_vector(DATA_WIDTH-1 downto 0);
        valid   : out std_logic
    );
end jtag_iface;

architecture bhv of jtag_iface is
    -- External/raw JTAG signals
    signal jtag_tdo, jtag_tck, jtag_tdi, jtag_sdr : std_logic;
    signal jtag_ir_in : std_logic_vector(1 downto 0);
    -- Internal JTAG signals
    signal dr_select : std_logic;
    signal dr0 : std_logic;
    signal dr1 : std_logic_vector(DATA_WIDTH-1 downto 0);
    -- Internal counter signals
    signal dr1_pulse : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
    
    -- Altera Virtual JTAG "megafunction"
    U_vJTAG : entity work.megawizard_vjtag
        port map (
            ir_out => "00",
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
            virtual_state_udr  => open,
            virtual_state_uir  => open
        );
    
    -- Break out the instruction register's low bit which we use to select the destination data register
    dr_select <= jtag_ir_in(0);
    
    -- Break out the instruction register's high bit which we use to perform a self-reset
    rst_out <= jtag_ir_in(1);
    
    -- Clocked process to shift data into the data registers
    process(rst, jtag_tck, dr_select)
    begin
        if(rst = '1') then
            dr0 <= '0';
            dr1 <= (others => '0');
            dr1_pulse <= (others => '0');
            dr1_pulse(DATA_WIDTH-1) <= '1';
        elsif(rising_edge(jtag_tck)) then
            dr0 <= jtag_tdi;
            if(jtag_sdr = '1' and dr_select = '1') then -- JTAG is in Shift DR state and data register 1 is selected
                dr1 <= (jtag_tdi & dr1(DATA_WIDTH-1 downto 1)); -- drop the LSB, shift in the new MSB
                dr1_pulse <= (dr1_pulse(0) & dr1_pulse(DATA_WIDTH-1 downto 1)); -- rotate right the dr1 word pulse
            end if;
        end if;
    end process;
    
    -- Maintain the TDO continuity
    process(dr_select, dr0, dr1)
    begin
        if(dr_select = '1') then
            jtag_tdo <= dr1(0);
        else
            jtag_tdo <= dr0;
        end if;
    end process;
    
    -- The UDR signal will assert when the data has been transmitted and the data register has
    -- captured the word. Ignoring this signal will cause an unwanted behavior as data is shifted
    -- through the data register. In this case we are using a memory to store the value in DR1.
    -- The original idea was to use UDR as the write clock (rising edge triggered), but this
    -- requires all JTAG transfers to be exactly one word. Instead, a bit counter is implemented
    -- that indicates when a full word is shifted in by the JTAG clock (TCK).
    valid <= dr1_pulse(DATA_WIDTH-1);
    
    -- Break out the data register to the output
    output <= dr1;
    
end bhv;