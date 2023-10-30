`define CYCLE_TIME 20.0
module PATTERN(
// Output signals
  in_n0,
  in_n1,
  in_n2,
  in_n3,
  in_n4,
  in_n5,
  opt,
  equ,
  // Input signals
  out_n
);
//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
output reg [3:0] in_n0, in_n1, in_n2, in_n3, in_n4, in_n5;
output reg [2:0] opt;
output reg equ;

input [9:0] out_n;
//================================================================
// parameters & integer
//================================================================
integer PATNUM = 1000;
integer seed;
integer total_latency;
integer patcount;
integer file_in, file_out, cnt_in, cnt_out;
integer lat,i,j;
//================================================================
// wire & registers 
//================================================================
reg signed [4:0] n [5:0];
reg [4:0] temp;
reg signed [10:0] temp_cal;
reg [9:0] out_n_ans;
//================================================================
// clock
//================================================================
reg clk;
real	CYCLE = `CYCLE_TIME;
always	#(CYCLE/2.0) clk = ~clk;
initial	clk = 0;

//================================================================
// initial
//================================================================
initial begin

    in_n0 = 4'dx;
	in_n1 = 4'dx;
	in_n2 = 4'dx;
	in_n3 = 4'dx;
    in_n4 = 4'dx;
	in_n5 = 4'dx;
	opt = 3'dx;
    equ = 2'bx;
    
	total_latency = 0;
	seed = 32;

	for(patcount = 0; patcount < PATNUM; patcount = patcount + 1)
	begin		
		gen_data;
		gen_golden;
        repeat(1) @(negedge clk);
		check_ans;
		repeat(3) @(negedge clk);
	end
    
	display_pass;
    
    repeat(3) @(negedge clk);
    $finish;
	$fclose(file_in);
	$fclose(file_out);
end

//================================================================
// task
//================================================================
task gen_data; begin
	//generate operation and inputs 
    in_n0=$random(seed)%'d16;
    in_n1=$random(seed)%'d16;
    in_n2=$random(seed)%'d16;
    in_n3=$random(seed)%'d16;
    in_n4=$random(seed)%'d16;
    in_n5=$random(seed)%'d16;
    opt = $random(seed)%'d8;
    equ = $random(seed)%'d4;
end endtask


task gen_golden; begin
	n[0]=(opt[0])? {in_n0[3],in_n0}:{1'b0,in_n0};
    n[1]=(opt[0])? {in_n1[3],in_n1}:{1'b0,in_n1};
    n[2]=(opt[0])? {in_n2[3],in_n2}:{1'b0,in_n2};
    n[3]=(opt[0])? {in_n3[3],in_n3}:{1'b0,in_n3};
    n[4]=(opt[0])? {in_n4[3],in_n4}:{1'b0,in_n4};
    n[5]=(opt[0])? {in_n5[3],in_n5}:{1'b0,in_n5};
    //$display("in_n0[0]=%d in_n0[1]=%d in_n0[2]=%d in_n0[3]=%d in_n0[4]=%d in_n0[5]=%d",n[0],n[1],n[2],n[3],n[4],n[5]);
    if(opt[1])
    begin
        for(i=0;i<5;i=i+1)
        begin
            for(j=0;j<5-i;j=j+1)
            begin
                if(n[j]<n[j+1])
                begin
                    temp=n[j];
                    n[j]=n[j+1];
                    n[j+1]=temp;
                end
            end
        end
    end
	if(!opt[1])
    begin
        for(i=0;i<5;i=i+1)
        begin
            for(j=0;j<5-i;j=j+1)
            begin
                if(n[j]>n[j+1])
                begin
                    temp=n[j];
                    n[j]=n[j+1];
                    n[j+1]=temp;
                end
            end
        end
    end
    //$display("n[0]=%d n[1]=%d n[2]=%d n[3]=%d n[4]=%d n[5]=%d",n[0],n[1],n[2],n[3],n[4],n[5]);
    if(!opt[2])begin
        n[1]=n[1]-n[0];
        n[2]=n[2]-n[0];
        n[3]=n[3]-n[0];
        n[4]=n[4]-n[0];
        n[5]=n[5]-n[0];
        n[0]=0;
    end
	if(opt[2])begin
		n[0]=(n[0]*2+n[0])/3;
		n[1]=(n[0]*2+n[1])/3;
		n[2]=(n[1]*2+n[2])/3;
		n[3]=(n[2]*2+n[3])/3;
		n[4]=(n[3]*2+n[4])/3;
		n[5]=(n[4]*2+n[5])/3;
	end
    //$display("n[0]=%d n[1]=%d n[2]=%d n[3]=%d n[4]=%d n[5]=%d",n[0],n[1],n[2],n[3],n[4],n[5]);
    temp_cal=(n[5]*n[1])-(n[5]*n[0]);
   
    out_n_ans=(equ==0)? ((n[3]+n[4]*4)*n[5])/3:
                     (temp_cal[10])? ~temp_cal+1:
                        temp_cal;
end endtask

task check_ans; 
begin
    //$fscanf(golden,"%d",golden_circle);  
    //$fscanf(golden,"%d",golden_value); 
                
    if(out_n!==out_n_ans)
    begin
        display_fail;
        $display ("-------------------------------------------------------------------");
		$display("*                            PATTERN NO.%4d 	                ",patcount);
        $display ("             answer should be : %d , your answer is : %d           ", out_n_ans, out_n);
        $display ("-------------------------------------------------------------------");
        #(100);
        $finish ;
    end
    else 
        $display ("             Pass Pattern NO. %d          ", patcount);
end
endtask
task display_fail;
begin
        $display("\n");
        $display("\n");
        $display("        ----------------------------               ");
        $display("        --                        --       |\__||  ");
        $display("        --  OOPS!!                --      / X,X  | ");
        $display("        --                        --    /_____   | ");
        $display("        --  Simulation Failed!!   --   /^ ^ ^ \\  |");
        $display("        --                        --  |^ ^ ^ ^ |w| ");
        $display("        ----------------------------   \\m___m__|_|");
        $display("\n");
end
endtask

task display_pass;
begin
        $display("\n");
        $display("\n");
        $display("        ----------------------------               ");
        $display("        --                        --       |\__||  ");
        $display("        --  Congratulations !!    --      / O.O  | ");
        $display("        --                        --    /_____   | ");
        $display("        --  Simulation PASS!!     --   /^ ^ ^ \\  |");
        $display("        --                        --  |^ ^ ^ ^ |w| ");
        $display("        ----------------------------   \\m___m__|_|");
        $display("\n");
end
endtask
endmodule
