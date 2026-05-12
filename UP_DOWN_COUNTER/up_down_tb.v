module tb_updowncounter;
  
  reg clk;
  initial clk=0;
  always #5 clk=~clk;
  
  reg reset,up_down;
  wire [3:0]out;
  
  up_down_counter test(.clk(clk),.reset(reset),.up_down(up_down),.out(out));
  
  initial 
    begin
      $dumpfile("dump.vcd");
      $dumpvars(1);
      
      reset=1; up_down=1;
      #15;
      
      reset=0;
      #100;
      
      up_down=0;
      #50;
      
      $finish;
    end
      
endmodule
