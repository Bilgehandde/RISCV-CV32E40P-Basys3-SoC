`timescale 1ns / 1ps

module boot_dma_master_wrapper (
    input  wire m_axi_aclk,
    input  wire m_axi_aresetn,

    // ===============================
    // AXI4-Lite Master Interface
    // ===============================
    output wire [31:0] m_axi_awaddr,
    output wire        m_axi_awvalid,
    input  wire        m_axi_awready,

    output wire [31:0] m_axi_wdata,
    output wire [3:0]  m_axi_wstrb,
    output wire        m_axi_wvalid,
    input  wire        m_axi_wready,

    input  wire [1:0]  m_axi_bresp,
    input  wire        m_axi_bvalid,
    output wire        m_axi_bready,

    output wire [31:0] m_axi_araddr,
    output wire        m_axi_arvalid,
    input  wire        m_axi_arready,

    input  wire [31:0] m_axi_rdata,
    input  wire [1:0]  m_axi_rresp,
    input  wire        m_axi_rvalid,
    output wire        m_axi_rready,

    // CPU kontrol
    output wire        cpu_fetch_enable
);

    // Alt DMA modülü - birebir baðlanýr
    boot_dma_master dma_i (
        .m_axi_aclk        (m_axi_aclk),
        .m_axi_aresetn     (m_axi_aresetn),

        .m_axi_awaddr      (m_axi_awaddr),
        .m_axi_awvalid     (m_axi_awvalid),
        .m_axi_awready     (m_axi_awready),

        .m_axi_wdata       (m_axi_wdata),
        .m_axi_wstrb       (m_axi_wstrb),
        .m_axi_wvalid      (m_axi_wvalid),
        .m_axi_wready      (m_axi_wready),

        .m_axi_bresp       (m_axi_bresp),
        .m_axi_bvalid      (m_axi_bvalid),
        .m_axi_bready      (m_axi_bready),

        .m_axi_araddr      (m_axi_araddr),
        .m_axi_arvalid     (m_axi_arvalid),
        .m_axi_arready     (m_axi_arready),

        .m_axi_rdata       (m_axi_rdata),
        .m_axi_rresp       (m_axi_rresp),
        .m_axi_rvalid      (m_axi_rvalid),
        .m_axi_rready      (m_axi_rready),

        .cpu_fetch_enable  (cpu_fetch_enable)
    );

endmodule
