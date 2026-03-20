class transaction;
  typedef enum logic [1:0] {write, read} state_t;
  rand state_t op;
  rand logic start, write_top, wrap_en;
  rand logic [31:0] addr_top;
  rand logic [31:0] data_top[4];
  rand logic [3:0] beat_length;
  logic [31:0] hrdata[4];
  logic hready;
  
  constraint c1{if(write_top==0) {foreach(data_top[i]) data_top[i]==32'h0;}}
endclass             
