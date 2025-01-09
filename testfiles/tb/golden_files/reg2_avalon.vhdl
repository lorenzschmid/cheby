library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg2_avalon is
  port (
    clk                  : in    std_logic;
    reset                : in    std_logic;
    address              : in    std_logic_vector(4 downto 2);
    readdata             : out   std_logic_vector(31 downto 0);
    writedata            : in    std_logic_vector(31 downto 0);
    byteenable           : in    std_logic_vector(3 downto 0);
    read                 : in    std_logic;
    write                : in    std_logic;
    readdatavalid        : out   std_logic;
    waitrequest          : out   std_logic;

    -- REG reg1
    reg1_o               : out   std_logic_vector(31 downto 0);

    -- REG reg2
    reg2_o               : out   std_logic_vector(31 downto 0);
    reg2_wr_o            : out   std_logic;

    -- REG rwo
    rwo_o                : out   std_logic_vector(31 downto 0);

    -- REG rwo_st
    rwo_st_o             : out   std_logic_vector(31 downto 0);
    rwo_st_wr_o          : out   std_logic;

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
end reg2_avalon;

architecture syn of reg2_avalon is
  signal rst_n                          : std_logic;
  signal rd_req                         : std_logic;
  signal rd_ack                         : std_logic;
  signal wr_req                         : std_logic;
  signal wr_ack                         : std_logic;
  signal wr_dat                         : std_logic_vector(31 downto 0);
  signal wait_int                       : std_logic;
  signal adr                            : std_logic_vector(4 downto 2);
  signal reg1_reg                       : std_logic_vector(31 downto 0);
  signal reg1_wreq                      : std_logic;
  signal reg1_wack                      : std_logic;
  signal reg2_reg                       : std_logic_vector(31 downto 0);
  signal reg2_wreq                      : std_logic;
  signal reg2_wack                      : std_logic;
  signal reg2_wstrb                     : std_logic;
  signal rwo_reg                        : std_logic_vector(31 downto 0);
  signal rwo_wreq                       : std_logic;
  signal rwo_wack                       : std_logic;
  signal rwo_st_reg                     : std_logic_vector(31 downto 0);
  signal rwo_st_wreq                    : std_logic;
  signal rwo_st_wack                    : std_logic;
  signal rwo_st_wstrb                   : std_logic;
  signal rwo_sa_reg                     : std_logic_vector(31 downto 0);
  signal rwo_sa_wreq                    : std_logic;
  signal rwo_sa_wstrb                   : std_logic;
  signal wwo_st_wreq                    : std_logic;
  signal wwo_sa_wreq                    : std_logic;
begin
  rst_n <= not reset;
  process (clk) begin
    if rising_edge(clk) then
      if rst_n = '0' then
        wait_int <= '0';
      else
        wait_int <= (wait_int or (read or write)) and not (rd_ack or wr_ack);
      end if;
    end if;
  end process;
  process (clk) begin
    if rising_edge(clk) then
      if rst_n = '0' then
        rd_req <= '0';
        wr_req <= '0';
      else
        if ((read or write) and not wait_int) = '1' then
          adr <= address;
        else
        end if;
        if (write and not wait_int) = '1' then
          wr_dat <= writedata;
        else
        end if;
        rd_req <= read and not wait_int;
        wr_req <= write and not wait_int;
      end if;
    end if;
  end process;
  readdatavalid <= rd_ack;
  waitrequest <= wait_int;

  -- Register reg1
  reg1_o <= reg1_reg;
  reg1_wack <= reg1_wreq;
  process (clk) begin
    if rising_edge(clk) then
      if rst_n = '0' then
        reg1_reg <= "10101011110011010001001000110100";
      else
        if reg1_wreq = '1' then
          reg1_reg <= wr_dat;
        end if;
      end if;
    end if;
  end process;

  -- Register reg2
  reg2_o <= reg2_reg;
  reg2_wack <= reg2_wreq;
  process (clk) begin
    if rising_edge(clk) then
      if rst_n = '0' then
        reg2_reg <= "10101011110011010001000000000100";
        reg2_wstrb <= '0';
      else
        if reg2_wreq = '1' then
          reg2_reg <= wr_dat;
        end if;
        reg2_wstrb <= reg2_wreq;
      end if;
    end if;
  end process;
  reg2_wr_o <= reg2_wstrb;

  -- Register rwo
  rwo_o <= rwo_reg;
  rwo_wack <= rwo_wreq;
  process (clk) begin
    if rising_edge(clk) then
      if rst_n = '0' then
        rwo_reg <= "00000000000000000000000000000000";
      else
        if rwo_wreq = '1' then
          rwo_reg <= wr_dat;
        end if;
      end if;
    end if;
  end process;

  -- Register rwo_st
  rwo_st_o <= rwo_st_reg;
  rwo_st_wack <= rwo_st_wreq;
  process (clk) begin
    if rising_edge(clk) then
      if rst_n = '0' then
        rwo_st_reg <= "00000000000000000000000000000000";
        rwo_st_wstrb <= '0';
      else
        if rwo_st_wreq = '1' then
          rwo_st_reg <= wr_dat;
        end if;
        rwo_st_wstrb <= rwo_st_wreq;
      end if;
    end if;
  end process;
  rwo_st_wr_o <= rwo_st_wstrb;

  -- Register rwo_sa
  rwo_sa_o <= rwo_sa_reg;
  process (clk) begin
    if rising_edge(clk) then
      if rst_n = '0' then
        rwo_sa_reg <= "00000000000000000000000000000000";
        rwo_sa_wstrb <= '0';
      else
        if rwo_sa_wreq = '1' then
          rwo_sa_reg <= wr_dat;
        end if;
        rwo_sa_wstrb <= rwo_sa_wreq;
      end if;
    end if;
  end process;
  rwo_sa_wr_o <= rwo_sa_wstrb;

  -- Register wwo_st
  wwo_st_o <= wr_dat;
  wwo_st_wr_o <= wwo_st_wreq;

  -- Register wwo_sa
  wwo_sa_o <= wr_dat;
  wwo_sa_wr_o <= wwo_sa_wreq;

  -- Process for write requests.
  process (adr, wr_req, reg1_wack, reg2_wack, rwo_wack, rwo_st_wack, rwo_sa_wack_i,
           wwo_sa_wack_i) begin
    reg1_wreq <= '0';
    reg2_wreq <= '0';
    rwo_wreq <= '0';
    rwo_st_wreq <= '0';
    rwo_sa_wreq <= '0';
    wwo_st_wreq <= '0';
    wwo_sa_wreq <= '0';
    case adr(4 downto 2) is
    when "000" =>
      -- Reg reg1
      reg1_wreq <= wr_req;
      wr_ack <= reg1_wack;
    when "001" =>
      -- Reg reg2
      reg2_wreq <= wr_req;
      wr_ack <= reg2_wack;
    when "010" =>
      -- Reg rwo
      rwo_wreq <= wr_req;
      wr_ack <= rwo_wack;
    when "011" =>
      -- Reg rwo_st
      rwo_st_wreq <= wr_req;
      wr_ack <= rwo_st_wack;
    when "100" =>
      -- Reg rwo_sa
      rwo_sa_wreq <= wr_req;
      wr_ack <= rwo_sa_wack_i;
    when "101" =>
      -- Reg wwo_st
      wwo_st_wreq <= wr_req;
      wr_ack <= wr_req;
    when "110" =>
      -- Reg wwo_sa
      wwo_sa_wreq <= wr_req;
      wr_ack <= wwo_sa_wack_i;
    when others =>
      wr_ack <= wr_req;
    end case;
  end process;

  -- Process for read requests.
  process (adr, rd_req, reg1_reg, reg2_reg) begin
    -- By default ack read requests
    readdata <= (others => 'X');
    case adr(4 downto 2) is
    when "000" =>
      -- Reg reg1
      rd_ack <= rd_req;
      readdata <= reg1_reg;
    when "001" =>
      -- Reg reg2
      rd_ack <= rd_req;
      readdata <= reg2_reg;
    when "010" =>
      -- Reg rwo
      rd_ack <= rd_req;
    when "011" =>
      -- Reg rwo_st
      rd_ack <= rd_req;
    when "100" =>
      -- Reg rwo_sa
      rd_ack <= rd_req;
    when "101" =>
      -- Reg wwo_st
      rd_ack <= rd_req;
    when "110" =>
      -- Reg wwo_sa
      rd_ack <= rd_req;
    when others =>
      rd_ack <= rd_req;
    end case;
  end process;
end syn;
