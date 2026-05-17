module stop_watch_tb;
  
  reg clk;
  reg reset;
  wire [6:0]seg;
  wire [1:0]digital_sel;
  
  initial clk=0;
  always #1 clk= ~clk;
  
  stop_watch u_sw(.fast_clk(clk),.reset(reset),.seg(seg),.digital_sel(digital_sel));
  
  initial 
    begin
      $dumpfile("dump.vcd");
      $dumpvars(1,stop_watch_tb);
      
      reset=1;
      #10;
      
      reset=0;
      #400;
      
      $finish;
    end
  
endmodule
