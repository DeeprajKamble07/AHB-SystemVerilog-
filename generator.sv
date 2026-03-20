class generator;
  transaction trans;
  mailbox #(transaction) gen2drv;

  function new(mailbox#(transaction) gen2drv);
    this.gen2drv = gen2drv;
  endfunction

  task main();
    trans = new();
    trans.randomize() with {write_top==1; start==1; wrap_en==0; beat_length==4; addr_top==32'h38;};
    
    trans.op = transaction::write;
    $display("GEN WRITE: write_top=%0b addr_top=%0h",trans.write_top,trans.addr_top);
    foreach(trans.data_top[i])
      $display("[GEN]   data_top[%0d] addr=%0h  data=%0h",
               i, (trans.addr_top + i*4) & 8'hFF, trans.data_top[i]);
    gen2drv.put(trans);
    
    
    trans = new();
    trans.randomize() with {write_top==0; start==1; wrap_en==0; beat_length==4; addr_top==32'h38;};
    trans.op = transaction::read;
    $display("[GEN] READ   write_top=%0b  addr_top=%0h", trans.write_top, trans.addr_top);
    gen2drv.put(trans);
  endtask
  
endclass
