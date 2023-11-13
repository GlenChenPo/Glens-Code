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



Action act_input;

always_ff @(posedge clk or negedge inf.rst_n) 
  begin 
    if(!inf.rst_n)
      begin
       act_input <= No_action;
      end
    else if(inf.act_valid)
      begin
        act_input <= inf.D[3:0];
      end
    else if(inf.out_valid)
      begin
        act_input <= No_action;
      end
    else 
      begin
        act_input <= act_input;
      end
  end

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
//                                          Please finish and hand in it
// This is an example assertion given by TA, please write the required assertions below
//  assert_interval : assert property ( @(posedge clk)  inf.out_valid |=> inf.id_valid == 0 [*2])
//  else
//  begin
//  	$display("Assertion X is violated");
//  	$fatal; 
//  end

// 1. All outputs signals (including pokemon.sv and bridge.sv) should be zero after reset.
  assert_rst: assert property ( @(posedge inf.rst_n) (inf.rst_n==1'b0) |-> (inf.out_valid==0 && inf.out_info==0 && inf.err_msg==0 && inf.complete==0
  && inf.C_addr==0 && inf.C_data_w==0 && inf.C_in_valid==0 && inf.C_r_wb==0 && inf.C_out_valid==0 && inf.C_data_r==0 && inf.AR_VALID==0 && inf.AR_ADDR==0
  && inf.R_READY==0 && inf.AW_VALID==0 && inf.AW_ADDR==0 && inf.W_VALID==0 && inf.W_DATA==0 && inf.B_READY==0))  
 else
 begin
 	$display("Assertion 1 is violated");
 	$fatal; 
 end

// 2. If action is completed, err_msg should be 4’b0.
  assert_err_msg: assert property ( @(posedge clk) (inf.out_valid===1'b1 && inf.complete===1'b1) |-> (inf.err_msg===No_Err))  
 else
 begin
 	$display("Assertion 2 is violated");
 	$fatal; 
 end

