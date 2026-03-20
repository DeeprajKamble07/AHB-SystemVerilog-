module ahb_master(input hclk, hrst, start, write_top, wrap_en, hready,
                  input [31:0] addr_top, data_top,
                  input [3:0]  beat_length,
                  output logic [31:0] haddr, hwdata,
                  output logic hwrite,
                  output logic [2:0]  hsize, hburst,
                  output logic [1:0]  htrans);


  logic [31:0] fifo[0:3];
  logic [2:0] wptr;
  logic filling;
  
  always @(posedge hclk or posedge hrst)
    begin
      if(hrst)
        begin
          wptr<=0;
          filling<=0;
        end
      else
        begin
          if(start && write_top)
            begin
              fifo[0]<=data_top;
              $display("MASTER BUF WRITE slot=0 data=%0h", data_top);
              wptr<=1;
              filling<=(beat_length>1);
            end
          else if(filling)
            begin
              fifo[wptr]<=data_top;
              $display("MASTER BUF WRITE slot=%0d data=%0h", wptr, data_top);
              if(wptr==beat_length-1)
                begin
                  filling<=0;
                end
              wptr<=wptr+1;
            end
        end
    end



  typedef enum logic [1:0] {IDLE, ADDR, DATA} state_t;
  state_t state,next;
  
  logic  [3:0] beat_count;
  logic  [3:0] addr_beat;
  logic  [31:0] addr_reg;
  logic  [2:0] rptr;

always @(posedge hclk or posedge hrst)
  begin
    if(hrst)
      begin
        state <= IDLE;
      end
    else
      begin
        state <= next;
      end
  end
  
  always_comb
    begin
      next = state;
    case(state)
      IDLE: begin
        if(start)
          begin
            next = ADDR;
          end
      end
      
      ADDR: begin
        if(hready)
          begin
            next = DATA;
          end
      end
      
      DATA: begin
        if(hready)
          begin
            if(beat_count == beat_length-1)
              begin
                next = IDLE;
              end
            else
              begin
                next = ADDR;
              end
          end
      end
    endcase
  end
  
  always @(posedge hclk or posedge hrst)
    begin
      if(hrst)
        begin
          haddr  <= 0;
		  hwdata <= 0;
          hwrite <= 0;
          htrans <= 2'b00;
          hsize  <= 3'b010;
          hburst <= 3'b011;
          beat_count <= 0;
          addr_beat<=0;
          addr_reg   <= 0;
          rptr       <= 0;
        end
      else
        begin
          case(state)
            IDLE: begin
              htrans <= 2'b00;
              hwrite<=0;
              haddr<=0;
              hwdata<=0;
              if(start)
                begin
                  addr_reg <= addr_top;
                  beat_count <= 0;
                  addr_beat<=0;
                  rptr<=0;
                end
            end
            
            ADDR: begin
              if(hready)
                begin
                  haddr  <= addr_reg;
                  hwrite<=write_top;
                  htrans <=(addr_beat==0)? 2'b10: 2'b11;
                  addr_reg<=addr_reg +4;
                  addr_beat<=addr_beat+1;
                end
            end
            
            DATA: begin
              if(hready)
                begin
                  if(write_top)
                    begin
                      hwdata <= fifo[rptr];
                      $display("MASTER SEND DATA slot=%0d data=%h", rptr, fifo[rptr]);
                      rptr   <= rptr + 1;
                    end
                  beat_count <= beat_count + 1;
                  if(beat_count==beat_length-1)
                    begin
                      htrans<=0;
                      hwrite<=0;
                    end
                end
            end
          endcase
        end
    end
endmodule



module ahb_slave(
input hclk, hrst,
input [31:0] haddr, hwdata,
input hwrite,
input [2:0] hsize, hburst,
input [1:0] htrans,
output logic  [31:0] hrdata,
output logic  hready
);

logic [31:0] mem [0:255];

logic [31:0] addr_reg;
logic write_reg;
logic valid_reg;



always @(posedge hclk or posedge hrst)
begin
    if(hrst)
    begin
        addr_reg <= 0;
        write_reg <= 0;
        valid_reg <= 0;
        hrdata <= 0;
        hready <= 1;

      for(int i=0;i<256;i=i+1)
            mem[i] <= 0;
    end
    else
    begin
        hready <= 1;
      
            if(valid_reg)
            begin
                if(write_reg)
                begin
                  mem[addr_reg[7:0]] <= hwdata;
                    $display("SLAVE WRITE addr=%h data=%h",addr_reg,hwdata);
                end
                else
                begin
                  hrdata <= mem[addr_reg[7:0]];
                  $display("SLAVE READ addr=%h data=%h",addr_reg,mem[addr_reg[7:0]]);
                end
            end

        
      if(htrans==2'b10 || htrans==2'b11)
            begin
                addr_reg  <= haddr;
                write_reg <= hwrite;
                valid_reg <= 1;
            end
            else
                valid_reg <= 0;
    end
  end
endmodule
                              
module top(
input hclk, hrst, start, write_top, wrap_en,
input [31:0] addr_top, data_top,
input [3:0]  beat_length,
output logic  [31:0] hrdata,
output logic hready
);

logic [31:0] haddr, hwdata;
logic hwrite;
logic [2:0] hsize, hburst;
logic [1:0] htrans;

ahb_master a1(
.hclk(hclk),
.hrst(hrst),
.start(start),
.write_top(write_top),
.wrap_en(wrap_en),
.hready(hready),
.addr_top(addr_top),
.data_top(data_top),
.beat_length(beat_length),
.haddr(haddr),
.hwdata(hwdata),
.hwrite(hwrite),
.hsize(hsize),
.hburst(hburst),
.htrans(htrans)
);

ahb_slave a2(
.hclk(hclk),
.hrst(hrst),
.haddr(haddr),
.hwdata(hwdata),
.hwrite(hwrite),
.hsize(hsize),
.hburst(hburst),
.htrans(htrans),
.hrdata(hrdata),
.hready(hready)
);

endmodule
