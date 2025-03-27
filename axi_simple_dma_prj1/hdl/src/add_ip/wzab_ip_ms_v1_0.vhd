library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wzab_ip_ms_v1_0 is
  generic (
    -- Users to add parameters here

    -- User parameters ends
    -- Do not modify the parameters beyond this line


    -- Parameters of Axi Slave Bus Interface S00_AXI
    C_S00_AXI_DATA_WIDTH : integer := 32;
    C_S00_AXI_ADDR_WIDTH : integer := 4;

    -- Parameters of Axi Master Bus Interface M00_AXI
    C_M00_AXI_START_DATA_VALUE       : std_logic_vector := x"AA000000";
    C_M00_AXI_TARGET_SLAVE_BASE_ADDR : std_logic_vector := x"40000000";
    C_M00_AXI_ADDR_WIDTH             : integer          := 32;
    C_M00_AXI_DATA_WIDTH             : integer          := 32;
    C_M00_AXI_TRANSACTIONS_NUM       : integer          := 4;

    -- Parameters of Axi Slave Bus Interface S_AXI_INTR
    C_S_AXI_INTR_DATA_WIDTH : integer          := 32;
    C_S_AXI_INTR_ADDR_WIDTH : integer          := 5;
    C_NUM_OF_INTR           : integer          := 1;
    C_INTR_SENSITIVITY      : std_logic_vector := x"FFFFFFFF";
    C_INTR_ACTIVE_STATE     : std_logic_vector := x"FFFFFFFF";
    C_IRQ_SENSITIVITY       : integer          := 1;
    C_IRQ_ACTIVE_STATE      : integer          := 1
    );
  port (
    -- Users to add ports here

    -- User ports ends
    -- Do not modify the ports beyond this line


    -- Ports of Axi Slave Bus Interface S00_AXI
    s00_axi_aclk    : in  std_logic;
    s00_axi_aresetn : in  std_logic;
    s00_axi_awaddr  : in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
    s00_axi_awprot  : in  std_logic_vector(2 downto 0);
    s00_axi_awvalid : in  std_logic;
    s00_axi_awready : out std_logic;
    s00_axi_wdata   : in  std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    s00_axi_wstrb   : in  std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
    s00_axi_wvalid  : in  std_logic;
    s00_axi_wready  : out std_logic;
    s00_axi_bresp   : out std_logic_vector(1 downto 0);
    s00_axi_bvalid  : out std_logic;
    s00_axi_bready  : in  std_logic;
    s00_axi_araddr  : in  std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
    s00_axi_arprot  : in  std_logic_vector(2 downto 0);
    s00_axi_arvalid : in  std_logic;
    s00_axi_arready : out std_logic;
    s00_axi_rdata   : out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
    s00_axi_rresp   : out std_logic_vector(1 downto 0);
    s00_axi_rvalid  : out std_logic;
    s00_axi_rready  : in  std_logic;

    -- Ports of Axi Master Bus Interface M00_AXI
    m00_axi_init_axi_txn : in  std_logic;
    m00_axi_error        : out std_logic;
    m00_axi_txn_done     : out std_logic;
    m00_axi_aclk         : in  std_logic;
    m00_axi_aresetn      : in  std_logic;
    m00_axi_awaddr       : out std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
    m00_axi_awprot       : out std_logic_vector(2 downto 0);
    m00_axi_awvalid      : out std_logic;
    m00_axi_awready      : in  std_logic;
    m00_axi_wdata        : out std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
    m00_axi_wstrb        : out std_logic_vector(C_M00_AXI_DATA_WIDTH/8-1 downto 0);
    m00_axi_wvalid       : out std_logic;
    m00_axi_wready       : in  std_logic;
    m00_axi_bresp        : in  std_logic_vector(1 downto 0);
    m00_axi_bvalid       : in  std_logic;
    m00_axi_bready       : out std_logic;
    m00_axi_araddr       : out std_logic_vector(C_M00_AXI_ADDR_WIDTH-1 downto 0);
    m00_axi_arprot       : out std_logic_vector(2 downto 0);
    m00_axi_arvalid      : out std_logic;
    m00_axi_arready      : in  std_logic;
    m00_axi_rdata        : in  std_logic_vector(C_M00_AXI_DATA_WIDTH-1 downto 0);
    m00_axi_rresp        : in  std_logic_vector(1 downto 0);
    m00_axi_rvalid       : in  std_logic;
    m00_axi_rready       : out std_logic;

    -- Ports of Axi Slave Bus Interface S_AXI_INTR
    s_axi_intr_aclk    : in  std_logic;
    s_axi_intr_aresetn : in  std_logic;
    s_axi_intr_awaddr  : in  std_logic_vector(C_S_AXI_INTR_ADDR_WIDTH-1 downto 0);
    s_axi_intr_awprot  : in  std_logic_vector(2 downto 0);
    s_axi_intr_awvalid : in  std_logic;
    s_axi_intr_awready : out std_logic;
    s_axi_intr_wdata   : in  std_logic_vector(C_S_AXI_INTR_DATA_WIDTH-1 downto 0);
    s_axi_intr_wstrb   : in  std_logic_vector((C_S_AXI_INTR_DATA_WIDTH/8)-1 downto 0);
    s_axi_intr_wvalid  : in  std_logic;
    s_axi_intr_wready  : out std_logic;
    s_axi_intr_bresp   : out std_logic_vector(1 downto 0);
    s_axi_intr_bvalid  : out std_logic;
    s_axi_intr_bready  : in  std_logic;
    s_axi_intr_araddr  : in  std_logic_vector(C_S_AXI_INTR_ADDR_WIDTH-1 downto 0);
    s_axi_intr_arprot  : in  std_logic_vector(2 downto 0);
    s_axi_intr_arvalid : in  std_logic;
    s_axi_intr_arready : out std_logic;
    s_axi_intr_rdata   : out std_logic_vector(C_S_AXI_INTR_DATA_WIDTH-1 downto 0);
    s_axi_intr_rresp   : out std_logic_vector(1 downto 0);
    s_axi_intr_rvalid  : out std_logic;
    s_axi_intr_rready  : in  std_logic;
    irq                : out std_logic
    );
