module clk_divider_tb;
  
  reg clk_in;
  reg reset;
  wire clk_out;
  
  initial clk_in=0;
  always #1 clk_in=~clk_in;
  
  clock_divider test(.clk_in(clk_in),.reset(reset),.clk_out(clk_out));
  
  initial 
    begin
      
      $dumpfile("dump.vcd");
      $dumpvars(1);
      
      reset=1;
      #10;
      reset=0;
      #200;
      
      $finish;
    end
  
endmodule
