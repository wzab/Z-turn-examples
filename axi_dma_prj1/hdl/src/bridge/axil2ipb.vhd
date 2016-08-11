-------------------------------------------------------------------------------
-- Title      : axil2ipb
-- Project    : 
-------------------------------------------------------------------------------
-- File       : axil2ipb.vhd
-- Author     : Wojciech M. Zabolotny  <wzab@ise.pw.edu.pl>
-- Company    : Institute of Electronic Systems, Warsaw University of Technology
-- Created    : 2016-04-24
-- Last update: 2016-05-14
-- License    : This is a PUBLIC DOMAIN code, published under
--              Creative Commons CC0 license
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: AXI Lite -> IPbus bridge
-------------------------------------------------------------------------------
-- Copyright (c) 2016 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2016-04-24  1.0      WZab    Created
-------------------------------------------------------------------------------

-- The AXI implementation is based on the description of AXI provided by
-- Rich Griffin in "Designing a Custom AXI-lite Slave Peripheral"
-- available at:
-- silica.com/wcsstore/Silica/Silica+Content+Library/Silica+Home/resources/71b10b18-9c9c-44c6-b62d-9a031b8f3df8/SILICA_Xilinx_Designing_a_custom_axi_slave_rev1.pdf
--
-- The IPbus implementation is based on the description provided in
-- "Notes on Firmware Implementation of an IPbus SoC Bus"
-- available at:
-- https://svnweb.cern.ch/trac/cactus/export/32752/trunk/doc/IPbus_firmware_notes.pdf

-------------------------------------------------------------------------------
-- Implementation details
-------------------------------------------------------------------------------
-- In the AXI bus the read and write accesses may be handled independently
-- In the IPbus they can't therefore we must provide an arbitration scheme.
-- We assume "Write before read"
-- 
-- We must avoid duplicated writes and reads (which may corruppt e.g.
-- FIFO slaves at IPbus!)
--
-- Additionally the IPbus uses the word adressing, while AXI uses the byte
-- addressing. That is handled by the function a_axi2ipb, which additionally
-- zeroes bits not used by the IPbus segment...



library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use work.ipbus.all;

entity axil2ipb is

  generic (
    ADRWIDTH : integer := 15);

  port (
    ---------------------------------------------------------------------------
    -- AXI Interface
    ---------------------------------------------------------------------------
    -- Clock and Reset
    S_AXI_ACLK    : in  std_logic;
    S_AXI_ARESETN : in  std_logic;
    -- Write Address Channel
    S_AXI_AWADDR  : in  std_logic_vector(ADRWIDTH-1 downto 0);
    S_AXI_AWVALID : in  std_logic;
    S_AXI_AWREADY : out std_logic;
    -- Write Data Channel
    S_AXI_WDATA   : in  std_logic_vector(31 downto 0);
    S_AXI_WSTRB   : in  std_logic_vector(3 downto 0);
    S_AXI_WVALID  : in  std_logic;
    S_AXI_WREADY  : out std_logic;
    -- Read Address Channel
    S_AXI_ARADDR  : in  std_logic_vector(ADRWIDTH-1 downto 0);
    S_AXI_ARVALID : in  std_logic;
    S_AXI_ARREADY : out std_logic;
    -- Read Data Channel
    S_AXI_RDATA   : out std_logic_vector(31 downto 0);
    S_AXI_RRESP   : out std_logic_vector(1 downto 0);
    S_AXI_RVALID  : out std_logic;
    S_AXI_RREADY  : in  std_logic;
    -- Write Response Channel
    S_AXI_BRESP   : out std_logic_vector(1 downto 0);
    S_AXI_BVALID  : out std_logic;
    S_AXI_BREADY  : in  std_logic;
    -- AWPROT and ARPROT - required by Altera
    --S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
    --S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
    -- Here we have the IPbus ports
    ipb_clk       : out std_logic;
    ipb_rst       : out std_logic;
    -- master_ipb_out - flattened due to Vivado inability to handle user types
    -- in BD
    ipb_addr      : out std_logic_vector(31 downto 0);
    ipb_wdata     : out std_logic_vector(31 downto 0);
    ipb_strobe    : out std_logic;
    ipb_write     : out std_logic;
    -- master_ipb_in -  flattened due to Vivado inability to handle user types
    -- in BD
    ipb_rdata     : in  std_logic_vector(31 downto 0);
    ipb_ack       : in  std_logic;
    ipb_err       :     std_logic
    );

end entity axil2ipb;

