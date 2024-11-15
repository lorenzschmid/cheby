
module csr
  (
    input   wire rst_n_i,
    input   wire clk_i,
    input   wire wb_cyc_i,
    input   wire wb_stb_i,
    input   wire [15:2] wb_adr_i,
    input   wire [3:0] wb_sel_i,
    input   wire wb_we_i,
    input   wire [31:0] wb_dat_i,
    output  wire wb_ack_o,
    output  wire wb_err_o,
    output  wire wb_rty_o,
    output  wire wb_stall_o,
    output  reg [31:0] wb_dat_o,

    // REG ident
    input   wire [63:0] ident_i,

    // REG version
    input   wire [31:0] version_i,

    // REG cal_ctrl
    output  wire [1:0] cal_ctrl_cal_sel_o,

    // WB bus i2c_master
    output  wire i2c_master_cyc_o,
    output  wire i2c_master_stb_o,
    output  wire [4:2] i2c_master_adr_o,
    output  reg [3:0] i2c_master_sel_o,
    output  wire i2c_master_we_o,
    output  wire [31:0] i2c_master_dat_o,
    input   wire i2c_master_ack_i,
    input   wire i2c_master_err_i,
    input   wire i2c_master_rty_i,
    input   wire i2c_master_stall_i,
    input   wire [31:0] i2c_master_dat_i,

    // RAM port for adc_offs
    input   wire [11:0] adc_offs_adr_i,
    input   wire adc_offs_data_we_i,
    input   wire [31:0] adc_offs_data_dat_i,

    // RAM port for adc_meas
    input   wire [11:0] adc_meas_adr_i,
    input   wire adc_meas_data_we_i,
    input   wire [31:0] adc_meas_data_dat_i
  );
  reg [31:0] wr_sel;
  wire rd_req_int;
  wire wr_req_int;
  reg rd_ack_int;
  reg wr_ack_int;
  wire wb_en;
  wire ack_int;
  reg wb_rip;
  reg wb_wip;
  reg [1:0] cal_ctrl_cal_sel_reg;
  reg cal_ctrl_wreq;
  wire cal_ctrl_wack;
  reg i2c_master_re;
  reg i2c_master_we;
  reg i2c_master_wt;
  reg i2c_master_rt;
  wire i2c_master_tr;
  wire i2c_master_wack;
  wire i2c_master_rack;
  wire [31:0] adc_offs_data_int_dato;
  wire [31:0] adc_offs_data_ext_dat;
  reg adc_offs_data_rreq;
  reg adc_offs_data_rack;
  wire [31:0] adc_meas_data_int_dato;
  wire [31:0] adc_meas_data_ext_dat;
  reg adc_meas_data_rreq;
  reg adc_meas_data_rack;
  reg rd_ack_d0;
  reg [31:0] rd_dat_d0;
  reg wr_req_d0;
  reg [15:2] wr_adr_d0;
  reg [31:0] wr_dat_d0;
  reg [31:0] wr_sel_d0;
  reg [3:0] adc_offs_sel_int;
  reg [3:0] adc_meas_sel_int;

  // WB decode signals
  always_comb
  begin
    wr_sel[7:0] = {8{wb_sel_i[0]}};
    wr_sel[15:8] = {8{wb_sel_i[1]}};
    wr_sel[23:16] = {8{wb_sel_i[2]}};
    wr_sel[31:24] = {8{wb_sel_i[3]}};
  end
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
        wr_adr_d0 <= 14'b00000000000000;
        wr_dat_d0 <= 32'b00000000000000000000000000000000;
        wr_sel_d0 <= 32'b00000000000000000000000000000000;
      end
    else
      begin
        rd_ack_int <= rd_ack_d0;
        wb_dat_o <= rd_dat_d0;
        wr_req_d0 <= wr_req_int;
        wr_adr_d0 <= wb_adr_i;
        wr_dat_d0 <= wb_dat_i;
        wr_sel_d0 <= wr_sel;
      end
  end

  // Register ident

  // Register version

  // Register cal_ctrl
  assign cal_ctrl_cal_sel_o = cal_ctrl_cal_sel_reg;
  assign cal_ctrl_wack = cal_ctrl_wreq;
  always_ff @(posedge(clk_i))
  begin
    if (!rst_n_i)
      cal_ctrl_cal_sel_reg <= 2'b00;
    else
      if (cal_ctrl_wreq == 1'b1)
        cal_ctrl_cal_sel_reg <= wr_dat_d0[1:0];
  end

  // Interface i2c_master
  assign i2c_master_tr = i2c_master_wt | i2c_master_rt;
  always_ff @(posedge(clk_i))
  begin
    if (!rst_n_i)
      begin
        i2c_master_rt <= 1'b0;
        i2c_master_wt <= 1'b0;
      end
    else
      begin
        i2c_master_rt <= (i2c_master_rt | i2c_master_re) & ~i2c_master_rack;
        i2c_master_wt <= (i2c_master_wt | i2c_master_we) & ~i2c_master_wack;
      end
  end
  assign i2c_master_cyc_o = i2c_master_tr;
  assign i2c_master_stb_o = i2c_master_tr;
  assign i2c_master_wack = i2c_master_ack_i & i2c_master_wt;
  assign i2c_master_rack = i2c_master_ack_i & i2c_master_rt;
  assign i2c_master_adr_o = wb_adr_i[4:2];
  always_comb
  begin
    i2c_master_sel_o = 4'b0;
    if (~(wr_sel_d0[7:0] == 8'b0))
      i2c_master_sel_o[0] = 1'b1;
    if (~(wr_sel_d0[15:8] == 8'b0))
      i2c_master_sel_o[1] = 1'b1;
    if (~(wr_sel_d0[23:16] == 8'b0))
      i2c_master_sel_o[2] = 1'b1;
    if (~(wr_sel_d0[31:24] == 8'b0))
      i2c_master_sel_o[3] = 1'b1;
  end
  assign i2c_master_we_o = i2c_master_wt;
  assign i2c_master_dat_o = wr_dat_d0;

  // Memory adc_offs
  cheby_dpssram #(
      .g_data_width(32),
      .g_size(4096),
      .g_addr_width(12),
      .g_dual_clock(1'b0),
      .g_use_bwsel(1'b1)
    )
  adc_offs_data_raminst (
      .clk_a_i(clk_i),
      .clk_b_i(clk_i),
      .addr_a_i(wb_adr_i[13:2]),
      .bwsel_a_i(adc_offs_sel_int),
      .data_a_i({32{1'bx}}),
      .data_a_o(adc_offs_data_int_dato),
      .rd_a_i(adc_offs_data_rreq),
      .wr_a_i(1'b0),
      .addr_b_i(adc_offs_adr_i),
      .bwsel_b_i({4{1'b1}}),
      .data_b_i(adc_offs_data_dat_i),
      .data_b_o(adc_offs_data_ext_dat),
      .rd_b_i(1'b0),
      .wr_b_i(adc_offs_data_we_i)
    );
  
  always_comb
  begin
    adc_offs_sel_int = 4'b0;
    if (~(wr_sel_d0[7:0] == 8'b0))
      adc_offs_sel_int[0] = 1'b1;
    if (~(wr_sel_d0[15:8] == 8'b0))
      adc_offs_sel_int[1] = 1'b1;
    if (~(wr_sel_d0[23:16] == 8'b0))
      adc_offs_sel_int[2] = 1'b1;
    if (~(wr_sel_d0[31:24] == 8'b0))
      adc_offs_sel_int[3] = 1'b1;
  end
  always_ff @(posedge(clk_i))
  begin
    if (!rst_n_i)
      adc_offs_data_rack <= 1'b0;
    else
      adc_offs_data_rack <= adc_offs_data_rreq;
  end

  // Memory adc_meas
  cheby_dpssram #(
      .g_data_width(32),
      .g_size(4096),
      .g_addr_width(12),
      .g_dual_clock(1'b0),
      .g_use_bwsel(1'b1)
    )
  adc_meas_data_raminst (
      .clk_a_i(clk_i),
      .clk_b_i(clk_i),
      .addr_a_i(wb_adr_i[13:2]),
      .bwsel_a_i(adc_meas_sel_int),
      .data_a_i({32{1'bx}}),
      .data_a_o(adc_meas_data_int_dato),
      .rd_a_i(adc_meas_data_rreq),
      .wr_a_i(1'b0),
      .addr_b_i(adc_meas_adr_i),
      .bwsel_b_i({4{1'b1}}),
      .data_b_i(adc_meas_data_dat_i),
      .data_b_o(adc_meas_data_ext_dat),
      .rd_b_i(1'b0),
      .wr_b_i(adc_meas_data_we_i)
    );
  
  always_comb
  begin
    adc_meas_sel_int = 4'b0;
    if (~(wr_sel_d0[7:0] == 8'b0))
      adc_meas_sel_int[0] = 1'b1;
    if (~(wr_sel_d0[15:8] == 8'b0))
      adc_meas_sel_int[1] = 1'b1;
    if (~(wr_sel_d0[23:16] == 8'b0))
      adc_meas_sel_int[2] = 1'b1;
    if (~(wr_sel_d0[31:24] == 8'b0))
      adc_meas_sel_int[3] = 1'b1;
  end
  always_ff @(posedge(clk_i))
  begin
    if (!rst_n_i)
      adc_meas_data_rack <= 1'b0;
    else
      adc_meas_data_rack <= adc_meas_data_rreq;
  end

  // Process for write requests.
  always_comb
  begin
    cal_ctrl_wreq = 1'b0;
    i2c_master_we = 1'b0;
    case (wr_adr_d0[15:14])
    2'b00:
      case (wr_adr_d0[13:5])
      9'b000000000:
        case (wr_adr_d0[4:3])
        2'b00:
          case (wr_adr_d0[2:2])
          1'b0:
            // Reg ident
            wr_ack_int = wr_req_d0;
          1'b1:
            // Reg ident
            wr_ack_int = wr_req_d0;
          default:
            wr_ack_int = wr_req_d0;
          endcase
        2'b01:
          case (wr_adr_d0[2:2])
          1'b0:
            // Reg version
            wr_ack_int = wr_req_d0;
          1'b1:
            begin
              // Reg cal_ctrl
              cal_ctrl_wreq = wr_req_d0;
              wr_ack_int = cal_ctrl_wack;
            end
          default:
            wr_ack_int = wr_req_d0;
          endcase
        default:
          wr_ack_int = wr_req_d0;
        endcase
      9'b000000001:
        begin
          // Submap i2c_master
          i2c_master_we = wr_req_d0;
          wr_ack_int = i2c_master_wack;
        end
      default:
        wr_ack_int = wr_req_d0;
      endcase
    2'b01:
      // Memory adc_offs
      wr_ack_int = wr_req_d0;
    2'b10:
      // Memory adc_meas
      wr_ack_int = wr_req_d0;
    default:
      wr_ack_int = wr_req_d0;
    endcase
  end

  // Process for read requests.
  always_comb
  begin
    // By default ack read requests
    rd_dat_d0 = {32{1'bx}};
    i2c_master_re = 1'b0;
    adc_offs_data_rreq = 1'b0;
    adc_meas_data_rreq = 1'b0;
    case (wb_adr_i[15:14])
    2'b00:
      case (wb_adr_i[13:5])
      9'b000000000:
        case (wb_adr_i[4:3])
        2'b00:
          case (wb_adr_i[2:2])
          1'b0:
            begin
              // Reg ident
              rd_ack_d0 = rd_req_int;
              rd_dat_d0 = ident_i[63:32];
            end
          1'b1:
            begin
              // Reg ident
              rd_ack_d0 = rd_req_int;
              rd_dat_d0 = ident_i[31:0];
            end
          default:
            rd_ack_d0 = rd_req_int;
          endcase
        2'b01:
          case (wb_adr_i[2:2])
          1'b0:
            begin
              // Reg version
              rd_ack_d0 = rd_req_int;
              rd_dat_d0 = version_i;
            end
          1'b1:
            begin
              // Reg cal_ctrl
              rd_ack_d0 = rd_req_int;
              rd_dat_d0[1:0] = cal_ctrl_cal_sel_reg;
              rd_dat_d0[31:2] = 30'b0;
            end
          default:
            rd_ack_d0 = rd_req_int;
          endcase
        default:
          rd_ack_d0 = rd_req_int;
        endcase
      9'b000000001:
        begin
          // Submap i2c_master
          i2c_master_re = rd_req_int;
          rd_dat_d0 = i2c_master_dat_i;
          rd_ack_d0 = i2c_master_rack;
        end
      default:
        rd_ack_d0 = rd_req_int;
      endcase
    2'b01:
      begin
        // Memory adc_offs
        rd_dat_d0 = adc_offs_data_int_dato;
        adc_offs_data_rreq = rd_req_int;
        rd_ack_d0 = adc_offs_data_rack;
      end
    2'b10:
      begin
        // Memory adc_meas
        rd_dat_d0 = adc_meas_data_int_dato;
        adc_meas_data_rreq = rd_req_int;
        rd_ack_d0 = adc_meas_data_rack;
      end
    default:
      rd_ack_d0 = rd_req_int;
    endcase
  end
endmodule
