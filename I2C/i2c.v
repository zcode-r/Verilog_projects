module i2c_top (
    input clk, reset,
    input start,
    input [6:0] slave_adr,
    input rw,
    input [7:0] tx_data,
    output ready,
    output ack,
    output error,
    output [7:0] slave_rx_data,
    output slave_data_valid
);
  
  wire scl;
  tri1 sda;
  
  i2c_master #(
    .WIDTH(8)
  ) master_inst(
    .clk(clk),
    .reset(reset),
    .start(start),
    .slave_adr(slave_adr),
    .rw(rw),
    .ack(ack),
    .tx_data(tx_data),
    .ready(ready),
    .error(error),
    .scl(scl),
    .sda(sda)
  );
  
  i2c_slave #(
      .SLAVE_ID(7'b0101010),
      .WIDTH(8)
  ) slave_inst (
      .clk(clk),
      .reset(reset),
      .scl(scl), 
      .sda(sda), 
      .received_data(slave_rx_data),
      .data_valid(slave_data_valid)
  );
  
endmodule

/////////////////////////////////////////////////
module i2c_master #(parameter WIDTH=8)
  (
    input clk, reset,
    input start,
    input [6:0] slave_adr,
    input rw,
    output reg ack,
    input [7:0] tx_data,
    output reg ready,
    output reg error,
    output reg scl,
    inout sda
  );
  
  reg [2:0] state;
  reg [3:0] clk_count;
  reg [2:0] bit_count;
  
  reg [6:0] addr_shift;
  reg rw_shift;
  reg [7:0] tx_shift;
  reg [7:0] rx_data;
  
  reg sda_out;
  reg sda_en;
  
  assign sda = (sda_en) ? sda_out : 1'bz;

  localparam STATE_IDLE       = 3'b000;
  localparam STATE_START      = 3'b001;
  localparam STATE_SLAVE_ADDR = 3'b010; 
  localparam STATE_RW_BIT      = 3'b011;
  localparam STATE_ACK_ADDR   = 3'b100; 
  localparam STATE_DATA       = 3'b101;
  localparam STATE_ACK_DATA   = 3'b110; 
  localparam STATE_STOP       = 3'b111; 
  
  // Master FSM
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= STATE_IDLE;
      clk_count <= 0;
      bit_count <= 0;
      scl <= 1;
      sda_en <= 1;
      sda_out <= 1;
      error <= 0;
      ack <= 0;
      addr_shift <= 0;
      tx_shift <= 0;
      rw_shift <= 0;
    end
    else begin
      case (state) 
        
        STATE_IDLE: begin
          clk_count <= 0;
          bit_count <= 0;
          scl <= 1;
          sda_en <= 1;
          sda_out <= 1;
          if (start) begin
            addr_shift <= slave_adr;
            tx_shift <= tx_data;
            rw_shift <= rw;
            state <= STATE_START;
          end
        end
        
        STATE_START: begin
          if (clk_count == 3) begin
            clk_count <= 0;
            state <= STATE_SLAVE_ADDR;
          end
          else clk_count <= clk_count + 1;
          
          if (clk_count == 0 || clk_count == 1) begin
            scl <= 1;
            sda_out <= 0;
            sda_en <= 1;
          end
          else begin
            scl <= 0;
            sda_out <= 0;
          end
        end
        
        STATE_SLAVE_ADDR: begin
          if (clk_count == 3) begin
            clk_count <= 0;
            if (bit_count == 6) begin
              bit_count <= 0;
              state <= STATE_RW_BIT;
            end
            else bit_count <= bit_count + 1;
          end
          else clk_count <= clk_count + 1;
          
          if (clk_count == 0 || clk_count == 1) begin
            scl <= 0;
            sda_en <= 1;
            sda_out <= addr_shift[6-bit_count];
          end
          else begin
            scl <= 1;
          end
        end
        
        STATE_RW_BIT: begin
          if (clk_count == 3) begin
            clk_count <= 0;
            state <= STATE_ACK_ADDR;
          end
          else clk_count <= clk_count + 1;
          
          if (clk_count == 0 || clk_count == 1) begin
            scl <= 0;
            sda_out <= rw_shift;
            if (rw_shift == 1) sda_en <= 0;
            else sda_en <= 1;
          end
          else begin
            scl <= 1;
            if (rw_shift == 1) sda_en <= 0;
          end
        end
        
        STATE_ACK_ADDR: begin
          if (clk_count == 3) begin 
            clk_count <= 0;
            if (error) state <= STATE_STOP;
            else state <= STATE_DATA;
          end
          else clk_count <= clk_count + 1;
          
          if (clk_count == 0 || clk_count == 1) begin
            scl <= 0;
            sda_en <= 0;
          end
          else begin
            scl <= 1;
            if (clk_count == 2) begin
              if (sda == 1) begin
                error <= 1;
                ack <= 0;
              end
              else begin
                error <= 0;
                ack <= 1;
              end
            end
          end
        end
        
        STATE_DATA: begin
          if (clk_count == 3) begin
            clk_count <= 0;
            if (bit_count == 7) begin
              bit_count <= 0;
              state <= STATE_ACK_DATA;
            end
            else bit_count <= bit_count + 1;
          end
          else clk_count <= clk_count + 1;
          
          if (clk_count == 0 || clk_count == 1) begin
            scl <= 0;
            if (rw_shift == 0) begin
              sda_en <= 1;
              sda_out <= tx_shift[7-bit_count];
            end
            else sda_en <= 0;
          end
          else begin
            scl <= 1;
            if (rw_shift == 1 && clk_count == 2) begin
              rx_data[7-bit_count] <= sda;
            end
          end
        end
        
        STATE_ACK_DATA: begin
          if (clk_count == 3) begin
            clk_count <= 0;
            state <= STATE_STOP;
          end
          else clk_count <= clk_count + 1;
          
          if (clk_count == 0 || clk_count == 1) begin
            scl <= 0;
            if (rw_shift == 0) begin
              sda_en <= 0;
            end
            else begin
              sda_en <= 1;
              sda_out <= 1;
            end
          end
          else begin
            scl <= 1;
            if (rw_shift == 0 && clk_count == 2) begin
              if (sda == 1) begin
                error <= 1;
                ack <= 0;
              end
              else begin
                error <= 0;
                ack <= 1;
              end
            end
          end  
        end
  
        STATE_STOP: begin
          if (clk_count == 3) begin
            clk_count <= 0;
            state <= STATE_IDLE;
          end
          else clk_count <= clk_count + 1;
          
          if (clk_count == 0 || clk_count == 1) begin
            scl <= 0;
            sda_en <= 1;
            sda_out <= 0;
          end
          else if (clk_count == 2) begin
            scl <= 1;
            sda_out <= 0;
          end
          else begin
            scl <= 1;
            sda_out <= 1;
          end
        end 
        
        default: state <= STATE_IDLE;
      endcase
      
      if (state == STATE_IDLE) ready <= 1;
      else ready <= 0;
    end
  end
      