architecture beh of axil2ipb is

  function a_axi2ipb (
    constant axi_addr : std_logic_vector(ADRWIDTH-1 downto 0))
    return std_logic_vector is
    variable ipb_addr : std_logic_vector(31 downto 0);
  begin  -- function a_axi2ipb
    ipb_addr                      := (others => '0');
    -- Divide the address by 4 (we use word addresses, not the byte addresses)
    ipb_addr(ADRWIDTH-3 downto 0) := axi_addr(ADRWIDTH-1 downto 2);
    return ipb_addr;
  end function a_axi2ipb;

  signal master_ipb_out                                     : ipb_wbus;
  signal master_ipb_in                                      : ipb_rbus;
  signal read_wait, read_wait_in, write_wait, write_wait_in : boolean                       := false;
  signal rdata, rdata_in, addr, addr_in, wdata, wdata_in    : std_logic_vector(31 downto 0) := (others => '0');
  signal bresp, rresp, bresp_in, rresp_in                   : std_logic_vector(1 downto 0)  := "00";
  signal del_bresp, del_rresp, del_bresp_in, del_rresp_in   : boolean                       := false;

begin  -- architecture beh

  ipb_clk    <= S_AXI_ACLK;
  ipb_rst    <= not S_AXI_ARESETN;
  -- We keep the master_ipb... signals internally in hope, that one day
  -- Xilinx/Vivado will be able to handle user defined records in ports of BD blocks...
  ipb_addr   <= master_ipb_out.ipb_addr;
  ipb_wdata  <= master_ipb_out.ipb_wdata;
  ipb_strobe <= master_ipb_out.ipb_strobe;
  ipb_write  <= master_ipb_out.ipb_write;

  master_ipb_in.ipb_rdata <= ipb_rdata;
  master_ipb_in.ipb_ack   <= ipb_ack;
  master_ipb_in.ipb_err   <= ipb_err;

  qq : process (S_AXI_ARADDR, S_AXI_ARVALID, S_AXI_AWADDR, S_AXI_AWVALID,
                S_AXI_BREADY, S_AXI_RREADY, S_AXI_WDATA, S_AXI_WSTRB,
                S_AXI_WVALID, addr, bresp, del_bresp, del_rresp, master_ipb_in,
                rdata, read_wait, rresp, wdata, write_wait) is
    variable is_read, is_write : boolean := false;
  begin  -- process qq
    -- Defaults
    is_read                   := false;
    is_write                  := false;
    master_ipb_out.ipb_strobe <= '0';
    master_ipb_out.ipb_addr   <= (others => '0');
    master_ipb_out.ipb_wdata  <= (others => '0');
    master_ipb_out.ipb_write  <= '0';
    -- Flags handling delayed acceptance of results
    del_bresp_in              <= del_bresp;
    del_rresp_in              <= del_rresp;
    -- Registers storing the results
    bresp_in                  <= bresp;
    rresp_in                  <= rresp;
    rdata_in                  <= rdata;
    wdata_in                  <= wdata;
    read_wait_in              <= read_wait;
    write_wait_in             <= write_wait;
    addr_in                   <= addr;
    S_AXI_BVALID              <= '0';
    S_AXI_BRESP               <= (others => '0');
    S_AXI_ARREADY             <= '0';
    S_AXI_RVALID              <= '0';
    S_AXI_RDATA               <= (others => '0');
    S_AXI_RRESP               <= (others => '0');
    S_AXI_AWREADY             <= '0';
    S_AXI_WREADY              <= '0';

    -- Real processing
    -- Handling of delayed responses
    if del_bresp then
      S_AXI_BRESP  <= bresp;
      S_AXI_BVALID <= '1';
      if S_AXI_BREADY = '1' then
        del_bresp_in <= false;
      end if;
    elsif del_rresp then
      S_AXI_RRESP  <= rresp;
      S_AXI_RDATA  <= rdata;
      S_AXI_RVALID <= '1';
      if S_AXI_RREADY = '1' then
        del_rresp_in <= false;
      end if;
    -- Handling of new transactions
    elsif (S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') or write_wait then
      is_write := true;
    elsif S_AXI_ARVALID = '1' or read_wait then
      is_read := true;
    end if;
    -- Set the IPbus signals
    if is_write then
      -- Check if this is a new transmission
      if S_AXI_AWVALID = '1' and S_AXI_WVALID = '1' and write_wait = false then
        -- This is a new transmission
        -- Check if this is a correct 32-bit write
        if S_AXI_WSTRB /= "1111" then
          -- Erroneouos write. If slave is ready to accept status, inform about it
          S_AXI_AWREADY <= '1';
          S_AXI_WREADY  <= '1';
          S_AXI_BRESP   <= "10";
          S_AXI_BVALID  <= '1';
          if S_AXI_BREADY = '0' then
            -- Prepare delayed response
            bresp_in     <= "10";
            del_bresp_in <= true;
          end if;
        else
          -- Correct write
          -- Write transaction on IPbus
          master_ipb_out.ipb_addr   <= a_axi2ipb(S_AXI_AWADDR);
          master_ipb_out.ipb_wdata  <= S_AXI_WDATA;
          master_ipb_out.ipb_strobe <= '1';
          master_ipb_out.ipb_write  <= '1';
          -- Store data for the next cycles
          addr_in                   <= a_axi2ipb(S_AXI_AWADDR);
          wdata_in                  <= S_AXI_WDATA;
          S_AXI_AWREADY             <= '1';
          S_AXI_WREADY              <= '1';
          write_wait_in             <= true;
        end if;
      else
        -- This the next cycle of the write transmission
        master_ipb_out.ipb_addr   <= addr;
        master_ipb_out.ipb_wdata  <= wdata;
        master_ipb_out.ipb_strobe <= '1';
        master_ipb_out.ipb_write  <= '1';
      end if;
      -- Check the slave response
      if master_ipb_in.ipb_err = '1' then
        write_wait_in <= false;
        S_AXI_BRESP   <= "10";
        S_AXI_BVALID  <= '1';
        if S_AXI_BREADY = '0' then
          -- Prepare delayed response
          bresp_in     <= "10";
          del_bresp_in <= true;
        end if;
      elsif master_ipb_in.ipb_ack = '1' then
        write_wait_in <= false;
        S_AXI_BRESP   <= "00";
        S_AXI_BVALID  <= '1';
        if S_AXI_BREADY = '0' then
          -- Prepare delayed response
          bresp_in     <= "00";
          del_bresp_in <= true;
        end if;
      end if;
    elsif is_read then
      -- Read transaction on IPbus
      if S_AXI_ARVALID = '1' and read_wait = false then
        addr_in                 <= a_axi2ipb(S_AXI_ARADDR);
        master_ipb_out.ipb_addr <= a_axi2ipb(S_AXI_ARADDR);
        S_AXI_ARREADY           <= '1';
        -- Remember that we are in read
        read_wait_in            <= true;
      else
        master_ipb_out.ipb_addr <= addr;
      end if;
      master_ipb_out.ipb_strobe <= '1';
      master_ipb_out.ipb_write  <= '0';
      -- Check the slave response
      if master_ipb_in.ipb_err = '1' then
        S_AXI_RRESP  <= "10";
        S_AXI_RDATA  <= master_ipb_in.ipb_rdata;
        S_AXI_RVALID <= '1';
        read_wait_in <= false;
        if S_AXI_RREADY = '0' then
          -- Prepare delayed response
          rresp_in     <= "10";
          rdata_in     <= master_ipb_in.ipb_rdata;
          del_rresp_in <= true;
        end if;
      elsif master_ipb_in.ipb_ack = '1' then
        S_AXI_RRESP  <= "00";
        S_AXI_RDATA  <= master_ipb_in.ipb_rdata;
        S_AXI_RVALID <= '1';
        read_wait_in <= false;
        if S_AXI_RREADY = '0' then
          -- Prepare delayed response
          rresp_in     <= "00";
          rdata_in     <= master_ipb_in.ipb_rdata;
          del_rresp_in <= true;
        end if;
      end if;
    end if;
  end process qq;

  process (S_AXI_ACLK) is
  begin  -- process
    if S_AXI_ACLK'event and S_AXI_ACLK = '1' then  -- rising clock edge
      if S_AXI_ARESETN = '0' then       -- synchronous reset (active low)
        del_rresp  <= false;
        del_bresp  <= false;
        rdata      <= (others => '0');
        wdata      <= (others => '0');
        rresp      <= (others => '0');
        bresp      <= (others => '0');
        addr       <= (others => '0');
        read_wait  <= false;
        write_wait <= false;
      else
        del_rresp  <= del_rresp_in;
        del_bresp  <= del_bresp_in;
        addr       <= addr_in;
        rdata      <= rdata_in;
        wdata      <= wdata_in;
        rresp      <= rresp_in;
        bresp      <= bresp_in;
        read_wait  <= read_wait_in;
        write_wait <= write_wait_in;
      end if;
    end if;
  end process;


end architecture beh;
