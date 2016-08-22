--Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2016.1 (lin64) Build 1538259 Fri Apr  8 15:45:23 MDT 2016
--Date        : Sun May  8 20:00:15 2016
--Host        : wzab running 64-bit Debian GNU/Linux testing/unstable
--Command     : generate_target design_1_wrapper.bd
--Design      : design_1_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_wrapper is
  port (
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    -- USER PORTS
    LEDS : out std_logic_vector(2 downto 0)
  );
end design_1_wrapper;

architecture STRUCTURE of design_1_wrapper is

  signal ipb_clk    : std_logic;
  signal ipb_rst    : std_logic;
  signal ipb_addr   : std_logic_vector (31 downto 0);
  signal ipb_wdata  : std_logic_vector (31 downto 0);
  signal ipb_strobe : std_logic;
  signal ipb_write  : std_logic;
  signal ipb_rdata  : std_logic_vector (31 downto 0);
  signal ipb_ack    : std_logic;
  signal ipb_err    : std_logic;
  signal s_leds     : std_logic_vector(2 downto 0);
  signal dma_start  : std_logic;
  
  component design_1 is
  port (
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    dma_start : out STD_LOGIC;
    ipb_clk : out STD_LOGIC;
    ipb_rst : out STD_LOGIC;
    ipb_addr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    ipb_wdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    ipb_strobe : out STD_LOGIC;
    ipb_write : out STD_LOGIC;
    ipb_rdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    ipb_ack : in STD_LOGIC;
    ipb_err : in STD_LOGIC
  );
  end component design_1;

  component slaves is
    port (
      ipb_clk    : in  std_logic;
      ipb_rst    : in  std_logic;
      ipb_addr   : in  std_logic_vector (31 downto 0);
      ipb_wdata  : in  std_logic_vector (31 downto 0);
      ipb_strobe : in  std_logic;
      ipb_write  : in  std_logic;
      ipb_rdata  : out std_logic_vector (31 downto 0);
      ipb_ack    : out std_logic;
      ipb_err    : out std_logic;
      leds       : out std_logic_vector(2 downto 0));
  end component slaves;
  
begin
design_1_i: component design_1
     port map (
      DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
      DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
      DDR_cas_n => DDR_cas_n,
      DDR_ck_n => DDR_ck_n,
      DDR_ck_p => DDR_ck_p,
      DDR_cke => DDR_cke,
      DDR_cs_n => DDR_cs_n,
      DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
      DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
      DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
      DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
      DDR_odt => DDR_odt,
      DDR_ras_n => DDR_ras_n,
      DDR_reset_n => DDR_reset_n,
      DDR_we_n => DDR_we_n,
      FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
      FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
      FIXED_IO_ps_clk => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
      dma_start => dma_start,
      ipb_ack => ipb_ack,
      ipb_addr(31 downto 0) => ipb_addr(31 downto 0),
      ipb_clk => ipb_clk,
      ipb_err => ipb_err,
      ipb_rdata(31 downto 0) => ipb_rdata(31 downto 0),
      ipb_rst => ipb_rst,
      ipb_strobe => ipb_strobe,
      ipb_wdata(31 downto 0) => ipb_wdata(31 downto 0),
      ipb_write => ipb_write
      );

slaves_1: slaves
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
    leds       => s_leds);
    
    LEDS(0) <= s_leds(0);
    LEDS(1) <= s_leds(1);
    LEDS(2) <= dma_start;
end STRUCTURE;
