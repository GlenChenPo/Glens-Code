`ifdef RTL
	`timescale 1ns/1ps
	`define CYCLE_TIME_clk1 3
	`define CYCLE_TIME_clk2 5
`endif
`ifdef GATE
	`timescale 1ns/1ps
	`define CYCLE_TIME_clk1 3
	`define CYCLE_TIME_clk2 5
`endif


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
integer input_file, output_file;
integer total_cycles, cycles;
integer patcount;
integer gap;
integer a, b, c, d, e, f, g;
integer i, j, k ;
integer golden_step;

parameter PATNUM = 1 ; 
integer seed = 30 ;

integer stall_cycle ;
integer total_stall_cycle ; 
integer continue_cycle ; 
integer total_output ; 
integer total_input  ; 
integer total_continue_cycle; 

integer max_performance;  
integer max_number ;
integer tmp_number;
integer min_sum ; 

integer total_current_delay ; 
integer total_delay ; 
integer all_cycles; 
// reg [7:0] in_T_data [0:3999]  ;
// reg [7:0] in_A_data [0:3999]  ;
reg [7:0] in_account_data [0:3999] ; 

reg [15:0] performance [0:3999] ; 
//================================================================
// clock
//================================================================
always	#(`CYCLE_TIME_clk1/2.0) clk1 = ~clk1;
initial	clk1 = 0;

always	#(`CYCLE_TIME_clk2/2.0) clk2 = ~clk2;
initial	clk2 = 0;

//================================================================
// initial
//================================================================
initial begin
	rst_n    = 1'b1;
	in_valid = 1'b0;
	
	
	// start    =  'bx;
	// stop     =  'bx;
	// window   =  'bx;
	// frame_id =  'bx; 
	// mode     =  'bx;
	total_output = 0 ;
	total_cycles = 0;
	total_input  = 0 ;
	cycles       = 0; 
	total_stall_cycle = 0 ;
	total_continue_cycle = 0 ;
	max_performance  = 0 ;
	max_number       = 0 ;
	all_cycles = 0 ;
	
	force clk1 = 0;
	force clk2 = 0;
	reset_task;

	// input_file  = $fopen("../00_TESTBED/input.txt","r");
  	// output_file = $fopen("../00_TESTBED/output.txt","r");
	@(negedge clk1);

	// a = $fscanf(input_file, "%d", PATNUM);
	for (patcount=0;patcount<PATNUM;patcount=patcount+1) begin
		while (total_output !== 3996)begin
			cycles = cycles + 'd1 ;
			@(negedge (clk2) ) ; 
			// input_data;
		end
		// compute_addr ;
		// compute_answer ; 
		// wait_out_valid; 
		// compute_addr ;
		// check_ans;
		$display("\033[0;34mPASS PATTERN NO.%4d,\033[m \033[0;32m Cycles: %3d\033[m", patcount ,cycles);
	end
	#(1000);
	YOU_PASS_task;
	$finish;
end 
//================================================================
// task
//================================================================
task reset_task ; begin
	#(10); rst_n = 0;
	#(10);
	if((ready !== 0) || (out_valid !== 0) || (out_account !== 0) ) begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        FAIL!                                                               ");
		$display ("                                                  Output signal should be 0 after initial RESET at %8t                                      ",$time);
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		#(100);
	    $finish ;
	end
	#(10); rst_n = 1 ;
	#(3.0); release clk1;
	release clk2;
	
end endtask


