/*****************************************************************************/
// MODULE:  Formal Env for Customized Invalid Outvalid to AXI4-Lite Bridge 
// FILE NAME: top.sv
// VERSION:   1.0
// DATE:      NOV 30, 2020
// AUTHOR:    Kai-Jyun Hung
// CODE TYPE: RTL or Behavioral Level
// DESCRIPTION: 
//        This rtl environment is used as course material for ICLAB Course 2020 Fall  
//        System Verilog Course Series @ Formal Verification
// (c) COPYRIGHT 2020 OASIS LAB, ED317A @ NCTU
// (c) COPYRIGHT 2020 Cadence Design Systems, Inc.
// ALL RIGHT RESERVED.
//
//MODIFICATION HISTORY:
// Date Description:
// 
/******************************************************************************/

module top;
 
  parameter ADDR_WIDTH = 8;
  parameter DATA_WIDTH = 32;
 
  INF  inf(SystemClock);
  bridge    dut_b(.clk(SystemClock), .inf(inf.bridge_inf) );
/*
	Vld   AR_READY, R_VALID, AW_READY, W_READY, B_VALID, B_RESP,
	      AR_VALID, R_READY, AW_VALID, W_VALID, B_READY;
		  
    logic [31:0] R_DATA, W_DATA;
	logic [16:0] AW_ADDR, AR_ADDR;

*/ 

    axi4_slave slave (
        .aclk            (SystemClock),
        .aresetn         (inf.rst_n),
        .awaddr          (inf.AW_ADDR),    	        
        .awvalid         (inf.AW_VALID),    		
        .awready         (inf.AW_READY),    		
     
        .wdata           (inf.W_DATA),    		
        .wvalid          (inf.W_VALID),    		
        .wready          (inf.W_READY),    		
//        .wstrb           (4'b1111),
        
        .bresp           (inf.B_RESP),    		
        .bvalid          (inf.B_VALID),    		
        .bready          (inf.B_READY),    		
        
        .araddr          (inf.AR_ADDR),    		
        .arvalid         (inf.AR_VALID),   		
        .arready         (inf.AR_READY),    		
        
        .rdata           (inf.R_DATA),     	 	
        .rvalid          (inf.R_VALID),   	 	
        .rready          (inf.R_READY)     		
        
    );

    defparam slave.ADDR_WIDTH              = ADDR_WIDTH;
    defparam slave.DATA_WIDTH              = DATA_WIDTH;
    defparam slave.MAX_PENDING             = 1;
    defparam slave.MAX_PENDING_WR          = 1;
    defparam slave.MAX_PENDING_RD          = 1;
    defparam slave.DATA_BEFORE_CONTROL_ON  = 1;
// Exmaple of Using Glue Logic:
// Motivation: 
//             Allow One Cycle C_in_valid 
//             only after C_out_valid is high , then next C_in_valid could be trigger

// GLUE LOGIC,  design_trigger 0 : BRIDGE IS IDLE , 1 : BRIDGE IS BUSY
reg design_trigger;
always@(posedge SystemClock)begin
    if(inf.C_out_valid == 1'b1) begin
        design_trigger <= 1'b0;
    end
    else if(inf.C_in_valid == 1'b1)begin
        design_trigger <= 1'b1;
    end
    else begin
        design_trigger <= design_trigger;
    end
end

// Assume Property
// in posedge clk, if design_trigger is 1, then no more C_in_valid
//                 if design_trigger is 0, then C_in_valid could be 1 or 0 
asm_invalid_i: assume property ( @(posedge SystemClock) design_trigger  |->  ! inf.C_in_valid); 
// Assert Property
// This is for verify whehter our assume property works !!!
assert_invalid_i: assert property ( @(posedge SystemClock) inf.C_in_valid  |=>  ! inf.C_in_valid); 

// GLUE LOGIC for indicate which mode we are testing
enum logic[1:0] {NO=2'd0,READ=2'd1,WRITE=2'd2} testmode;
always@(posedge SystemClock)begin
    if(inf.C_out_valid)
        testmode <= NO;
    else if(inf.C_in_valid)
        testmode <= (inf.C_r_wb) ? READ : WRITE;
    else 
        testmode <= testmode;
end




// Example for Using JasperGold Buid-In ScoreBoard IP to verify the "data integrity" for C_data_r & R_DATA
jasper_scoreboard_3 #(
.CHUNK_WIDTH(32),
.SINGLE_CLOCK(1),
.ORDERING(`JS3_IN_ORDER),
.MAX_PENDING(1)
)sc_r(
 .clk(SystemClock)
 ,.rstN(inf.rst_n)
 ,.incoming_vld(inf.R_VALID && inf.R_READY)
 ,.incoming_data(inf.R_DATA)
 ,.outgoing_vld(inf.C_out_valid && testmode==READ)
 ,.outgoing_data(inf.C_data_r)
);


// ------------------------------------------------------------------
// Using JasperGold Buid-In ScoreBoard IP 
// to verify the data integrity for "AW_ADDR" address translation
//         Just Fill in the blanks of port !



// ------------------------------------------------------------------
// Using Alternative Method to Verify the Data Integrity of inf.W_DATA
// Suggensted Methods:
//            Method1:  Glue Logic                             +  SVA
//                      Hint :  Using Glue Logic to store test data for verification
//
//            Method2:  Undetermined Constant(assume property) +  SVA
//                      Hint : Using Undterministic Constant as test data for verification



// ------------------------------------------------------------------------------
// A Brief Demonstration of Coverge Property Supported by Formal Tool Jasper Gold 

covergroup Spec1 @(posedge SystemClock);
	cover_r_wb: coverpoint inf.C_r_wb;
endgroup

Spec1 inst_1 = new();

endmodule
