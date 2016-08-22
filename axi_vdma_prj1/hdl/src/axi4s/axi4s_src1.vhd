-------------------------------------------------------------------------------
-- Title      : AXI4 Stream simple source
-- Project    : 
-------------------------------------------------------------------------------
-- File       : axi4s_src1.vhd
-- Author     : Wojciech M. Zabolotny <wzab01@gmail.com>
-- Company    : 
-- Created    : 2016-08-09
-- Last update: 2016-08-11
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: This file implements the minimalistic source of data
--              transmitted via AXI4 Stream
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-08-09  1.0      xl      Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-------------------------------------------------------------------------------
entity axi4s_src1 is

  port (
    -- AXI4 Stream interface
    tdata  : out std_logic_vector(31 downto 0);
    tkeep  : out std_logic_vector(3 downto 0);
    tlast  : out std_logic;
    tready : in  std_logic;
    tvalid : out std_logic;
    -- System interface
    clk    : in  std_logic;
    resetn : in  std_logic;
    -- Start signal
    start  : in  std_logic
    );

end entity axi4s_src1;

architecture rtl of axi4s_src1 is

  signal pkt_num : integer               := 0;
  signal s_data  : unsigned(31 downto 0) := (others => '0');
  signal old_start : std_logic := '0';
  signal wrd_count : integer := 0;

  constant PKT1_START : integer := 10;
  constant PKT1_STEP  : integer := 3;
  constant PKT1_LEN   : integer := 50;

  constant PKT2_START : integer := 1;
  constant PKT2_STEP  : integer := 2;
  constant PKT2_LEN   : integer := 20;

  constant PKT3_START : integer := 8;
  constant PKT3_STEP  : integer := 4;
  constant PKT3_LEN   : integer := 30;


begin  -- architecture rtl

  tkeep <= (others => '1');
  tdata <= std_logic_vector(s_data);
  
  p1 : process (clk) is
  begin  -- process p1
    if clk'event and clk = '1' then     -- rising clock edge
      if resetn = '0' then              -- synchronous reset (active low)
        pkt_num <= 0;
        s_data   <= (others => '0');
        tvalid  <= '0';
        tlast   <= '0';
        old_start <= '0';
      else
        old_start <= start;
        case pkt_num is
          when 0 =>
            tvalid <= '0';
            tlast  <= '0';
            -- Idle state, waiting for start
            if (old_start = '0') and (start = '1') then
              pkt_num   <= 1;
              wrd_count <= 1;
              s_data    <= to_unsigned(PKT1_START, 32);
              tvalid    <= '1';
              tlast     <= '0';
            end if;
          when 1 =>
            -- Transmit packet 1
            if tready = '1' then
              if wrd_count < PKT1_LEN then
                wrd_count <= wrd_count+1;
                s_data <= s_data + PKT1_STEP;
                if wrd_count = PKT1_LEN-1 then
                  tlast <= '1';
                end if;
              else
                pkt_num   <= 2;
                wrd_count <= 1;
                s_data    <= to_unsigned(PKT2_START, 32);
                tlast     <= '0';
              end if;
            end if;
          when 2 =>
            -- Transmit packet 2
            if tready = '1' then
              if wrd_count < PKT2_LEN then
                wrd_count <= wrd_count+1;
                s_data <= s_data + PKT2_STEP;
                if wrd_count = PKT2_LEN-1 then
                  tlast <= '1';
                end if;
              else
                pkt_num   <= 3;
                wrd_count <= 1;
                s_data    <= to_unsigned(PKT3_START, 32);
                tlast     <= '0';
              end if;
            end if;
          when 3 =>
            -- Transmit packet 2
            if tready = '1' then
              if wrd_count < PKT3_LEN then
                wrd_count <= wrd_count+1;
                s_data <= s_data + PKT3_STEP;
                if wrd_count = PKT3_LEN-1 then
                  tlast <= '1';
                end if;
              else
                pkt_num   <= 0;
                wrd_count <= 0;
                s_data    <= to_unsigned(0, 32);
                tvalid    <= '0';
                tlast     <= '0';
              end if;
            end if;
          when others => null;
        end case;
      end if;
    end if;
  end process p1;

end architecture rtl;
