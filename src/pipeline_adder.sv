module pipeline_adder #(
  parameter int NUMBERS_AMOUNT  = 10,
  parameter int NUMBER_WIDTH    = 10,
  // If 1 - will do sign extension, not extension otherwise
  parameter int SIGNED          = 0,
  // Defines how many triggers will be inserted in the pipeline,
  // also defines delay between input and output
  parameter int PIPELINE_FACTOR = 8,//$clog2( INPUTS_AMOUNT ) + 1
  // Don't change
  parameter int SUM_WIDTH       = NUMBER_WIDTH + $clog2( NUMBERS_AMOUNT )
)(
  input                                                 clk_i,
  input                                                 rst_i,
  input  [NUMBERS_AMOUNT - 1 : 0][NUMBER_WIDTH - 1 : 0] data_i,
  input                                                 data_valid_i,
  output                                                ready_o,
  output [SUM_WIDTH - 1 : 0]                            data_o,
  output                                                data_valid_o,
  input                                                 ready_i
);

// Tree base must be even
localparam int INPUTS_AMOUNT = NUMBERS_AMOUNT % 2 ? NUMBERS_AMOUNT + 1 : NUMBERS_AMOUNT;
// Vertical length of tree
localparam int STAGES_AMOUNT = $clog2( INPUTS_AMOUNT ) + 1;
// Check if it's not zero, or we will get synthesizer error
localparam int VALID_PIPE    = PIPELINE_FACTOR ? PIPELINE_FACTOR : 1;
// If PIPELINE_FACTOR is greater than necessary addition stages
localparam int EXCESSIVE_PIPE = PIPELINE_FACTOR <= STAGES_AMOUNT ? 1 : 
                                PIPELINE_FACTOR - STAGES_AMOUNT;

// Distributes pipelines evenly between tree stages
function bit [STAGES_AMOUNT - 1 : 0] distribute_pipeline( input int pipeline_factor );

  int interval;
  
  distribute_pipeline = STAGES_AMOUNT'( 0 );
  
  // Divide by zero protection
  if( pipeline_factor == 0 )
    return distribute_pipeline;
  
  // How many combinatoric additions between registers  
  interval = pipeline_factor > STAGES_AMOUNT ? 1 : STAGES_AMOUNT / pipeline_factor;
  
  for( int i = 0; i < STAGES_AMOUNT; i += interval )
    begin
      distribute_pipeline[i] = 1'b1;
      pipeline_factor--;
      // If we've ran out of pipelines
      if( pipeline_factor == 0 )
        break;
    end

endfunction

// For 4 stage addition following PIPELINE_FACTOR values will give these chart
// results:
// 0: 4'b0000
// 1: 4'b0001
// 2: 4'b0101
// 3: 4'b0111
// 4: 4'b1111
// 1 stand for registered stage and 0 stand for combinatoric stage
localparam bit [STAGES_AMOUNT - 1 : 0] PIPELINE_CHART = distribute_pipeline( PIPELINE_FACTOR );

logic [STAGES_AMOUNT - 1 : 0][INPUTS_AMOUNT - 1 : 0][SUM_WIDTH - 1 : 0] add_stages;
logic [VALID_PIPE - 1 : 0]                                              valid_d;
logic [EXCESSIVE_PIPE - 1 : 0][SUM_WIDTH - 1 : 0]                       ex_pipe;

always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    valid_d <= VALID_PIPE'( 0 );
  else
    if( ready_o )
      begin
        valid_d[0] <= data_valid_i;
        for( int i = 1; i < VALID_PIPE; i++ )
          valid_d[i] <= valid_d[i - 1];
      end

genvar g;

generate
  // Go through tree vertically
  for( g = 0; g < STAGES_AMOUNT; g++ )
    // This layer will be registered
    if( PIPELINE_CHART[g] )
      begin : ff_stage
        always_ff @( posedge clk_i, posedge rst_i )
          if( rst_i )
            add_stages[g] <= ( INPUTS_AMOUNT * SUM_WIDTH )'( 0 );
          else
            if( ready_o )
              // Fetch data from input to first layer
              if( g == 0 )
                // Amount of nodes is even so if numbers amount is odd
                // we will assign one element to zero 
                if( INPUTS_AMOUNT != NUMBERS_AMOUNT )
                  begin
                    // Go through all inputs and fetch them
                    for( int i = 0; i < NUMBERS_AMOUNT; i++ )
                      // If signed we need to special sign extension to input
                      // data
                      // Signed input won't work because we are going by index
                      if( SIGNED )
                        add_stages[g][i] <= SUM_WIDTH'( signed'( data_i[i] ) );
                      else
                        add_stages[g][i] <= data_i[i];
                    add_stages[g][INPUTS_AMOUNT - 1] <= SUM_WIDTH'( 0 );
                  end
                else
                  for( int i = 0; i < NUMBERS_AMOUNT; i++ )
                    if( SIGNED )
                      add_stages[g][i] <= SUM_WIDTH'( signed'( data_i[i] ) );
                    else
                      add_stages[g][i] <= data_i[i];
              else
                // If the layer is not first, then we fetch data from previous
                // layer, each time we will use 2 times less data
                for( int i = 0; i < ( INPUTS_AMOUNT / ( g + 1 ) ); i++ )
                  add_stages[g][i] <= add_stages[g - 1][i * 2] + add_stages[g - 1][i * 2 + 1];
      end
    else
      // This layer will be combinatoric
      // Everything else is the same as above 
      begin : comb_stage
        always_comb
          if( g == 0 )
            begin
              add_stages[g] = ( INPUTS_AMOUNT * SUM_WIDTH )'( 0 );
              if( INPUTS_AMOUNT != NUMBERS_AMOUNT )
                begin
                  for( int i = 0; i < NUMBERS_AMOUNT; i++ )
                    if( SIGNED )
                      add_stages[g][i] = SUM_WIDTH'( signed'( data_i[i] ) );
                    else
                      add_stages[g][i] = data_i[i];
                  add_stages[g][INPUTS_AMOUNT - 1] = SUM_WIDTH'( 0 );
                end
              else
                for( int i = 0; i < NUMBERS_AMOUNT; i++ )
                  if( SIGNED )
                    add_stages[g][i] = SUM_WIDTH'( signed'( data_i[i] ) );
                  else
                    add_stages[g][i] = data_i[i];
            end
          else
            begin
              add_stages[g] = add_stages[g - 1];
              for( int i = 0; i < NUMBERS_AMOUNT; i++ )
                add_stages[g][i] = add_stages[g - 1][i * 2] + add_stages[g - 1][i * 2 + 1];
            end
      end
endgenerate
      
// If output delay is desired
always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    ex_pipe <= ( EXCESSIVE_PIPE * SUM_WIDTH )'( 0 );
  else
    if( ready_o )
      begin
        ex_pipe[0] <= add_stages[STAGES_AMOUNT - 1][0];
        for( int i = 1; i < EXCESSIVE_PIPE; i++ )
          ex_pipe[i] <= ex_pipe[i - 1];
      end

assign data_o       = PIPELINE_FACTOR > STAGES_AMOUNT ? ex_pipe[EXCESSIVE_PIPE - 1] : 
                                                        add_stages[STAGES_AMOUNT - 1][0];
assign data_valid_o = PIPELINE_FACTOR ? valid_d[PIPELINE_FACTOR - 1] : data_valid_i;
assign ready_o      = PIPELINE_FACTOR ? !valid_d[PIPELINE_FACTOR - 1] || ready_i :
                      ready_i;

endmodule
