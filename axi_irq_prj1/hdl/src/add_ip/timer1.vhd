-------------------------------------------------------------------------------
-- Title      : timer1 
-- Project    : 
-------------------------------------------------------------------------------
-- File       : timer1.vhd
-- Author     : Wojciech M. Zabołotny  <wojciech.zabolotny@pw.edu.pl>
-- Company    : Institute of Electronic Systems
-- Created    : 2022-04-13
-- Last update: 2022-04-23
-- Platform   : 
-- Standard   : VHDL'93/02
-- License    : BSD 2-Clause License
-------------------------------------------------------------------------------
-- Description:
--   Timer for SWIS course (based on the QEMU model)
-- Credits:
--   The code is significantly based on the
--   axi_rc_servo_controller.vhd from
--   https://github.com/Architech-Silica/Designing-a-Custom-AXI-Slave-Peripheral
--   BSD 2-Clause License
--   Copyright (c) 2018, Architech (Silica EMEA)
--   All rights reserved.
--
-------------------------------------------------------------------------------
-- Copyright (c) 2022 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2022-04-13  1.0      WZab    Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;

entity timer1 is
  generic
    (
      -- AXI Parameters
      C_S_AXI_ACLK_FREQ_HZ : integer := 100_000_000;
      C_S_AXI_DATA_WIDTH   : integer := 32;
      C_S_AXI_ADDR_WIDTH   : integer := 5
      );
  port
    (
      -- AXI Lite interface
      S_AXI_ACLK    : in  std_logic;
      S_AXI_ARESETN : in  std_logic;
      S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_AWVALID : in  std_logic;
      S_AXI_AWREADY : out std_logic;
      S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_ARVALID : in  std_logic;
      S_AXI_ARREADY : out std_logic;
      S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
      S_AXI_WVALID  : in  std_logic;
      S_AXI_WREADY  : out std_logic;
      S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_RRESP   : out std_logic_vector(1 downto 0);
      S_AXI_RVALID  : out std_logic;
      S_AXI_RREADY  : in  std_logic;
      S_AXI_BRESP   : out std_logic_vector(1 downto 0);
      S_AXI_BVALID  : out std_logic;
      S_AXI_BREADY  : in  std_logic;
      S_AXI_ARPROT  : in  std_logic;
      S_AXI_AWPROT  : in  std_logic;
      -- Interrupt output
      irq           : out std_logic
      );
end entity timer1;

architecture rtl of timer1 is

-- Type declarations
  type main_fsm_type is (reset, idle, read_transaction_in_progress, read_transaction_in_progress_2, write_transaction_in_progress, complete);

  signal current_state, next_state            : main_fsm_type;
  signal write_enable_registers               : std_logic;
  signal send_read_data_to_AXI                : std_logic;
  signal Local_Reset                          : std_logic;
  signal combined_S_AXI_AWVALID_S_AXI_ARVALID : std_logic_vector(1 downto 0);
  signal local_address                        : integer range 0 to 2**C_S_AXI_ADDR_WIDTH;
  signal local_address_valid                  : std_logic;

  signal id_register   : std_logic_vector(31 downto 0) := (others => '0');
  signal stat_reg      : std_logic_vector(31 downto 0) := (others => '0');
  signal stat_register : std_logic_vector(31 downto 0) := (others => '0');
  signal divl_register : std_logic_vector(31 downto 0) := (others => '0');
  signal divh_register : std_logic_vector(31 downto 0) := (others => '0');
  signal cntl_register : std_logic_vector(31 downto 0) := (others => '0');
  signal cnth_register : std_logic_vector(31 downto 0) := (others => '0');

  signal id_register_address_valid   : std_logic := '0';
  signal stat_register_address_valid : std_logic := '0';
  signal divl_register_address_valid : std_logic := '0';
  signal divh_register_address_valid : std_logic := '0';
  signal cntl_register_address_valid : std_logic := '0';
  signal cnth_register_address_valid : std_logic := '0';

  signal timer_latch, timer_count, timer_limit : unsigned(63 downto 0);

  signal irq_req, irq_clear, set_timer : std_logic := '0';