always@(negedge clk1 )begin
	if (total_stall_cycle == 'd150)
		stall_cycle = 0 ;
	else if (all_cycles >= 500)
		stall_cycle = 0 ;
	else
		stall_cycle = $urandom_range (0,1) ;
	
	if (ready && total_input < 4000  && stall_cycle == 0 ) begin
		total_stall_cycle = 0 ;
		in_valid = 1 ; 
				
		in_A       =  $random(seed) ;
		while (in_A===0)
			in_A = $random(seed) ; 

		in_T       =  $random(seed) ;
		while (in_T===0)
			in_T = $random(seed) ; 
			
		in_account =  $random(seed) ;
		in_account_data [total_input] = in_account ; 
		
		performance[total_input] = in_A * in_T ; 
		
		total_input = total_input + 1 ;
	end else begin
		in_valid = 0 ;
		in_A = 'dx ;
		in_T = 'dx ;
		in_account = 'dx ; 
	end
	total_stall_cycle = total_stall_cycle + 'd1 ; 
	all_cycles = all_cycles + total_stall_cycle  ;
end

always@(negedge clk2)begin
	if (out_valid)begin
		$display ("-----------OUT------- Your account -> result: %d                                                     ", out_account  );
		check_ans ; 
		total_output = total_output + 'd1 ;
		// @(negedge clk2);
	end
end



always@(*)begin
	if(cycles === 20000) begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        FAIL!                                                               ");
		$display ("                                                                   Cycles NO.%03d                                                          ", cycles);
		$display ("                                                     The execution latency are over 1,000,000 cycles                                            ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		repeat(2)@(negedge clk1);
		$finish;
	end
end

// task input_data; begin
		
	// while (ready && total_continue_cycle!==4000) begin
		// stall_cycle = $urandom_range (0,150) ;
		
		// if (total_continue_cycle >= 3000)
			// continue_cycle = 4000 - total_continue_cycle ; 
		// else	
			// continue_cycle = $urandom_range (1,1000) ; 
			
		// total_continue_cycle = total_continue_cycle + continue_cycle ; 
		
		// total_stall_cycle = total_stall_cycle + stall_cycle ; 
		
		// if (total_stall_cycle <500)
			// repeat(stall_cycle) @(negedge clk1 ) ;
		
		// for (i=0 ; i<continue_cycle ; i=i+1)begin
			// in_valid = 1 ; 
			
			// in_A       =  $urandom_range(1 , 255) ;
			// in_T       =  $urandom_range(1 , 255) ; 
			
			// in_account =  $urandom_range(0 , 255) ;
			// in_account_data [total_input] = in_account ; 
			
			// performance[total_input] = in_A * in_T ; 
			
			// total_input = total_input + 1 ;
			// @(negedge (clk2-clk1) )  ; 
			// if (out_valid)begin
				// $display ("-----------OUT---------------------");
				// check_ans ; 
				// total_output = total_output + 'd1 ;
				// @(negedge clk2);
			// end else begin
				// @(negedge clk2);
			// end
		// end
		
		// in_valid = 0 ;
		// in_A = 'dx ;
		// in_T = 'dx ;
		// in_account = 'dx ; 
		
		
		
		
		// cycles = cycles + 'd1 ;
			// if(cycles === 1000) begin
				// $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
				// $display ("                                                                        FAIL!                                                               ");
				// $display ("                                                                   Cycles NO.%03d                                                          ", cycles);
				// $display ("                                                     The execution latency are over 1,000,000 cycles                                            ");
				// $display ("--------------------------------------------------------------------------------------------------------------------------------------------");
				// repeat(2)@(negedge clk1);
				// $finish;
			// end
		// @( negedge clk1) ;
	// end
	
	// cycles = cycles + 'd1 ;
	// @( negedge clk1) ;
	
// end endtask 


task YOU_PASS_task; begin
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$display ("                                                  Congratulations!                						             ");
	$display ("                                           You have passed all patterns!          						             ");
	$display ("                                           Your execution cycles = %5d cycles   						                 ", cycles);
	$display ("                               Your clock1 period = %.1f ns  , Your clock2 period = %.1f ns       					 ", `CYCLE_TIME_clk1 , `CYCLE_TIME_clk2);
	$display ("                                           Your total latency = %.1f ns         						                 ", cycles*`CYCLE_TIME_clk2);
	$display ("----------------------------------------------------------------------------------------------------------------------");
	$finish;
end endtask  


task check_ans; begin

	// tmp_number = 0 ;
	// min_sum = 0 ;
	for (i=0 ; i<= 4 ; i=i+1) begin 
		if (i == 0 )begin
			min_sum = performance[total_output ] ; 
			max_number = total_output  ; 
		end else begin
			if (performance[total_output + i ] <= min_sum ) begin
				min_sum    = performance[total_output + i ] ;
				max_number = total_output + i ; 
			end	
		end
	end
	// max_number = tmp_number  ; 
	
	if (out_account !== in_account_data[max_number])begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        OUTPUT_FAIL!                                                               ");
		$display ("------------------------------------------------------------------have passed : %d output--------------------------------------" , total_output );
		$display ("                                                              Your account -> result: %d                                                     ", out_account  );
		$display ("                                                            Golden output -> result: %d                                         ", in_account_data[max_number] );
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		repeat(2) @(negedge clk2);
		$finish;
	end
	
	
end endtask




endmodule 