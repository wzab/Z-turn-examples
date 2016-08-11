-------------------------------------------------------------------------------
-- Title      : LFSR TEST
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

entity lfsr_test is

  generic (
    width : integer range 1 to 32 := 11;
    poly  : integer               := 3);

  port (
    clk       : in  std_logic;
    reset     : in  std_logic;
    ipbus_in  : in  ipb_wbus;
    ipbus_out : out ipb_rbus
    );


end entity lfsr_test;

architecture rtl of lfsr_test is

  signal shift_reg  : std_logic_vector(31 downto 0);
  constant xor_mask : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(poly, 32));
  signal d          : ipb_reg_v(0 to 0)             := (others => (others => '0'));
  signal q          : ipb_reg_v(0 to 1)             := (others => (others => '0'));
  signal stb        : std_logic_vector(1 downto 0)  := (others => '0');

begin  -- architecture rtl


  ipbus_ctrlreg_v_1 : entity work.ipbus_ctrlreg_v
    generic map (
      N_CTRL => 2,
      N_STAT => 1)
    port map (
      clk       => clk,
      reset     => reset,
      ipbus_in  => ipbus_in,
      ipbus_out => ipbus_out,
      d         => d,
      q         => q,
      stb       => stb);

  d(0) <= shift_reg;

  process (clk) is
    variable new_bit : std_logic := '0';
  begin  -- process
    if clk'event and clk = '1' then     -- rising clock edge
      if reset = '1' then               -- synchronous reset (active high)
        shift_reg <= std_logic_vector(to_unsigned(1, 32));
      else
        if stb(0) = '1' then
          shift_reg <= ipbus_in.ipb_wdata;
        elsif stb(1) = '1' then
          -- Shift register
          new_bit := '0';
          for i in 0 to width-1 loop
            if xor_mask(i) = '1' then
              new_bit := new_bit xor shift_reg(i);
            end if;
          end loop;  -- i
          shift_reg <= shift_reg(30 downto 0) & new_bit;
        end if;
      end if;
    end if;
  end process;

end architecture rtl;
