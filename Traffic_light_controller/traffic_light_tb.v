module traffic_controller_tb;
  
  reg clk,reset,car;
  wire [2:0] main_light,side_light;
  
  traffic_light uut(.clk(clk),.reset(reset),.car(car),.main_light(main_light),.side_light(side_light));
  
  initial clk=0;
  always #5 clk=~clk;
  
  initial begin
    
    $dumpfile("dump.vcd");
    $dumpvars(1);
    
    reset=1;car=0;#15;
    
    reset=0;#15;
    
    car=0;#50;
    
    $display("[TIMING ASSIGNMENT] Car detected at side street. Initializing transition sequence.");
    car = 1;#400;
    
    $display("[TIMING ASSIGNMENT] Side street cleared early. Checking sensor bypass loop.");
    car = 0;#100;
    
    $display("Simulation complete. Analyzing wave vector segments.");
    
    $finish;
  end
  
endmodule
