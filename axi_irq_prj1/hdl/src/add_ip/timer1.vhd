-------------------------------------------------------------------------------
-- Title      : timer1
-- Project    :
-------------------------------------------------------------------------------
-- File       : timer1.vhd
-- Author     : Wojciech M. Zabołotny  <wojciech.zabolotny@pw.edu.pl>
-- Company    : Institute of Electronic Systems
-- Created    : 2022-04-13
-- Last update: 2026-04-20
-- Platform   :
-- Standard   : VHDL'93/02
-- License    : BSD 2-Clause License
-------------------------------------------------------------------------------
-- Description:
--   Timer for SWIS course (based on the QEMU model)
--
--   This version contains a reworked AXI4-Lite frontend with the
--   following properties:
--     * no dependency between captured address and address-valid flag,
--     * exactly one register write per accepted AXI write transaction,
--     * invalid / unaligned / partial accesses return SLVERR,
--     * only aligned 32-bit reads are accepted,
--     * only aligned full-word 32-bit writes are accepted (WSTRB = "1111"),
--     * CNTL read latches the full 64-bit counter for a consistent CNTH read.
--
--   Register map:
--     0x00 : ID    (RO)  identification register
--     0x04 : STAT  (RW)  bit 0 = IRQ enable, bit 31 = IRQ pending (read-only)
--     0x08 : DIVL  (RW)  lower 32 bits of divisor / reload value
--     0x0C : DIVH  (RW)  upper 32 bits of divisor / reload value
--     0x10 : CNTL  (RO/W) read low word of counter and latch full counter,
--                       write clears pending IRQ
--     0x14 : CNTH  (RO)  high word of latched counter
--
--   Recommended SW sequence when programming timer limit:
--     1) write DIVH
--     2) write DIVL   -- this arms the new timer value
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
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

  constant AXI_RESP_OKAY   : std_logic_vector(1 downto 0) := "00";
  constant AXI_RESP_SLVERR : std_logic_vector(1 downto 0) := "10";

  constant ADDR_ID   : integer := 0;
  constant ADDR_STAT : integer := 4;
  constant ADDR_DIVL : integer := 8;
  constant ADDR_DIVH : integer := 12;
  constant ADDR_CNTL : integer := 16;
  constant ADDR_CNTH : integer := 20;

  signal Local_Reset : std_logic;

  -- Ready signals kept internal so the code remains VHDL-93/02 friendly
  signal awready_i : std_logic := '0';
  signal wready_i  : std_logic := '0';
  signal arready_i : std_logic := '0';

  -- Write channel state
  signal awaddr_reg : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0) := (others => '0');
  signal wdata_reg  : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0) := (others => '0');
  signal wstrb_reg  : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0) := (others => '0');
  signal aw_pending : std_logic := '0';
  signal w_pending  : std_logic := '0';
  signal bvalid_reg : std_logic := '0';
  signal bresp_reg  : std_logic_vector(1 downto 0) := AXI_RESP_OKAY;

  -- Read channel state
  signal rvalid_reg : std_logic := '0';
  signal rresp_reg  : std_logic_vector(1 downto 0) := AXI_RESP_OKAY;
  signal rdata_reg  : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0) := (others => '0');

  -- Register bank
  signal id_register   : std_logic_vector(31 downto 0) := x"7130900d";
  signal stat_reg      : std_logic_vector(31 downto 0) := (others => '0');
  signal stat_register : std_logic_vector(31 downto 0) := (others => '0');
  signal divl_register : std_logic_vector(31 downto 0) := (others => '0');
  signal divh_register : std_logic_vector(31 downto 0) := (others => '0');
  signal cntl_register : std_logic_vector(31 downto 0) := (others => '0');
  signal cnth_register : std_logic_vector(31 downto 0) := (others => '0');

  signal timer_latch : unsigned(63 downto 0) := (others => '0');
  signal timer_count : unsigned(63 downto 0) := (others => '0');
  signal timer_limit : unsigned(63 downto 0) := (others => '0');

  signal irq_req   : std_logic := '0';
  signal irq_clear : std_logic := '0';
  signal set_timer : std_logic := '0';

  function decode_valid(addr : std_logic_vector) return std_logic is
    variable a : integer;
  begin
    a := to_integer(unsigned(addr));
    case a is
      when ADDR_ID | ADDR_STAT | ADDR_DIVL | ADDR_DIVH | ADDR_CNTL | ADDR_CNTH =>
        return '1';
      when others =>
        return '0';
    end case;
  end function;

  function read_is_word_access(addr : std_logic_vector) return std_logic is
  begin
    if addr(1 downto 0) = "00" then
      return '1';
    else
      return '0';
    end if;
  end function;

  function write_is_full_word(
    addr  : std_logic_vector;
    wstrb : std_logic_vector)
    return std_logic is
  begin
    if addr(1 downto 0) /= "00" then
      return '0';
    elsif wstrb /= "1111" then
      return '0';
    else
      return '1';
    end if;
  end function;

  function read_mux(
    addr          : std_logic_vector;
    id_reg        : std_logic_vector(31 downto 0);
    stat_reg_in   : std_logic_vector(31 downto 0);
    divl_reg      : std_logic_vector(31 downto 0);
    divh_reg      : std_logic_vector(31 downto 0);
    cntl_reg_in   : std_logic_vector(31 downto 0);
    cnth_reg_in   : std_logic_vector(31 downto 0))
    return std_logic_vector is
    variable a : integer;
  begin
    a := to_integer(unsigned(addr));
    case a is
      when ADDR_ID   => return id_reg;
      when ADDR_STAT => return stat_reg_in;
      when ADDR_DIVL => return divl_reg;
      when ADDR_DIVH => return divh_reg;
      when ADDR_CNTL => return cntl_reg_in;
      when ADDR_CNTH => return cnth_reg_in;
      when others    => return (others => '0');
    end case;
  end function;

