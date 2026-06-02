module combinational_lock(input clk,reset,keypressed,input [3:0] key,output reg unlock);
  
  localparam idle=2'b00;
  localparam got_2=2'b01;
  localparam got_23=2'b10;
  localparam got_235=2'b11;
  
  reg [1:0] cur;
  reg [1:0] next;
  
  always@(posedge clk or posedge reset)
    begin
      if(reset) cur<=idle;
      else cur<=next;
    end
  
  always@(*)
    begin
      
      next=cur;
      
      case(cur)
        
        idle: begin
          if(keypressed) begin
            if(key==4'd2) next=got_2;
            else next=idle;
          end
        end
        
        got_2: begin
          if(keypressed) begin
            if(key==4'd3) next=got_23;
            else next=idle;
          end
        end
        
        got_23: begin
          if(keypressed) begin
            if(key==4'd5) next=got_235;
            else next=idle;
          end
        end
        
        got_235: begin
          if(keypressed)begin
            next=idle;
          end
        end
        
        default: next=idle;
      endcase
    end
  
  always@(*) begin
    if(cur==got_235) unlock=1'b1;
    else unlock=1'b0;
  end
  
endmodule
