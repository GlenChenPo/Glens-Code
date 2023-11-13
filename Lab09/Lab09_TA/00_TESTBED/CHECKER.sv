//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//
//   File Name   : CHECKER.sv
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module Checker(input clk, INF.CHECKER inf);
import usertype::*;

integer test1, test2, test3, test4, test5, fp_w;

initial begin
fp_w = $fopen("out_valid.txt", "w");
end

/*
1.Create a covergroup including coverpoint inf.out_info[31:28] and inf.out_info[27:24]
(Player Pokemon info when action is not Attack; Defender Pokemon info when action is Attack).
The bins of inf.out_info[31:28] needs to be No_stage, Lowest, Middle and Highest, respectively. 
The bins of inf.out_info[27:24] needs to be No_type, Grass, Fire, Water, Electric, Normal, respectively. 
Each bin should be hit at least 20 times. (sample the value at negedge clk when inf.out_valid is high)
*/

covergroup coverage1@(negedge clk iff inf.out_valid);	
	option.per_instance = 1;
	option.at_least = 20;
	coverpoint inf.out_info[31:28]{
		bins stage_No_stage = {No_stage};	
        bins stage_Lowest   = {Lowest};
        bins stage_Middle   = {Middle};
        bins stage_Highest  = {Highest};
	}
       coverpoint inf.out_info[27:24]{
		bins type_No_type = {No_type};	
        bins type_Grass   = {Grass};
        bins type_Fire    = {Fire};
        bins type_Water   = {Water};
        bins type_Electric= {Electric};	
		bins type_Normal  = {Normal};	
	}
endgroup
coverage1 coverage_1 = new();

/*
2.Create a covergroup including coverpoint inf.D.d_id[0] (means 0~7 bits of input signal D when typing your ID)
 with auto_bin_max = 256. (means that you need to divide the inf.D.d_id[0] signal into 256 bins averagely). 
 And each bin has to be hit at least 1 time. (sample the value at posedge clk when id_valid is high)
*/
covergroup coverage2@(posedge clk iff inf.id_valid);	
	option.per_instance = 1;
	option.at_least = 1;
	coverpoint inf.D.d_id[0]{
		option.auto_bin_max = 256;	
	}
endgroup
coverage2 coverage_2 = new();

/*
3.Create a covergroup including coverpoint inf.D.d_act[0] (means 0~3 bits of input signal D when typing your action). 
There are six actions for inf.D.d_act[0]: Buy, Sell, Deposit, Check, Use_item, Attack. 
Create the transition bins from one action to itself or others. 
such as: Buy to Buy, Buy to Sell, Buy to Deposit, Buy to Check, Buy to Use_item, Buy to Attack and so on. 
There are total 36 transition bins. Each transition bin should be hit at least 5 times. (sample the value at posedge clk when act_valid is high).
*/
covergroup coverage3@(posedge clk iff inf.act_valid);	
	option.per_instance = 1;
	option.at_least = 10;
	coverpoint inf.D.d_act[0]{
		bins bin [] = (Buy,Sell,Deposit,Check,Use_item,Attack => Buy,Sell,Deposit,Check,Use_item,Attack);	
	}
endgroup
coverage3 coverage_3 = new();
/*
4.Create a covergroup including coverpoints inf.complete. 
The bins of inf.complete need to be 0 and 1, and each bin should be hit at least 200 times. 
(sample the value at negedge clk when inf.out_valid is high) 
*/
covergroup coverage4@(negedge clk iff inf.out_valid);	
	option.per_instance = 1;
	option.at_least = 200;
	coverpoint inf.complete{
		bins complete_0 = {0};
		bins complete_1 = {1};
	}
endgroup
coverage4 coverage_4 = new();
/*
5.Create a covergroup including coverpoint inf.err_msg. 
Every case of inf.err_msg except No_Err should occur at least 20 times. 
(sample the value at negedge clk when inf.out_valid is high)
*/
covergroup coverage5@(negedge clk iff inf.out_valid);	
	option.per_instance = 1;
	option.at_least = 20;
	coverpoint inf.err_msg{		
		bins bin [] = {Already_Have_PKM, Out_of_money, Bag_is_full, Not_Having_PKM, Has_Not_Grown, Not_Having_Item, HP_is_Zero};
	}
endgroup
coverage5 coverage_5 = new();

initial begin
	test1 = 0;
	test2 = 0;
	test3 = 0;
	test4 = 0;
	test5 = 0;
	forever @(posedge clk) begin
		if ( coverage_1.get_coverage() == 100  && test1 == 0 ) begin
			test1 = test1 + 1;
			$display( "\033[32m--- Coverage 1 pass ---\033[0m" );
		end

		if ( coverage_2.get_coverage() == 100  && test2 == 0 ) begin
			test2 = test2 + 1;
			$display( "\033[32m--- Coverage 2 pass ---\033[0m" );
		end

		if ( coverage_3.get_coverage() == 100  && test3 == 0 ) begin
			test3 = test3 + 1;
			$display( "\033[32m--- Coverage 3 pass ---\033[0m" );
		end

		if ( coverage_4.get_coverage() == 100  && test4 == 0 ) begin
			test4 = test4 + 1;
			$display( "\033[32m--- Coverage 4 pass ---\033[0m" );
		end
		
		if ( coverage_5.get_coverage() == 100  && test5 == 0 ) begin
			test5 = test5 + 1;
			$display( "\033[32m--- Coverage 5 pass ---\033[0m" );
		end

	end
end

always @(posedge inf.out_valid) begin
	outvalid_check_1 : assert property ( @(negedge clk) (inf.out_valid) |-> inf.out_valid ) begin
		// $display( inf.out_valid );
		$fwrite(fp_w, "%d\n", inf.out_valid);
	end
	else begin
		$display("Assertion 6 is violated");
		$fatal; 
	end

	outvalid_check_2 : assert property ( @(negedge clk) (inf.out_valid) |=> inf.out_valid==0) begin
		// $display( inf.out_valid );
		$fwrite(fp_w, "%d\n", inf.out_valid);
	end
	else begin
		$display("Assertion 6 is violated");
		$fatal; 
	end
end

//************************************ below assertion is to check your pattern ***************************************** 

endmodule