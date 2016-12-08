`timescale 1ns/1ns
`include "./env.sv"

module init_test();
   env_m env();
   init_test_p init_test();
endmodule

program init_test_p();
   initial begin
      env.run();
   end
endprogram

