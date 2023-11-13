
 
// fast to slow
`ifdef RTL
	`timescale 1ns/1ps
	`define CYCLE_TIME_clk1 10
	`define CYCLE_TIME_clk2 15
`endif
`ifdef GATE
	`timescale 1ns/1ps
	`define CYCLE_TIME_clk1 10
	`define CYCLE_TIME_clk2 15
`endif


/*
// slow to fast
`ifdef RTL
	`timescale 1ns/1ps
	`define CYCLE_TIME_clk1 16
	`define CYCLE_TIME_clk2 15
`endif
`ifdef GATE
	`timescale 1ns/1ps
	`define CYCLE_TIME_clk1 16
	`define CYCLE_TIME_clk2 15
`endif
*/


module PATTERN #(parameter DSIZE = 8,
			   parameter ASIZE = 4)(
	//Output Port
	rst_n,
	clk1,
    clk2,
	in_valid,
	in_account,
	in_A,
	in_T,

    //Input Port
	ready,
    out_valid,
	out_account
); 
//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
output reg				rst_n, clk1, clk2, in_valid;
output reg [DSIZE-1:0] 	in_account,in_A,in_T;

input 				ready, out_valid;
input [DSIZE-1:0] 	out_account;

//================================================================
// parameters & integer
//================================================================
// input 
integer input_file, output_file;
integer total_cycles, cycles;
integer PATNUM, patcount;
integer gap;
integer in_counter, out_counter;

integer i, j;
integer a, b, c, d, e;

// output
integer f;
integer golden_step;

//================================================================
// Wire & Reg Declaration
//================================================================
reg [DSIZE-1:0] golden_account[3999:0], golden_A[3999:0], golden_T[3999:0];
reg [DSIZE-1:0] golden_out_account[3995:0];
//================================================================
// clock
//================================================================
real CYCLE1 = `CYCLE_TIME_clk1;
initial clk1 = 0;
always #(CYCLE1/2.0) clk1 = ~clk1;

real CYCLE2 = `CYCLE_TIME_clk2;
initial clk2 = 0;
always #(CYCLE2/2.0) clk2 = ~clk2;

//================================================================
// initial
//================================================================



initial begin

	rst_n    = 1'b1;
	in_valid = 1'b0;
	in_account = 'bx;
	in_A = 'bx;
	in_T = 'bx;	

	input_file  = $fopen("../00_TESTBED/input.txt","r");
	output_file  = $fopen("../00_TESTBED/output.txt","r");	
	a = $fscanf(input_file, "%d", PATNUM);
	
	for (patcount=0;patcount<PATNUM;patcount=patcount+1) begin
		reset_task;
		input_data;
		wait_out_finish;
		$display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles: %3d\033[m", patcount ,total_cycles);
	end
	#(1000);
	$finish;	
	
end


//================================================================
// task
//================================================================

task reset_task ; begin 
	force clk1 = 0;
	force clk2 = 0;
	#(10); rst_n = 0;
	#(10);
	
	if( (out_valid !== 0) || (out_account !== 0) ) begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                  Output signal should be 0 after initial RESET at %8t                                      ",$time);
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		#(100);
	    $finish ;
	end
	
	#(10); rst_n = 1 ;
	#(3.0); 
	release clk1;
	release clk2;
	
	@(negedge clk1);
end endtask


task input_data; begin 
	
	total_cycles = 0; in_counter  = 0; out_counter = 0;
	for(i=0; i<4000; i=i+1) b = $fscanf (input_file, "%d", golden_account[i]); 
	for(i=0; i<4000; i=i+1) c = $fscanf (input_file, "%d", golden_A[i]); 
	for(i=0; i<4000; i=i+1) d = $fscanf (input_file, "%d", golden_T[i]); 
	for(i=0; i<3996; i=i+1) d = $fscanf (output_file, "%d", golden_out_account[i]); 
	
	gap = $urandom_range(2,4);
	repeat(gap) @(negedge clk1);
	
	while(in_counter < 4000)begin
		while(ready !== 1)begin
			in_valid = 0;
			in_account = 'bx;
			in_A = 'bx;
			in_T = 'bx;	
			@(negedge clk1);
		end
		
		//gap = $urandom_range(0,149);
		//repeat(gap) @(negedge clk1);
		
		while(ready === 1 && in_counter < 4000)begin
			in_valid = 1;
			in_account = golden_account[in_counter];
			in_A = golden_A[in_counter];
			in_T = golden_T[in_counter];
			in_counter = in_counter + 1;
			@(negedge clk1);
		end
	end
	in_valid = 0;
	in_account = 'bx;
	in_A = 'bx;
	in_T = 'bx;	
	
end endtask

task wait_out_finish; begin 
	while(out_counter < 3996)begin
		@(negedge clk2);
	end
	
end endtask

always@(negedge clk2)begin
	if(total_cycles == 0)begin
		total_cycles = (in_valid == 1)? total_cycles+1 : 0;
	end else begin
		total_cycles = total_cycles + 1;
		if(total_cycles > 100000)begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                        FAIL!                                                               ");
			$display ("                                                            can not over 100,000 clk2 cycles                                                 ");
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			@(negedge clk2);
			$finish;			
		end
	end
end


always@(negedge clk2)begin
	if(out_valid === 1)begin
		if(out_counter < 3996)begin
			if(out_account !== golden_out_account[out_counter])begin
				$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
				$display ("                                                                        FAIL!                                                               ");
				$display ("                                                          Pattern NO.%03d  Counter : %d 	    at %8t                                         ", patcount, out_counter, $time );
				$display ("                                                              Your output -> out_account: %d                                                ", out_account );
				$display ("                                                            Golden output -> out_account: %d		                                           ", golden_out_account[out_counter] );
				$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
				@(negedge clk2);
				$finish;			
			end
			out_counter = out_counter + 1;
		end
	end else begin
		if(out_account !== 0)begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                        FAIL!                                                               ");
			$display ("                                                                   Pattern NO.%03d                                                          ", patcount);
			$display ("                                                      The output should be 0 when out_valid = 0.                                            ");
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			repeat(2)@(negedge clk2);
			$finish;		
		end
	end

end



endmodule 