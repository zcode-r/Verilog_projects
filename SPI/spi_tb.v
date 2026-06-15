`timescale 1ns / 1ps

module spi_tb;

  parameter WIDTH = 8;
  
  reg clk;
  reg reset;
  reg [WIDTH-1:0] master_tx_data;
  reg [1:0] target_slave;
  reg start;
  
  wire [WIDTH-1:0] master_rx_data;
  wire ready;
  
  reg [WIDTH-1:0] slave0_tx_data;
  reg [WIDTH-1:0] slave1_tx_data;
  reg [WIDTH-1:0] slave2_tx_data;
  
  wire [WIDTH-1:0] slave0_rx_data;
  wire [WIDTH-1:0] slave1_rx_data;
  wire [WIDTH-1:0] slave2_rx_data;
  wire slave0_done;
  wire slave1_done;
  wire slave2_done;

  spi #(.WIDTH(WIDTH)) uut (
    .clk(clk),
    .reset(reset),
    .master_tx_data(master_tx_data),
    .target_slave(target_slave),
    .start(start),
    .master_rx_data(master_rx_data),
    .ready(ready),
    .slave0_tx_data(slave0_tx_data),
    .slave1_tx_data(slave1_tx_data),
    .slave2_tx_data(slave2_tx_data),
    .slave0_rx_data(slave0_rx_data),
    .slave1_rx_data(slave1_rx_data),
    .slave2_rx_data(slave2_rx_data),
    .slave0_done(slave0_done),
    .slave1_done(slave1_done),
    .slave2_done(slave2_done)
  );

  always begin
    #10 clk = ~clk;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, spi_tb);

    clk            = 0;
    reset          = 1;
    start          = 0;
    target_slave   = 2'b00;
    master_tx_data = 8'h00;
    slave0_tx_data = 8'h00;
    slave1_tx_data = 8'h00;
    slave2_tx_data = 8'h00;

    #40;
    reset = 0; 
    #20;
    

    // TRANSACTION 1: MASTER COMMUNICATES WITH SLAVE 1

    $display("[TB] Starting Transaction 1: Master <-> Slave 1");
    
    wait(ready == 1); // Confirm the bus is clear
    @(posedge clk);
    #1; 
    master_tx_data = 8'hD5;  
    slave1_tx_data = 8'h39;  
    target_slave   = 2'b01;  
    
    start          = 1;      
    
    @(posedge clk);
    #1;
    start          = 0;      

    #10; 
    wait(ready == 1);
    #50; 
    
    $display("[TB] Master Sent: 0x%h, Received: 0x%h (Expected: 0x39)", 8'hD5, master_rx_data);
    $display("[TB] Slave 1 Received: 0x%h (Expected: 0xD5), Done: %b", slave1_rx_data, slave1_done);
    $display("-----------------------------------------------------------------");

    // TRANSACTION 2: MASTER COMMUNICATES WITH SLAVE 2

    #100;
    $display("[TB] Starting Transaction 2: Master <-> Slave 2");
    
    wait(ready == 1);
    @(posedge clk);
    #1;
    master_tx_data = 8'hAA;  
    slave2_tx_data = 8'h55;  
    target_slave   = 2'b10; 
    start          = 1;
    
    @(posedge clk);
    #1;
    start          = 0;
    
    #10;
    wait(ready == 1);
    #50;
    
    $display("[TB] Master Sent: 0x%h, Received: 0x%h (Expected: 0x55)", 8'hAA, master_rx_data);
    $display("[TB] Slave 2 Received: 0x%h (Expected: 0xAA), Done: %b", slave2_rx_data, slave2_done);

    #100;
    $display("[TB] Simulation Completed Successfully.");
    $finish;
  end

endmodule
