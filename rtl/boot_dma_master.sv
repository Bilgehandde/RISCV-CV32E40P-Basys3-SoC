`timescale 1ns / 1ps

module boot_dma_master (
    input  logic        m_axi_aclk,
    input  logic        m_axi_aresetn,

    // AXI4-Lite Read Address
    output logic [31:0] m_axi_araddr,
    output logic        m_axi_arvalid,
    input  logic        m_axi_arready,

    // AXI4-Lite Read Data
    input  logic [31:0] m_axi_rdata,
    input  logic [1:0]  m_axi_rresp,
    input  logic        m_axi_rvalid,
    output logic        m_axi_rready,

    // AXI4-Lite Write Address
    output logic [31:0] m_axi_awaddr,
    output logic        m_axi_awvalid,
    input  logic        m_axi_awready,

    // AXI4-Lite Write Data
    output logic [31:0] m_axi_wdata,
    output logic [3:0]  m_axi_wstrb,
    output logic        m_axi_wvalid,
    input  logic        m_axi_wready,

    // AXI4-Lite Write Response
    input  logic [1:0]  m_axi_bresp,
    input  logic        m_axi_bvalid,
    output logic        m_axi_bready,

    // CPU Fetch Control
    output logic        cpu_fetch_enable
);

    typedef enum logic [2:0] {
        IDLE    = 3'd0,
        AR_SEND = 3'd1,
        R_WAIT  = 3'd2,
        AW_SEND = 3'd3,
        W_SEND  = 3'd4,
        B_WAIT  = 3'd5,
        DONE    = 3'd6
    } state_t;

    state_t state;
    localparam STOP_SIGNATURE = 32'hBDEDE000;

    logic [31:0] src_addr;
    logic [31:0] dst_addr;
    logic [31:0] temp_data;

    assign m_axi_wstrb = 4'b1111;

    always_ff @(posedge m_axi_aclk or negedge m_axi_aresetn) begin
        if (!m_axi_aresetn) begin
            state            <= IDLE;
            cpu_fetch_enable <= 1'b0;
            m_axi_arvalid    <= 1'b0;
            m_axi_rready     <= 1'b0;
            m_axi_awvalid    <= 1'b0;
            m_axi_wvalid     <= 1'b0;
            m_axi_bready     <= 1'b0;
            src_addr         <= 32'h0000_2000;
            dst_addr         <= 32'h0000_4000;
            temp_data        <= 32'd0;
        end else begin
            case (state)
                IDLE: begin
                    state <= AR_SEND;
                end

                AR_SEND: begin
                    m_axi_araddr  <= src_addr;
                    m_axi_arvalid <= 1'b1;
                    if (m_axi_arready && m_axi_arvalid) begin
                        m_axi_arvalid <= 1'b0;
                        m_axi_rready  <= 1'b1;
                        state         <= R_WAIT;
                    end
                end

                R_WAIT: begin
                    if (m_axi_rvalid && m_axi_rready) begin
                        m_axi_rready <= 1'b0;
                        if (m_axi_rdata == STOP_SIGNATURE) begin
                            state <= DONE;
                        end else begin
                            temp_data <= m_axi_rdata;
                            state     <= AW_SEND;
                        end
                    end
                end

                AW_SEND: begin
                    m_axi_awaddr  <= dst_addr;
                    m_axi_awvalid <= 1'b1;
                    // m_axi_awvalid'in 1 oldu�unu g�rmeden ve ready gelmeden ge�me
                    if (m_axi_awready && m_axi_awvalid) begin
                        m_axi_awvalid <= 1'b0;
                        state         <= W_SEND;
                    end
                end

                W_SEND: begin
                    m_axi_wdata  <= temp_data;
                    m_axi_wvalid <= 1'b1;
                    if (m_axi_wready && m_axi_wvalid) begin
                        m_axi_wvalid <= 1'b0;
                        m_axi_bready <= 1'b1;
                        state         <= B_WAIT;
                    end
                end

                B_WAIT: begin
                    if (m_axi_bvalid && m_axi_bready) begin
                        m_axi_bready <= 1'b0;
                        src_addr     <= src_addr + 4;
                        dst_addr     <= dst_addr + 4;
                        state        <= AR_SEND;
                    end
                end

                DONE: begin
                    cpu_fetch_enable <= 1'b1;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
