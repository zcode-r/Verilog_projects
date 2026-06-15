module spi #(parameter WIDTH=8)
  (
    input clk,
    input reset,
    
    input [WIDTH-1:0] master_tx_data,
    input [1:0] target_slave,
    input start,
    output [WIDTH-1:0] master_rx_data,
    output ready,
    
    input [WIDTH-1:0] slave0_tx_data,
    input [WIDTH-1:0] slave1_tx_data,
    input [WIDTH-1:0] slave2_tx_data,
    
    output [WIDTH-1:0] slave0_rx_data,
    output [WIDTH-1:0] slave1_rx_data,
    output [WIDTH-1:0] slave2_rx_data,
    output slave0_done,
    output slave1_done,
    output slave2_done
  );
  
  wire sclk_bus;
  wire mosi_bus;
  wire miso_bus;
  wire [2:0] ss_bus;
  
  spi_master #(.WIDTH(WIDTH)) master_inst (
    .clk(clk),
    .reset(reset),
    .tx_data(master_tx_data),
    .slave(target_slave),
    .start(start),
    .rx_data(master_rx_data),
    .ready(ready),
    .sclk(sclk_bus),
    .mosi(mosi_bus),
    .miso(miso_bus),
    .ss(ss_bus)
  );
  
  spi_slave #(.WIDTH(WIDTH)) slave0_inst (
    .sclk(sclk_bus),
    .mosi(mosi_bus),
    .miso(miso_bus),
    .ss(ss_bus[0]),
    .tx_data(slave0_tx_data),
    .rx_data(slave0_rx_data),
    .rx_done(slave0_done)
  );
  
  spi_slave #(.WIDTH(WIDTH)) slave1_inst (
    .sclk(sclk_bus),
    .mosi(mosi_bus),
    .miso(miso_bus),
    .ss(ss_bus[1]),
    .tx_data(slave1_tx_data),
    .rx_data(slave1_rx_data),
    .rx_done(slave1_done)
  );

  spi_slave #(.WIDTH(WIDTH)) slave2_inst (
    .sclk(sclk_bus),
    .mosi(mosi_bus),
    .miso(miso_bus),
    .ss(ss_bus[2]),
    .tx_data(slave2_tx_data),
    .rx_data(slave2_rx_data),
    .rx_done(slave2_done)
  );
  
endmodule


//MASTER MODULE
module spi_master #(parameter WIDTH=8) 
  (
    input clk,reset,
    input [WIDTH-1:0] tx_data,
    input [1:0] slave,
    input start,
    output reg [WIDTH-1:0] rx_data,
    output reg ready,
    
    output reg sclk,
    output reg mosi,
    input miso,
    output reg [2:0] ss
  );
  
  localparam IDLE=2'b00;
  localparam START=2'b01;
  localparam TRANSFER=2'b10;
  localparam STOP=2'b11;
  
  reg [1:0] state;
  
  reg [3:0] count;
  reg [2:0] bit_count;
  reg [WIDTH-1:0] shift_tx_data;
  reg [WIDTH-1:0] shift_rx_data;
  
  localparam clk_div=5;
  
  
  
  always@(*) begin
    if(state==IDLE) ss=3'b111;
    else begin
      case(slave)
        2'b00: ss=3'b110;
        2'b01: ss=3'b101;
        2'b10: ss=3'b011;
        default: ss=3'b111;
      endcase
    end
  end
  
  
  
  always@(posedge clk or posedge reset) begin
    if(reset) begin
      state<=IDLE;
      count<=0;
      bit_count<=0;
      shift_tx_data<=0;
      shift_rx_data<=0;
      rx_data<=0;
      sclk<=0;
      mosi<=0;
      ready<=1;
    end
    else begin
      
      case(state) 
        //STATE:IDLE
        IDLE: begin
          sclk<=0;
          mosi<=0;
          count<=0;
          bit_count<=0;
          ready<=1;
          
          if(start) begin
            ready<=0;
            shift_tx_data<=tx_data;
            state<=START;
          end
        end
        
        
        //STATE:START    
        START: begin
          mosi<=shift_tx_data[WIDTH-1];
          
          if(count==clk_div-1) begin
            count<=0;
            state<=TRANSFER;
          end
          else count<=count+1;
        end
        
        
        //STATE:TRANSFER
        TRANSFER: begin
          if(count==clk_div-1) begin
            count<=0;
            sclk<=~sclk;
            
            if(sclk==1) begin
              if(bit_count==WIDTH-1) begin
                sclk<=0;
                state<=STOP;
              end
              else begin
                bit_count<=bit_count+1;
                shift_tx_data<=shift_tx_data<<1;
                mosi<=shift_tx_data[WIDTH-2];
            end              
          end
            else begin
              shift_rx_data<={shift_rx_data[WIDTH-2:0],miso};
            end
            
          end
          else count<=count+1;
        end
          
        
        //STATE:STOP
          STOP: begin
            mosi<=0;
            rx_data<=shift_rx_data;
            
            if(count==clk_div-1) begin
              count<=0;
              state<=IDLE;
            end
            else count<=count+1;
          end
          
          default: state<=IDLE;
        
      endcase
    end
  end
      
endmodule


//SLAVE MODULE
module spi_slave #(parameter WIDTH=8) 
  (
    input sclk,
    input mosi,
    output reg miso,
    input ss,
    
    input [WIDTH-1:0] tx_data,
    output reg [WIDTH-1:0] rx_data,
    output reg rx_done
  );
  
  reg [WIDTH-1:0] shift_tx,shift_rx;
  reg [2:0] bit_count;
  
  always@(*) begin
    if(ss) begin
      miso=1'bz;
    end
    else begin
      miso=shift_tx[WIDTH-1];
    end
  end
  
  always@(posedge sclk or posedge ss) begin
    if(ss) begin
      shift_rx<=0;
      bit_count<=0;
      rx_done<=0;
    end
    else begin
      shift_rx<={shift_rx[WIDTH-2:0],mosi};
      
      if(bit_count==WIDTH-1) begin
        bit_count<=0;
        rx_data<={shift_rx[WIDTH-2:0],mosi};
        rx_done<=1;
      end
      else begin
        bit_count<=bit_count+1;
        rx_done<=0;
      end
      
    end
  end
  
  always @(negedge ss) begin
      shift_tx<=tx_data;
  end
  
  always @(negedge sclk) begin
    if(!ss)
        shift_tx<=shift_tx<<1;
	end
  
endmodule
