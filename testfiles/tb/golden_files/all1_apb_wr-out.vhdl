library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cheby_pkg.all;

entity all1_apb is
  port (
    pclk                 : in    std_logic;
    presetn              : in    std_logic;
    paddr                : in    std_logic_vector(14 downto 2);
    psel                 : in    std_logic;
    pwrite               : in    std_logic;
    penable              : in    std_logic;
    pready               : out   std_logic;
    pwdata               : in    std_logic_vector(31 downto 0);
    pstrb                : in    std_logic_vector(3 downto 0);
    prdata               : out   std_logic_vector(31 downto 0);
    pslverr              : out   std_logic;

    -- REG reg1
    reg1_o               : out   std_logic_vector(31 downto 0);

    -- REG reg2
    reg2_o               : out   std_logic_vector(31 downto 0);

    -- RAM port for ram1
    ram1_adr_i           : in    std_logic_vector(2 downto 0);
    ram1_val_rd_i        : in    std_logic;
    ram1_val_dat_o       : out   std_logic_vector(31 downto 0);

    -- RAM port for ram_ro
    ram_ro_adr_i         : in    std_logic_vector(2 downto 0);
    ram_ro_val_we_i      : in    std_logic;
    ram_ro_val_dat_i     : in    std_logic_vector(31 downto 0);

    -- SRAM bus ram2
    ram2_addr_o          : out   std_logic_vector(4 downto 2);
    ram2_data_i          : in    std_logic_vector(31 downto 0);
    ram2_data_o          : out   std_logic_vector(31 downto 0);
    ram2_wr_o            : out   std_logic;

    -- WB bus sub1_wb
    sub1_wb_cyc_o        : out   std_logic;
    sub1_wb_stb_o        : out   std_logic;
    sub1_wb_adr_o        : out   std_logic_vector(11 downto 2);
    sub1_wb_sel_o        : out   std_logic_vector(3 downto 0);
    sub1_wb_we_o         : out   std_logic;
    sub1_wb_dat_o        : out   std_logic_vector(31 downto 0);
    sub1_wb_ack_i        : in    std_logic;
    sub1_wb_err_i        : in    std_logic;
    sub1_wb_rty_i        : in    std_logic;
    sub1_wb_stall_i      : in    std_logic;
    sub1_wb_dat_i        : in    std_logic_vector(31 downto 0);

    -- AXI-4 lite bus sub2_axi4
    sub2_axi4_awvalid_o  : out   std_logic;
    sub2_axi4_awready_i  : in    std_logic;
    sub2_axi4_awaddr_o   : out   std_logic_vector(11 downto 2);
    sub2_axi4_awprot_o   : out   std_logic_vector(2 downto 0);
    sub2_axi4_wvalid_o   : out   std_logic;
    sub2_axi4_wready_i   : in    std_logic;
    sub2_axi4_wdata_o    : out   std_logic_vector(31 downto 0);
    sub2_axi4_wstrb_o    : out   std_logic_vector(3 downto 0);
    sub2_axi4_bvalid_i   : in    std_logic;
    sub2_axi4_bready_o   : out   std_logic;
    sub2_axi4_bresp_i    : in    std_logic_vector(1 downto 0);
    sub2_axi4_arvalid_o  : out   std_logic;
    sub2_axi4_arready_i  : in    std_logic;
    sub2_axi4_araddr_o   : out   std_logic_vector(11 downto 2);
    sub2_axi4_arprot_o   : out   std_logic_vector(2 downto 0);
    sub2_axi4_rvalid_i   : in    std_logic;
    sub2_axi4_rready_o   : out   std_logic;
    sub2_axi4_rdata_i    : in    std_logic_vector(31 downto 0);
    sub2_axi4_rresp_i    : in    std_logic_vector(1 downto 0);

    -- cern-be-vme bus sub3_cernbe
    sub3_cernbe_VMEAddr_o : out   std_logic_vector(11 downto 2);
    sub3_cernbe_VMERdData_i : in    std_logic_vector(31 downto 0);
    sub3_cernbe_VMEWrData_o : out   std_logic_vector(31 downto 0);
    sub3_cernbe_VMERdMem_o : out   std_logic;
    sub3_cernbe_VMEWrMem_o : out   std_logic;
    sub3_cernbe_VMERdDone_i : in    std_logic;
    sub3_cernbe_VMEWrDone_i : in    std_logic;

    -- Avalon bus sub4_avalon
    sub4_avalon_address_o : out   std_logic_vector(11 downto 2);
    sub4_avalon_readdata_i : in    std_logic_vector(31 downto 0);
    sub4_avalon_writedata_o : out   std_logic_vector(31 downto 0);
    sub4_avalon_byteenable_o : out   std_logic_vector(3 downto 0);
    sub4_avalon_read_o   : out   std_logic;
    sub4_avalon_write_o  : out   std_logic;
    sub4_avalon_readdatavalid_i : in    std_logic;
    sub4_avalon_waitrequest_i : in    std_logic;
    sub5_apb_paddr_o     : out   std_logic_vector(11 downto 2);
    sub5_apb_psel_o      : out   std_logic;
    sub5_apb_pwrite_o    : out   std_logic;
    sub5_apb_penable_o   : out   std_logic;
    sub5_apb_pready_i    : in    std_logic;
    sub5_apb_pwdata_o    : out   std_logic_vector(31 downto 0);
    sub5_apb_pstrb_o     : out   std_logic_vector(3 downto 0);
    sub5_apb_prdata_i    : in    std_logic_vector(31 downto 0);
    sub5_apb_pslverr_i   : in    std_logic;

    -- simple bus sub6_simple
    sub6_simple_adr_o    : out   std_logic_vector(11 downto 2);
    sub6_simple_dato_i   : in    std_logic_vector(31 downto 0);
    sub6_simple_dati_o   : out   std_logic_vector(31 downto 0);
    sub6_simple_rd_o     : out   std_logic;
    sub6_simple_wr_o     : out   std_logic;
    sub6_simple_rack_i   : in    std_logic;
    sub6_simple_wack_i   : in    std_logic
  );
