`timescale 1 ps / 1 ps

module pipeline_adder_tb;

parameter int NUMBERS_AMOUNT = 16;
parameter int NUMBER_WIDTH   = 10;
parameter int CLK_T          = 10_000;

bit                                                clk;
bit                                                rst;
bit [NUMBERS_AMOUNT - 1 : 0][NUMBER_WIDTH - 1 : 0] data;
bit                                                valid;
bit                                                ready;

int sum_q [$];

task automatic clk_gen();
  forever
    begin
      #( CLK_T / 2 );
      clk = !clk;
    end
endtask

task automatic apply_rst();
  @( posedge clk );
  rst <= 1'b1;
  @( posedge clk );
  rst <= 1'b0;
endtask

task automatic manipulate_ready();
  forever
    begin
      @( posedge clk )
      ready <= $urandom_range( 1 );
    end
endtask

task automatic send_new_data();

  int sum;
  int num;

  for( int i = 0; i < NUMBERS_AMOUNT; i++ )
    begin
      num = $urandom_range( 2 ** NUMBER_WIDTH - 1 );
      data[i] <= num;
      sum    += num;
    end
  valid <= 1'b1;
  do
    @( posedge clk );
  while( !DUT.ready_o );
  valid <= 1'b0;
  sum_q.push_back( sum );
endtask

task automatic check_sum();
  int ref_sum;
  forever
    begin
      while( DUT.data_valid_o != 1'b1 || DUT.ready_i != 1'b1 )
        @( posedge clk );
      ref_sum = sum_q.pop_front();
      if( DUT.data_o != ref_sum )
        begin
          $display( "Sum missmatch" );
          $display( "Was %0d", DUT.data_o );
          $display( "Should %0d", ref_sum );
          @( posedge clk );
          $stop();
        end
      else
        begin
          $display( "Sum match %d", DUT.data_o );
          @( posedge clk );
        end
    end
endtask

pipeline_adder #(
  .NUMBERS_AMOUNT ( NUMBERS_AMOUNT ),
  .NUMBER_WIDTH   ( NUMBER_WIDTH   )
) DUT (
  .clk_i          ( clk            ),
  .rst_i          ( rst            ),
  .data_i         ( data           ),
  .data_valid_i   ( valid          ),
  .ready_o        (                ),
  .data_o         (                ),
  .data_valid_o   (                ),
  .ready_i        ( ready          )
);

initial
  begin
    fork
      clk_gen();
      manipulate_ready();
    join_none
    apply_rst();
    @( posedge clk );
    fork
      check_sum();
    join_none
    repeat( 10 )
      send_new_data();
    repeat( 10 )
      @( posedge clk );
    $stop();
  end

endmodule
