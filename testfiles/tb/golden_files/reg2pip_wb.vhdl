library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg2pip_wb is
  port (
    rst_n_i              : in    std_logic;
    clk_i                : in    std_logic;
    wb_cyc_i             : in    std_logic;
    wb_stb_i             : in    std_logic;
    wb_adr_i             : in    std_logic_vector(3 downto 2);
    wb_sel_i             : in    std_logic_vector(3 downto 0);
    wb_we_i              : in    std_logic;
    wb_dat_i             : in    std_logic_vector(31 downto 0);
    wb_ack_o             : out   std_logic;
    wb_err_o             : out   std_logic;
    wb_rty_o             : out   std_logic;
    wb_stall_o           : out   std_logic;
    wb_dat_o             : out   std_logic_vector(31 downto 0);

    -- REG reg1
    reg1_o               : out   std_logic_vector(31 downto 0);

    -- REG rwo_sa
    rwo_sa_o             : out   std_logic_vector(31 downto 0);
    rwo_sa_wr_o          : out   std_logic;
    rwo_sa_wack_i        : in    std_logic;

    -- REG wwo_st
    wwo_st_o             : out   std_logic_vector(31 downto 0);
    wwo_st_wr_o          : out   std_logic;

    -- REG wwo_sa
    wwo_sa_o             : out   std_logic_vector(31 downto 0);
    wwo_sa_wr_o          : out   std_logic;
    wwo_sa_wack_i        : in    std_logic
  );
end reg2pip_wb;

architecture syn of reg2pip_wb is
  signal rd_req_int                     : std_logic;
  signal wr_req_int                     : std_logic;
  signal rd_ack_int                     : std_logic;
  signal wr_ack_int                     : std_logic;
  signal wb_en                          : std_logic;
  signal ack_int                        : std_logic;
  signal wb_rip                         : std_logic;
  signal wb_wip                         : std_logic;
  signal reg1_reg                       : std_logic_vector(31 downto 0);
  signal reg1_wreq                      : std_logic;
  signal reg1_wack                      : std_logic;
  signal rwo_sa_reg                     : std_logic_vector(31 downto 0);
  signal rwo_sa_wreq                    : std_logic;
  signal rwo_sa_wstrb                   : std_logic;
  signal wwo_st_wreq                    : std_logic;
  signal wwo_sa_wreq                    : std_logic;
  signal wr_req_d0                      : std_logic;
  signal wr_adr_d0                      : std_logic_vector(3 downto 2);
  signal wr_dat_d0                      : std_logic_vector(31 downto 0);
begin

  -- WB decode signals
  wb_en <= wb_cyc_i and wb_stb_i;

  process (clk_i) begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        wb_rip <= '0';
      else
        wb_rip <= (wb_rip or (wb_en and not wb_we_i)) and not rd_ack_int;
      end if;
    end if;
  end process;
  rd_req_int <= (wb_en and not wb_we_i) and not wb_rip;

  process (clk_i) begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        wb_wip <= '0';
      else
        wb_wip <= (wb_wip or (wb_en and wb_we_i)) and not wr_ack_int;
      end if;
    end if;
  end process;
  wr_req_int <= (wb_en and wb_we_i) and not wb_wip;

  ack_int <= rd_ack_int or wr_ack_int;
  wb_ack_o <= ack_int;
  wb_stall_o <= not ack_int and wb_en;
  wb_rty_o <= '0';
  wb_err_o <= '0';

  -- pipelining for wr-in
  process (clk_i) begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        wr_req_d0 <= '0';
        wr_adr_d0 <= "00";
        wr_dat_d0 <= "00000000000000000000000000000000";
      else
        wr_req_d0 <= wr_req_int;
        wr_adr_d0 <= wb_adr_i;
        wr_dat_d0 <= wb_dat_i;
      end if;
    end if;
  end process;

  -- Register reg1
  reg1_o <= reg1_reg;
  reg1_wack <= reg1_wreq;
  process (clk_i) begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        reg1_reg <= "10101011110011010001001000110100";
      else
        if reg1_wreq = '1' then
          reg1_reg <= wr_dat_d0;
        end if;
      end if;
    end if;
  end process;

  -- Register rwo_sa
  rwo_sa_o <= rwo_sa_reg;
  process (clk_i) begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        rwo_sa_reg <= "00000000000000000000000000000000";
        rwo_sa_wstrb <= '0';
      else
        if rwo_sa_wreq = '1' then
          rwo_sa_reg <= wr_dat_d0;
        end if;
        rwo_sa_wstrb <= rwo_sa_wreq;
      end if;
    end if;
  end process;
  rwo_sa_wr_o <= rwo_sa_wstrb;

  -- Register wwo_st
  wwo_st_o <= wr_dat_d0;
  wwo_st_wr_o <= wwo_st_wreq;

  -- Register wwo_sa
  wwo_sa_o <= wr_dat_d0;
  wwo_sa_wr_o <= wwo_sa_wreq;

  -- Process for write requests.
  process (wr_adr_d0, wr_req_d0, reg1_wack, rwo_sa_wack_i, wwo_sa_wack_i) begin
    reg1_wreq <= '0';
    rwo_sa_wreq <= '0';
    wwo_st_wreq <= '0';
    wwo_sa_wreq <= '0';
    case wr_adr_d0(3 downto 2) is
    when "00" =>
      -- Reg reg1
      reg1_wreq <= wr_req_d0;
      wr_ack_int <= reg1_wack;
    when "01" =>
      -- Reg rwo_sa
      rwo_sa_wreq <= wr_req_d0;
      wr_ack_int <= rwo_sa_wack_i;
    when "10" =>
      -- Reg wwo_st
      wwo_st_wreq <= wr_req_d0;
      wr_ack_int <= wr_req_d0;
    when "11" =>
      -- Reg wwo_sa
      wwo_sa_wreq <= wr_req_d0;
      wr_ack_int <= wwo_sa_wack_i;
    when others =>
      wr_ack_int <= wr_req_d0;
    end case;
  end process;

  -- Process for read requests.
  process (wb_adr_i, rd_req_int, reg1_reg) begin
    -- By default ack read requests
    wb_dat_o <= (others => 'X');
    case wb_adr_i(3 downto 2) is
    when "00" =>
      -- Reg reg1
      rd_ack_int <= rd_req_int;
      wb_dat_o <= reg1_reg;
    when "01" =>
      -- Reg rwo_sa
      rd_ack_int <= rd_req_int;
    when "10" =>
      -- Reg wwo_st
      rd_ack_int <= rd_req_int;
    when "11" =>
      -- Reg wwo_sa
      rd_ack_int <= rd_req_int;
    when others =>
      rd_ack_int <= rd_req_int;
    end case;
  end process;
end syn;
