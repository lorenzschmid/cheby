library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg5rwbe_wb is
  port (
    rst_n_i              : in    std_logic;
    clk_i                : in    std_logic;
    wb_cyc_i             : in    std_logic;
    wb_stb_i             : in    std_logic;
    wb_adr_i             : in    std_logic_vector(2 downto 2);
    wb_sel_i             : in    std_logic_vector(3 downto 0);
    wb_we_i              : in    std_logic;
    wb_dat_i             : in    std_logic_vector(31 downto 0);
    wb_ack_o             : out   std_logic;
    wb_err_o             : out   std_logic;
    wb_rty_o             : out   std_logic;
    wb_stall_o           : out   std_logic;
    wb_dat_o             : out   std_logic_vector(31 downto 0);

    -- REG frrw
    frrw_f1_o            : out   std_logic_vector(11 downto 0);
    frrw_f2_o            : out   std_logic_vector(15 downto 0);
    frrw_f3_o            : out   std_logic_vector(23 downto 0)
  );
end reg5rwbe_wb;

architecture syn of reg5rwbe_wb is
  signal rd_req_int                     : std_logic;
  signal wr_req_int                     : std_logic;
  signal rd_ack_int                     : std_logic;
  signal wr_ack_int                     : std_logic;
  signal wb_en                          : std_logic;
  signal ack_int                        : std_logic;
  signal wb_rip                         : std_logic;
  signal wb_wip                         : std_logic;
  signal frrw_f1_reg                    : std_logic_vector(11 downto 0);
  signal frrw_f2_reg                    : std_logic_vector(15 downto 0);
  signal frrw_f3_reg                    : std_logic_vector(23 downto 0);
  signal frrw_wreq                      : std_logic_vector(1 downto 0);
  signal frrw_wack                      : std_logic_vector(1 downto 0);
  signal rd_ack_d0                      : std_logic;
  signal rd_dat_d0                      : std_logic_vector(31 downto 0);
  signal wr_req_d0                      : std_logic;
  signal wr_adr_d0                      : std_logic_vector(2 downto 2);
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

  -- pipelining for wr-in+rd-out
  process (clk_i) begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        rd_ack_int <= '0';
        wb_dat_o <= "00000000000000000000000000000000";
        wr_req_d0 <= '0';
        wr_adr_d0 <= "0";
        wr_dat_d0 <= "00000000000000000000000000000000";
      else
        rd_ack_int <= rd_ack_d0;
        wb_dat_o <= rd_dat_d0;
        wr_req_d0 <= wr_req_int;
        wr_adr_d0 <= wb_adr_i;
        wr_dat_d0 <= wb_dat_i;
      end if;
    end if;
  end process;

  -- Register frrw
  frrw_f1_o <= frrw_f1_reg;
  frrw_f2_o <= frrw_f2_reg;
  frrw_f3_o <= frrw_f3_reg;
  frrw_wack <= frrw_wreq;
  process (clk_i) begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        frrw_f1_reg <= "000000000000";
        frrw_f2_reg <= "0001001000110100";
        frrw_f3_reg <= "000000000000000000000000";
      else
        if frrw_wreq(0) = '1' then
          frrw_f1_reg <= wr_dat_d0(11 downto 0);
          frrw_f2_reg(7 downto 0) <= wr_dat_d0(31 downto 24);
        end if;
        if frrw_wreq(1) = '1' then
          frrw_f2_reg(15 downto 8) <= wr_dat_d0(7 downto 0);
          frrw_f3_reg <= wr_dat_d0(31 downto 8);
        end if;
      end if;
    end if;
  end process;

  -- Process for write requests.
  process (wr_adr_d0, wr_req_d0, frrw_wack) begin
    frrw_wreq <= (others => '0');
    case wr_adr_d0(2 downto 2) is
    when "0" =>
      -- Reg frrw
      frrw_wreq(1) <= wr_req_d0;
      wr_ack_int <= frrw_wack(1);
    when "1" =>
      -- Reg frrw
      frrw_wreq(0) <= wr_req_d0;
      wr_ack_int <= frrw_wack(0);
    when others =>
      wr_ack_int <= wr_req_d0;
    end case;
  end process;

  -- Process for read requests.
  process (wb_adr_i, rd_req_int, frrw_f2_reg, frrw_f3_reg, frrw_f1_reg) begin
    -- By default ack read requests
    rd_dat_d0 <= (others => 'X');
    case wb_adr_i(2 downto 2) is
    when "0" =>
      -- Reg frrw
      rd_ack_d0 <= rd_req_int;
      rd_dat_d0(7 downto 0) <= frrw_f2_reg(15 downto 8);
      rd_dat_d0(31 downto 8) <= frrw_f3_reg;
    when "1" =>
      -- Reg frrw
      rd_ack_d0 <= rd_req_int;
      rd_dat_d0(11 downto 0) <= frrw_f1_reg;
      rd_dat_d0(23 downto 12) <= (others => '0');
      rd_dat_d0(31 downto 24) <= frrw_f2_reg(7 downto 0);
    when others =>
      rd_ack_d0 <= rd_req_int;
    end case;
  end process;
end syn;
