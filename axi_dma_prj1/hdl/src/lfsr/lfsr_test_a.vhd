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
use work.ipbus_reg_types.all;

entity lfsr_test_a is

  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    ipbus_in  : in  ipb_wbus;
    ipbus_out : out ipb_rbus
    );


end entity lfsr_test_a;

architecture rtl of lfsr_test_a is

  component lfsr_test is
    generic (
      width : integer range 1 to 32;
      poly  : integer);
    port (
      clk       : in  std_logic;
      reset     : in  std_logic;
      ipbus_in  : in  ipb_wbus;
      ipbus_out : out ipb_rbus);
  end component lfsr_test;
  
begin

  lfsr_test_1: lfsr_test
    generic map(
      width      => 4,
      poly       => 12
      )
    port map (
      clk       => clk,
      reset     => reset,
      ipbus_in  => ipbus_in,
      ipbus_out => ipbus_out);
  
end architecture rtl;
