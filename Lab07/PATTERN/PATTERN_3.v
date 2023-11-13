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
parameter PATNUM = 4000;


integer total_latency, patcount, lat;
integer ready_cycles_now, ready_cycles;
integer A;
integer T;
integer account;
integer performance;
integer input_file;
integer a, b, c, d, e, g, h;
integer i;
integer performance_store[0:4];
integer A_store[0:4], T_store[0:4], account_store[0:4];
integer gold_performance, gold_account;
reg [7:0]gold_account_store[0:3995];
integer gold_performance_store[0:3995];
integer input_patcount;
integer clk2_lat, clk1_lat;
integer not_ready = 0;
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

always@(negedge clk2)begin
	if(patcount == 3996)
		YOU_PASS_task;
	if(input_patcount == 0)begin
		not_ready = not_ready + 1;
	end
	if(not_ready == 100000)begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        FAIL!                                                               ");
		$display ("                                                   		  Pls pull up ready                                            ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");

		repeat(2)@(negedge clk2);
		$finish;
	end
	if(input_patcount > 0)begin
		clk2_lat = clk2_lat + 1;
	end
	if(clk2_lat == 100000)begin
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        FAIL!                                                               ");
		$display ("                                                     The execution latency are over 100000   cycles                                            ");
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");

		repeat(2)@(negedge clk2);
		$finish;
	end
	if(out_valid === 1 && patcount < 3996)begin
		if(out_account === gold_account_store[patcount])begin
			//patcount = patcount + 1;
			$display("\033[0;34mPASS PATTERN NO.%4d,\033[m out_account: ", patcount, gold_account_store[patcount]);
			patcount = patcount + 1;
		end
		else begin
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			$display ("                                                                        FAIL!                                                               ");
			$display ("                                                                   PATTERN NO.%4d					                              ",patcount);
			$display ("                                                     Ans account: %d,  Your output : %d                                               ",gold_account_store[patcount],out_account);
			$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
			repeat(9) @(negedge clk2);
			$finish;
		end
	end
end

initial begin

    rst_n = 1;    
    in_valid = 1'b0; 
	in_account = 'bx;
	in_A = 'bx;
	in_T = 'bx;
	patcount = 0;
	clk2_lat = -1;
	not_ready = 0;
	
	force clk1 = 0;
	force clk2 = 0;
	
    total_latency = 0; 
	reset_signal_task;
	input_file  = $fopen("../00_TESTBED/input.txt","r");
	ready_cycles = 0;
	ready_cycles_now = 0;
	input_patcount = 0;
	
	
	clk1_lat = -1;
	
	for (i=0;i<5;i=i+1)begin
		performance_store[i] = 65026;
		account_store[i] = 256;
	end
	account = 256;
	performance = 65026;
	while(input_patcount != 4000)begin
		@(negedge clk1);
		input_task;
		
	end
	//$finish;
	
end
//================================================================
// task
//================================================================
task reset_signal_task; begin 
    #(0.5);   rst_n=0;
	
	#(2.0);
	if((out_valid !== 0)||(out_account !== 0)||(ready !== 0)) begin
		//fail;
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");
		$display ("                                                                        FAIL!                                                               ");
		$display ("                                                  Output signal should be 0 after initial RESET at %t                                 ",$time);
		$display ("--------------------------------------------------------------------------------------------------------------------------------------------");

		
		$finish;
	end
	#(10);   rst_n=1;
	#(3);   
	release clk1;
	release clk2;
end endtask


task input_task; begin
	if(input_patcount > 0)begin
		clk1_lat = clk1_lat + 1;
	end
	if(input_patcount == 4000)begin
		in_A = 'dx;
		in_T = 'dx;
		in_account = 'dx;
		in_valid = 0;
		//ready_cycles_now = ready_cycles_now + 1;
	end
	else if(ready)begin
		if(ready_cycles_now == 0)begin
			a = $fscanf (input_file, "%d", ready_cycles);
		end
		if(ready_cycles == ready_cycles_now)begin
			in_valid = 1;
			//performance = 0;
			A = $urandom_range(1, 255);
			T = $urandom_range(1, 255);
			performance = A*T;
			
			performance_store[0] = performance_store[1];
			performance_store[1] = performance_store[2];
			performance_store[2] = performance_store[3];
			performance_store[3] = performance_store[4];
			performance_store[4] = performance;
			
			A_store[0] = A_store[1];
			A_store[1] = A_store[2];
			A_store[2] = A_store[3];
			A_store[3] = A_store[4];
			A_store[4] = A;
			T_store[0] = T_store[1];
			T_store[1] = T_store[2];
			T_store[2] = T_store[3];
			T_store[3] = T_store[4];
			T_store[4] = T;
			
			in_A = A;
			in_T = T;
			
			//account = 256;
			while(account == account_store[1] || account == account_store[2] || account == account_store[3] || account == account_store[4])begin
				account = $urandom_range(0, 255);
			end
			account_store[0] = account_store[1];
			account_store[1] = account_store[2];
			account_store[2] = account_store[3];
			account_store[3] = account_store[4];
			account_store[4] = account;
			
			if(performance_store[0] < performance_store[1])begin
				gold_performance = performance_store[0];
				gold_account = account_store[0];
			end
			else begin
				gold_performance = performance_store[1];
				gold_account = account_store[1];
			end
			
			if(performance_store[2] <= gold_performance)begin
				gold_performance = performance_store[2];
				gold_account = account_store[2];
			end
			
			if(performance_store[3] <= gold_performance)begin
				gold_performance = performance_store[3];
				gold_account = account_store[3];
			end
			
			if(performance_store[4] <= gold_performance)begin
				gold_performance = performance_store[4];
				gold_account = account_store[4];
			end
			
			if(input_patcount >=4)begin
				gold_account_store[input_patcount - 4] = gold_account;
				gold_performance_store[input_patcount - 4] = gold_performance;
			end
			
			in_account = account;
			ready_cycles_now = 0;
			input_patcount = input_patcount + 1;
		end
		else begin
			in_A = 'dx;
			in_T = 'dx;
			in_account = 'dx;
			in_valid = 0;
			ready_cycles_now = ready_cycles_now + 1;
		end
	end
	else begin
		in_A = 'dx;
		in_T = 'dx;
		in_account = 'dx;
		in_valid = 0;
		//ready_cycles_now = ready_cycles_now + 1;
	end
end endtask



task YOU_PASS_task; begin
    $display ("----------------------------------------------------------------------------------------------------------------------");
    $display ("                                                  Congratulations!                						            ");
    $display ("                                           You have pased all patterns!          						            ");
    $display ("                                           Your execution latency = %5d cycles   						            ", clk1_lat);
    $display ("                                           Your clock period = %.1f ns        					                ", `CYCLE_TIME_clk1);
    $display ("                                           Your total latency = %.1f ns         						            ", clk1_lat*`CYCLE_TIME_clk1);
    $display ("----------------------------------------------------------------------------------------------------------------------");
    $finish;
end endtask

endmodule 