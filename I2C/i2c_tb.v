`timescale 1ns/1ps

module i2c_tb;

  reg clk;
  reg reset;

  reg start;
  reg [6:0] slave_adr;
  reg rw;
  reg [7:0] tx_data;

  wire ready;
  wire ack;
  wire error;

  wire [7:0] slave_rx_data;
  wire slave_data_valid;

  // Track the read data captured by Master FSM for verification
  wire [7:0] master_rx_data_captured = dut.master_inst.rx_data;

  // Instantiate the Device Under Test (DUT)
  i2c_top dut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .slave_adr(slave_adr),
    .rw(rw),
    .tx_data(tx_data),
    .ready(ready),
    .ack(ack),
    .error(error),
    .slave_rx_data(slave_rx_data),
    .slave_data_valid(slave_data_valid)
  );

  //--------------------------------------------------
  // Clock Generator (50MHz)
  //--------------------------------------------------
  always #10 clk = ~clk;

  //--------------------------------------------------
  // Task: Start & Auto-Verify Transaction
  //--------------------------------------------------
  task automatic do_transaction;
    input [6:0] addr;
    input       rw_mode;
    input [7:0] data_to_send;
    input [7:0] expected_data; // Data we expect to see at the destination
    
    begin
      slave_adr = addr;
      rw        = rw_mode;
      tx_data   = data_to_send;

      // Generate Start Pulse
      @(posedge clk);
      start = 1;
      @(posedge clk);
      start = 0;

      // Wait until master leaves IDLE
      wait (ready == 0);
      // Wait until transaction completes and master returns to IDLE
      wait (ready == 1);
      
      @(posedge clk);

      //------------------------------------------------
      // VERIFICATION LOGIC (Console Reporting)
      //------------------------------------------------
      $display("---------------------------------------------------------");
      if (rw_mode == 1'b0) begin
        // WRITE Verification: Master Tx -> Slave Rx
        $display("[VERIFICATION] WRITE Mode | Target Slave Addr: 7'h%h", addr);
        $display("[DATA TRACKING] Master Transmitted: 8'h%h (%0d)", data_to_send, data_to_send);
        $display("[DATA TRACKING] Slave Received:     8'h%h (%0d)", slave_rx_data, slave_rx_data);
        
        if (slave_rx_data == expected_data && error == 0 && ack == 1) begin
          $display(">>> [RESULT] STATUS: SUCCESS! Data matched perfectly between Master and Slave. <<<");
        end else begin
          $display(">>> [RESULT] STATUS: ERROR! Data mismatch or Protocol Fault occurred. <<<");
        end
      end 
      else begin
        // READ Verification: Slave Tx (data_local) -> Master Rx
        $display("[VERIFICATION] READ Mode | Target Slave Addr: 7'h%h", addr);
        $display("[DATA TRACKING] Slave Transmitted:  8'h%h (%0d) [Hardcoded data_local]", dut.slave_inst.data_local, dut.slave_inst.data_local);
        $display("[DATA TRACKING] Master Received:     8'h%h (%0d)", master_rx_data_captured, master_rx_data_captured);
        
        if (master_rx_data_captured == expected_data && error == 0 && ack == 1) begin
          $display(">>> [RESULT] STATUS: SUCCESS! Master successfully read correct byte from Slave. <<<");
        end else begin
          $display(">>> [RESULT] STATUS: ERROR! Read data mismatch or Protocol Fault occurred. <<<");
        end
      end
      $display("---------------------------------------------------------\n");

    end
  endtask

  //--------------------------------------------------
  // Test Stimulus Generator
  //--------------------------------------------------
  initial begin
    // Initialize Inputs
    clk       = 0;
    reset     = 1;
    start     = 0;
    slave_adr = 0;
    rw        = 0;
    tx_data   = 0;

    // Apply Reset Pulse
    #40;
    reset = 0;
    #40;

    //==================================================
    // TESTCASE 1: WRITE TEST
    //==================================================
    $display("\n=== STARTING I2C WRITE TRANSACTION ===");
    // Parameters: (addr, rw_mode, data_to_send, expected_data)
    do_transaction(
      7'b0101010, // Slave ID (42)
      1'b0,       // Write Mode
      8'hD4,      // Transmitting 0xD4 (212)
      8'hD4       // Expecting Slave to receive 0xD4
    );
    #200;

    //==================================================
    // TESTCASE 2: READ TEST
    //==================================================
    $display("\n=== STARTING I2C READ TRANSACTION ===");
    // Parameters: (addr, rw_mode, data_to_send, expected_data)
    do_transaction(
      7'b0101010, // Slave ID (42)
      1'b1,       // Read Mode
      8'h00,      // Dummy data (ignored during reads)
      8'hA5       // Expecting Master to receive Slave's default local data (0xA5)
    );
    #500;

    $finish;
  end

  //--------------------------------------------------
  // Waveform Generation Configuration (EDA Playground)
  //--------------------------------------------------
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, i2c_tb);
  end

endmodule
