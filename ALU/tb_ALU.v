module tb_ALU;
  
  reg [7:0] A,B;
  reg [2:0] Sel;
  wire [15:0] out;
  
  ALU test(.A(A),.B(B),.ALU_Sel(Sel),.out(out));
  
  initial begin
    
    $dumpfile("dump.vcd"); 
    $dumpvars(1);
    
    A=8'd10; B=8'd5; Sel=3'b000;
    
    #10;
    $display("Testing: Sel=%b%b%b A=%d, B=%d, Result=%d",Sel[2],Sel[1],Sel[0],A,B,out);
    #10;
    
    A = 8'd20; B = 8'd8; Sel = 3'b001;
    
    #10;
    $display("Testing: Sel=%b%b%b A=%d, B=%d, Result=%d",Sel[2],Sel[1],Sel[0],A,B,out);
    #10;
    
    A = 8'd10; B = 8'd10; Sel = 3'b010;
    
    #10;
    $display("Testing: Sel=%b%b%b A=%d, B=%d, Result=%d",Sel[2],Sel[1],Sel[0],A,B,out);
    #10;
    $finish;
  end
endmodule