end all1_apb;

architecture syn of all1_apb is
  signal wr_req                         : std_logic;
  signal wr_addr                        : std_logic_vector(14 downto 2);
  signal wr_data                        : std_logic_vector(31 downto 0);
  signal wr_sel                         : std_logic_vector(31 downto 0);
  signal rd_req                         : std_logic;
  signal rd_addr                        : std_logic_vector(14 downto 2);
  signal rd_data                        : std_logic_vector(31 downto 0);
  signal wr_ack                         : std_logic;
  signal rd_ack                         : std_logic;
  signal reg1_reg                       : std_logic_vector(31 downto 0);
  signal reg1_wreq                      : std_logic;
  signal reg1_wack                      : std_logic;
  signal reg2_reg                       : std_logic_vector(31 downto 0);
  signal reg2_wreq                      : std_logic;
  signal reg2_wack                      : std_logic;
  signal ram1_val_int_dato              : std_logic_vector(31 downto 0);
  signal ram1_val_ext_dat               : std_logic_vector(31 downto 0);
  signal ram1_val_rreq                  : std_logic;
  signal ram1_val_rack                  : std_logic;
  signal ram1_val_int_wr                : std_logic;
  signal ram_ro_val_int_dato            : std_logic_vector(31 downto 0);
  signal ram_ro_val_ext_dat             : std_logic_vector(31 downto 0);
  signal ram_ro_val_rreq                : std_logic;
  signal ram_ro_val_rack                : std_logic;
  signal ram2_rack                      : std_logic;
  signal ram2_re                        : std_logic;
  signal sub1_wb_re                     : std_logic;
  signal sub1_wb_we                     : std_logic;
  signal sub1_wb_wt                     : std_logic;
  signal sub1_wb_rt                     : std_logic;
  signal sub1_wb_tr                     : std_logic;
  signal sub1_wb_wack                   : std_logic;
  signal sub1_wb_rack                   : std_logic;
  signal sub1_wb_wr                     : std_logic;
  signal sub1_wb_rr                     : std_logic;
  signal sub2_axi4_aw_val               : std_logic;
  signal sub2_axi4_w_val                : std_logic;
  signal sub2_axi4_ar_val               : std_logic;
  signal sub2_axi4_rd                   : std_logic;
  signal sub2_axi4_wr                   : std_logic;
  signal sub3_cernbe_wr                 : std_logic;
  signal sub3_cernbe_rr                 : std_logic;
  signal sub3_cernbe_ws                 : std_logic;
  signal sub3_cernbe_rs                 : std_logic;
  signal sub3_cernbe_re                 : std_logic;
  signal sub3_cernbe_we                 : std_logic;
  signal sub3_cernbe_wt                 : std_logic;
  signal sub3_cernbe_rt                 : std_logic;
  signal sub4_avalon_re                 : std_logic;
  signal sub4_avalon_we                 : std_logic;
  signal sub4_avalon_rr                 : std_logic;
  signal sub4_avalon_wr                 : std_logic;
  signal sub4_avalon_rt                 : std_logic;
  signal sub4_avalon_wp                 : std_logic;
  signal sub4_avalon_rp                 : std_logic;
  signal sub5_apb_wr_req                : std_logic;
  signal sub5_apb_wr_ack                : std_logic;
  signal sub5_apb_wr                    : std_logic;
  signal sub5_apb_wr_reg                : std_logic;
  signal sub5_apb_rd_req                : std_logic;
  signal sub5_apb_rd_ack                : std_logic;
  signal sub5_apb_rd                    : std_logic;
  signal sub5_apb_rd_reg                : std_logic;
  signal sub6_simple_wr                 : std_logic;
  signal sub6_simple_rr                 : std_logic;
  signal sub6_simple_ws                 : std_logic;
  signal sub6_simple_rs                 : std_logic;
  signal sub6_simple_re                 : std_logic;
  signal sub6_simple_we                 : std_logic;
  signal sub6_simple_wt                 : std_logic;
  signal sub6_simple_rt                 : std_logic;
  signal wr_ack_d0                      : std_logic;
  signal ram1_wr                        : std_logic;
  signal ram1_wreq                      : std_logic;
  signal ram1_adr_int                   : std_logic_vector(2 downto 0);
  signal ram1_sel_int                   : std_logic_vector(3 downto 0);
  signal ram_ro_sel_int                 : std_logic_vector(3 downto 0);
  signal ram2_wp                        : std_logic;
  signal ram2_we                        : std_logic;
