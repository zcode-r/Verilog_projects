module async_fifo #(parameter DEPTH=8,parameter WIDTH=8)
  (input clk_w,reset_w,w_en,
   input [WIDTH-1:0] w_data,
   output full,
   
   input clk_r,reset_r,r_en,
   output [WIDTH-1:0] r_data,
   output empty);
  
  localparam BITS=$clog2(DEPTH);
  
  reg [WIDTH-1:0] fifo [DEPTH-1:0];
  
  //ptr 
  reg [BITS:0] w_ptr,r_ptr;
  
  //gray
  reg [BITS:0] w_gray,r_gray;
  
  //2FF synchronizer
  wire [BITS:0] w_2ffs,r_2ffs;
  
  
  ///////////////////////////////////////////////
  ///////////////2-FF SYNCHRONIZER///////////////
  ///////////////////////////////////////////////
  
  //write ptr into read clk domain
  reg [BITS:0] w_sync1,w_sync2;
  
  always@(posedge clk_r or posedge reset_r) begin
    if(reset_r) begin
      w_sync1<=0;
      w_sync2<=0;
    end
    else begin
      w_sync1<=w_gray;
      w_sync2<=w_sync1;
    end
  end
  
  assign w_2ffs=w_sync2;
  
  //read ptr into write clk domain
  reg [BITS:0] r_sync1,r_sync2;
  
  always@(posedge clk_w or posedge reset_w) begin
    if(reset_w) begin
      r_sync1<=0;
      r_sync2<=0;
    end
    else begin
      r_sync1<=r_gray;
      r_sync2<=r_sync1;
    end
  end
  
  assign r_2ffs=r_sync2;
  
  
  /////////////////////////////////////////////////////
  ////////////////WRITE DOMAIN & POINTERS/////////////
  /////////////////////////////////////////////////////
  
  always@(posedge clk_w or posedge reset_w) begin
    if(reset_w) w_ptr<=0;
    else begin
        if(w_en && !full) begin
        fifo[w_ptr[BITS-1:0]]<=w_data;
        w_ptr<=w_ptr+1;
      end
    end
  end
  
  always@(*) begin
    w_gray=w_ptr^(w_ptr>>1);
  end
  
  
    /////////////////////////////////////////////////////
  /////////////////READ DOMAIN & POINTERS//////////////
  /////////////////////////////////////////////////////
  
  always@(posedge clk_r or posedge reset_r) begin
    if(reset_r) r_ptr<=0;
    else begin
      if(r_en && !empty) begin
        r_ptr<=r_ptr+1;
      end
    end
  end
  
  always@(*) begin
    r_gray=r_ptr^(r_ptr>>1);
  end
  
  assign r_data=fifo[r_ptr[BITS-1:0]];
  
  
  //checking for empty and full
  assign empty=(w_2ffs==r_gray);
  assign full=(w_gray[BITS]!=r_2ffs[BITS]) && 
    (w_gray[BITS-1]!=r_2ffs[BITS-1]) &&
    (w_gray[BITS-2:0]==r_2ffs[BITS-2:0]); 
    

endmodule
