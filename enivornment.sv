`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "reference.sv"
`include "scoreboard.sv"

class enivornment;
  generator gen;
  driver drv;
  monitor mon;
  reference reff;
  scoreboard scb;
  
  mailbox#(transaction) gen2drv;
  mailbox#(transaction) drv2scb;
  mailbox#(transaction) drv2rm;
  mailbox#(transaction) mon2scb;
  mailbox#(transaction) rm2scb;
  
  virtual intf vif;
  
  function new(virtual intf vif);
    this.vif=vif;
    gen2drv=new();
    drv2scb=new();
    drv2rm=new();
    mon2scb=new();
    rm2scb=new();
    
    gen=new(gen2drv);
    drv=new(vif,gen2drv,drv2scb,drv2rm);
    mon=new(vif,mon2scb);
    reff=new(drv2rm,rm2scb);
    scb=new(rm2scb,mon2scb);
  endfunction
  
  task run();
    fork
      gen.main();
      drv.main();
      mon.main();
      reff.main();
      scb.main();
    join_any
    wait(scb.trans_count>=2);
    #50;
    scb.report();
  endtask
endclass
