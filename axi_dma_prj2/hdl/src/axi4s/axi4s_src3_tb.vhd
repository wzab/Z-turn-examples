-------------------------------------------------------------------------------
-- Title      : Testbench for design "axi4s_src3"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : axi4s_src1_tb.vhd
-- Author     : Wojciech Zabołotny  <wzab@wzab.nasz.dom>
-- Company    : 
-- Created    : 2016-12-11
-- Last update: 2016-12-11
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-12-11  1.0      wzab	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity axi4s_src3_tb is

end entity axi4s_src3_tb;

-------------------------------------------------------------------------------

architecture test of axi4s_src3_tb is

  -- component ports
  signal tdata  : std_logic_vector(31 downto 0);
  signal tkeep  : std_logic_vector(3 downto 0);
  signal tlast  : std_logic;
  signal tready : std_logic := '1';
  signal tvalid : std_logic;
  signal resetn : std_logic := '0';
  signal start  : std_logic := '0';

  -- clock
  signal Clk : std_logic := '1';

begin  -- architecture test

  -- component instantiation
  DUT: entity work.axi4s_src3
    port map (
      tdata  => tdata,
      tkeep  => tkeep,
      tlast  => tlast,
      tready => tready,
      tvalid => tvalid,
      clk    => clk,
      resetn => resetn,
      start  => start);

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    wait until Clk = '1';
    wait for  15 ns;
    resetn <= '1';
    wait for 20 ns;
    start <= '1';
    wait;
  end process WaveGen_Proc;


  

end architecture test;

-------------------------------------------------------------------------------