endmodule


///////////////////////////////////////////////////////////
module i2c_slave #(
    parameter [6:0] SLAVE_ID = 7'b0101010,
    parameter WIDTH = 8
)(
    input clk, reset,
    input scl,
    inout sda,
    output reg [7:0] received_data,
    output reg data_valid
);
  
  localparam STATE_IDLE       = 3'b000;
  localparam STATE_SLAVE_ADDR = 3'b001;
  localparam STATE_RW_BIT      = 3'b010;
  localparam STATE_ACK_ADDR   = 3'b011;
  localparam STATE_DATA       = 3'b100;
  localparam STATE_ACK_DATA   = 3'b101;
  
  reg [2:0] state;
  reg [2:0] bit_count;
  
  reg [6:0] addr_rx;
  reg rw_rx;
  reg [7:0] data_local;
  reg [7:0] rx_shift;
  
  reg sda_out;
  reg sda_en;
  
  assign sda = (sda_en) ? sda_out : 1'bz;
  
  reg sda_delayed;
  reg start_detected;
  reg stop_detected;
  
  // Asynchronous Start/Stop Condition Detector Block
  always @(posedge clk or posedge reset) begin
    if (reset) begin 
      sda_delayed <= 1;
      start_detected <= 0;
      stop_detected <= 0;
    end
    else begin 
      sda_delayed <= sda;
      if (scl == 1 && sda_delayed == 1 && sda == 0) begin
          start_detected <= 1;
          stop_detected  <= 0;
      end
      else if (scl == 1 && sda_delayed == 0 && sda == 1) begin
          stop_detected  <= 1;
          start_detected <= 0;
      end
    end
  end
  
  // Slave Sequential Protocol Engine
  always @(posedge scl or posedge reset) begin
    if (reset) begin
      state <= STATE_IDLE;
      bit_count <= 0;
      rw_rx <= 0;
      addr_rx <= 0;
      received_data <= 0;
      rx_shift <= 0;
      data_valid <= 0;
      sda_out <= 1;
      sda_en <= 0;
      data_local <= 8'hA5;
    end
    else begin
      data_valid <= 0;
      
      if (stop_detected && (state == STATE_IDLE || state == STATE_SLAVE_ADDR)) begin
        state <= STATE_IDLE;
        sda_en <= 0;
      end
      else begin
        case (state) 
          
          STATE_IDLE: begin
            bit_count <= 0;
            sda_en <= 0;
            if (start_detected) begin
              start_detected <= 0; 
              addr_rx[6] <= sda;   
              bit_count <= 1;
              state <= STATE_SLAVE_ADDR;
            end
          end
          
          STATE_SLAVE_ADDR: begin
            sda_en <= 0;
            addr_rx[6-bit_count] <= sda;
            if (bit_count == 6) begin
              bit_count <= 0;
              state <= STATE_RW_BIT;
            end
            else bit_count <= bit_count + 1;
          end

          STATE_RW_BIT: begin
            rw_rx <= sda;
            if (addr_rx == SLAVE_ID) begin
              sda_en <= 1;
              sda_out <= 0; 
              state <= STATE_ACK_ADDR;
            end
            else
              state <= STATE_IDLE;
          end
                  
          STATE_ACK_ADDR: begin
            if (rw_rx == 0) begin
              sda_en <= 0;
            end
            else begin
              sda_en  <= 1;
              sda_out <= data_local[7];
            end
            bit_count <= 0;
            state     <= STATE_DATA;
          end

          STATE_DATA: begin
            if (rw_rx == 0) begin
              rx_shift[7-bit_count] <= sda;
              if (bit_count == 7) begin
                bit_count <= 0;
                state <= STATE_ACK_DATA;
                sda_en <= 1; 
                sda_out <= 0;
              end
              else begin
                sda_en <= 0;
                bit_count <= bit_count + 1;
              end
            end
            else begin
              if (bit_count == 7) begin
                bit_count <= 0;
                state <= STATE_ACK_DATA;
                sda_en <= 0;
              end
              else begin
                sda_en <= 1;
                sda_out <= data_local[6-bit_count];
                bit_count <= bit_count + 1;
              end
            end
          end
          
          STATE_ACK_DATA: begin
            if (rw_rx == 0) begin
              received_data <= rx_shift;
              data_valid <= 1;
            end
            sda_en <= 0;
            state <= STATE_IDLE;
          end
          
          default: state <= STATE_IDLE;
        endcase
      end
    end
  end
  
endmodule
