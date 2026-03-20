`include "enivornment.sv"
program test(intf intff);
  enivornment env;
  initial begin
    env=new(intff);
    env.run();
    $finish;
  end
endprogram
