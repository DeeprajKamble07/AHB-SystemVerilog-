interface intf(input logic hclk);
  logic hrst,start, write_top, wrap_en;
  logic [31:0] addr_top, data_top;
  logic [3:0] beat_length;
  logic [31:0] hrdata;
  logic hready;
  
  logic [31:0] haddr, hwdata;
  logic hwrite;
  logic [1:0] htrans;
  logic [2:0] hsize, hburst;
  
  clocking drvcb @(posedge hclk);
    output hrst, start, write_top, wrap_en, addr_top, data_top, beat_length;
    input hrdata, hready;
  endclocking
  
  clocking moncb @(posedge hclk);
    input #1  hrst, start, write_top, wrap_en, addr_top, data_top, beat_length;
    input #1 hrdata, hready;
    input #1 haddr, hwdata, hwrite, htrans;
  endclocking
  
  modport drvmod(clocking drvcb, input hclk);
  modport monmod(clocking moncb, input hclk);
endinterface
