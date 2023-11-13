//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : PATTERN_IP.v
//   Module Name : PATTERN_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`ifdef RTL
    `define CYCLE_TIME 60.0
`endif

`ifdef GATE
    `define CYCLE_TIME 60.0
`endif

module PATTERN_IP #(parameter WIDTH = 3) (
    // Input signals
    IN_P, IN_Q, IN_E,
    // Output signals
    OUT_N, OUT_D
);

// ===============================================================
// Input & Output Declaration
// ===============================================================
output reg [WIDTH-1:0]   IN_P, IN_Q;
output reg [WIDTH*2-1:0] IN_E;
input      [WIDTH*2-1:0] OUT_N, OUT_D;

// ===============================================================
// Parameter & Integer Declaration
// ===============================================================
real CYCLE = `CYCLE_TIME;
integer input_file, output_file;
integer PATNUM, patcount;
integer a, b, c, d, e, f;
integer i, j, k;

//================================================================
// Wire & Reg Declaration
//================================================================
reg clk;
reg [WIDTH-1:0]   in_data_p, in_data_q;
reg [WIDTH*2-1:0] in_data_e;
reg [WIDTH*2-1:0] golden_n;
reg [WIDTH*4-1:0] golden_m, golden_ed, mod_ed;

//================================================================
// Clock
//================================================================
initial clk = 0;
always #(CYCLE/2.0) clk = ~clk;

//================================================================
// Initial
//================================================================
initial begin
    IN_P = 0;
    IN_Q = 0;
    IN_E = 0;
    input_file  = $fopen ("../00_TESTBED/input_ip.txt", "r");

    @(negedge clk);
    a = $fscanf(input_file, "%d", PATNUM);
    for (patcount=0; patcount<PATNUM; patcount=patcount+1) begin
        input_task;
        @(negedge clk);
        check_ans_task;
    end
	@(negedge clk);
	YOU_PASS_task;
end

//================================================================
// TASK
//================================================================
task input_task; begin
    b = $fscanf(input_file, "%d", in_data_p);
    IN_P = in_data_p;
    c = $fscanf(input_file, "%d", in_data_q);
    IN_Q = in_data_q;
    d = $fscanf(input_file, "%d", in_data_e);
    IN_E = in_data_e;
end endtask

task check_ans_task; begin
    golden_n  = in_data_p * in_data_q;
    golden_m  = (in_data_p - 1) * (in_data_q - 1);
    golden_ed = in_data_e * OUT_D;
    mod_ed = golden_ed % golden_m;
    if(golden_n !== OUT_N) begin
		$display ("-------------------------------------------------------------------");
		$display ("                      PATTERN  %5d  FAILED!!!                      ", patcount);
		$display ("                   N: Correct: %8d, Yours: %8d                     ", golden_n, OUT_N);
		$display ("-------------------------------------------------------------------");
		repeat(7) @(negedge clk);
		$finish;
	end
    if (mod_ed !== 1) begin
        $display ("-------------------------------------------------------------------");
		$display ("                      PATTERN  %5d  FAILED!!!                      ", patcount);
		$display ("     OUT_D = %2d is not satisfied the requirement of private key   ", OUT_D);
        $display ("                     p = %2d                                       ", in_data_p);
        $display ("                     q = %2d                                       ", in_data_q);
        $display ("                     e = %2d                                       ", in_data_e);
		$display ("-------------------------------------------------------------------");
		repeat(7) @(negedge clk);
		$finish;
    end
	$display("\033[0;32mPASS PATTERN NO.%4d\033[m \033[0;32\033[m", patcount);
end endtask

task YOU_PASS_task; begin
	$display ("-------------------------------------------------------------------");
	$display ("            ~(￣▽￣)~(＿△＿)~(￣▽￣)~(＿△＿)~(￣▽￣)~            ");
	$display ("                          Congratulations!                         ");
	$display ("                   You have passed all patterns!                   ");
	$display ("-------------------------------------------------------------------");
	repeat(7) @(negedge clk);
	$finish;
end endtask


endmodule