//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2020 ICLAB Fall Course
//   Lab09      : HF
//   Author     : Lien-Feng Hsu
//                
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : INF.sv
//   Module Name : INF
//   Release version : v1.0 (Release Date: May -2020)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
//`include "Usertype_PKG.sv"

interface INF(input clk);
	import      usertype::*;
	logic 	rst_n ; 
	logic   act_valid;
	logic   id_valid;
	logic   cat_valid;
	logic   amnt_valid;
	DATA  	D;
	
	logic   	out_valid;
	Error_Msg 	err_msg;
	logic[31:0] out_deposit;
	logic[31:0] out_status;
	
	logic complete;
	logic [6:0]  C_addr;
	logic [31:0] C_data_w;
	logic [31:0] C_data_r;
	logic C_in_valid;
	logic C_out_valid;
	logic C_r_wb;
	
	logic   AR_READY, R_VALID, AW_READY, W_READY, B_VALID,
	        AR_VALID, R_READY, AW_VALID, W_VALID, B_READY;
	logic [1:0]	 R_RESP, B_RESP;
    logic [31:0] R_DATA, W_DATA;
	logic [16:0] AW_ADDR, AR_ADDR;

    modport PATTERN(
	    input  clk,
		       out_valid, err_msg,  complete, out_deposit, out_status,
	    output rst_n,
			   D, act_valid, id_valid, cat_valid, amnt_valid
    );
	
	modport DESIGN(
	    input  clk,rst_n,
			   D, act_valid, id_valid, cat_valid, amnt_valid,
			   AR_READY, R_VALID, R_RESP, R_DATA, AW_READY, W_READY, B_VALID, B_RESP,
	    output out_valid, err_msg,  complete, out_deposit, out_status,
		       AR_VALID, AR_ADDR, R_READY, AW_VALID, AW_ADDR, W_VALID, W_DATA, B_READY
    );
	
    modport DRAM(
	    input  clk,
		       AR_VALID, AR_ADDR, R_READY, AW_VALID, AW_ADDR, W_VALID, W_DATA, B_READY,
	    output AR_READY, R_VALID, R_RESP, R_DATA, AW_READY, W_READY, B_VALID, B_RESP
    );
	
    //  sub module port //
    modport farm_inf(
	    input  clk, rst_n,
			   D, act_valid, id_valid, cat_valid, amnt_valid,
			   C_out_valid, C_data_r,
        output out_valid, err_msg,  complete, out_deposit, out_status, 
			   C_addr, C_data_w, C_in_valid, C_r_wb
	);
		
    modport bridge_inf(
	    input  clk, rst_n,
		       C_addr, C_data_w, C_in_valid, C_r_wb,
			   AR_READY, R_VALID, R_RESP, R_DATA, AW_READY, W_READY, B_VALID, B_RESP,
        output C_out_valid, C_data_r, 
		       AR_VALID, AR_ADDR, R_READY, AW_VALID, AW_ADDR, W_VALID, W_DATA, B_READY
    );
	
	modport PATTERN_farm(
	    input  clk,
		       out_valid, err_msg,  complete, out_deposit, out_status, 
		       C_addr,    C_data_w, C_in_valid, C_r_wb,
	    output rst_n, D, act_valid, id_valid, cat_valid, amnt_valid,
			   C_out_valid, C_data_r
    );

	modport PATTERN_bridge(
	    input  clk,
		       C_out_valid, C_data_r, AR_VALID, AR_ADDR, R_READY, AW_VALID, AW_ADDR, W_VALID, W_DATA, B_READY, 
	    output rst_n, C_addr, C_data_w, C_in_valid, C_r_wb,
			   AR_READY, R_VALID, R_RESP, R_DATA, AW_READY, W_READY, B_VALID, B_RESP
    );
	
endinterface