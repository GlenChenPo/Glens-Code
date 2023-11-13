module bridge(input clk, INF.bridge_inf inf);


// /*
// C_out_valid, C_data_r, 
// AR_VALID, AR_ADDR, R_READY, AW_VALID, AW_ADDR, W_VALID, W_DATA, B_READY
// */
// //================================================================
// // logic 
// //================================================================
logic [63:0] data;
logic [11:0] address;

//================================================================
// other
//================================================================
always_ff @(posedge clk or negedge inf.rst_n) 
begin
if (!inf.rst_n) 
   data <= 0;

else if (inf.C_r_wb==0 && inf.C_in_valid) 
    data <= inf.C_data_w;

else if(inf.C_out_valid)
   data <= 0;
end

always_comb 
begin 
address = inf.C_addr*8'h08;
end

//================================================================
// write address channel
//================================================================
// aw_valid
always_ff @(posedge clk or negedge inf.rst_n) 
begin
if (!inf.rst_n) 
    inf.AW_VALID <= 0;

else if (inf.C_r_wb==0 && inf.C_in_valid) 
    inf.AW_VALID <= 1;

else if(inf.AW_READY)
    inf.AW_VALID <= 0;
end
// aw_address
always_ff @(posedge clk or negedge inf.rst_n) 
begin
if (!inf.rst_n) 
    inf.AW_ADDR  <= 0 ; 

else if (inf.C_r_wb==0 && inf.C_in_valid) 
    inf.AW_ADDR  <= {1'b1,4'h0,address};

end
//================================================================
// write data channel
//================================================================
always_ff @(posedge clk or negedge inf.rst_n) 
begin
if (!inf.rst_n) 
    inf.W_VALID  <= 0 ; 

else if (inf.AW_READY) 
    inf.W_VALID  <= 1;

else if (inf.W_READY) 
       inf.W_VALID  <= 0 ; 
end

always_ff @(posedge clk or negedge inf.rst_n) 
begin
if (!inf.rst_n) 
    inf.W_DATA <= 0 ; 

else if (inf.AW_VALID) 
    inf.W_DATA <= data;

else if (inf.B_VALID) 
       inf.W_DATA <= 0 ; 
end

always_ff @(posedge clk or negedge inf.rst_n) 
begin
if (!inf.rst_n) 
    inf.B_READY <= 0 ; 

else if (inf.AW_READY) 
    inf.B_READY <= 1;

else if (inf.B_VALID) 
       inf.B_READY <= 0 ; 
end



//================================================================
// read address channel
//================================================================
// ar_valid
always_ff @(posedge clk or negedge inf.rst_n) 
begin
if (!inf.rst_n) 
    inf.AR_VALID <= 0;

else if (inf.C_r_wb && inf.C_in_valid) 
    inf.AR_VALID <= 1;

else if(inf.AR_READY)
    inf.AR_VALID <= 0;
end
// ar_address
always_ff @(posedge clk or negedge inf.rst_n) 
begin
if (!inf.rst_n) 
    inf.AR_ADDR  <= 0 ; 

else if (inf.C_r_wb && inf.C_in_valid) 
    inf.AR_ADDR  <= {1'b1,4'h0,address};

end


//================================================================
// read data channel
//================================================================
// R_READY
always_ff @(posedge clk or negedge inf.rst_n) 
begin
if (!inf.rst_n) 
    inf.R_READY  <= 0 ; 

else if (inf.AR_READY) 
    inf.R_READY  <= 1;

else if (inf.R_VALID) 
    inf.R_READY  <= 0 ; 
end

// output
always_ff @(posedge clk or negedge inf.rst_n) 
begin
if (!inf.rst_n)
    inf.C_data_r <= 0;
else if (inf.R_VALID) 
    inf.C_data_r <= inf.R_DATA;
else if(inf.C_out_valid)
    inf.C_data_r <= 0;
end

always_ff @(posedge clk or negedge inf.rst_n) begin
   if (!inf.rst_n)
     inf.C_out_valid <= 0;
   else if (inf.R_VALID) 
     inf.C_out_valid <= 1;
   else if (inf.B_VALID)
    inf.C_out_valid <= 1;
   else 
     inf.C_out_valid <= 0;
end
   

endmodule