-- The ipbus slaves live in this entity - modify according to requirements
--
-- Ports can be added to give ipbus slaves access to the chip top level.
--
-- Dave Newbold, February 2011

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.ipbus.all;
library work;

entity slaves is
  port(
    ipb_clk    : in  std_logic;
    ipb_rst    : in  std_logic;
    ipb_addr   : in  std_logic_vector (31 downto 0);
    ipb_wdata  : in  std_logic_vector (31 downto 0);
    ipb_strobe : in  std_logic;
    ipb_write  : in  std_logic;
    ipb_rdata  : out std_logic_vector (31 downto 0);
    ipb_ack    : out std_logic;
    ipb_err    : out std_logic; 

    -- User logic connections
    -- You may use record types for more complex connections
    leds : out std_logic_vector(2 downto 0)
    );

end slaves;

architecture rtl of slaves is

  signal ipb_in  : ipb_wbus;
  signal ipb_out : ipb_rbus;

  constant NSLV             : positive := 5;
  signal ipbw               : ipb_wbus_array(NSLV-1 downto 0);
  signal ipbr, ipbr_d       : ipb_rbus_array(NSLV-1 downto 0);
  signal ctrl_reg           : std_logic_vector(31 downto 0);
  signal test_reg           : std_logic_vector(31 downto 0);
  signal inj_ctrl, inj_stat : std_logic_vector(63 downto 0);

  component lfsr_test_a is
    port (
      clk       : in  std_logic;
      reset     : in  std_logic;
      ipbus_in  : in  ipb_wbus;
      ipbus_out : out ipb_rbus);
  end component lfsr_test_a;

  component lfsr_test_b is
    port (
      clk       : in  std_logic;
      reset     : in  std_logic;
      ipbus_in  : in  ipb_wbus;
      ipbus_out : out ipb_rbus);
  end component lfsr_test_b;


begin

  ipb_in.ipb_addr   <= ipb_addr;
  ipb_in.ipb_wdata  <= ipb_wdata;
  ipb_in.ipb_strobe <= ipb_strobe;
  ipb_in.ipb_write  <= ipb_write;
  ipb_rdata         <= ipb_out.ipb_rdata;
  ipb_ack           <= ipb_out.ipb_ack;
  ipb_err           <= ipb_out.ipb_err;


  fabric : entity work.ipbus_fabric
    generic map(NSLV => NSLV)
    port map(
      ipb_in          => ipb_in,
      ipb_out         => ipb_out,
      ipb_to_slaves   => ipbw,
      ipb_from_slaves => ipbr
      );

-- Slave 0: id / rst reg

  slave0 : entity work.ipbus_ctrlreg
    port map(
      clk       => ipb_clk,
      reset     => ipb_rst,
      ipbus_in  => ipbw(0),
      ipbus_out => ipbr(0),
      d         => X"abcdfedc",
      q         => ctrl_reg
      );

  leds <= ctrl_reg(2 downto 0);
-- Slave 1: register

  slave1 : entity work.ipbus_reg
    generic map(addr_width => 0)
    port map(
      clk       => ipb_clk,
      reset     => ipb_rst,
      ipbus_in  => ipbw(1),
      ipbus_out => ipbr(1),
      q         => test_reg
      );
-- Slave 2: LFSR with register access
-- Must be instantiated in "OLD" way to allow OOC!
  slave2 : lfsr_test_b
    port map(
      clk       => ipb_clk,
      reset     => ipb_rst,
      ipbus_in  => ipbw(2),
      ipbus_out => ipbr(2)
      );
-- Slave 3: LFSR with register access
-- Must be instantiated in "OLD" way to allow OOC!
  slave3 : lfsr_test_a
    port map(
      clk       => ipb_clk,
      reset     => ipb_rst,
      ipbus_in  => ipbw(3),
      ipbus_out => ipbr(3)
      );


-- Slave 2: 4kword RAM

  slave4 : entity work.ipbus_ram
    generic map(addr_width => 12)
    port map(
      clk       => ipb_clk,
      reset     => ipb_rst,
      ipbus_in  => ipbw(4),
      ipbus_out => ipbr(4)
      );

end rtl;
