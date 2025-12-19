//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
//Date        : Fri Dec 19 22:14:42 2025
//Host        : Bilgehan running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (interrupt_0,
    leds_16bits_tri_o,
    reset,
    rx_0,
    sys_clock,
    tx_0);
  output interrupt_0;
  output [15:0]leds_16bits_tri_o;
  input reset;
  input rx_0;
  input sys_clock;
  output tx_0;

  wire interrupt_0;
  wire [15:0]leds_16bits_tri_o;
  wire reset;
  wire rx_0;
  wire sys_clock;
  wire tx_0;

  design_1 design_1_i
       (.interrupt_0(interrupt_0),
        .leds_16bits_tri_o(leds_16bits_tri_o),
        .reset(reset),
        .rx_0(rx_0),
        .sys_clock(sys_clock),
        .tx_0(tx_0));
endmodule
