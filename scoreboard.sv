class scoreboard;
  transaction act, exp;
  mailbox#(transaction) rm2scb;
  mailbox#(transaction) mon2scb;
  int pass_count, fail_count, trans_count;
  
  function new(mailbox#(transaction) rm2scb, mailbox#(transaction) mon2scb);
    this.rm2scb=rm2scb;
    this.mon2scb=mon2scb;
    pass_count= 0;
    fail_count= 0;
    trans_count= 0;
  endfunction
  
  task main();
     forever begin
      rm2scb.get(exp);
      mon2scb.get(act);
      trans_count++;
       
      $display("[SCB] --- comparison (trans %0d) ---", trans_count);
       
       if(act.write_top)
         begin
           $display("[SCB] WRITE transaction — no read comparison needed");
         end
       else
         begin
           for(int i=0; i<exp.beat_length; i++)
             begin
               if(exp.hrdata[i]==act.hrdata[i])
                 begin
                   $display("PASS : Beat %0d Expected=%0h Actual=%0h",
                    i, exp.hrdata[i], act.hrdata[i]);
                   pass_count++;
                 end
               else
                 begin
                   $display("FAIL : Beat %0d Expected=%0h Actual=%0h",
                    i, exp.hrdata[i], act.hrdata[i]);
                   fail_count++;
                 end
             end
         end
     end
  endtask
  function void report();
    $display("\n========================================");
    $display("  SCOREBOARD SUMMARY");
    $display("  PASS: %0d   FAIL: %0d", pass_count, fail_count);
    if (fail_count == 0)
      $display("  *** ALL TESTS PASSED ***");
    else
      $display("  *** TESTS FAILED ***");
    $display("========================================\n");
  endfunction
endclass
