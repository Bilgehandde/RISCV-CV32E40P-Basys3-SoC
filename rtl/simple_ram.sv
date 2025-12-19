`timescale 1ns / 1ps

module simple_ram #(
    parameter SIZE_WORDS = 1024 // 1024 kelime = 4KB Hafýza
)(
    input  logic        clk,
    input  logic        rst_n,
    
    // Ýþlemciden gelen sinyaller
    input  logic        req_i,       // "Veri istiyorum" sinyali
    input  logic        we_i,        // "Yazma yapýcam" sinyali (0 ise Okuma)
    input  logic [31:0] addr_i,      // "Hangi adresteki veri?"
    input  logic [31:0] wdata_i,     // Yazýlacak veri
    input  logic [3:0]  be_i,        // Byte Enable (Hangi byte'larý yazalým?)
    
    // Ýþlemciye giden sinyaller
    output logic [31:0] rdata_o,     // Okunan veri
    output logic        rvalid_o     // "Veri hazýr" sinyali
);

    // 1. Hafýza Dizisi (Asýl Depo)
    // 32 bit geniþliðinde, 1024 satýrlýk bir tablo
    logic [31:0] mem [0:SIZE_WORDS-1];

    // 2. Baþlangýçta Ýçini Doldur (Yazýlýmý Yükle)
    initial begin
        // program.hex dosyasýný okuyup hafýzaya yazar
        // Bu dosyanýn projenin simülasyon klasöründe olmasý lazým!
        $readmemh("program.hex", mem);
    end

    // 3. Okuma ve Yazma Mantýðý
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rdata_o  <= 32'h0;
            rvalid_o <= 1'b0;
        end else begin
            // Varsayýlan olarak valid 0 olsun
            rvalid_o <= 1'b0;

            if (req_i) begin
                // Eðer istek varsa 1 çevrim sonra cevap ver (Synchronous RAM)
                rvalid_o <= 1'b1;

                if (we_i) begin
                    // --- YAZMA ÝÞLEMÝ ---
                    // RISC-V adresleri byte bazlýdýr (0, 4, 8...). 
                    // Ama bizim dizimiz word bazlý (0, 1, 2...). 
                    // O yüzden adresi 4'e bölüyoruz (addr_i >> 2).
                    if (be_i[0]) mem[addr_i[31:2]][7:0]   <= wdata_i[7:0];
                    if (be_i[1]) mem[addr_i[31:2]][15:8]  <= wdata_i[15:8];
                    if (be_i[2]) mem[addr_i[31:2]][23:16] <= wdata_i[23:16];
                    if (be_i[3]) mem[addr_i[31:2]][31:24] <= wdata_i[31:24];
                end else begin
                    // --- OKUMA ÝÞLEMÝ ---
                    rdata_o <= mem[addr_i[31:2]];
                end
            end
        end
    end

endmodule