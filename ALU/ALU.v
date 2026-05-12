module ALU(input [7:0]A,B, input [2:0] ALU_Sel,output reg [15:0] out);
  
  always@(*)
    begin
      
      case(ALU_Sel)
      	3'b000: out=A+B;
        3'b001: out=A-B;
        3'b010: out=A*B;
        3'b011: out=A&B;
        3'b100: out=A|B;
        3'b101: out=A^B;
        3'b110: out=A<<B;
        3'b111: out=A>>B;
        default: out=8'b0;
      endcase
    end
  
endmodule
