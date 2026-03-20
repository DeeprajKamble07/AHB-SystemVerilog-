// Code your testbench here
// or browse Examples

`timescale 1ns/1ns
`include "interface.sv"
`include "test.sv"

module tb;
  logic hclk;
  intf intff(hclk);
  test tst(intff);
  
  top dut(.hclk(intff.hclk),.hrst(intff.hrst), .start(intff.start), .write_top(intff.write_top), .wrap_en(intff.wrap_en),.addr_top(intff.addr_top),. data_top(intff.data_top),.beat_length(intff.beat_length),.hrdata(intff.hrdata),.hready(intff.hready));
  
  
  assign intff.haddr= dut.haddr;
  assign intff.hwdata= dut.hwdata;
  assign intff.hwrite= dut.hwrite;
  assign intff.htrans= dut.htrans;
  assign intff.hsize= dut.hsize;
  assign intff.hburst= dut.hburst;
  
  initial begin
    hclk=0;
    forever #5 hclk=~hclk;
  end
  
  initial begin
    #5000 $finish;
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
  end
endmodule