end wzab_ip_ms_v1_0;

architecture arch_imp of wzab_ip_ms_v1_0 is

  signal internal_axi_init_txn : std_logic;
  signal internal_axi_error : std_logic;
  signal internal_axi_txn_done : std_logic;
  
  -- component declaration
  component wzab_ip_ms_v1_0_S00_AXI is
    generic (
      C_S_AXI_DATA_WIDTH : integer := 32;
      C_S_AXI_ADDR_WIDTH : integer := 4
      );
    port (
      init_txn      : out std_logic;
      error_txn     : in  std_logic;
      txn_done      : in  std_logic;
      cnt_irq       : out std_logic;
      S_AXI_ACLK    : in  std_logic;
      S_AXI_ARESETN : in  std_logic;
      S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
      S_AXI_AWVALID : in  std_logic;
      S_AXI_AWREADY : out std_logic;
      S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
      S_AXI_WVALID  : in  std_logic;
      S_AXI_WREADY  : out std_logic;
      S_AXI_BRESP   : out std_logic_vector(1 downto 0);
      S_AXI_BVALID  : out std_logic;
      S_AXI_BREADY  : in  std_logic;
      S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
      S_AXI_ARVALID : in  std_logic;
      S_AXI_ARREADY : out std_logic;
      S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_RRESP   : out std_logic_vector(1 downto 0);
      S_AXI_RVALID  : out std_logic;
      S_AXI_RREADY  : in  std_logic
      );
  end component wzab_ip_ms_v1_0_S00_AXI;

  component wzab_ip_ms_v1_0_M00_AXI is
    generic (
      C_M_START_DATA_VALUE       : std_logic_vector := x"AA000000";
      C_M_TARGET_SLAVE_BASE_ADDR : std_logic_vector := x"40000000";
      C_M_AXI_ADDR_WIDTH         : integer          := 32;
      C_M_AXI_DATA_WIDTH         : integer          := 32;
      C_M_TRANSACTIONS_NUM       : integer          := 4
      );
    port (
      INIT_AXI_TXN  : in  std_logic;
      error         : out std_logic;
      TXN_DONE      : out std_logic;
      M_AXI_ACLK    : in  std_logic;
      M_AXI_ARESETN : in  std_logic;
      M_AXI_AWADDR  : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
      M_AXI_AWPROT  : out std_logic_vector(2 downto 0);
      M_AXI_AWVALID : out std_logic;
      M_AXI_AWREADY : in  std_logic;
      M_AXI_WDATA   : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
      M_AXI_WSTRB   : out std_logic_vector(C_M_AXI_DATA_WIDTH/8-1 downto 0);
      M_AXI_WVALID  : out std_logic;
      M_AXI_WREADY  : in  std_logic;
      M_AXI_BRESP   : in  std_logic_vector(1 downto 0);
      M_AXI_BVALID  : in  std_logic;
      M_AXI_BREADY  : out std_logic;
      M_AXI_ARADDR  : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);
      M_AXI_ARPROT  : out std_logic_vector(2 downto 0);
      M_AXI_ARVALID : out std_logic;
      M_AXI_ARREADY : in  std_logic;
      M_AXI_RDATA   : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);
      M_AXI_RRESP   : in  std_logic_vector(1 downto 0);
      M_AXI_RVALID  : in  std_logic;
      M_AXI_RREADY  : out std_logic
      );
  end component wzab_ip_ms_v1_0_M00_AXI;

  component wzab_ip_ms_v1_0_S_AXI_INTR is
    generic (
      C_S_AXI_DATA_WIDTH  : integer          := 32;
      C_S_AXI_ADDR_WIDTH  : integer          := 5;
      C_NUM_OF_INTR       : integer          := 1;
      C_INTR_SENSITIVITY  : std_logic_vector := x"FFFFFFFF";
      C_INTR_ACTIVE_STATE : std_logic_vector := x"FFFFFFFF";
      C_IRQ_SENSITIVITY   : integer          := 1;
      C_IRQ_ACTIVE_STATE  : integer          := 1
      );
    port (
      S_AXI_ACLK    : in  std_logic;
      S_AXI_ARESETN : in  std_logic;
      S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
      S_AXI_AWVALID : in  std_logic;
      S_AXI_AWREADY : out std_logic;
      S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
      S_AXI_WVALID  : in  std_logic;
      S_AXI_WREADY  : out std_logic;
      S_AXI_BRESP   : out std_logic_vector(1 downto 0);
      S_AXI_BVALID  : out std_logic;
      S_AXI_BREADY  : in  std_logic;
      S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
      S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
      S_AXI_ARVALID : in  std_logic;
      S_AXI_ARREADY : out std_logic;
      S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
      S_AXI_RRESP   : out std_logic_vector(1 downto 0);
      S_AXI_RVALID  : out std_logic;
      S_AXI_RREADY  : in  std_logic;
      irq           : out std_logic
      );
  end component wzab_ip_ms_v1_0_S_AXI_INTR;