// 3. If action is not completed, out_info should be 64’b0.
 assert_out_info: assert property ( @(posedge clk) (inf.out_valid===1'b1 && inf.complete===1'b0) |-> (inf.out_info===64'b0))  
 else
 begin
 	$display("Assertion 3 is violated");
 	$fatal; 
 end

// 4. The gap between each input valid is at least 1 cycle and at most 5 cycles.
assert_gap_Sell: assert property ( @(posedge clk) ((inf.id_valid===1 && act_input===Sell) |=> ##[1:5] inf.act_valid===1) 
and ((inf.act_valid===1 && inf.D.d_act[0]===Sell) |=> ##[1:5](inf.type_valid===1 || inf.item_valid===1))) 
 else
 begin
 	$display("Assertion 4 is violated");
 	$fatal; 
 end

assert_gap_Buy: assert property ( @(posedge clk) ((inf.id_valid===1 && act_input===Buy) |=> ##[1:5] inf.act_valid===1) 
and ((inf.act_valid===1 && inf.D.d_act[0]===Buy) |=> ##[1:5](inf.type_valid===1 || inf.item_valid===1))) 
 else
 begin
 	$display("Assertion 4 is violated");
 	$fatal; 
 end

assert_gap_Use: assert property ( @(posedge clk)((inf.id_valid===1 && act_input===Use_item)|=>##[1:5] inf.act_valid===1)
 and ((inf.act_valid===1 && inf.D.d_act[0]===Use_item) |=>##[1:5] inf.item_valid===1)) 
 else
 begin
 	$display("Assertion 4 is violated");
 	$fatal; 
 end

assert_gap_Deposit: assert property ( @(posedge clk) ((inf.id_valid===1 && act_input===Deposit)|=> ##[1:5] inf.act_valid===1) 
and ((inf.act_valid===1 && inf.D.d_act[0]===Deposit)|=>##[1:5] inf.amnt_valid===1)) 
 else
 begin
 	$display("Assertion 4 is violated");
 	$fatal; 
 end

//  assert_gap_Check: assert property ( @(posedge clk) ((inf.id_valid==1 && act_input==Check)|-> ##[1:5] inf.act_valid===1) 
// ) 
//  else
//  begin
//  	$display("Assertion 4 is violated");
//  	$fatal; 
//  end

 assert_gap_IDtoAct: assert property ( @(posedge clk) ((inf.id_valid===1 && act_input!==Attack)|=> ##[1:5] inf.act_valid===1) 
) 
 else
 begin
 	$display("Assertion 4 is violated");
 	$fatal; 
 end
// assert_gap_Attack1: assert property ( @(posedge clk)
// ((inf.id_valid===1 && act_input===Attack) |=> ##[1:5] (inf.act_valid===1 && inf.D.d_act[0]===Attack) |=>##[1:5] inf.id_valid==1)) 
//  else
//  begin
//  	$display("Assertion 4 is violated");
//  	$fatal; 
//  end

assert_gap_Attack2: assert property ( @(posedge clk)  ((inf.act_valid===1 && inf.D.d_act[0]===Attack) |=>##[1:5] inf.id_valid==1)
) 
 else
 begin
 	$display("Assertion 4 is violated");
 	$fatal; 
 end

//--------------- 5. All input valid signals won’t overlap with each other.------------------------------------------------------------------------------------------ 
assert_in_overlap: assert property ( @(posedge clk) ((inf.id_valid==1'b1) |-> (inf.act_valid==1'b0 && inf.item_valid==1'b0 && inf.type_valid==1'b0 && inf.amnt_valid==1'b0))
                                                and  ((inf.act_valid==1'b1) |-> (inf.id_valid==1'b0 && inf.item_valid==1'b0 && inf.type_valid==1'b0 && inf.amnt_valid==1'b0)) 
                                                and  ((inf.item_valid==1'b1) |-> (inf.act_valid==1'b0 && inf.id_valid==1'b0 && inf.type_valid==1'b0 && inf.amnt_valid==1'b0))  
                                                and  ((inf.type_valid==1'b1) |-> (inf.act_valid==1'b0 && inf.item_valid==1'b0 && inf.id_valid==1'b0 && inf.amnt_valid==1'b0))  
                                                and  ((inf.amnt_valid==1'b1) |-> (inf.act_valid==1'b0 && inf.item_valid==1'b0 && inf.type_valid==1'b0 && inf.id_valid==1'b0)) )
 else
 begin
 	$display("Assertion 5 is violated");
 	$fatal; 
 end


//--------------- 6. Out_valid can only be high for exactly one cycle.-----------------------------------------------------------------------------------------------
// assert_out_valid: assert property ( @(posedge clk) (inf.out_valid===1) |=> (inf.out_valid===0))  
//  else
//  begin
//  	$display("Assertion 6 is violated");
//  	$fatal; 
//  end

//--------------- 7. Next operation will be valid 2-10 cycles after out_valid fall.----------------------------------------------------------------------------------
assert_gap: assert property ( @(posedge clk) ((inf.out_valid==1 |-> (inf.id_valid==0 && inf.act_valid==0 && inf.item_valid==0 && inf.type_valid==0 && inf.amnt_valid==0))
and (inf.out_valid==1 |=> (inf.id_valid==0 && inf.act_valid==0 && inf.item_valid==0 && inf.type_valid==0 && inf.amnt_valid==0)) 
and ( (inf.out_valid==1 |-> ##[2:10] (inf.id_valid==1 || inf.act_valid==1)) ) ) )  
 else
 begin
 	$display("Assertion 7 is violated");
 	$fatal; 
 end

//--------------- 8. Latency should be less than 1200 cycles for each operation.-------------------------------------------------------------------------------------
assert_laten_1: assert property ( @(posedge clk) ((act_input===Buy && (inf.item_valid===1 || inf.type_valid===1)) |=> ##[1:1200] inf.out_valid===1)) 
 else
 begin
 	$display("Assertion 8 is violated");
 	$fatal; 
 end

assert_laten_2: assert property ( @(posedge clk) ((act_input===Sell && (inf.item_valid===1 || inf.type_valid===1))  |=> ##[1:1200] inf.out_valid===1))
 else
 begin
 	$display("Assertion 8 is violated");
 	$fatal; 
 end

assert_laten_3: assert property ( @(posedge clk) ((act_input===Deposit && inf.amnt_valid===1) |=> ##[1:1200] inf.out_valid===1))
  else
  begin
  	$display("Assertion 8 is violated");
  	$fatal; 
  end
 
assert_laten_4: assert property ( @(posedge clk) ((act_input===Use_item && inf.item_valid===1) |=> ##[1:1200] inf.out_valid===1))
 else
 begin
 	$display("Assertion 8 is violated");
 	$fatal; 
 end

assert_laten_5: assert property ( @(posedge clk) ((inf.D.d_act[0]===Check && inf.act_valid===1)  |=> ##[1:1200] inf.out_valid===1))
 else
 begin
 	$display("Assertion 8 is violated");
 	$fatal; 
 end

assert_laten_6: assert property ( @(posedge clk) ((act_input===Attack && inf.id_valid===1) |=> ##[1:1200] inf.out_valid===1)) 
 else
 begin
 	$display("Assertion 8 is violated");
 	$fatal; 
 end

endmodule

