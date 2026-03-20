class driver;
  virtual intf.drvmod vif;
  transaction trans;
  mailbox#(transaction) gen2drv;
  mailbox#(transaction) drv2scb;
  mailbox#(transaction) drv2rm;
  
  function new(virtual intf.drvmod vif, mailbox#(transaction) gen2drv, mailbox#(transaction) drv2scb, mailbox#(transaction) drv2rm);
    this.vif=vif;
    this.gen2drv=gen2drv;
    this.drv2scb=drv2scb;
    this.drv2rm=drv2rm;
  endfunction
  
  task rst_phase();
    vif.drvcb.hrst<=1;
    vif.drvcb.start<=0;
    vif.drvcb.write_top<=0;
    vif.drvcb.wrap_en<=0;
    vif.drvcb.addr_top<=0;
    vif.drvcb.data_top<=0;
    vif.drvcb.beat_length<=0;
    repeat(5) @(vif.drvcb);
    vif.drvcb.hrst<=0;
    @(vif.drvcb);
  endtask
  
  task main();
    rst_phase();
    forever begin
    gen2drv.get(trans);
    send(trans);
    drv2scb.put(trans);
    drv2rm.put(trans);
      $display("DRV: write_top=%0b addr_top=%0h",trans.write_top,trans.addr_top);
      foreach(trans.data_top[i])
        $display("[DRV]   data_top[%0d]=%0h", i, trans.data_top[i]);
    end
  endtask
  
  task send(transaction trans);
    logic is_write;
    is_write=(trans.op==transaction::write);
    
    vif.drvcb.addr_top<=trans.addr_top;
    vif.drvcb.beat_length<=trans.beat_length;
    vif.drvcb.write_top <= is_write;
    vif.drvcb.data_top    <= (is_write ? trans.data_top[0] : 32'h0);
    vif.drvcb.start<=1;
    
    @(vif.drvcb);
    vif.drvcb.start<=0;
    
    if(is_write)
      begin
        for(int i=1; i< trans.beat_length; i++)
        begin
        vif.drvcb.data_top<=trans.data_top[i];
          @(vif.drvcb);
        end
      end
    repeat(trans.beat_length * 2 + 2)
      @(vif.drvcb);
  endtask
endclass