begin

-- Instantiation of Axi Bus Interface S00_AXI
  wzab_ip_ms_v1_0_S00_AXI_inst : wzab_ip_ms_v1_0_S00_AXI
    generic map (
      C_S_AXI_DATA_WIDTH => C_S00_AXI_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH => C_S00_AXI_ADDR_WIDTH
      )
    port map (
      init_txn      => internal_axi_init_txn,
      error_txn     => internal_axi_error,
      txn_done  => internal_axi_txn_done,
      cnt_irq => irq,
      S_AXI_ACLK    => s00_axi_aclk,
      S_AXI_ARESETN => s00_axi_aresetn,
      S_AXI_AWADDR  => s00_axi_awaddr,
      S_AXI_AWPROT  => s00_axi_awprot,
      S_AXI_AWVALID => s00_axi_awvalid,
      S_AXI_AWREADY => s00_axi_awready,
      S_AXI_WDATA   => s00_axi_wdata,
      S_AXI_WSTRB   => s00_axi_wstrb,
      S_AXI_WVALID  => s00_axi_wvalid,
      S_AXI_WREADY  => s00_axi_wready,
      S_AXI_BRESP   => s00_axi_bresp,
      S_AXI_BVALID  => s00_axi_bvalid,
      S_AXI_BREADY  => s00_axi_bready,
      S_AXI_ARADDR  => s00_axi_araddr,
      S_AXI_ARPROT  => s00_axi_arprot,
      S_AXI_ARVALID => s00_axi_arvalid,
      S_AXI_ARREADY => s00_axi_arready,
      S_AXI_RDATA   => s00_axi_rdata,
      S_AXI_RRESP   => s00_axi_rresp,
      S_AXI_RVALID  => s00_axi_rvalid,
      S_AXI_RREADY  => s00_axi_rready
      );

