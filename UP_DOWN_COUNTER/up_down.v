module up_down_counter#(parameter WIDTH=4)(input clk,reset,up_down,output reg [WIDTH-1:0]out);
  
  always@(posedge clk or posedge reset)
    begin
      
      if(reset) out<={WIDTH{1'b0}};
      else
        begin
          if(up_down) out<=out+1;
          else out<=out-1;
        end
      
    end
      
endmodule