begin

  Local_Reset <= not S_AXI_ARESETN;

  stat_register <= stat_reg when irq_req = '0' else (stat_reg or x"80000000");
  cntl_register <= std_logic_vector(timer_latch(31 downto 0));
  cnth_register <= std_logic_vector(timer_latch(63 downto 32));

  irq <= '1' when (irq_req = '1') and (stat_reg(0) = '1') else '0';

  -- AXI output mapping
  S_AXI_AWREADY <= awready_i;
  S_AXI_WREADY  <= wready_i;
  S_AXI_ARREADY <= arready_i;
  S_AXI_BVALID  <= bvalid_reg;
  S_AXI_BRESP   <= bresp_reg;
  S_AXI_RVALID  <= rvalid_reg;
  S_AXI_RRESP   <= rresp_reg;
  S_AXI_RDATA   <= rdata_reg;

  -- Ready generation:
  -- * collect AW and W independently,
  -- * execute one write transaction at a time,
  -- * allow one outstanding read response at a time.
  awready_i <= '1' when (aw_pending = '0' and bvalid_reg = '0') else '0';
  wready_i  <= '1' when (w_pending  = '0' and bvalid_reg = '0') else '0';
  arready_i <= '1' when (rvalid_reg = '0' and bvalid_reg = '0' and aw_pending = '0' and w_pending = '0') else '0';

  axi_register_bank : process (S_AXI_ACLK)
    variable wr_addr_int : integer;
    variable rd_addr_int : integer;
  begin
    if rising_edge(S_AXI_ACLK) then
      irq_clear <= '0';
      set_timer <= '0';

      if Local_Reset = '1' then
        awaddr_reg    <= (others => '0');
        wdata_reg     <= (others => '0');
        wstrb_reg     <= (others => '0');
        aw_pending    <= '0';
        w_pending     <= '0';
        bvalid_reg    <= '0';
        bresp_reg     <= AXI_RESP_OKAY;

        rvalid_reg    <= '0';
        rresp_reg     <= AXI_RESP_OKAY;
        rdata_reg     <= (others => '0');

        stat_reg      <= (others => '0');
        divl_register <= (others => '0');
        divh_register <= (others => '0');
        timer_latch   <= (others => '0');

      else
        -- Capture write address
        if (S_AXI_AWVALID = '1') and (awready_i = '1') then
          awaddr_reg <= S_AXI_AWADDR;
          aw_pending <= '1';
        end if;

        -- Capture write data
        if (S_AXI_WVALID = '1') and (wready_i = '1') then
          wdata_reg <= S_AXI_WDATA;
          wstrb_reg <= S_AXI_WSTRB;
          w_pending <= '1';
        end if;

        -- Execute exactly one write after both AW and W were accepted
        if (aw_pending = '1') and (w_pending = '1') and (bvalid_reg = '0') then
          wr_addr_int := to_integer(unsigned(awaddr_reg));

          if (decode_valid(awaddr_reg) = '1') and (write_is_full_word(awaddr_reg, wstrb_reg) = '1') then
            case wr_addr_int is
              when ADDR_STAT =>
                -- Only bit 0 is writable; bit 31 is a read-only IRQ pending flag.
                stat_reg  <= wdata_reg and x"00000001";
                bresp_reg <= AXI_RESP_OKAY;

              when ADDR_DIVL =>
                divl_register <= wdata_reg;
                set_timer     <= '1';
                bresp_reg     <= AXI_RESP_OKAY;

              when ADDR_DIVH =>
                divh_register <= wdata_reg;
                bresp_reg     <= AXI_RESP_OKAY;

              when ADDR_CNTL =>
                irq_clear <= '1';
                bresp_reg <= AXI_RESP_OKAY;

              when ADDR_ID | ADDR_CNTH =>
                -- Existing register, but read-only for write accesses.
                bresp_reg <= AXI_RESP_SLVERR;

              when others =>
                bresp_reg <= AXI_RESP_SLVERR;
            end case;
          else
            -- Invalid address, partial write, or unaligned write.
            bresp_reg <= AXI_RESP_SLVERR;
          end if;

          bvalid_reg <= '1';
          aw_pending <= '0';
          w_pending  <= '0';
        end if;

        -- Complete write response
        if (bvalid_reg = '1') and (S_AXI_BREADY = '1') then
          bvalid_reg <= '0';
        end if;

        -- Accept and serve one read transaction
        if (S_AXI_ARVALID = '1') and (arready_i = '1') then
          rd_addr_int := to_integer(unsigned(S_AXI_ARADDR));

          if (decode_valid(S_AXI_ARADDR) = '1') and (read_is_word_access(S_AXI_ARADDR) = '1') then
            rresp_reg <= AXI_RESP_OKAY;

            case rd_addr_int is
              when ADDR_CNTL =>
                -- Latch the whole 64-bit counter so that a subsequent CNTH read
                -- returns the upper word from the same snapshot.
                timer_latch <= timer_count;
                rdata_reg   <= std_logic_vector(timer_count(31 downto 0));

              when ADDR_CNTH =>
                rdata_reg <= std_logic_vector(timer_latch(63 downto 32));

              when others =>
                rdata_reg <= read_mux(
                  S_AXI_ARADDR,
                  id_register,
                  stat_register,
                  divl_register,
                  divh_register,
                  cntl_register,
                  cnth_register);
            end case;
          else
            -- Invalid address or unaligned read.
            rresp_reg <= AXI_RESP_SLVERR;
            rdata_reg <= (others => '0');
          end if;

          rvalid_reg <= '1';
        end if;

        -- Complete read response
        if (rvalid_reg = '1') and (S_AXI_RREADY = '1') then
          rvalid_reg <= '0';
        end if;
      end if;
    end if;
  end process;

  -- Counter / timer core
  counter : process (S_AXI_ACLK)
  begin
    if rising_edge(S_AXI_ACLK) then
      if Local_Reset = '1' then
        timer_count <= (others => '0');
        timer_limit <= (others => '0');
        irq_req     <= '0';
      else
        -- Clear interrupt if required
        if irq_clear = '1' then
          irq_req <= '0';
        end if;

        -- Program timer if required. The timer is armed after writing DIVL.
        if set_timer = '1' then
          timer_count <= (others => '0');
          if unsigned(divh_register & divl_register) /= 0 then
            timer_limit <= unsigned(divh_register & divl_register) - 1;
          else
            timer_limit <= (others => '0');
          end if;
          irq_req <= '0';

        -- Normal counting
        elsif timer_limit /= 0 then
          if timer_count /= timer_limit then
            timer_count <= timer_count + 1;
          else
            timer_count <= (others => '0');
            irq_req     <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;

end rtl;
