module pipeline_division #(
  parameter int DIVINDED_WIDTH = 8,
  parameter int DIVISOR_WIDTH  = 8
)(
  input                           clk_i,
  input                           rst_i,
  input  [DIVINDED_WIDTH - 1 : 0] divinded_i,
  input  [DIVISOR_WIDTH - 1 : 0]  divisor_i,
  input                           valid_i,
  output                          ready_o,
  output [DIVINDED_WIDTH - 1 : 0] quotient_o,
  output [DIVISOR_WIDTH - 1 : 0]  reminder_o,
  output                          valid_o,
  input                           ready_i
);

localparam int STAGES_AMOUNT   = DIVINDED_WIDTH + 2;
localparam int SHIFT_REG_WIDTH = DIVINDED_WIDTH * 2;

typedef struct packed {
  logic [DIVINDED_WIDTH - 1 : 0] rh;
  logic [DIVINDED_WIDTH - 1 : 0] rl;
} shift_reg_t;

shift_reg_t [STAGES_AMOUNT - 1 : 0]                         division_stages;
logic       [STAGES_AMOUNT - 1 : 0][DIVINDED_WIDTH - 1 : 0] rh_comb;
logic       [STAGES_AMOUNT - 1 : 0]                         q;
logic       [STAGES_AMOUNT - 1 : 0][DIVISOR_WIDTH - 1 : 0]  divisor_lock;
logic       [STAGES_AMOUNT - 1 : 0]                         valid_d;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    valid_d <= STAGES_AMOUNT'( 0 );
  else
    if( ready_o )
      begin
        valid_d[0] <= valid_i;
        for( int i = 1; i < STAGES_AMOUNT; i++ )
          valid_d[i] <= valid_d[i - 1];
      end

always_comb
  for( int i = 0; i < STAGES_AMOUNT; i++ )
    begin
      q[i] = division_stages[i].rh >= divisor_lock[i];
      rh_comb[i] = division_stages[i].rh;
      if( q[i] )
        rh_comb[i] = division_stages[i].rh - divisor_lock[i];
    end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    divisor_lock <= ( STAGES_AMOUNT * DIVISOR_WIDTH )'( 0 );
  else
    if( ready_o )
      for( int i = 0; i < STAGES_AMOUNT; i++ )
        if( i == 0 )
          divisor_lock[i] <= divisor_i;
        else
          divisor_lock[i] <= divisor_lock[i - 1];

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    division_stages <= ( STAGES_AMOUNT * SHIFT_REG_WIDTH )'( 0 );
  else
    if( ready_o )
      for( int i = 0; i < STAGES_AMOUNT; i++ )
        if( i == 0 )
          division_stages[i] <= SHIFT_REG_WIDTH'( divinded_i );
        else
          if( i == ( STAGES_AMOUNT - 1 ) )
            begin
              division_stages[i].rh <= rh_comb[i - 1];
              division_stages[i].rl <= { division_stages[i - 1].rl[DIVINDED_WIDTH - 2 : 0], q[i - 1] };
            end
          else
            begin
              division_stages[i].rh <= { rh_comb[i - 1], division_stages[i - 1].rl[DIVINDED_WIDTH - 1] };
              division_stages[i].rl <= { division_stages[i - 1].rl[DIVINDED_WIDTH - 2 : 0], q[i - 1] };
            end

assign quotient_o = division_stages[STAGES_AMOUNT - 1].rl;
assign reminder_o = division_stages[STAGES_AMOUNT - 1].rh;
assign ready_o    = !valid_d[STAGES_AMOUNT - 1] || ready_i;
assign valid_o    = valid_d[STAGES_AMOUNT - 1];

endmodule
