`timescale 1ns/1ps

module tb_design_1_wrapper_selfcheck;

    // -------------------------------------------------
    // Saat ve Reset (100 MHz)
    // -------------------------------------------------
    logic sys_clock;
    logic reset;

    always #5 sys_clock = ~sys_clock; 

    initial begin
        sys_clock = 0;
        reset     = 1;
        #200;
        reset     = 0;
        $display("[TB] %t | Reset birakildi. Sistem basliyor...", $time);
    end

    // -------------------------------------------------
    // DUT (Design Under Test)
    // -------------------------------------------------
    design_1_wrapper uut (
        .sys_clock(sys_clock),
        .reset(reset),
        .rx_0(1'b1),
        .tx_0(),
        .leds_16bits_tri_o()
    );

    // -------------------------------------------------
    // DO�RULANMI� S�NYAL YOLLARI (Senin payla�t���n yollar)
    // -------------------------------------------------
    
    // PC (Program Counter) - En kritik sinyal
    wire [31:0] cpu_pc = uut.design_1_i.cv32e40p_axi_top_0.inst.u_core.core_i.pc_id;

    // ��lemcinin o an i�ledi�i instruction
    wire [31:0] cpu_instr = uut.design_1_i.cv32e40p_axi_top_0.inst.u_core.core_i.id_stage_i.instr_rdata_i;

    // DMA Bitti mi? (��lemciye giden izin sinyali)
    wire dma_done = uut.design_1_i.boot_dma_master_wrap_0.inst.cpu_fetch_enable;

    // AXI Eri�im Takibi (BRAM Controller'lar �zerinden)
    wire qspi_access  = uut.design_1_i.ctrl_qspi_flash.s_axi_arvalid;
    wire imem_access  = uut.design_1_i.ctrl_instr.s_axi_arvalid;
    wire rom_access   = uut.design_1_i.ctrl_ROM.s_axi_arvalid;

    // LSU (Load Store Unit) Takibi
    wire [31:0] lsu_addr = uut.design_1_i.cv32e40p_axi_top_0.inst.u_core.core_i.load_store_unit_i.data_addr_o;

    // -------------------------------------------------
    // MONITORING & LOGGING LOGIC
    // -------------------------------------------------
    initial begin
        wait(reset == 0);
        $display("[STATUS] %t | Sistem aktif, DMA bekleniyor...", $time);
        
        // 1. DMA Kontrol�
        fork
            begin
                wait(qspi_access);
                $display("[DMA] %t | OK: QSPI Flash (0x2000) okunuyor...", $time);
            end
            begin
                wait(dma_done);
                $display("--------------------------------------------------");
                $display("[DMA] %t | SUCCESS: DMA Kopyalama Islemi Bitti!", $time);
                $display("--------------------------------------------------");
            end
        join_any

        // 2. CPU Boot ve Jump Kontrol�
        forever begin
            @(posedge sys_clock);
            // Sadece bir �eyler de�i�ti�inde log yaz (kalabal�k yapmas�n)
            if (dma_done && imem_access) begin
                $display("[CPU] %t | PC: 0x%h | Instr: 0x%h | LSU_Addr: 0x%h", 
                         $time, cpu_pc, cpu_instr, lsu_addr);
                
                // E�er PC 0x4000 (IMem) adresine ula�t�ysa LED kodu ba�lam��t�r
                if (cpu_pc >= 32'h4000 && cpu_pc < 32'h6000) begin
                    $display("==================================================");
                    $display("[SUCCESS] %t | CPU Uygulama Koduna (0x4000) Girdi!", $time);
                    $display("==================================================");
                    #2000; $finish;
                end
            end
        end
    end

    // -------------------------------------------------
    // TIMEOUT (Sistem kilitlenirse)
    // -------------------------------------------------
    initial begin
        #1_000_000; // 1 ms s�re veriyoruz
        $display("\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        $display("[FAIL] %t | TIMEOUT: Sistem 0x4000'e ulasamadi!", $time);
        $display("[INFO] Son PC: 0x%h", cpu_pc);
        $display("[INFO] Son Instr: 0x%h", cpu_instr);
        $display("[INFO] DMA Durumu: %b", dma_done);
        $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
        $finish;
    end

endmodule
