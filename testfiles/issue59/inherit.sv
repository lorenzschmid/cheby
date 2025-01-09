
module inherit
  (
    input   wire rst_n_i,
    input   wire clk_i,
    input   wire wb_cyc_i,
    input   wire wb_stb_i,
    input   wire [3:0] wb_sel_i,
    input   wire wb_we_i,
    input   wire [31:0] wb_dat_i,
    output  wire wb_ack_o,
    output  wire wb_err_o,
    output  wire wb_rty_o,
    output  wire wb_stall_o,
    output  reg [31:0] wb_dat_o,

    // REG reg0
    input   wire reg0_field00_i,
    output  wire reg0_field00_o,
    output  wire [3:0] reg0_field01_o,
    output  wire [2:0] reg0_field02_o,
    output  wire reg0_wr_o
  );
  wire rd_req_int;
  wire wr_req_int;
  reg rd_ack_int;
  reg wr_ack_int;
  wire wb_en;
  wire ack_int;
  reg wb_rip;
  reg wb_wip;
  reg [3:0] reg0_field01_reg;
  reg [2:0] reg0_field02_reg;
  reg reg0_wreq;
  wire reg0_wack;
  wire reg0_wstrb;
  reg rd_ack_d0;
  reg [31:0] rd_dat_d0;
  reg wr_req_d0;
  reg [31:0] wr_dat_d0;

  // WB decode signals
  always_comb
  ;
  assign wb_en = wb_cyc_i & wb_stb_i;

  always_ff @(posedge(clk_i))
  begin
    if (!rst_n_i)
      wb_rip <= 1'b0;
    else
      wb_rip <= (wb_rip | (wb_en & ~wb_we_i)) & ~rd_ack_int;
  end
  assign rd_req_int = (wb_en & ~wb_we_i) & ~wb_rip;

  always_ff @(posedge(clk_i))
  begin
    if (!rst_n_i)
      wb_wip <= 1'b0;
    else
      wb_wip <= (wb_wip | (wb_en & wb_we_i)) & ~wr_ack_int;
  end
  assign wr_req_int = (wb_en & wb_we_i) & ~wb_wip;

  assign ack_int = rd_ack_int | wr_ack_int;
  assign wb_ack_o = ack_int;
  assign wb_stall_o = ~ack_int & wb_en;
  assign wb_rty_o = 1'b0;
  assign wb_err_o = 1'b0;

  // pipelining for wr-in+rd-out
  always_ff @(posedge(clk_i))
  begin
    if (!rst_n_i)
      begin
        rd_ack_int <= 1'b0;
        wb_dat_o <= 32'b00000000000000000000000000000000;
        wr_req_d0 <= 1'b0;
        wr_dat_d0 <= 32'b00000000000000000000000000000000;
      end
    else
      begin
        rd_ack_int <= rd_ack_d0;
        wb_dat_o <= rd_dat_d0;
        wr_req_d0 <= wr_req_int;
        wr_dat_d0 <= wb_dat_i;
      end
  end

  // Register reg0
  assign reg0_field00_o = wr_dat_d0[1];
  assign reg0_field01_o = reg0_field01_reg;
  assign reg0_field02_o = reg0_field02_reg;
  assign reg0_wack = reg0_wreq;
  assign reg0_wstrb = reg0_wreq;
  always_ff @(posedge(clk_i))
  begin
    if (!rst_n_i)
      begin
        reg0_field01_reg <= 4'b0000;
        reg0_field02_reg <= 3'b010;
      end
    else
      if (reg0_wreq == 1'b1)
        begin
          reg0_field01_reg <= wr_dat_d0[7:4];
          reg0_field02_reg <= wr_dat_d0[10:8];
        end
  end
  assign reg0_wr_o = reg0_wstrb;

  // Process for write requests.
  always_comb
  begin
    reg0_wreq = 1'b0;
    // Reg reg0
    reg0_wreq = wr_req_d0;
    wr_ack_int = reg0_wack;
  end

  // Process for read requests.
  always_comb
  begin
    // By default ack read requests
    rd_dat_d0 = {32{1'bx}};
    // Reg reg0
    rd_ack_d0 = rd_req_int;
    rd_dat_d0[0] = 1'b0;
    rd_dat_d0[1] = reg0_field00_i;
    rd_dat_d0[3:2] = 2'b0;
    rd_dat_d0[7:4] = reg0_field01_reg;
    rd_dat_d0[10:8] = reg0_field02_reg;
    rd_dat_d0[31:11] = 21'b0;
  end
endmodule
