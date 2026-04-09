class coverage;
  virtual intf.monmod vif;
  
  covergroup cg @(posedge vif.hclk);
    
    cp_write: coverpoint vif.moncb.hwrite{bins write={1};
                                          bins read={0};}
    
    cp_burst: coverpoint vif.moncb.hburst{bins single={3'b000};
                                          bins incr={3'b001};
                                          bins wrap4={3'b010};
                                          bins incr4={3'b011};}
    
    cp_htrans: coverpoint vif.moncb.htrans{bins idle={2'b00};
                                           bins busy={2'b01};
                                           bins seq={2'b10};
                                           bins non_seq={2'b11};}
    
    cp_addr: coverpoint vif.moncb.haddr[7:0]{bins low={[0:63]};
                                             bins mid={[64:127]};
                                             bins high={[128:255]};}
    
    cp_write_x_cp_burst: cross cp_write, cp_burst;
  endgroup
  
  function new(virtual intf.monmod vif);
    this.vif=vif;
    cg=new();
  endfunction
  
endclass
