module division #(
  parameter int WORD_W = 8
)(
  input                   clk_i,
  input                   rst_i,
  input                   start_i,
  input  [WORD_W - 1 : 0] divinded_i,
  input  [WORD_W - 1 : 0] divisor_i,
  output                  ready_o,
  output                  valid_o,
  output [WORD_W - 1 : 0] quotient_o,
  output [WORD_W - 1 : 0] reminder_o
);

localparam int CNT_W = $clog2( WORD_W );

logic [WORD_W - 1 : 0] rh, rh_comb;
logic [WORD_W - 1 : 0] rl;
logic [WORD_W - 1 : 0] divisor_lock;
logic [CNT_W : 0]      shifts_left;
logic                  q;

enum logic [1 : 0] { IDLE_S,
                     OP_S,
                     LAST_S,
                     DONE_S } state, next_state;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    state <= IDLE_S;
  else
    state <= next_state;

always_comb
  begin
    next_state = state;
    case( state )
      IDLE_S:
        begin
          if( start_i )
            next_state = OP_S;
        end
      OP_S:
        begin
          if( shifts_left == 'd1 )
            next_state = LAST_S;
        end
      LAST_S:
        begin
          next_state = DONE_S;
        end
      DONE_S:
        begin
          next_state = IDLE_S;
        end
    endcase
  end

assign q = rh >= divisor_lock;

always_comb
  begin
    rh_comb = rh;
    if( rh >= divisor_lock )
      rh_comb = rh - divisor_lock;
  end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      rh <= '0;
      rl <= '0;
    end
  else
    if( state == IDLE_S && start_i )
      begin
        rh <= '0;
        rl <= divinded_i;
      end
    else
      if( state == OP_S )
        begin
          rh <= { rh_comb[WORD_W - 2 : 0], rl[WORD_W - 1] };
          rl <= { rl[WORD_W - 2 : 0], q };
        end
      else
        if( state == LAST_S )
          begin
            rh <= rh_comb;
            rl <= { rl[WORD_W - 2 : 0], q };  
          end

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    shifts_left <= '0;
  else
    if( state == IDLE_S && start_i )
      shifts_left <= WORD_W[CNT_W : 0];
    else
      if( state == OP_S )
        shifts_left <= shifts_left - 1'b1;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    divisor_lock <= '0;
  else
    if( state == IDLE_S && start_i )
      divisor_lock <= divisor_i;

assign ready_o    = state == IDLE_S;
assign valid_o    = state == DONE_S;
assign quotient_o = rl;
assign reminder_o = rh;

endmodule
