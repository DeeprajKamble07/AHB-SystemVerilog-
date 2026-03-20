class reference;
  transaction trans, exp;
  mailbox#(transaction) drv2rm;
  mailbox#(transaction) rm2scb;
  bit [31:0] mem[256];
  
  function new(mailbox#(transaction) drv2rm, mailbox#(transaction) rm2scb);
    this.drv2rm=drv2rm;
    this.rm2scb=rm2scb;
    foreach (mem[i]) mem[i] = 0;
  endfunction
  
  task main();
    forever begin
    drv2rm.get(trans);
    exp=new();
    exp.beat_length = trans.beat_length;
    exp.write_top=trans.write_top;
      if(trans.write_top)
        begin
          for(int i=0; i< trans.beat_length; i++)
            begin
              mem[(trans.addr_top + i*4) & 8'hFF]  = trans.data_top[i];
              $display("[REF] WRITE mem[%0h]=%0h",
                   (trans.addr_top + i*4) & 8'hFF,
                   mem[(trans.addr_top + i*4) & 8'hFF]);
            end
        end
      
      else
        begin
          for(int i=0; i< trans.beat_length; i++)
            begin
              exp.hrdata[i]=mem[(trans.addr_top + i*4) & 8'hFF];
              $display("REF READ: hrdata[%0d]=%0h",i,exp.hrdata[i]);
            end
        end
    rm2scb.put(exp);
    end
  endtask
endclass
