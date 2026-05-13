module clock_divider#(parameter DIV=10)(input clk_in,reset,output reg clk_out);
  
  reg [31:0]counter;
  
  always@(posedge clk_in or posedge reset)
    begin
      
      if(reset)
        begin 
          clk_out<=0;
          counter<=0;
        end
      
      else
        begin
          if(counter==(DIV-1)/2)
            begin
              clk_out<=~clk_out;
              counter<=0;
            end
          else counter<=counter+1;
        end
      
    end
  
  
endmodule
