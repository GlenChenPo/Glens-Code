//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : PATTERN.v
//   Module Name : PATTERN
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`ifdef RTL_TOP
    `define CYCLE_TIME 60.0
`endif

`ifdef GATE_TOP
    `define CYCLE_TIME 60.0
`endif

module PATTERN (
    // Output signals
    clk, rst_n, in_valid,
    in_p, in_q, in_e, in_c,
    // Input signals
    out_valid, out_m
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
output reg clk, rst_n, in_valid;
output reg [3:0] in_p, in_q;
output reg [7:0] in_e, in_c;
input out_valid;
input [7:0] out_m;

// ===============================================================
// Parameter & Integer Declaration
// ===============================================================
real CYCLE = `CYCLE_TIME;
integer input_file, output_file;
integer total_cycles, cycles;
integer PATNUM, patcount;
integer gap;
integer a, b, c, d, e, f;
integer i, j, k;
integer golden_step;

//================================================================
// Wire & Reg Declaration
//================================================================
reg [3:0] p_reg, q_reg;
reg [7:0] e_reg;
reg [7:0] c_reg [0:7];
reg [7:0] golden_n [0:7];

//================================================================
// Clock
//================================================================
initial clk = 0;
always #(CYCLE/2.0) clk = ~clk;

//================================================================
// Initial
//================================================================
initial begin
    rst_n    = 1'b1;
    in_valid = 1'b0;
    in_p = 'dx;
    in_q = 'dx;
    in_e = 'dx;
    in_c = 'dx;
	total_cycles = 0;

    force clk = 0;
    reset_task;

    input_file  = $fopen("../00_TESTBED/input_top.txt","r");
  	output_file = $fopen("../00_TESTBED/output_top.txt","r");
    @(negedge clk);

    a = $fscanf(input_file, "%d", PATNUM);
	for (patcount=0; patcount<PATNUM; patcount=patcount+1) begin
		input_data;
		wait_out_valid;
		check_ans;
		$display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles: %3d\033[m", patcount ,cycles);
	end
	#(50);
	YOU_PASS_task;
	$finish;
end

//================================================================
// TASK
//================================================================
task reset_task ; begin
	#(10); rst_n = 0;
	#(10);
	if((out_valid !== 0) || (out_m !== 0)) begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        FAIL!                                                               ");
		$display ("                                                  Output signal should be 0 after initial RESET at %8t                                      ",$time);
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		#(100);
	    $finish ;
	end
	#(10); rst_n = 1 ;
	#(3.0); release clk;
end endtask

task input_data; begin
	gap = $urandom_range(2,4);
	repeat(gap) @(negedge clk);
	in_valid = 1'b1;
	b = $fscanf (input_file, "%d", p_reg);
    c = $fscanf (input_file, "%d", q_reg);
    d = $fscanf (input_file, "%d", e_reg);
	for (i=0; i<8; i=i+1) begin
		if (i == 0) begin
			in_p = p_reg;
			in_q = q_reg;
			in_e = e_reg;
		end
		else begin
			in_p = 'dx;
			in_q = 'dx;
			in_e = 'dx;
		end
		e = $fscanf (input_file, "%d", c_reg[i]);
		in_c = c_reg[i];
		@(negedge clk);
	end
	in_valid = 1'b0;
    in_c = 'dx;
end endtask

task wait_out_valid; begin
	cycles = 0;
	while(out_valid === 0)begin
		cycles = cycles + 1;
		if(cycles == 10000) begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                        FAIL!                                                               ");
			$display ("                                                                   Pattern NO.%03d                                                          ", patcount);
			$display ("                                                     The execution latency are over 10000 cycles                                             ");
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			repeat(2)@(negedge clk);
			$finish;
		end
	@(negedge clk);
	end
	total_cycles = total_cycles + cycles;
end endtask

task check_ans; begin
	for (i=0; i<8; i=i+1) f = $fscanf(output_file, "%d", golden_n[i]);
	golden_step = 1;
	while (out_valid === 1) begin
		if ( golden_n[ golden_step-1 ] !== out_m ) begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                        FAIL!                                                               ");
			$display ("                                                                   Pattern NO.%03d                                                          ", patcount);
			$display ("                                                              Your output -> result: %d                                                     ", out_m);
			$display ("                                                            Golden output -> result: %d, step: %d                                           ", golden_n[golden_step-1], golden_step);
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$finish;
		end
		@(negedge clk);
		golden_step = golden_step + 1;
	end
	if(golden_step !== 9) begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        FAIL!                                                               ");
		$display ("                                                                   Pattern NO.%03d                                                          ", patcount);
		$display ("	                                                          Output cycle should be 8 cycles                                                  ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		@(negedge clk);
		$finish;
	end
end endtask

task YOU_PASS_task; begin
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$display ("                                                  Congratulations!                						             ");
	$display ("                                           You have passed all patterns!          						             ");
	$display ("                                           Your execution cycles = %5d cycles   						                 ", total_cycles);
	$display ("                                           Your clock period = %.1f ns        					                     ", `CYCLE_TIME);
	$display ("                                           Your total latency = %.1f ns         						                 ", total_cycles*`CYCLE_TIME);
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$finish;
end endtask


endmodule