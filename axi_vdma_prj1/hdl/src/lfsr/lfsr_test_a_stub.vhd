-------------------------------------------------------------------------------
-- Title      : LFSR TEST - Instantiation A
-- Project    : 
-------------------------------------------------------------------------------
-- File       : lfsr_test.vhd
-- Author     : FPGA Developer  <xl@awzsrv.nasz.dom>
-- Company    : 
-- Created    : 2016-05-08
-- Last update: 2016-05-08
-- Platform   : 
-- Standard   : VHDL'93/02
-- Licence    : Creative Commons CC0 or PUBLIC DOMAIN
-------------------------------------------------------------------------------
-- Description: Quick & dirty implementation of LFSR register
--              with width up to 32 bits, controlled by IPbus
--              It shouldn't be used for any serious applications
--              It was created just for testing of VEXTPROJ environment
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-05-08  1.0      xl      Created
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
library work;
use work.ipbus.all;

entity lfsr_test_a is

  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    ipbus_in  : in  ipb_wbus;
    ipbus_out : out ipb_rbus
    );


end entity lfsr_test_a;

architecture stub of lfsr_test_a is
attribute syn_black_box : boolean;
--attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
begin
end;