begin

  Local_Reset                          <= not S_AXI_ARESETN;
  combined_S_AXI_AWVALID_S_AXI_ARVALID <= S_AXI_AWVALID & S_AXI_ARVALID;


  state_machine_update : process (S_AXI_ACLK)
  begin
    if S_AXI_ACLK'event and S_AXI_ACLK = '1' then
      if Local_Reset = '1' then
        current_state <= reset;
      else
        current_state <= next_state;
      end if;
    end if;
  end process;

  state_machine_decisions : process (S_AXI_ARVALID, S_AXI_AWVALID,
                                     S_AXI_BREADY, S_AXI_RREADY, S_AXI_WVALID,
                                     combined_S_AXI_AWVALID_S_AXI_ARVALID,
                                     current_state)
  begin
    S_AXI_ARREADY          <= '0';
    S_AXI_RRESP            <= "--";
    S_AXI_RVALID           <= '0';
    S_AXI_WREADY           <= '0';
    S_AXI_BRESP            <= "--";
    S_AXI_BVALID           <= '0';
    S_AXI_WREADY           <= '0';
    S_AXI_AWREADY          <= '0';
    write_enable_registers <= '0';
    send_read_data_to_AXI  <= '0';

    case current_state is
      when reset =>
        next_state <= idle;

      when idle =>
        next_state <= idle;
        case combined_S_AXI_AWVALID_S_AXI_ARVALID is
          when "01"   => next_state <= read_transaction_in_progress;
          when "10"   => next_state <= write_transaction_in_progress;
          when others => null;
        end case;

        -- Handling of read transaction had to be changed, as described in
        -- https://www.fpgarelated.com/showthread/comp.arch.fpga/127408-1.php
        --
        -- The Intel/Altera interconnect does not accept RVALID in the same
        -- cycle when ARREADY is asserted.
        -- Therefore, an additional state read_transaction_in_progress_2
        -- had to be introduced.

      when read_transaction_in_progress =>
        next_state    <= read_transaction_in_progress;
        S_AXI_ARREADY <= S_AXI_ARVALID;
        if S_AXI_ARVALID = '1' then
          next_state <= read_transaction_in_progress_2;
        end if;

      when read_transaction_in_progress_2 =>
        next_state            <= read_transaction_in_progress;
        S_AXI_RVALID          <= '1';
        S_AXI_RRESP           <= "00";
        send_read_data_to_AXI <= '1';
        if S_AXI_RREADY = '1' then
          next_state <= complete;
        end if;

      when write_transaction_in_progress =>
        next_state             <= write_transaction_in_progress;
        write_enable_registers <= '1';
        S_AXI_AWREADY          <= S_AXI_AWVALID;
        S_AXI_WREADY           <= S_AXI_WVALID;
        S_AXI_BRESP            <= "00";
        S_AXI_BVALID           <= '1';
        if S_AXI_BREADY = '1' then
          next_state <= complete;
        end if;

      when complete =>
        case combined_S_AXI_AWVALID_S_AXI_ARVALID is
          when "00"   => next_state <= idle;
          when others => next_state <= complete;
        end case;

      when others =>
        next_state <= reset;
    end case;
  end process;

  send_data_to_AXI_RDATA : process (cnth_register, cntl_register,
                                    divh_register, divl_register, id_register,
                                    local_address, local_address_valid,
                                    send_read_data_to_AXI, stat_register)
  begin
    S_AXI_RDATA <= (others => '-');
    if (local_address_valid = '1' and send_read_data_to_AXI = '1') then
      case (local_address) is
        when 0 =>
          S_AXI_RDATA <= id_register;
        when 4 =>
          S_AXI_RDATA <= stat_register;
        when 8 =>
          S_AXI_RDATA <= divl_register;
        when 12 =>
          S_AXI_RDATA <= divh_register;
        when 16 =>
          S_AXI_RDATA <= cntl_register;
        when 20 =>
          S_AXI_RDATA <= cnth_register;
        when others => null;
      end case;
    end if;
  end process;

  local_address_capture_register : process (S_AXI_ACLK)
  begin
    if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
      if Local_Reset = '1' then
        local_address <= 0;
      else
        if local_address_valid = '1' then
          case (combined_S_AXI_AWVALID_S_AXI_ARVALID) is
            when "10"   => local_address <= to_integer(unsigned(S_AXI_AWADDR(C_S_AXI_ADDR_WIDTH-1 downto 0)));
            when "01"   => local_address <= to_integer(unsigned(S_AXI_ARADDR(C_S_AXI_ADDR_WIDTH-1 downto 0)));
            when others => local_address <= local_address;
          end case;
        end if;
      end if;
    end if;
  end process;

  address_range_analysis : process (local_address)
  begin
    id_register_address_valid   <= '0';
    stat_register_address_valid <= '0';
    divl_register_address_valid <= '0';
    divh_register_address_valid <= '0';
    cntl_register_address_valid <= '0';
    cnth_register_address_valid <= '0';
    local_address_valid         <= '1';

    case (local_address) is
      when 0 => id_register_address_valid   <= '1';
      when 4 => stat_register_address_valid <= '1';
      when 8 =>
        divl_register_address_valid <= '1';
      when 12 =>
        divh_register_address_valid <= '1';
      when 16 =>
        cntl_register_address_valid <= '1';
      when 20 =>
        cnth_register_address_valid <= '1';
      when others =>
        local_address_valid <= '0';
    end case;
  end process;

  id_register <= x"7130900d";


  stat_register_process : process (S_AXI_ACLK)
  begin
    if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
      if Local_Reset = '1' then
        stat_reg <= (others => '0');
      elsif stat_register_address_valid = '1' then
        if send_read_data_to_AXI = '1' then
          -- Actions taken when reading the register
          null;
        end if;
        if write_enable_registers = '1' then
          -- Actions taken when writing the register
          stat_reg <= S_AXI_WDATA and x"00000001";
        end if;
      end if;
    end if;
  end process;

  stat_register <= stat_reg when irq_req = '0'                                else (stat_reg or x"80000000");
  irq           <= '1'      when (irq_req = '1') and (stat_register(0) = '1') else '0';

  divl_register_process : process (S_AXI_ACLK)
  begin
    if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
      set_timer <= '0';
      if Local_Reset = '1' then
        divl_register <= (others => '0');
      elsif divl_register_address_valid = '1' then
        if send_read_data_to_AXI = '1' then
          -- Actions taken when reading the register
          null;
        end if;
        if write_enable_registers = '1' then
          -- Actions taken when writing the register
          divl_register <= S_AXI_WDATA;
          set_timer     <= '1';         -- The timer will be set in the next
        -- clock period
        end if;
      end if;
    end if;
  end process;

  divh_register_process : process (S_AXI_ACLK)
  begin
    if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
      if Local_Reset = '1' then
        divh_register <= (others => '0');
      elsif divh_register_address_valid = '1' then
        if send_read_data_to_AXI = '1' then
          -- Actions taken when reading the register
          null;
        end if;
        if write_enable_registers = '1' then
          -- Actions taken when writing the register
          divh_register <= S_AXI_WDATA;
        end if;
      end if;
    end if;
  end process;


  cntl_register_process : process (S_AXI_ACLK)
  begin
    if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
      irq_clear <= '0';
      if Local_Reset = '1' then
        timer_latch <= (others => '0');
      elsif cntl_register_address_valid = '1' then
        if send_read_data_to_AXI = '1' then
          -- Actions taken when reading the register
          timer_latch <= timer_count;
        end if;
        if write_enable_registers = '1' then
          -- Actions taken when writing the register
          irq_clear <= '1';
        end if;
      end if;
    end if;
  end process;
  cntl_register <= std_logic_vector(timer_count(31 downto 0));

  cnth_register_process : process (S_AXI_ACLK)
  begin
    if (S_AXI_ACLK'event and S_AXI_ACLK = '1') then
      if Local_Reset = '1' then
        null;
      elsif cnth_register_address_valid = '1' then
        if send_read_data_to_AXI = '1' then
          -- Actions taken when reading the register
          null;
        end if;
        if write_enable_registers = '1' then
          -- Actions taken when writing the register
          null;
        end if;
      end if;
    end if;
  end process;
  cnth_register <= std_logic_vector(timer_latch(63 downto 32));


  -- Counter process
  counter : process (S_AXI_ACLK) is
  begin  -- process
    if S_AXI_ACLK'event and S_AXI_ACLK = '1' then  -- rising clock edge
      if Local_Reset = '1' then
        timer_count <= (others => '0');
        irq_req     <= '0';
      else
        -- Clear interrupt if required
        if irq_clear = '1' then
          irq_req <= '0';
        end if;
        -- Normal counting
        if timer_limit /= 0 then
          if timer_count /= timer_limit then
            timer_count <= timer_count + 1;
          else
            timer_count <= (others => '0');
            irq_req     <= '1';
          end if;
        end if;
        -- Set timer if required
        if set_timer = '1' then
          timer_count <= (others => '0');
          timer_limit <= unsigned(divh_register & divl_register)-1;
          irq_req     <= '0';
        end if;
      end if;
    end if;
  end process;


end rtl;