-- Instantiation of Axi Bus Interface M00_AXI
  wzab_ip_ms_v1_0_M00_AXI_inst : wzab_ip_ms_v1_0_M00_AXI
    generic map (
      C_M_START_DATA_VALUE       => C_M00_AXI_START_DATA_VALUE,
      C_M_TARGET_SLAVE_BASE_ADDR => C_M00_AXI_TARGET_SLAVE_BASE_ADDR,
      C_M_AXI_ADDR_WIDTH         => C_M00_AXI_ADDR_WIDTH,
      C_M_AXI_DATA_WIDTH         => C_M00_AXI_DATA_WIDTH,
      C_M_TRANSACTIONS_NUM       => C_M00_AXI_TRANSACTIONS_NUM
      )
    port map (
      INIT_AXI_TXN  => internal_axi_init_txn,
      error         => internal_axi_error,
      TXN_DONE      => internal_axi_txn_done,
      M_AXI_ACLK    => m00_axi_aclk,
      M_AXI_ARESETN => m00_axi_aresetn,
      M_AXI_AWADDR  => m00_axi_awaddr,
      M_AXI_AWPROT  => m00_axi_awprot,
      M_AXI_AWVALID => m00_axi_awvalid,
      M_AXI_AWREADY => m00_axi_awready,
      M_AXI_WDATA   => m00_axi_wdata,
      M_AXI_WSTRB   => m00_axi_wstrb,
      M_AXI_WVALID  => m00_axi_wvalid,
      M_AXI_WREADY  => m00_axi_wready,
      M_AXI_BRESP   => m00_axi_bresp,
      M_AXI_BVALID  => m00_axi_bvalid,
      M_AXI_BREADY  => m00_axi_bready,
      M_AXI_ARADDR  => m00_axi_araddr,
      M_AXI_ARPROT  => m00_axi_arprot,
      M_AXI_ARVALID => m00_axi_arvalid,
      M_AXI_ARREADY => m00_axi_arready,
      M_AXI_RDATA   => m00_axi_rdata,
      M_AXI_RRESP   => m00_axi_rresp,
      M_AXI_RVALID  => m00_axi_rvalid,
      M_AXI_RREADY  => m00_axi_rready
      );

  m00_axi_error <= internal_axi_init_txn;
  m00_axi_txn_done <= internal_axi_txn_done;

-- Instantiation of Axi Bus Interface S_AXI_INTR
  wzab_ip_ms_v1_0_S_AXI_INTR_inst : wzab_ip_ms_v1_0_S_AXI_INTR
    generic map (
      C_S_AXI_DATA_WIDTH  => C_S_AXI_INTR_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH  => C_S_AXI_INTR_ADDR_WIDTH,
      C_NUM_OF_INTR       => C_NUM_OF_INTR,
      C_INTR_SENSITIVITY  => C_INTR_SENSITIVITY,
      C_INTR_ACTIVE_STATE => C_INTR_ACTIVE_STATE,
      C_IRQ_SENSITIVITY   => C_IRQ_SENSITIVITY,
      C_IRQ_ACTIVE_STATE  => C_IRQ_ACTIVE_STATE
      )
    port map (
      S_AXI_ACLK    => s_axi_intr_aclk,
      S_AXI_ARESETN => s_axi_intr_aresetn,
      S_AXI_AWADDR  => s_axi_intr_awaddr,
      S_AXI_AWPROT  => s_axi_intr_awprot,
      S_AXI_AWVALID => s_axi_intr_awvalid,
      S_AXI_AWREADY => s_axi_intr_awready,
      S_AXI_WDATA   => s_axi_intr_wdata,
      S_AXI_WSTRB   => s_axi_intr_wstrb,
      S_AXI_WVALID  => s_axi_intr_wvalid,
      S_AXI_WREADY  => s_axi_intr_wready,
      S_AXI_BRESP   => s_axi_intr_bresp,
      S_AXI_BVALID  => s_axi_intr_bvalid,
      S_AXI_BREADY  => s_axi_intr_bready,
      S_AXI_ARADDR  => s_axi_intr_araddr,
      S_AXI_ARPROT  => s_axi_intr_arprot,
      S_AXI_ARVALID => s_axi_intr_arvalid,
      S_AXI_ARREADY => s_axi_intr_arready,
      S_AXI_RDATA   => s_axi_intr_rdata,
      S_AXI_RRESP   => s_axi_intr_rresp,
      S_AXI_RVALID  => s_axi_intr_rvalid,
      S_AXI_RREADY  => s_axi_intr_rready,
      irq           => open
      );

  -- Add user logic here

  -- User logic ends

end arch_imp;
