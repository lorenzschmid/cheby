library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test is
  port (
    aclk                 : in    std_logic;
    areset_n             : in    std_logic;
    awvalid              : in    std_logic;
    awready              : out   std_logic;
    awaddr               : in    std_logic_vector(4 downto 2);
    awprot               : in    std_logic_vector(2 downto 0);
    wvalid               : in    std_logic;
    wready               : out   std_logic;
    wdata                : in    std_logic_vector(31 downto 0);
    wstrb                : in    std_logic_vector(3 downto 0);
    bvalid               : out   std_logic;
    bready               : in    std_logic;
    bresp                : out   std_logic_vector(1 downto 0);
    arvalid              : in    std_logic;
    arready              : out   std_logic;
    araddr               : in    std_logic_vector(4 downto 2);
    arprot               : in    std_logic_vector(2 downto 0);
    rvalid               : out   std_logic;
    rready               : in    std_logic;
    rdata                : out   std_logic_vector(31 downto 0);
    rresp                : out   std_logic_vector(1 downto 0);

    -- REG register1
    register1_o          : out   std_logic_vector(63 downto 0);

    -- REG register2
    block1_register2_field1_i : in    std_logic;
    block1_register2_field2_i : in    std_logic_vector(2 downto 0);

    -- REG register3
    block1_register3_o   : out   std_logic_vector(31 downto 0);

    -- REG register4
    block1_block2_register4_field3_i : in    std_logic;
    block1_block2_register4_field4_i : in    std_logic_vector(2 downto 0)
  );
end test;

architecture syn of test is
  signal wr_req                         : std_logic;
  signal wr_ack                         : std_logic;
  signal wr_addr                        : std_logic_vector(4 downto 2);
  signal wr_data                        : std_logic_vector(31 downto 0);
  signal axi_awset                      : std_logic;
  signal axi_wset                       : std_logic;
  signal axi_wdone                      : std_logic;
  signal rd_req                         : std_logic;
  signal rd_ack                         : std_logic;
  signal rd_addr                        : std_logic_vector(4 downto 2);
  signal rd_data                        : std_logic_vector(31 downto 0);
  signal axi_arset                      : std_logic;
  signal axi_rdone                      : std_logic;
  signal register1_reg                  : std_logic_vector(63 downto 0);
  signal register1_wreq                 : std_logic_vector(1 downto 0);
  signal register1_wack                 : std_logic_vector(1 downto 0);
  signal block1_register3_reg           : std_logic_vector(31 downto 0);
  signal block1_register3_wreq          : std_logic;
  signal block1_register3_wack          : std_logic;
  signal rd_ack_d0                      : std_logic;
  signal rd_dat_d0                      : std_logic_vector(31 downto 0);
  signal wr_req_d0                      : std_logic;
  signal wr_adr_d0                      : std_logic_vector(4 downto 2);
  signal wr_dat_d0                      : std_logic_vector(31 downto 0);