begin

  -- Write Channel
  wr_req <= (psel and pwrite) and not penable;
  wr_addr <= paddr;
  wr_data <= pwdata;
  process (pstrb) begin
    wr_sel(7 downto 0) <= (others => pstrb(0));
    wr_sel(15 downto 8) <= (others => pstrb(1));
    wr_sel(23 downto 16) <= (others => pstrb(2));
    wr_sel(31 downto 24) <= (others => pstrb(3));
  end process;

  -- Read Channel
  rd_req <= (psel and not pwrite) and not penable;
  rd_addr <= paddr;
  prdata <= rd_data;
  pready <= wr_ack or rd_ack;
  pslverr <= '0';

  -- pipelining for wr-out
  process (pclk) begin
    if rising_edge(pclk) then
      if presetn = '0' then
        wr_ack <= '0';
      else
        wr_ack <= wr_ack_d0;
      end if;
    end if;
  end process;

  -- Register reg1
  reg1_o <= reg1_reg;
  reg1_wack <= reg1_wreq;
  process (pclk) begin
    if rising_edge(pclk) then
      if presetn = '0' then
        reg1_reg <= "00010010001101000000000000000000";
      else
        if reg1_wreq = '1' then
          reg1_reg <= wr_data;
        end if;
      end if;
    end if;
  end process;

  -- Register reg2
  reg2_o <= reg2_reg;
  reg2_wack <= reg2_wreq;
  process (pclk) begin
    if rising_edge(pclk) then
      if presetn = '0' then
        reg2_reg <= "00010010001101000000000000000010";
      else
        if reg2_wreq = '1' then
          reg2_reg <= wr_data;
        end if;
      end if;
    end if;
  end process;

  -- Memory ram1
  process (rd_addr, wr_addr, ram1_wr) begin
    if ram1_wr = '1' then
      ram1_adr_int <= wr_addr(4 downto 2);
    else
      ram1_adr_int <= rd_addr(4 downto 2);
    end if;
  end process;
  ram1_wreq <= ram1_val_int_wr;
  ram1_wr <= ram1_wreq;
  ram1_val_raminst: cheby_dpssram
    generic map (
      g_data_width         => 32,
      g_size               => 8,
      g_addr_width         => 3,
      g_dual_clock         => '0',
      g_use_bwsel          => '1'
    )
    port map (
      clk_a_i              => pclk,
      clk_b_i              => pclk,
      addr_a_i             => ram1_adr_int,
      bwsel_a_i            => ram1_sel_int,
      data_a_i             => wr_data,
      data_a_o             => ram1_val_int_dato,
      rd_a_i               => ram1_val_rreq,
      wr_a_i               => ram1_val_int_wr,
      addr_b_i             => ram1_adr_i,
      bwsel_b_i            => (others => '1'),
      data_b_i             => ram1_val_ext_dat,
      data_b_o             => ram1_val_dat_o,
      rd_b_i               => ram1_val_rd_i,
      wr_b_i               => '0'
    );
  
  process (wr_sel) begin
    ram1_sel_int <= (others => '0');
    if not (wr_sel(7 downto 0) = (7 downto 0 => '0')) then
      ram1_sel_int(0) <= '1';
    end if;
    if not (wr_sel(15 downto 8) = (7 downto 0 => '0')) then
      ram1_sel_int(1) <= '1';
    end if;
    if not (wr_sel(23 downto 16) = (7 downto 0 => '0')) then
      ram1_sel_int(2) <= '1';
    end if;
    if not (wr_sel(31 downto 24) = (7 downto 0 => '0')) then
      ram1_sel_int(3) <= '1';
    end if;
  end process;
  process (pclk) begin
    if rising_edge(pclk) then
      if presetn = '0' then
        ram1_val_rack <= '0';
      else
        ram1_val_rack <= (ram1_val_rreq and not ram1_wreq) and not ram1_val_rack;
      end if;
    end if;
  end process;

  -- Memory ram_ro
  ram_ro_val_raminst: cheby_dpssram
    generic map (
      g_data_width         => 32,
      g_size               => 8,
      g_addr_width         => 3,
      g_dual_clock         => '0',
      g_use_bwsel          => '1'
    )
    port map (
      clk_a_i              => pclk,
      clk_b_i              => pclk,
      addr_a_i             => rd_addr(4 downto 2),
      bwsel_a_i            => ram_ro_sel_int,
      data_a_i             => (others => 'X'),
      data_a_o             => ram_ro_val_int_dato,
      rd_a_i               => ram_ro_val_rreq,
      wr_a_i               => '0',
      addr_b_i             => ram_ro_adr_i,
      bwsel_b_i            => (others => '1'),
      data_b_i             => ram_ro_val_dat_i,
      data_b_o             => ram_ro_val_ext_dat,
      rd_b_i               => '0',
      wr_b_i               => ram_ro_val_we_i
    );
  
  process (wr_sel) begin
    ram_ro_sel_int <= (others => '0');
    if not (wr_sel(7 downto 0) = (7 downto 0 => '0')) then
      ram_ro_sel_int(0) <= '1';
    end if;
    if not (wr_sel(15 downto 8) = (7 downto 0 => '0')) then
      ram_ro_sel_int(1) <= '1';
    end if;
    if not (wr_sel(23 downto 16) = (7 downto 0 => '0')) then
      ram_ro_sel_int(2) <= '1';
    end if;
    if not (wr_sel(31 downto 24) = (7 downto 0 => '0')) then
      ram_ro_sel_int(3) <= '1';
    end if;
  end process;
  process (pclk) begin
    if rising_edge(pclk) then
      if presetn = '0' then
        ram_ro_val_rack <= '0';
      else
        ram_ro_val_rack <= ram_ro_val_rreq;
      end if;
    end if;
  end process;

  -- Interface ram2
  process (pclk) begin
    if rising_edge(pclk) then
      if presetn = '0' then
        ram2_rack <= '0';
      else
        ram2_rack <= ram2_re and not ram2_rack;
      end if;
    end if;
  end process;
  ram2_data_o <= wr_data;
  process (pclk) begin
    if rising_edge(pclk) then
      if presetn = '0' then
        ram2_wp <= '0';
      else
        ram2_wp <= (wr_req or ram2_wp) and rd_req;
      end if;
    end if;
  end process;
  ram2_we <= (wr_req or ram2_wp) and not rd_req;
  process (rd_addr, wr_addr, ram2_re) begin
    if ram2_re = '1' then
      ram2_addr_o <= rd_addr(4 downto 2);
    else
      ram2_addr_o <= wr_addr(4 downto 2);
    end if;
  end process;

  -- Interface sub1_wb
  sub1_wb_tr <= sub1_wb_wt or sub1_wb_rt;
  process (pclk) begin
    if rising_edge(pclk) then
      if presetn = '0' then
        sub1_wb_rt <= '0';
        sub1_wb_wt <= '0';
        sub1_wb_wr <= '0';
        sub1_wb_rr <= '0';
      else
        sub1_wb_wr <= (sub1_wb_wr or sub1_wb_we) and not sub1_wb_wack;
        sub1_wb_wt <= (sub1_wb_wt or (sub1_wb_wr and not sub1_wb_tr)) and not sub1_wb_wack;
        sub1_wb_rr <= (sub1_wb_rr or sub1_wb_re) and not sub1_wb_rack;
        sub1_wb_rt <= (sub1_wb_rt or (sub1_wb_rr and not (sub1_wb_wr or sub1_wb_tr))) and not sub1_wb_rack;
      end if;
    end if;
  end process;
  sub1_wb_cyc_o <= sub1_wb_tr;
  sub1_wb_stb_o <= sub1_wb_tr;
  sub1_wb_wack <= sub1_wb_ack_i and sub1_wb_wt;
  sub1_wb_rack <= sub1_wb_ack_i and sub1_wb_rt;
  process (rd_addr, wr_addr, sub1_wb_wt) begin
    if sub1_wb_wt = '1' then
      sub1_wb_adr_o <= wr_addr(11 downto 2);
    else
      sub1_wb_adr_o <= rd_addr(11 downto 2);
    end if;
  end process;
  process (wr_sel) begin
    sub1_wb_sel_o <= (others => '0');
    if not (wr_sel(7 downto 0) = (7 downto 0 => '0')) then
      sub1_wb_sel_o(0) <= '1';
    end if;
    if not (wr_sel(15 downto 8) = (7 downto 0 => '0')) then
      sub1_wb_sel_o(1) <= '1';
    end if;
    if not (wr_sel(23 downto 16) = (7 downto 0 => '0')) then
      sub1_wb_sel_o(2) <= '1';
    end if;
    if not (wr_sel(31 downto 24) = (7 downto 0 => '0')) then
      sub1_wb_sel_o(3) <= '1';
    end if;
  end process;
  sub1_wb_we_o <= sub1_wb_wt;
  sub1_wb_dat_o <= wr_data;

  -- Interface sub2_axi4
  sub2_axi4_awvalid_o <= sub2_axi4_aw_val;
  sub2_axi4_awaddr_o <= wr_addr(11 downto 2);
  sub2_axi4_awprot_o <= "000";
  sub2_axi4_wvalid_o <= sub2_axi4_w_val;
  sub2_axi4_wdata_o <= wr_data;
  process (wr_sel) begin
    sub2_axi4_wstrb_o <= (others => '0');
    if not (wr_sel(7 downto 0) = (7 downto 0 => '0')) then
      sub2_axi4_wstrb_o(0) <= '1';
    end if;
    if not (wr_sel(15 downto 8) = (7 downto 0 => '0')) then
      sub2_axi4_wstrb_o(1) <= '1';
    end if;
    if not (wr_sel(23 downto 16) = (7 downto 0 => '0')) then
      sub2_axi4_wstrb_o(2) <= '1';
    end if;
    if not (wr_sel(31 downto 24) = (7 downto 0 => '0')) then
      sub2_axi4_wstrb_o(3) <= '1';
    end if;
  end process;
  sub2_axi4_bready_o <= '1';
  sub2_axi4_arvalid_o <= sub2_axi4_ar_val;
  sub2_axi4_araddr_o <= rd_addr(11 downto 2);
  sub2_axi4_arprot_o <= "000";
  sub2_axi4_rready_o <= '1';
  process (pclk) begin
    if rising_edge(pclk) then
      if presetn = '0' then
        sub2_axi4_aw_val <= '0';
        sub2_axi4_w_val <= '0';
        sub2_axi4_ar_val <= '0';
      else
        sub2_axi4_aw_val <= sub2_axi4_wr or (sub2_axi4_aw_val and not sub2_axi4_awready_i);
        sub2_axi4_w_val <= sub2_axi4_wr or (sub2_axi4_w_val and not sub2_axi4_wready_i);
        sub2_axi4_ar_val <= sub2_axi4_rd or (sub2_axi4_ar_val and not sub2_axi4_arready_i);
      end if;
    end if;
  end process;

  -- Interface sub3_cernbe
  sub3_cernbe_VMEWrData_o <= wr_data;
  process (pclk) begin
    if rising_edge(pclk) then
      if presetn = '0' then
        sub3_cernbe_wr <= '0';
        sub3_cernbe_wt <= '0';
        sub3_cernbe_rr <= '0';
        sub3_cernbe_rt <= '0';
      else
        sub3_cernbe_wr <= (sub3_cernbe_wr or sub3_cernbe_we) and not sub3_cernbe_VMEWrDone_i;
        sub3_cernbe_wt <= (sub3_cernbe_wt or sub3_cernbe_ws) and not sub3_cernbe_VMEWrDone_i;
        sub3_cernbe_rr <= (sub3_cernbe_rr or sub3_cernbe_re) and not sub3_cernbe_VMERdDone_i;
        sub3_cernbe_rt <= (sub3_cernbe_rt or sub3_cernbe_rs) and not sub3_cernbe_VMERdDone_i;
      end if;
    end if;
  end process;
  sub3_cernbe_rs <= sub3_cernbe_rr and not (sub3_cernbe_wr or (sub3_cernbe_rt or sub3_cernbe_wt));
  sub3_cernbe_ws <= sub3_cernbe_wr and not (sub3_cernbe_rt or sub3_cernbe_wt);
  process (rd_addr, wr_addr, sub3_cernbe_wt, sub3_cernbe_ws) begin
    if (sub3_cernbe_ws or sub3_cernbe_wt) = '1' then
      sub3_cernbe_VMEAddr_o <= wr_addr(11 downto 2);
    else
      sub3_cernbe_VMEAddr_o <= rd_addr(11 downto 2);
    end if;
  end process;

  -- Interface sub4_avalon
  process (pclk) begin
    if rising_edge(pclk) then
      if presetn = '0' then
        sub4_avalon_rr <= '0';
        sub4_avalon_wr <= '0';
        sub4_avalon_wp <= '0';
        sub4_avalon_rp <= '0';
        sub4_avalon_rt <= '0';
      else
        sub4_avalon_wr <= (sub4_avalon_wr and sub4_avalon_waitrequest_i) or ((sub4_avalon_we or sub4_avalon_wp) and not (sub4_avalon_rr or sub4_avalon_rt));
        sub4_avalon_wp <= (sub4_avalon_wp or sub4_avalon_we) and (sub4_avalon_rr or sub4_avalon_rt);
        sub4_avalon_rr <= ((sub4_avalon_re or sub4_avalon_rp) and not (sub4_avalon_we or (sub4_avalon_wr or sub4_avalon_wp))) or (sub4_avalon_rr and (not sub4_avalon_readdatavalid_i and sub4_avalon_waitrequest_i));
        sub4_avalon_rp <= (sub4_avalon_re or sub4_avalon_rp) and (sub4_avalon_we or (sub4_avalon_wr or sub4_avalon_wp));
        sub4_avalon_rt <= (sub4_avalon_rr and not (sub4_avalon_readdatavalid_i or sub4_avalon_waitrequest_i)) or (sub4_avalon_rt and not sub4_avalon_readdatavalid_i);
      end if;
    end if;
  end process;
  process (rd_addr, wr_addr, sub4_avalon_wr) begin
    if sub4_avalon_wr = '1' then
      sub4_avalon_address_o <= wr_addr(11 downto 2);
    else
      sub4_avalon_address_o <= rd_addr(11 downto 2);
    end if;
  end process;
  process (wr_sel) begin
    sub4_avalon_byteenable_o <= (others => '0');
    if not (wr_sel(7 downto 0) = (7 downto 0 => '0')) then
      sub4_avalon_byteenable_o(0) <= '1';
    end if;
    if not (wr_sel(15 downto 8) = (7 downto 0 => '0')) then
      sub4_avalon_byteenable_o(1) <= '1';
    end if;
    if not (wr_sel(23 downto 16) = (7 downto 0 => '0')) then
      sub4_avalon_byteenable_o(2) <= '1';
    end if;
    if not (wr_sel(31 downto 24) = (7 downto 0 => '0')) then
      sub4_avalon_byteenable_o(3) <= '1';
    end if;
  end process;
  sub4_avalon_write_o <= sub4_avalon_wr;
  sub4_avalon_read_o <= sub4_avalon_rr;
  sub4_avalon_writedata_o <= wr_data;

  -- Interface sub5_apb
  process (pclk) begin
    if rising_edge(pclk) then
      if presetn = '0' then
        sub5_apb_wr_reg <= '0';
        sub5_apb_rd_reg <= '0';
      else
        if sub5_apb_wr_ack = '1' then
          sub5_apb_wr_reg <= '0';
        elsif sub5_apb_wr_req = '1' then
          sub5_apb_wr_reg <= '1';
        end if;
        if sub5_apb_rd_ack = '1' then
          sub5_apb_rd_reg <= '0';
        elsif sub5_apb_rd_req = '1' then
          sub5_apb_rd_reg <= '1';
        end if;
      end if;
    end if;
  end process;
  sub5_apb_wr <= sub5_apb_wr_reg or sub5_apb_wr_req;
  sub5_apb_rd <= sub5_apb_rd_reg or sub5_apb_rd_req;
  sub5_apb_psel_o <= sub5_apb_wr or sub5_apb_rd;
  sub5_apb_penable_o <= (not wr_req and sub5_apb_wr) or (not rd_req and sub5_apb_rd);
  sub5_apb_pwrite_o <= sub5_apb_wr;
  process (sub5_apb_wr, wr_addr, rd_addr) begin
    if sub5_apb_wr = '1' then
      sub5_apb_paddr_o <= wr_addr(11 downto 2);
    else
      sub5_apb_paddr_o <= rd_addr(11 downto 2);
    end if;
  end process;
  sub5_apb_pwdata_o <= wr_data;
  process (wr_sel) begin
    sub5_apb_pstrb_o <= (others => '0');
    if not (wr_sel(7 downto 0) = (7 downto 0 => '0')) then
      sub5_apb_pstrb_o(0) <= '1';
    end if;
    if not (wr_sel(15 downto 8) = (7 downto 0 => '0')) then
      sub5_apb_pstrb_o(1) <= '1';
    end if;
    if not (wr_sel(23 downto 16) = (7 downto 0 => '0')) then
      sub5_apb_pstrb_o(2) <= '1';
    end if;
    if not (wr_sel(31 downto 24) = (7 downto 0 => '0')) then
      sub5_apb_pstrb_o(3) <= '1';
    end if;
  end process;

  -- Interface sub6_simple
  sub6_simple_dati_o <= wr_data;
  process (pclk) begin
    if rising_edge(pclk) then
      if presetn = '0' then
        sub6_simple_wr <= '0';
        sub6_simple_wt <= '0';
        sub6_simple_rr <= '0';
        sub6_simple_rt <= '0';
      else
        sub6_simple_wr <= (sub6_simple_wr or sub6_simple_we) and not sub6_simple_wack_i;
        sub6_simple_wt <= (sub6_simple_wt or sub6_simple_ws) and not sub6_simple_wack_i;
        sub6_simple_rr <= (sub6_simple_rr or sub6_simple_re) and not sub6_simple_rack_i;
        sub6_simple_rt <= (sub6_simple_rt or sub6_simple_rs) and not sub6_simple_rack_i;
      end if;
    end if;
  end process;
  sub6_simple_rs <= sub6_simple_rr and not (sub6_simple_wr or (sub6_simple_rt or sub6_simple_wt));
  sub6_simple_ws <= sub6_simple_wr and not (sub6_simple_rt or sub6_simple_wt);
  process (rd_addr, wr_addr, sub6_simple_wt, sub6_simple_ws) begin
    if (sub6_simple_ws or sub6_simple_wt) = '1' then
      sub6_simple_adr_o <= wr_addr(11 downto 2);
    else
      sub6_simple_adr_o <= rd_addr(11 downto 2);
    end if;
  end process;

  -- Process for write requests.
  process (wr_addr, wr_req, reg1_wack, reg2_wack, ram2_we, sub1_wb_wack,
           sub2_axi4_bvalid_i, sub3_cernbe_ws, sub3_cernbe_VMEWrDone_i,
           sub4_avalon_wr, sub4_avalon_waitrequest_i, wr_ack_d0, sub5_apb_wr,
           sub5_apb_pready_i, sub5_apb_pslverr_i, sub6_simple_ws,
           sub6_simple_wack_i) begin
    reg1_wreq <= '0';
    reg2_wreq <= '0';
    ram1_val_int_wr <= '0';
    ram2_wr_o <= '0';
    sub1_wb_we <= '0';
    sub2_axi4_wr <= '0';
    sub3_cernbe_we <= '0';
    sub3_cernbe_VMEWrMem_o <= '0';
    sub4_avalon_we <= '0';
    sub5_apb_wr_req <= '0';
    sub5_apb_wr_ack <= '0';
    sub6_simple_we <= '0';
    sub6_simple_wr_o <= '0';
    case wr_addr(14 downto 12) is
    when "000" =>
      case wr_addr(11 downto 5) is
      when "0000000" =>
        case wr_addr(4 downto 2) is
        when "000" =>
          -- Reg reg1
          reg1_wreq <= wr_req;
          wr_ack_d0 <= reg1_wack;
        when "001" =>
          -- Reg reg2
          reg2_wreq <= wr_req;
          wr_ack_d0 <= reg2_wack;
        when others =>
          wr_ack_d0 <= wr_req;
        end case;
      when "0000001" =>
        -- Memory ram1
        ram1_val_int_wr <= wr_req;
        wr_ack_d0 <= wr_req;
      when "0000010" =>
        -- Memory ram_ro
        wr_ack_d0 <= wr_req;
      when "0000011" =>
        -- Memory ram2
        ram2_wr_o <= ram2_we;
        wr_ack_d0 <= ram2_we;
      when others =>
        wr_ack_d0 <= wr_req;
      end case;
    when "001" =>
      -- Submap sub1_wb
      sub1_wb_we <= wr_req;
      wr_ack_d0 <= sub1_wb_wack;
    when "010" =>
      -- Submap sub2_axi4
      sub2_axi4_wr <= wr_req;
      wr_ack_d0 <= sub2_axi4_bvalid_i;
    when "011" =>
      -- Submap sub3_cernbe
      sub3_cernbe_we <= wr_req;
      sub3_cernbe_VMEWrMem_o <= sub3_cernbe_ws;
      wr_ack_d0 <= sub3_cernbe_VMEWrDone_i;
    when "100" =>
      -- Submap sub4_avalon
      sub4_avalon_we <= wr_req;
      wr_ack_d0 <= sub4_avalon_wr and not sub4_avalon_waitrequest_i;
    when "101" =>
      -- Submap sub5_apb
      sub5_apb_wr_req <= wr_req;
      sub5_apb_wr_ack <= wr_ack_d0;
      wr_ack_d0 <= sub5_apb_wr and sub5_apb_pready_i;
    when "110" =>
      -- Submap sub6_simple
      sub6_simple_we <= wr_req;
      sub6_simple_wr_o <= sub6_simple_ws;
      wr_ack_d0 <= sub6_simple_wack_i;
    when others =>
      wr_ack_d0 <= wr_req;
    end case;
  end process;

  -- Process for read requests.
  process (rd_addr, rd_req, reg1_reg, reg2_reg, ram1_val_int_dato, ram1_wreq,
           ram1_val_rack, ram_ro_val_int_dato, ram_ro_val_rack, ram2_data_i,
           ram2_rack, sub1_wb_dat_i, sub1_wb_rack, sub2_axi4_rdata_i,
           sub2_axi4_rvalid_i, sub3_cernbe_rs, sub3_cernbe_VMERdData_i,
           sub3_cernbe_VMERdDone_i, sub4_avalon_readdata_i,
           sub4_avalon_readdatavalid_i, rd_ack, sub5_apb_prdata_i, sub5_apb_rd,
           sub5_apb_pready_i, sub5_apb_pslverr_i, sub6_simple_rs,
           sub6_simple_dato_i, sub6_simple_rack_i) begin
    -- By default ack read requests
    rd_data <= (others => 'X');
    ram1_val_rreq <= '0';
    ram_ro_val_rreq <= '0';
    ram2_re <= '0';
    sub1_wb_re <= '0';
    sub2_axi4_rd <= '0';
    sub3_cernbe_VMERdMem_o <= '0';
    sub3_cernbe_re <= '0';
    sub4_avalon_re <= '0';
    sub5_apb_rd_req <= '0';
    sub5_apb_rd_ack <= '0';
    sub6_simple_rd_o <= '0';
    sub6_simple_re <= '0';
    case rd_addr(14 downto 12) is
    when "000" =>
      case rd_addr(11 downto 5) is
      when "0000000" =>
        case rd_addr(4 downto 2) is
        when "000" =>
          -- Reg reg1
          rd_ack <= rd_req;
          rd_data <= reg1_reg;
        when "001" =>
          -- Reg reg2
          rd_ack <= rd_req;
          rd_data <= reg2_reg;
        when others =>
          rd_ack <= rd_req;
        end case;
      when "0000001" =>
        -- Memory ram1
        rd_data <= ram1_val_int_dato;
        ram1_val_rreq <= rd_req and not ram1_wreq;
        rd_ack <= ram1_val_rack;
      when "0000010" =>
        -- Memory ram_ro
        rd_data <= ram_ro_val_int_dato;
        ram_ro_val_rreq <= rd_req;
        rd_ack <= ram_ro_val_rack;
      when "0000011" =>
        -- Memory ram2
        rd_data <= ram2_data_i;
        rd_ack <= ram2_rack;
        ram2_re <= rd_req;
      when others =>
        rd_ack <= rd_req;
      end case;
    when "001" =>
      -- Submap sub1_wb
      sub1_wb_re <= rd_req;
      rd_data <= sub1_wb_dat_i;
      rd_ack <= sub1_wb_rack;
    when "010" =>
      -- Submap sub2_axi4
      sub2_axi4_rd <= rd_req;
      rd_data <= sub2_axi4_rdata_i;
      rd_ack <= sub2_axi4_rvalid_i;
    when "011" =>
      -- Submap sub3_cernbe
      sub3_cernbe_re <= rd_req;
      sub3_cernbe_VMERdMem_o <= sub3_cernbe_rs;
      rd_data <= sub3_cernbe_VMERdData_i;
      rd_ack <= sub3_cernbe_VMERdDone_i;
    when "100" =>
      -- Submap sub4_avalon
      sub4_avalon_re <= rd_req;
      rd_data <= sub4_avalon_readdata_i;
      rd_ack <= sub4_avalon_readdatavalid_i;
    when "101" =>
      -- Submap sub5_apb
      sub5_apb_rd_req <= rd_req;
      sub5_apb_rd_ack <= rd_ack;
      rd_data <= sub5_apb_prdata_i;
      rd_ack <= sub5_apb_rd and sub5_apb_pready_i;
    when "110" =>
      -- Submap sub6_simple
      sub6_simple_re <= rd_req;
      sub6_simple_rd_o <= sub6_simple_rs;
      rd_data <= sub6_simple_dato_i;
      rd_ack <= sub6_simple_rack_i;
    when others =>
      rd_ack <= rd_req;
    end case;
  end process;
end syn;
