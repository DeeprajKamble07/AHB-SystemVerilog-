class monitor;
  virtual intf.monmod vif;
  transaction trans;
  mailbox#(transaction) mon2scb;
  function new(virtual intf.monmod vif, mailbox#(transaction) mon2scb);
    this.vif=vif;
    this.mon2scb=mon2scb;
  endfunction
  
  task main();
 forever begin
   @(vif.moncb);

   if(vif.moncb.htrans==2'b10)
   begin
     trans = new();
     trans.addr_top = vif.moncb.haddr;
     trans.write_top = vif.moncb.hwrite;
     trans.beat_length = vif.moncb.beat_length;
     trans.hready = vif.moncb.hready;
     
     for(int i=0; i< trans.beat_length; i++)
       begin
         @(vif.moncb);
         while(vif.moncb.hready != 1'b1) @(vif.moncb);
           
         if(trans.write_top)
           begin
             trans.data_top[i] = vif.moncb.hwdata;
             $display("[MON] WRITE beat[%0d]  addr=%0h  hwdata=%0h",
                     i, (trans.addr_top + i*4) & 8'hFF, trans.data_top[i]);
           end
         else
           begin
             @(vif.moncb);
             trans.hrdata[i]=vif.moncb.hrdata;
             $display("[MON] READ  beat[%0d]  addr=%0h  hrdata=%0h",
                     i, (trans.addr_top + i*4) & 8'hFF, trans.hrdata[i]);
           end
       end
     mon2scb.put(trans);
   end
 end
  endtask
endclass
