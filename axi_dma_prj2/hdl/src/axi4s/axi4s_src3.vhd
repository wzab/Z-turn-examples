-------------------------------------------------------------------------------
-- Title      : AXI4 Stream simple source
-- Project    : 
-------------------------------------------------------------------------------
-- File       : axi4s_src1.vhd
-- Author     : Wojciech M. Zabolotny <wzab01@gmail.com>
-- Company    : 
-- Created    : 2016-08-09
-- Last update: 2016-12-11
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: This file implements the minimalistic source of data
--              transmitted via AXI4 Stream
--              The source provides packets with pseudorandom length
--              and pseudorandom step
--              Rate of packet generation is adjustable
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
entity axi4s_src3 is

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

end entity axi4s_src3;

architecture rtl of axi4s_src3 is
  constant PKT_DEL : integer               := 100;
  type T_SRC_STATE is (ST_IDLE, ST_START_HEAD, ST_START_PKT, ST_SEND_PKT);
  signal src_state : T_SRC_STATE           := ST_IDLE;
  signal pkt_step  : integer               := 0;
  signal s_data    : unsigned(31 downto 0) := (others => '0');
  signal old_start : std_logic             := '0';
  signal wrd_count : integer               := 0;
  signal pkt_len   : integer               := 0;
  signal del_cnt   : integer               := 0;
  signal init_data : integer               := 0;
  signal shift_reg : std_logic_vector(48 downto 0);
  signal ack_pkt   : std_logic             := '0';
  signal start_pkt : std_logic             := '0';


begin  -- architecture rtl

  tkeep <= (others => '1');
  tdata <= std_logic_vector(s_data);

  -- Here we have the pseudorandom generator, used to generate the length of
  -- the packet and its step
  p2 : process (clk) is
    variable new_bit : std_logic := '0';
  begin  -- process p2
    if clk'event and clk = '1' then     -- rising clock edge
      if resetn = '0' then              -- synchronous reset (active high)
        shift_reg <= std_logic_vector(to_unsigned(1, 49));
      else
        -- Shift register
        new_bit   := shift_reg(48) xor shift_reg(39);
        shift_reg <= shift_reg(47 downto 0) & new_bit;
      end if;
    end if;
  end process p2;

  -- We need a process, that periodically starts sending of the new packet
  -- The delay between packets should not depend on the length of each packet
  p0 : process (clk) is
  begin  -- process p0
    if clk'event and clk = '1' then     -- rising clock edge
      if (resetn = '0') or (start = '0') then  -- synchronous reset (active high)
        del_cnt   <= 0;
        start_pkt <= '0';
      else
        -- If generation of packet is acknowledged, clear start_pkt
        if ack_pkt = '1' then
          start_pkt <= '0';
        end if;
        -- Update the delay counter, and set the start_pkt flag when necessary
        if del_cnt < PKT_DEL then
          del_cnt <= del_cnt + 1;
        else
          start_pkt <= '1';
          del_cnt   <= 0;
        end if;
      end if;
    end if;
  end process p0;


  p1 : process (clk) is
  begin  -- process p1
    if clk'event and clk = '1' then     -- rising clock edge
      if resetn = '0' then              -- synchronous reset (active low)
        s_data    <= (others => '0');
        tvalid    <= '0';
        tlast     <= '0';
        old_start <= '0';
        ack_pkt   <= '0';
        src_state <= ST_IDLE;
      else
        -- Ensure defaul values of the signal
        ack_pkt <= '0';
        case src_state is
          when ST_IDLE =>
            if start_pkt = '1' then
              -- Get the pseudorandom length of the packet, initial value and step
              -- initial value
              pkt_len   <= to_integer(unsigned(shift_reg(28 downto 12))) + 16000;
              --pkt_len   <= to_integer(unsigned(shift_reg(16 downto 12))) + 4;
              pkt_step  <= to_integer(unsigned(shift_reg(11 downto 8)));
              init_data <= to_integer(unsigned(shift_reg(7 downto 0)));
              src_state <= ST_START_HEAD;
            end if;
          when ST_START_HEAD =>
            s_data(7 downto 0)   <= to_unsigned(init_data, 8);
            s_data(11 downto 8)  <= to_unsigned(pkt_step, 4);
            s_data(31 downto 12) <= to_unsigned(pkt_len, 31-12+1);
            wrd_count            <= 1;
            tvalid               <= '1';
            tlast                <= '0';
            ack_pkt              <= '1';
            src_state            <= ST_START_PKT;
          when ST_START_PKT =>
            if tready = '1' then
              wrd_count <= 2;
              s_data    <= to_unsigned(init_data, 32);
              src_state <= ST_SEND_PKT;
            end if;
          when ST_SEND_PKT =>
            if tready = '1' then
              if wrd_count < pkt_len then
                wrd_count <= wrd_count+1;
                s_data    <= s_data + pkt_step;
                if wrd_count = pkt_len-1 then
                  tlast <= '1';
                end if;
              else
                wrd_count <= 0;
                s_data    <= to_unsigned(0, 32);
                tvalid    <= '0';
                tlast     <= '0';
                src_state <= ST_IDLE;
              end if;
            end if;
          when others => null;
        end case;
      end if;
    end if;
  end process p1;

end architecture rtl;