begin

  -- AW, W and B channels
  awready <= not axi_awset;
  wready <= not axi_wset;
  bvalid <= axi_wdone;
  process (aclk) begin
    if rising_edge(aclk) then
      if areset_n = '0' then
        wr_req <= '0';
        axi_awset <= '0';
        axi_wset <= '0';
        axi_wdone <= '0';
      else
        wr_req <= '0';
        if awvalid = '1' and axi_awset = '0' then
          wr_addr <= awaddr;
          axi_awset <= '1';
          wr_req <= axi_wset;
        end if;
        if wvalid = '1' and axi_wset = '0' then
          wr_data <= wdata;
          axi_wset <= '1';
          wr_req <= axi_awset or awvalid;
        end if;
        if (axi_wdone and bready) = '1' then
          axi_wset <= '0';
          axi_awset <= '0';
          axi_wdone <= '0';
        end if;
        if wr_ack = '1' then
          axi_wdone <= '1';
        end if;
      end if;
    end if;
  end process;
  bresp <= "00";

  -- AR and R channels
  arready <= not axi_arset;
  rvalid <= axi_rdone;
  process (aclk) begin
    if rising_edge(aclk) then
      if areset_n = '0' then
        rd_req <= '0';
        axi_arset <= '0';
        axi_rdone <= '0';
        rdata <= (others => '0');
      else
        rd_req <= '0';
        if arvalid = '1' and axi_arset = '0' then
          rd_addr <= araddr;
          axi_arset <= '1';
          rd_req <= '1';
        end if;
        if (axi_rdone and rready) = '1' then
          axi_arset <= '0';
          axi_rdone <= '0';
        end if;
        if rd_ack = '1' then
          axi_rdone <= '1';
          rdata <= rd_data;
        end if;
      end if;
    end if;
  end process;
  rresp <= "00";

  -- pipelining for wr-in+rd-out
  process (aclk) begin
    if rising_edge(aclk) then
      if areset_n = '0' then
        rd_ack <= '0';
        rd_data <= "00000000000000000000000000000000";
        wr_req_d0 <= '0';
        wr_adr_d0 <= "000";
        wr_dat_d0 <= "00000000000000000000000000000000";
      else
        rd_ack <= rd_ack_d0;
        rd_data <= rd_dat_d0;
        wr_req_d0 <= wr_req;
        wr_adr_d0 <= wr_addr;
        wr_dat_d0 <= wr_data;
      end if;
    end if;
  end process;

  -- Register register1
  register1_o <= register1_reg;
  register1_wack <= register1_wreq;
  process (aclk) begin
    if rising_edge(aclk) then
      if areset_n = '0' then
        register1_reg <= "0000000000000000000000000000000000000000000000000000000000000000";
      else
        if register1_wreq(0) = '1' then
          register1_reg(31 downto 0) <= wr_dat_d0;
        end if;
        if register1_wreq(1) = '1' then
          register1_reg(63 downto 32) <= wr_dat_d0;
        end if;
      end if;
    end if;
  end process;

  -- Register block1_register2

  -- Register block1_register3
  block1_register3_o <= block1_register3_reg;
  block1_register3_wack <= block1_register3_wreq;
  process (aclk) begin
    if rising_edge(aclk) then
      if areset_n = '0' then
        block1_register3_reg <= "00000000000000000000000000000000";
      else
        if block1_register3_wreq = '1' then
          block1_register3_reg <= wr_dat_d0;
        end if;
      end if;
    end if;
  end process;

  -- Register block1_block2_register4

  -- Process for write requests.
  process (wr_adr_d0, wr_req_d0, register1_wack, block1_register3_wack) begin
    register1_wreq <= (others => '0');
    block1_register3_wreq <= '0';
    case wr_adr_d0(4 downto 3) is
    when "00" =>
      case wr_adr_d0(2 downto 2) is
      when "0" =>
        -- Reg register1
        register1_wreq(0) <= wr_req_d0;
        wr_ack <= register1_wack(0);
      when "1" =>
        -- Reg register1
        register1_wreq(1) <= wr_req_d0;
        wr_ack <= register1_wack(1);
      when others =>
        wr_ack <= wr_req_d0;
      end case;
    when "10" =>
      case wr_adr_d0(2 downto 2) is
      when "0" =>
        -- Reg block1_register2
        wr_ack <= wr_req_d0;
      when "1" =>
        -- Reg block1_register3
        block1_register3_wreq <= wr_req_d0;
        wr_ack <= block1_register3_wack;
      when others =>
        wr_ack <= wr_req_d0;
      end case;
    when "11" =>
      case wr_adr_d0(2 downto 2) is
      when "0" =>
        -- Reg block1_block2_register4
        wr_ack <= wr_req_d0;
      when others =>
        wr_ack <= wr_req_d0;
      end case;
    when others =>
      wr_ack <= wr_req_d0;
    end case;
  end process;

  -- Process for read requests.
  process (rd_addr, rd_req, block1_register2_field1_i, block1_register2_field2_i,
           block1_register3_reg, block1_block2_register4_field3_i,
           block1_block2_register4_field4_i) begin
    -- By default ack read requests
    rd_dat_d0 <= (others => 'X');
    case rd_addr(4 downto 3) is
    when "00" =>
      case rd_addr(2 downto 2) is
      when "0" =>
        -- Reg register1
        rd_ack_d0 <= rd_req;
      when "1" =>
        -- Reg register1
        rd_ack_d0 <= rd_req;
      when others =>
        rd_ack_d0 <= rd_req;
      end case;
    when "10" =>
      case rd_addr(2 downto 2) is
      when "0" =>
        -- Reg block1_register2
        rd_ack_d0 <= rd_req;
        rd_dat_d0(0) <= block1_register2_field1_i;
        rd_dat_d0(3 downto 1) <= block1_register2_field2_i;
        rd_dat_d0(31 downto 4) <= (others => '0');
      when "1" =>
        -- Reg block1_register3
        rd_ack_d0 <= rd_req;
        rd_dat_d0 <= block1_register3_reg;
      when others =>
        rd_ack_d0 <= rd_req;
      end case;
    when "11" =>
      case rd_addr(2 downto 2) is
      when "0" =>
        -- Reg block1_block2_register4
        rd_ack_d0 <= rd_req;
        rd_dat_d0(0) <= block1_block2_register4_field3_i;
        rd_dat_d0(3 downto 1) <= block1_block2_register4_field4_i;
        rd_dat_d0(31 downto 4) <= (others => '0');
      when others =>
        rd_ack_d0 <= rd_req;
      end case;
    when others =>
      rd_ack_d0 <= rd_req;
    end case;
  end process;
end syn;
