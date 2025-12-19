`timescale 1ns / 1ps

module obi_to_axi (
    input  logic        clk,
    input  logic        rst_n,

    // ========================================================================
    // OBI ARAYÜZÜ (Ýþlemci Tarafý - Slave)
    // ========================================================================
    input  logic        obi_req_i,
    input  logic        obi_we_i,
    input  logic [3:0]  obi_be_i,
    input  logic [31:0] obi_addr_i,
    input  logic [31:0] obi_wdata_i,
    output logic        obi_gnt_o,
    output logic        obi_rvalid_o,
    output logic [31:0] obi_rdata_o,

    // ========================================================================
    // AXI4 ARAYÜZÜ (Sistem Tarafý - Master)
    // ========================================================================
    
    // --- Write Address Channel (AW) ---
    output logic [31:0] m_axi_awaddr,
    output logic [7:0]  m_axi_awlen,   // Burst Uzunluðu
    output logic [2:0]  m_axi_awsize,  // Transfer Boyutu
    output logic [1:0]  m_axi_awburst, // Burst Tipi
    output logic        m_axi_awvalid,
    input  logic        m_axi_awready,

    // --- Write Data Channel (W) ---
    output logic [31:0] m_axi_wdata,
    output logic [3:0]  m_axi_wstrb,
    output logic        m_axi_wlast,   // Paketin sonu mu?
    output logic        m_axi_wvalid,
    input  logic        m_axi_wready,

    // --- Write Response Channel (B) ---
    input  logic [1:0]  m_axi_bresp,
    input  logic        m_axi_bvalid,
    output logic        m_axi_bready,

    // --- Read Address Channel (AR) ---
    output logic [31:0] m_axi_araddr,
    output logic [7:0]  m_axi_arlen,
    output logic [2:0]  m_axi_arsize,
    output logic [1:0]  m_axi_arburst,
    output logic        m_axi_arvalid,
    input  logic        m_axi_arready,

    // --- Read Data Channel (R) ---
    input  logic [31:0] m_axi_rdata,
    input  logic [1:0]  m_axi_rresp,
    input  logic        m_axi_rlast,
    input  logic        m_axi_rvalid,
    output logic        m_axi_rready
);

    // Durum Makinesi
    typedef enum logic [1:0] { IDLE, ADDR_PHASE, DATA_PHASE, RESP_PHASE } state_t;
    state_t state, next_state;

    // AXI Sabitleri (Single Beat Transfer için)
    assign m_axi_awlen   = 8'h00; // Tek transfer (Length = 0)
    assign m_axi_awsize  = 3'b010; // 4 Byte (32 bit)
    assign m_axi_awburst = 2'b01; // INCR tipi burst
    
    assign m_axi_arlen   = 8'h00;
    assign m_axi_arsize  = 3'b010;
    assign m_axi_arburst = 2'b01;

    // Tek transfer yaptýðýmýz için her veri ayný zamanda "Son" veridir.
    assign m_axi_wlast   = 1'b1; 

    // Veri Yollarý (Direkt Baðlantý)
    assign m_axi_awaddr = obi_addr_i;
    assign m_axi_wdata  = obi_wdata_i;
    assign m_axi_wstrb  = obi_be_i;
    assign m_axi_araddr = obi_addr_i;
    
    // Cevap Yollarý
    assign obi_rdata_o  = m_axi_rdata;

    // Basit bir State Machine ile el sýkýþmalarý yönetelim
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) state <= IDLE;
        else        state <= next_state;
    end

    always_comb begin
        next_state = state;
        
        // Varsayýlan Çýkýþlar
        obi_gnt_o     = 1'b0;
        obi_rvalid_o  = 1'b0;
        
        m_axi_awvalid = 1'b0;
        m_axi_wvalid  = 1'b0;
        m_axi_arvalid = 1'b0;
        m_axi_bready  = 1'b0;
        m_axi_rready  = 1'b0;

        case (state)
            IDLE: begin
                if (obi_req_i) begin
                    // Ýþlemciden istek geldi
                    if (obi_we_i) begin
                        // Yazma Ýsteði: Adres ve Veriyi AXI'ye sür
                        m_axi_awvalid = 1'b1;
                        m_axi_wvalid  = 1'b1;
                        
                        // Eðer ikisi de hemen kabul edilirse (Ready=1)
                        if (m_axi_awready && m_axi_wready) begin
                            obi_gnt_o = 1'b1; // Ýsteði kabul ettik
                            next_state = RESP_PHASE; // Cevap bekle
                        end else begin
                            // Biri veya ikisi bekletiyor
                            next_state = DATA_PHASE; 
                        end
                    end else begin
                        // Okuma Ýsteði: Adresi AXI'ye sür
                        m_axi_arvalid = 1'b1;
                        
                        if (m_axi_arready) begin
                            obi_gnt_o = 1'b1; // Ýsteði kabul ettik
                            next_state = RESP_PHASE;
                        end else begin
                            next_state = ADDR_PHASE;
                        end
                    end
                end
            end

            // Sadece bir tarafýn (Adres veya Veri) kabul edilmesini bekleyen ara durumlar
            // (Bu basit kodda karmaþýklýðý önlemek için "IDLE"da hepsini deniyoruz, 
            // olmazsa burada bekliyoruz)
            DATA_PHASE: begin 
                // Yazma durumunda buraya düþtüysek, ya AW ya W kabul edilmedi demektir.
                // Basitlik için burada tekrar ikisini de deniyoruz (AXI spec'ine uygun hale getirilebilir)
                // Amaç: Her iki ready gelene kadar bekle.
                m_axi_awvalid = 1'b1;
                m_axi_wvalid  = 1'b1;
                if (m_axi_awready && m_axi_wready) begin
                    obi_gnt_o = 1'b1;
                    next_state = RESP_PHASE;
                end
            end

            ADDR_PHASE: begin
                // Okuma durumunda adresin kabul edilmesini bekle
                m_axi_arvalid = 1'b1;
                if (m_axi_arready) begin
                    obi_gnt_o = 1'b1;
                    next_state = RESP_PHASE;
                end
            end

            RESP_PHASE: begin
                if (obi_we_i) begin
                    // Yazma cevabý (B) bekle
                    m_axi_bready = 1'b1;
                    if (m_axi_bvalid) begin
                        // Yazma bitti
                        // obi_rvalid_o genelde yazma için gerekmez ama opsiyoneldir.
                        next_state = IDLE;
                    end
                end else begin
                    // Okuma cevabý (R) ve verisi bekle
                    m_axi_rready = 1'b1;
                    if (m_axi_rvalid) begin
                        obi_rvalid_o = 1'b1; // Veriyi iþlemciye ver
                        next_state = IDLE;
                    end
                end
            end
        endcase
    end

endmodule