module down_timer(
  input clk,reset,load_en,
  input [31:0] load_val,
  output timer_done);
  
  reg [31:0] count;
  
  always@(posedge clk or posedge reset) begin
    if(reset) count<=0;
    else if(load_en) count<=load_val;
    else if(count>0) count<=count-1;
  end
  
  assign timer_done=(count==0);
  
endmodule

//////////////////////////////////////////////////////////

module traffic_light(
  input clk,reset,car,
  output reg [2:0] main_light,
  output reg [2:0] side_light);
  
  localparam M_GREEN=2'b00;
  localparam M_YELLOW=2'b01;
  localparam S_GREEN=2'b10;
  localparam S_YELLOW=2'b11;
  
  localparam RED=3'b100;
  localparam YELLOW=3'b010;
  localparam GREEN=3'b001;
  
  reg load_en;
  reg [31:0] load_val;
  wire timer_done;
  
  reg [1:0] cur;
  reg [1:0] next;
  //////////////////////////////////////////////////////////

  down_timer timer(.clk(clk),.reset(reset),.load_en(load_en),.load_val(load_val),.timer_done(timer_done));
  //////////////////////////////////////////////////////////

  
  always@(posedge clk or posedge reset) begin
    if(reset) cur<=M_GREEN;
    else cur<=next;
  end
  
  always@(*) begin
    
    next=cur;
    load_en=0;
    load_val=0;
    
    case(cur)
      
      M_GREEN: begin
        if(car) begin
          if(timer_done) begin
            next=M_YELLOW;
            load_en=1;
            load_val=32'd5;
          end
        end
      end
      
      M_YELLOW: begin
        if(timer_done) begin
          next=S_GREEN;
          load_en=1;
          load_val=32'd30;
        end
      end
      
      S_GREEN: begin
        if(timer_done || !car) begin
          next=S_YELLOW;
          load_en=1;
          load_val=32'd5;
        end
      end
      
      S_YELLOW: begin
        if(timer_done) begin
          next=M_GREEN;
          load_en=0;
        end
      end
      
      default: next=M_GREEN;
      
    endcase
  end
  //////////////////////////////////////////////////////////
  
  always@(*) begin
    
    case(cur)
      
      M_GREEN: begin
        main_light=GREEN;
        side_light=RED;
      end
      
      M_YELLOW: begin
        main_light=YELLOW;
        side_light=RED;
      end
      
      S_GREEN: begin
        main_light=RED;
        side_light=GREEN;
      end
      
      S_YELLOW: begin
        main_light=RED;
        side_light=YELLOW;
      end
      
      default: begin
        main_light=RED;
        side_light=RED;
      end
      
    endcase
  end
  //////////////////////////////////////////////////////////
  
  
endmodule
