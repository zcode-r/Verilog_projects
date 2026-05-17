module seven_seg_dis(input [3:0]binary_in,output reg [6:0]out);
  
  always@(*)
    begin
      case(binary_in)
        4'b0000: out=7'b0111111;
        4'b0001: out=7'b0000110;
        4'b0010: out=7'b1011011;
        4'b0011: out=7'b1001111;
        4'b0100: out=7'b1100110;
        4'b0101: out=7'b1101101;
        4'b0110: out=7'b1111101;
        4'b0111: out=7'b0000111;
        4'b1000: out=7'b1111111;
        4'b1001: out=7'b1101111;
        default: out=7'b0000000;
      endcase
    end
  
endmodule



module counter(input clk,reset,output reg [3:0]count_ones,count_tens);
  
  always@(posedge clk or posedge reset)
    begin
      if(reset)
        begin
          count_ones<=0;
          count_tens<=0;
        end
      else 
        begin
          if(count_ones==4'd9)
            begin
              count_ones<=0;
              if(count_tens==4'd9) count_tens<=0;
              else count_tens<=count_tens+1;
            end
          else count_ones<=count_ones+1;
        end
    end
endmodule


module clk_div#(parameter div=10)(input clk,reset,output reg clk_out);
  
  reg [31:0]count;
  
  always@(posedge clk or posedge reset)
    begin
      if(reset)
        begin
          count<=0;
          clk_out<=0;
        end
      else 
        begin
          if(count==(div-1)/2)
            begin
              clk_out<=~clk_out;
              count<=0;
            end
          else count<=count+1;
        end
    end
  
endmodule


module stop_watch(input fast_clk,reset,output [6:0]seg,output reg [1:0]digital_sel);
  
  wire w_clk;
  wire [3:0] w_ones;
  wire [3:0] w_tens;
  reg [3:0] w_mux;
  reg refresh_bit;
  
  clk_div #(.div(10)) u_div(.clk(fast_clk),.reset(reset),.clk_out(w_clk));
  
  counter u_counter(.clk(w_clk),.reset(reset),.count_ones(w_ones),.count_tens(w_tens));
  
  always@(posedge fast_clk or posedge reset)
    begin
      if(reset) refresh_bit<=0;
      else refresh_bit<= ~refresh_bit;
    end
  
  always@(*)
    begin
      if(refresh_bit==1'b0)
        begin 
          w_mux=w_ones;
          digital_sel=2'b01;
        end
      else
        begin
          w_mux=w_tens;
          digital_sel=2'b10;
        end
    end
  
  seven_seg_dis u_seven(.binary_in(w_mux),.out(seg));
  
endmodule
