-------------------------------------------------------------------------------
-- Title      : Testbench for design "ipbus_ctrl"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ipbus_ctrl_tb.vhd
-- Author     : Wojciech M. Zabolotny  <wzab@ise.pw.edu.pl>
-- Company    : 
-- Created    : 2016-06-07
-- Last update: 2016-06-07
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-06-07  1.0      wzab	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.ipbus.all;
library work;
-------------------------------------------------------------------------------

entity ipbus_ctrl_tb is

end entity ipbus_ctrl_tb;

-------------------------------------------------------------------------------
architecture rtl of ipbus_ctrl_tb is

  -- component generics
  constant rdpipename : string := "/tmp/rdpipe";
  constant wrpipename : string := "/tmp/wrpipe"; 

  -- component ports
  signal ipb_out : ipb_wbus;
  signal ipb_in  : ipb_rbus;
  signal ipb_clk : std_logic; 

  signal ipb_rst    : std_logic := '1';
  signal ipb_addr   : std_logic_vector (31 downto 0);
  signal ipb_wdata  : std_logic_vector (31 downto 0);
  signal ipb_strobe : std_logic;
  signal ipb_write  : std_logic;
  signal ipb_rdata  : std_logic_vector (31 downto 0);
  signal ipb_ack    : std_logic;
  signal ipb_err    : std_logic;
  signal leds       : std_logic_vector(2 downto 0);
  
  -- clock
  signal Clk : std_logic := '1';

begin  -- architecture rtl

  -- component instantiation
  DUT: entity work.ipbus_ctrl
    generic map (
      rdpipename => rdpipename,
      wrpipename => wrpipename)
    port map (
      ipb_out => ipb_out,
      ipb_in  => ipb_in,
      ipb_clk => ipb_clk);

  slaves_1: entity work.slaves
    port map (
      ipb_clk    => ipb_clk,
      ipb_rst    => ipb_rst,
      ipb_addr   => ipb_addr,
      ipb_wdata  => ipb_wdata,
      ipb_strobe => ipb_strobe,
      ipb_write  => ipb_write,
      ipb_rdata  => ipb_rdata,
      ipb_ack    => ipb_ack,
      ipb_err    => ipb_err,
      leds       => leds);

  ipb_clk <= Clk;
  -- Mapping of signals from the "flattened" IP-bus implementation
  ipb_addr <= ipb_out.ipb_addr;
  ipb_wdata <= ipb_out.ipb_wdata;
  ipb_strobe <= ipb_out.ipb_strobe;
  ipb_write <= ipb_out.ipb_write;

  ipb_in.ipb_rdata <= ipb_rdata;
  ipb_in.ipb_ack <= ipb_ack;
  ipb_in.ipb_err <= ipb_err;
  
  
  -- clock generation
  Clk <= not Clk after 10 ns;
  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here

    wait until Clk = '1';
    wait for 15 ns;
    ipb_rst <= '0';
  end process WaveGen_Proc;

  

end architecture rtl;

-------------------------------------------------------------------------------

