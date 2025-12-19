`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Module Name: cv32e40p_axi_top
// Description: Top level wrapper for CV32E40P core with OBI-to-AXI4 bridges.
//              Converts native OBI interface to industry standard AXI4.
//////////////////////////////////////////////////////////////////////////////////

module cv32e40p_axi_top (
    input  logic        clk_i,
    input  logic        rst_ni,

    // -----------------------------------------------------------------------
    // Konfigürasyon Sinyalleri (Static Configuration)
    // -----------------------------------------------------------------------
    input  logic [31:0] boot_addr_i,
    input  logic [31:0] mtvec_addr_i,
    input  logic        fetch_enable_i,

    // =======================================================================
    // AXI4 MASTER INTERFACE - INSTRUCTION (Komut Hattý)
    // =======================================================================
    // Write Address Channel (AW) - Instruction hattý yazma yapmaz ama AXI standardý gereði portlar durur
    output logic [31:0] m_axi_instr_awaddr,
    output logic [7:0]  m_axi_instr_awlen,
    output logic [2:0]  m_axi_instr_awsize,
    output logic [1:0]  m_axi_instr_awburst,
    output logic        m_axi_instr_awvalid,
    input  logic        m_axi_instr_awready,
    
    // Write Data Channel (W)
    output logic [31:0] m_axi_instr_wdata,
    output logic [3:0]  m_axi_instr_wstrb,
    output logic        m_axi_instr_wlast,
    output logic        m_axi_instr_wvalid,
    input  logic        m_axi_instr_wready,
    
    // Write Response Channel (B)
    input  logic [1:0]  m_axi_instr_bresp,
    input  logic        m_axi_instr_bvalid,
    output logic        m_axi_instr_bready,
    
    // Read Address Channel (AR)
    output logic [31:0] m_axi_instr_araddr,
    output logic [7:0]  m_axi_instr_arlen,
    output logic [2:0]  m_axi_instr_arsize,
    output logic [1:0]  m_axi_instr_arburst,
    output logic        m_axi_instr_arvalid,
    input  logic        m_axi_instr_arready,
    
    // Read Data Channel (R)
    input  logic [31:0] m_axi_instr_rdata,
    input  logic [1:0]  m_axi_instr_rresp,
    input  logic        m_axi_instr_rlast,
    input  logic        m_axi_instr_rvalid,
    output logic        m_axi_instr_rready,

    // =======================================================================
    // AXI4 MASTER INTERFACE - DATA (Veri Hattý)
    // =======================================================================
    // Write Address Channel (AW)
    output logic [31:0] m_axi_data_awaddr,
    output logic [7:0]  m_axi_data_awlen,
    output logic [2:0]  m_axi_data_awsize,
    output logic [1:0]  m_axi_data_awburst,
    output logic        m_axi_data_awvalid,
    input  logic        m_axi_data_awready,
    
    // Write Data Channel (W)
    output logic [31:0] m_axi_data_wdata,
    output logic [3:0]  m_axi_data_wstrb,
    output logic        m_axi_data_wlast,
    output logic        m_axi_data_wvalid,
    input  logic        m_axi_data_wready,
    
    // Write Response Channel (B)
    input  logic [1:0]  m_axi_data_bresp,
    input  logic        m_axi_data_bvalid,
    output logic        m_axi_data_bready,
    
    // Read Address Channel (AR)
    output logic [31:0] m_axi_data_araddr,
    output logic [7:0]  m_axi_data_arlen,
    output logic [2:0]  m_axi_data_arsize,
    output logic [1:0]  m_axi_data_arburst,
    output logic        m_axi_data_arvalid,
    input  logic        m_axi_data_arready,
    
    // Read Data Channel (R)
    input  logic [31:0] m_axi_data_rdata,
    input  logic [1:0]  m_axi_data_rresp,
    input  logic        m_axi_data_rlast,
    input  logic        m_axi_data_rvalid,
    output logic        m_axi_data_rready
);

    // -----------------------------------------------------------------------
    // Internal OBI Signals (Between Core and Bridge)
    // -----------------------------------------------------------------------
    // Instruction Bus
    logic        instr_req;
    logic        instr_gnt;
    logic        instr_rvalid;
    logic [31:0] instr_addr;
    logic [31:0] instr_rdata;

    // Data Bus
    logic        data_req;
    logic        data_we;
    logic [3:0]  data_be;
    logic [31:0] data_addr;
    logic [31:0] data_wdata;
    logic        data_gnt;
    logic        data_rvalid;
    logic [31:0] data_rdata;

    // -----------------------------------------------------------------------
    // 1. PROCESSOR CORE INSTANTIATION
    // -----------------------------------------------------------------------
    cv32e40p_top u_core (
        .clk_i          (clk_i),
        .rst_ni         (rst_ni),
        .pulp_clock_en_i(1'b1),
        .scan_cg_en_i   (1'b0),
        
        .boot_addr_i    (boot_addr_i),
        .mtvec_addr_i   (mtvec_addr_i),
        .dm_halt_addr_i (32'h0),
        .hart_id_i      (32'h0),
        .dm_exception_addr_i(32'h0),
        .fetch_enable_i (fetch_enable_i),
        .core_sleep_o   (),

        // Instruction OBI
        .instr_req_o    (instr_req),
        .instr_gnt_i    (instr_gnt),
        .instr_rvalid_i (instr_rvalid),
        .instr_addr_o   (instr_addr),
        .instr_rdata_i  (instr_rdata),

        // Data OBI
        .data_req_o     (data_req),
        .data_gnt_i     (data_gnt),
        .data_rvalid_i  (data_rvalid),
        .data_we_o      (data_we),
        .data_be_o      (data_be),
        .data_addr_o    (data_addr),
        .data_wdata_o   (data_wdata),
        .data_rdata_i   (data_rdata),

        .irq_i(32'h0), 
        .debug_req_i(1'b0)
    );

    // -----------------------------------------------------------------------
    // 2. INSTRUCTION BRIDGE (OBI -> AXI4)
    // -----------------------------------------------------------------------
    obi_to_axi u_instr_bridge (
        .clk(clk_i), .rst_n(rst_ni),
        
        // OBI Side
        .obi_req_i(instr_req), .obi_we_i(1'b0), .obi_be_i(4'b1111),
        .obi_addr_i(instr_addr), .obi_wdata_i(32'h0),
        .obi_gnt_o(instr_gnt), .obi_rvalid_o(instr_rvalid), .obi_rdata_o(instr_rdata),
        
        // AXI Side
        .m_axi_awaddr(m_axi_instr_awaddr), .m_axi_awlen(m_axi_instr_awlen), 
        .m_axi_awsize(m_axi_instr_awsize), .m_axi_awburst(m_axi_instr_awburst),
        .m_axi_awvalid(m_axi_instr_awvalid), .m_axi_awready(m_axi_instr_awready),
        
        .m_axi_wdata(m_axi_instr_wdata), .m_axi_wstrb(m_axi_instr_wstrb), 
        .m_axi_wlast(m_axi_instr_wlast), .m_axi_wvalid(m_axi_instr_wvalid), 
        .m_axi_wready(m_axi_instr_wready),
        
        .m_axi_bresp(m_axi_instr_bresp), .m_axi_bvalid(m_axi_instr_bvalid), 
        .m_axi_bready(m_axi_instr_bready),
        
        .m_axi_araddr(m_axi_instr_araddr), .m_axi_arlen(m_axi_instr_arlen), 
        .m_axi_arsize(m_axi_instr_arsize), .m_axi_arburst(m_axi_instr_arburst),
        .m_axi_arvalid(m_axi_instr_arvalid), .m_axi_arready(m_axi_instr_arready),
        
        .m_axi_rdata(m_axi_instr_rdata), .m_axi_rresp(m_axi_instr_rresp), 
        .m_axi_rlast(m_axi_instr_rlast), .m_axi_rvalid(m_axi_instr_rvalid), 
        .m_axi_rready(m_axi_instr_rready)
    );

    // -----------------------------------------------------------------------
    // 3. DATA BRIDGE (OBI -> AXI4)
    // -----------------------------------------------------------------------
    obi_to_axi u_data_bridge (
        .clk(clk_i), .rst_n(rst_ni),
        
        // OBI Side
        .obi_req_i(data_req), .obi_we_i(data_we), .obi_be_i(data_be),
        .obi_addr_i(data_addr), .obi_wdata_i(data_wdata),
        .obi_gnt_o(data_gnt), .obi_rvalid_o(data_rvalid), .obi_rdata_o(data_rdata),
        
        // AXI Side
        .m_axi_awaddr(m_axi_data_awaddr), .m_axi_awlen(m_axi_data_awlen), 
        .m_axi_awsize(m_axi_data_awsize), .m_axi_awburst(m_axi_data_awburst),
        .m_axi_awvalid(m_axi_data_awvalid), .m_axi_awready(m_axi_data_awready),
        
        .m_axi_wdata(m_axi_data_wdata), .m_axi_wstrb(m_axi_data_wstrb), 
        .m_axi_wlast(m_axi_data_wlast), .m_axi_wvalid(m_axi_data_wvalid), 
        .m_axi_wready(m_axi_data_wready),
        
        .m_axi_bresp(m_axi_data_bresp), .m_axi_bvalid(m_axi_data_bvalid), 
        .m_axi_bready(m_axi_data_bready),
        
        .m_axi_araddr(m_axi_data_araddr), .m_axi_arlen(m_axi_data_arlen), 
        .m_axi_arsize(m_axi_data_arsize), .m_axi_arburst(m_axi_data_arburst),
        .m_axi_arvalid(m_axi_data_arvalid), .m_axi_arready(m_axi_data_arready),
        
        .m_axi_rdata(m_axi_data_rdata), .m_axi_rresp(m_axi_data_rresp), 
        .m_axi_rlast(m_axi_data_rlast), .m_axi_rvalid(m_axi_data_rvalid), 
        .m_axi_rready(m_axi_data_rready)
    );

endmodule