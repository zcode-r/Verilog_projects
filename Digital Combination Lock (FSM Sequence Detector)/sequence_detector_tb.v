module combinational_lock_tb;
  
  reg clk,reset,keypressed;
  reg [3:0] key;
  wire unlock;
  
  initial clk=0;
  always #5 clk=~clk;
  
  combinational_lock uut(.clk(clk),.reset(reset),.keypressed(keypressed),.key(key),.unlock(unlock));
  
  initial begin
    
    $dumpfile("dump.vcd");
    $dumpvars(1);
    
    reset = 1;
    keypressed = 0;
    key = 4'd0;
    #15;
    
    reset = 0;
    #10;

    key = 4'd2; keypressed = 1; #10; keypressed = 0; #10;
    key = 4'd3; keypressed = 1; #10; keypressed = 0; #10;
    key = 4'd9; keypressed = 1; #10; keypressed = 0; #10;
    
    #30; 
    
    key = 4'd2; keypressed = 1; #10; keypressed = 0; #10;
    key = 4'd3; keypressed = 1; #10; keypressed = 0; #10;
    key = 4'd5; keypressed = 1; #10; keypressed = 0; #10;

    key = 4'd7; keypressed = 1; #10; keypressed = 0; #10;

    #50;
    $finish;
  end
  
endmodule
