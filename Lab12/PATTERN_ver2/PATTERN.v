//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : PATTERN.v
//   Module Name : PATTERN
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`ifdef RTL
	`timescale 1ns/10ps
	`include "WD.v"
	`define CYCLE_TIME 7.0
`endif
`ifdef GATE
	`timescale 1ns/10ps
	`include "WD_SYN.v"
	`define CYCLE_TIME 7.0
`endif
`ifdef POST
	`timescale 1ns/10ps
	`include "CHIP.v"
    `define CYCLE_TIME 8.0
`endif

module PATTERN(
    // Output signals
	clk,
	rst_n,
	in_valid,
	keyboard,
	answer,
    weight,
    match_target,
    // Input signals
	out_valid,
	result,
    out_value
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
output reg clk, rst_n, in_valid;
output reg [4:0] keyboard, answer;
output reg [3:0] weight;
output reg [2:0] match_target;
input out_valid;
input [4:0]  result;
input [10:0] out_value;

// ===============================================================
// Parameters & Integer Declaration
// ===============================================================
integer input_file, output_file;
integer total_cycles, cycles;
integer temp, patcount;
integer PATNUM=20;
integer gap;
integer a, b, c, d, e, f, g;
integer i, j;
integer golden_step;

// ===============================================================
// Wire & Reg Declaration
// ===============================================================
reg [4:0] keyboard_data [0:7];
reg [4:0] answer_data [0:4];
reg [3:0] weight_data [0:4];
reg [2:0] target_data [0:1];
reg [4:0]  golden_result [0:4];
reg [10:0] golden_value;

// ===============================================================
// Clock
// ===============================================================
always	#(`CYCLE_TIME/2.0) clk = ~clk;
initial	clk = 0;

// ===============================================================
// Initial
// ===============================================================
initial begin
	rst_n    = 1'b1;
	in_valid = 1'b0;
	keyboard =  'bx;
	answer   =  'bx;
	weight   =  'bx;
	match_target = 'bx;
	total_cycles = 0;

	force clk = 0;
	reset_task;

	
	input_file  = $fopen("../00_TESTBED/input_demo.txt","r");
  	output_file = $fopen("../00_TESTBED/output_demo.txt","r");
	
	@(negedge clk);

	a = $fscanf(input_file, "%d", temp);
	for (patcount=0;patcount<PATNUM;patcount=patcount+1) begin
		input_data;
		wait_out_valid;
		check_ans;
		$display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles: %3d\033[m", patcount ,cycles);
	end
	#(1000);
	YOU_PASS_task;
	$finish;
end 

// ===============================================================
// TASK
// ===============================================================
task reset_task ; begin
	#(10); rst_n = 0;
	#(10);
	if((out_valid !== 0) || (result !== 0) || (out_value !== 0)) begin
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
	for (i=0; i<8; i=i+1) b = $fscanf (input_file, "%d", keyboard_data[i]);
	for (i=0; i<5; i=i+1) c = $fscanf (input_file, "%d", answer_data[i]);
	for (i=0; i<5; i=i+1) d = $fscanf (input_file, "%d", weight_data[i]);
	e = $fscanf (input_file, "%d %d", target_data[0], target_data[1]);
	for (i=0; i<8; i=i+1) begin
		keyboard = keyboard_data[i];
		if (i<5) begin
			answer = answer_data[i];
			weight = weight_data[i];
		end
		else begin
			answer = 'bx;
			weight = 'bx;
		end
		if (i<2) match_target = target_data[i];
		else	 match_target = 'bx;
		@(negedge clk);
	end
	in_valid = 1'b0;
	keyboard = 'bx;
end endtask

task wait_out_valid; begin
	cycles = 0;
	while(out_valid === 0)begin
		cycles = cycles + 1;
		if(cycles == 20000) begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                        FAIL!                                                               ");
			$display ("                                                                   Pattern NO.%03d                                                          ", patcount);
			$display ("                                                     The execution latency are over 20000 cycles                                            ");
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			repeat(2)@(negedge clk);
			$finish;
		end
	@(negedge clk);
	end
	total_cycles = total_cycles + cycles;
end endtask

task check_ans; begin
	for (i=0; i<5; i=i+1) f = $fscanf(output_file, "%d", golden_result[i]);
	g = $fscanf(output_file, "%d", golden_value);
	golden_step = 0;
	while (out_valid === 1) begin
		if ( result !== golden_result[ golden_step ] ) begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                        FAIL!                                                               ");
			$display ("                                                                   Pattern NO.%03d                                                          ", patcount);
			$display ("                                                              Your output -> result: %d                                                     ", result);
			$display ("                                                            Golden output -> result: %d, step: %d                                           ", golden_result[golden_step], golden_step+1);
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			@(negedge clk);
			$finish;
		end
		if (golden_step == 4 && out_value !== golden_value) begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                        FAIL!                                                               ");
			$display ("                                                                   Pattern NO.%03d                                                          ", patcount);
			$display ("                                                              Your output -> out_value: %d                                                  ", out_value);
			$display ("                                                            Golden output -> out_value: %d                                                  ", golden_value);
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			@(negedge clk);
			$finish;
		end
		@(negedge clk);
		golden_step=golden_step+1;
	end
	if(golden_step !== 5) begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        FAIL!                                                               ");
		$display ("                                                                   Pattern NO.%03d                                                          ", patcount);
		$display ("	                                                          Output cycle should be 5 cycles                                                  ");
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

