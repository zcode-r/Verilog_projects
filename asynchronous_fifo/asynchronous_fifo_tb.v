module async_fifo_tb;

  reg clk_w;
  reg clk_r;

  reg reset_w;
  reg reset_r;

  reg w_en;
  reg r_en;

  reg [7:0] w_data;

  wire [7:0] r_data;
  wire full;
  wire empty;

  async_fifo uut (
      .clk_w(clk_w),
      .reset_w(reset_w),
      .w_en(w_en),
      .w_data(w_data),
      .full(full),

      .clk_r(clk_r),
      .reset_r(reset_r),
      .r_en(r_en),
      .r_data(r_data),
      .empty(empty)
  );

  //----------------------------------------
  // Different Clock Frequencies
  //----------------------------------------

  initial clk_w = 0;
  always #5 clk_w = ~clk_w;     // 10ns period

  initial clk_r = 0;
  always #12 clk_r = ~clk_r;    // 24ns period

  //----------------------------------------
  // Test
  //----------------------------------------

  initial begin

    $dumpfile("dump.vcd");
    $dumpvars(0,async_fifo_tb);

    reset_w = 1;
    reset_r = 1;

    w_en = 0;
    r_en = 0;
    w_data = 0;

    #50;

    reset_w = 0;
    reset_r = 0;

    //------------------------------------------------
    // TEST 1 : Fill FIFO
    //------------------------------------------------

    $display("FILL FIFO");

    w_en = 1;

    for(int i=1;i<=10;i++) begin
      @(posedge clk_w);
      w_data = i;
    end

    @(posedge clk_w);
    w_en = 0;

    #100;

    //------------------------------------------------
    // TEST 2 : Empty FIFO
    //------------------------------------------------

    $display("EMPTY FIFO");

    r_en = 1;

    for(int i=1;i<=10;i++) begin
      @(posedge clk_r);
    end

    @(posedge clk_r);
    r_en = 0;

    #100;

    //------------------------------------------------
    // TEST 3 : Wraparound
    //------------------------------------------------

    $display("WRAPAROUND");

    w_en = 1;

    for(int i=20;i<25;i++) begin
      @(posedge clk_w);
      w_data = i;
    end

    @(posedge clk_w);
    w_en = 0;

    #50;

    r_en = 1;

    for(int i=0;i<3;i++) begin
      @(posedge clk_r);
    end

    @(posedge clk_r);
    r_en = 0;

    #50;

    w_en = 1;

    for(int i=30;i<36;i++) begin
      @(posedge clk_w);
      w_data = i;
    end

    @(posedge clk_w);
    w_en = 0;

    #50;

    r_en = 1;

    for(int i=0;i<20;i++) begin
      @(posedge clk_r);
    end

    @(posedge clk_r);
    r_en = 0;

    #100;

    //------------------------------------------------
    // TEST 4 : Simultaneous Activity
    //------------------------------------------------

    $display("SIMULTANEOUS READ WRITE");

    fork

      begin
        w_en = 1;

        for(int i=100;i<110;i++) begin
          @(posedge clk_w);
          w_data = i;
        end

        @(posedge clk_w);
        w_en = 0;
      end

      begin
        #40;

        r_en = 1;

        repeat(10)
          @(posedge clk_r);

        @(posedge clk_r);
        r_en = 0;
      end

    join

    #200;

    $finish;

  end

endmodule
