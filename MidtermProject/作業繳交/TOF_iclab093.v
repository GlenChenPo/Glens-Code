//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NYCU ED430
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2022 SPRING
//   Midterm Proejct   : TOF
//   TA                : Wen-Yue, Lin
//   Author            : Po-Jiun, Chen
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : TOF.v
//   Module Name : TOF
//   Release version : V1.0 (Release Date: 2022-3)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module TOF(
           // CHIP IO
           clk,
           rst_n,
           in_valid,
           start,
           stop,
           window,
           mode,
           frame_id,
           busy,

           // AXI4 IO
           arid_m_inf,
           araddr_m_inf,
           arlen_m_inf,
           arsize_m_inf,
           arburst_m_inf,
           arvalid_m_inf,
           arready_m_inf,

           rid_m_inf,
           rdata_m_inf,
           rresp_m_inf,
           rlast_m_inf,
           rvalid_m_inf,
           rready_m_inf,

           awid_m_inf,
           awaddr_m_inf,
           awsize_m_inf,
           awburst_m_inf,
           awlen_m_inf,
           awvalid_m_inf,
           awready_m_inf,

           wdata_m_inf,
           wlast_m_inf,
           wvalid_m_inf,
           wready_m_inf,

           bid_m_inf,
           bresp_m_inf,
           bvalid_m_inf,
           bready_m_inf
       );
// ===============================================================
//                      Parameter Declaration
// ===============================================================
parameter ID_WIDTH=4, DATA_WIDTH=128, ADDR_WIDTH=32;    // DO NOT modify AXI4 Parameter


// ===============================================================
//                      Input / Output
// ===============================================================

// << CHIP io port with system >>
input           clk, rst_n;
input           in_valid;
input           start;
input [15:0]    stop;
input [1:0]     window;
input           mode;
input [4:0]     frame_id;
output reg      busy;

// AXI Interface wire connecttion for pseudo DRAM read/write
/* Hint:
    Your AXI-4 interface could be designed as a bridge in submodule,
    therefore I declared output of AXI as wire.  
    Ex: AXI4_interface AXI4_INF(...);
*/

// ------------------------
// <<<<< AXI READ >>>>>
// ------------------------
// (1)    axi read address channel
output wire [ID_WIDTH-1:0]      arid_m_inf;
output wire [1:0]            arburst_m_inf;
output wire [2:0]             arsize_m_inf;
output wire [7:0]              arlen_m_inf;
output reg                   arvalid_m_inf;
input  wire                  arready_m_inf;
output reg  [ADDR_WIDTH-1:0]  araddr_m_inf;
// ------------------------
// (2)    axi read data channel
input  wire [ID_WIDTH-1:0]       rid_m_inf;
input  wire                   rvalid_m_inf;
output wire                   rready_m_inf;
input  wire [DATA_WIDTH-1:0]   rdata_m_inf;
input  wire                    rlast_m_inf;
input  wire [1:0]              rresp_m_inf;
// ------------------------
// <<<<< AXI WRITE >>>>>
// ------------------------
// (1)     axi write address channel
output wire [ID_WIDTH-1:0]      awid_m_inf;
output wire [1:0]            awburst_m_inf;
output wire [2:0]             awsize_m_inf;
output reg  [7:0]              awlen_m_inf;
output reg                   awvalid_m_inf;
input  wire                  awready_m_inf;
output reg  [ADDR_WIDTH-1:0]  awaddr_m_inf;
// -------------------------
// (2)    axi write data channel
output wire                    wvalid_m_inf;
input  wire                   wready_m_inf;
output reg [DATA_WIDTH-1:0]    wdata_m_inf;
output reg                     wlast_m_inf;
// -------------------------
// (3)    axi write response channel
input  wire  [ID_WIDTH-1:0]      bid_m_inf;
input  wire                   bvalid_m_inf;
output wire                   bready_m_inf;
input  wire  [1:0]             bresp_m_inf;
// -----------------------------

//-------default(can't modify)-------------

//  READ
// (1)    axi read address channel
assign arid_m_inf    = 'b0  ;
assign arburst_m_inf = 2'b01;
assign arsize_m_inf  = 3'b100;
assign arlen_m_inf   = 15;

//  READ data channel

assign rready_m_inf=1;

//  WRITE address channel
assign awid_m_inf    = 'b0;
assign awburst_m_inf = 2'b01;
assign awsize_m_inf  = 3'b100;

//  WRITE data channel
assign wvalid_m_inf = 1;
//  WRITE Response channel

assign bready_m_inf = 1;

//=======================  memory  ===========================================================

reg [127:0] Data_1 , Data_2 ;
reg [7:0]   address_1 , address_2 ;
reg [0:0]  WEN_1 , WEN_2 ;
wire [127:0] memo_OUT_1 , memo_OUT_2;

RAISH1 memo1( .Q(memo_OUT_1), .CLK(clk), .CEN(1'b0), .WEN(WEN_1), .A(address_1), .D(Data_1), .OEN(1'b0) );
RAISH1 memo2( .Q(memo_OUT_2), .CLK(clk), .CEN(1'b0), .WEN(WEN_2), .A(address_2), .D(Data_2), .OEN(1'b0) );


// ===============================================================
// Parameter & Integer Declaration
// ===============================================================
reg MODE;
reg [5:0]  FRAME;
reg [1:0]  WINDOW;
reg [15:0] STOP ;
//cnt
reg [9:0] Bigcnt_1 ,  Smallcnt_2;
reg [7:0] cnt_write_1 ;
reg [3:0] cnt_his_num;
reg [5:0] Smallcnt_1;
reg [3:0] cnt_16_1 , cnt_16_2;

// window
reg [10:0] sum_max;
reg [8:0]  sum_max_dis;
//  window=8
reg [10:0] sum8_o[15:0];
reg [10:0] sum8_1[7:0];
reg [10:0] sum8_2[3:0];
reg [10:0] sum8_3[1:0];
reg [10:0] sum8_4;
reg [8:0]  sum8_o_dis[15:0];
reg [8:0]  sum8_1_dis[7:0];
reg [8:0]  sum8_2_dis[3:0];
reg [8:0]  sum8_3_dis[1:0];
reg [8:0]  sum8_4_dis;
//  window=4
reg [9:0]  sum4_o[15:0];
reg [9:0]  sum4_1[7:0];
reg [9:0]  sum4_2[3:0];
reg [9:0]  sum4_3[1:0];
reg [9:0]  sum4_4;
reg [8:0]  sum4_o_dis[15:0];
reg [8:0]  sum4_1_dis[7:0];
reg [8:0]  sum4_2_dis[3:0];
reg [8:0]  sum4_3_dis[1:0];
reg [8:0]  sum4_4_dis;
// window=2
reg [8:0]  sum2_o[15:0];
reg [8:0]  sum2_1[7:0];
reg [8:0]  sum2_2[3:0];
reg [8:0]  sum2_3[1:0];
reg [8:0]  sum2_4;
reg [8:0]  sum2_o_dis[15:0];
reg [8:0]  sum2_1_dis[7:0];
reg [8:0]  sum2_2_dis[3:0];
reg [8:0]  sum2_3_dis[1:0];
reg [8:0]  sum2_4_dis;

// window=1
reg [7:0]  sum1_o[15:0];
reg [7:0]  sum1_1[7:0];
reg [7:0]  sum1_2[3:0];
reg [7:0]  sum1_3[1:0];
reg [7:0]  sum1_4;
reg [8:0]  sum1_o_dis[15:0];
reg [8:0]  sum1_1_dis[7:0];
reg [8:0]  sum1_2_dis[3:0];
reg [8:0]  sum1_3_dis[1:0];
reg [8:0]  sum1_4_dis;

reg [127:0] DISTANCE;
// Bin
reg [7:0]bin_1 [22:0];
reg [7:0]bin_2 [22:0];
reg [119:0] bin_for_last ;

//  Delay
reg in_valid_d1 , rvalid_m_inf_d1 , rvalid_m_inf_d2 , rvalid_m_inf_d3;

// flag
reg switch_1;             // use to switch which memo
reg flag_write; 
reg flag_1stFinish , flag_saveHistFinish , flag_finish;
reg FinTrans;
// store the first memo_out
reg [127:0] Store_1 ;

reg [127:0] DataForDram [1:16][1:16];

// state
parameter STATE0_IDLE     = 4'd0;
parameter STATE1_HOME     = 4'd1;
parameter STATE2_MAKEhis  = 4'd2;
parameter STATE3_WRITEhis = 4'd3;
parameter STATE4_RAVALID  = 4'd4;
parameter STATE5_READ     = 4'd5;
parameter STATE6_WAVALID  = 4'd6;
parameter STATE7_WRITEdis = 4'd7;
parameter STATE8_TRANShis = 4'd8;
parameter STATE9_BUSY     = 4'd9;



integer i;
integer j;
reg [4:0] current_state,next_state,current_state_d;
//================================================================
//                FSM
//================================================================
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        current_state <= STATE0_IDLE ;
    else
        current_state <= next_state ;
end
always @(*)
begin
    next_state = current_state ;
    case(current_state)
        STATE0_IDLE:
            if (in_valid)
                next_state = STATE1_HOME ;
            else
                next_state = STATE0_IDLE ;
        STATE1_HOME:
            if (MODE==0)
                next_state = STATE2_MAKEhis ;
            else if (MODE==1)
                next_state =  STATE4_RAVALID ;
            else
                next_state = STATE1_HOME ;
        STATE2_MAKEhis:
            if (in_valid==0 && Bigcnt_1==256)
                next_state =  STATE8_TRANShis ;
            else
                next_state = STATE2_MAKEhis ;
        STATE3_WRITEhis:
            if (bvalid_m_inf)
                next_state = STATE4_RAVALID;
            else
                next_state = STATE3_WRITEhis ;
        STATE4_RAVALID:
            if (arready_m_inf)
                next_state = STATE5_READ ;
            else
                next_state =  STATE4_RAVALID;
        STATE5_READ:
            if (rvalid_m_inf_d3 && rvalid_m_inf_d2==0)
                next_state = STATE6_WAVALID ;
            else
                next_state =  STATE5_READ;
        STATE6_WAVALID:
            if (awready_m_inf)
            begin
                if(flag_write)
                    next_state = STATE3_WRITEhis;
                else if(flag_write==0)
                    next_state = STATE7_WRITEdis;
            end
            else
            begin
                next_state = STATE6_WAVALID;
            end
        STATE7_WRITEdis:
            if (bvalid_m_inf)
            begin
                if (cnt_his_num==4'hf)
                begin
                    next_state = STATE9_BUSY;
                end
                else
                begin
                    next_state = STATE4_RAVALID ;
                end
            end
            else
                next_state = STATE7_WRITEdis;
        STATE8_TRANShis:
            if (Bigcnt_1==256)
                next_state = STATE6_WAVALID ;
            else
                next_state = STATE8_TRANShis;
        STATE9_BUSY:
            next_state = STATE0_IDLE;
        default:
            next_state = STATE0_IDLE;
    endcase
end
// ===============================================================
//      Busy
// ===============================================================
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        busy<=0;
    else if(current_state==STATE0_IDLE)
        busy<=0;
    else if(in_valid)
        busy<=0;
    else
        busy<=1;
end
// ===============================================================
//      Delay
// ===============================================================
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        in_valid_d1 <= 0;
    else
        in_valid_d1 <= in_valid;
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rvalid_m_inf_d1 <= 0;
    else
    begin
        if (current_state==STATE4_RAVALID || current_state==STATE5_READ)
        begin
            rvalid_m_inf_d1 <=  rvalid_m_inf;
        end
        else
        begin
            rvalid_m_inf_d1 <= 0;
        end
    end
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rvalid_m_inf_d2 <= 0;
    else
        rvalid_m_inf_d2 <= rvalid_m_inf_d1;
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        rvalid_m_inf_d3 <= 0;
    else
        rvalid_m_inf_d3 <= rvalid_m_inf_d2;
end
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        current_state_d <= STATE0_IDLE;
    else
        current_state_d <= current_state;
end

//==================================================================================
//          DDDDDDD     RRRRRRRR        AAA      MM      MM
//          DD     DD   RR      RR     AA AA     MMM    MMM
//          DD      DD  RRRRRRRRR     AA   AA    MM M  M MM
//          DD      DD  RR   RRR     AAAAAAAAA   MM  MM  MM
//          DDDDDDDD    RR     RRR  AA       AA  MM      MM
//==================================================================================
//         Write address channel
//==================================================================================
// always @(posedge clk or negedge rst_n)
// begin
//     if (~rst_n)
//     begin
//         awaddr_m_inf <= 0;
//     end
//     else
//     begin
//         if (current_state==STATE1_HOME)
//         begin
//             awaddr_m_inf <= 0;
//         end
//         else if (next_state==STATE6_WAVALID)
//         begin
//             if (FinTrans)
//             begin
//                 awaddr_m_inf = {12'd0,FRAME, cnt_his_num, 8'h00};
//             end
//             else
//             begin
//                 awaddr_m_inf = {12'd0,FRAME, cnt_his_num, 8'hF0};
//             end
//         end
//         else if (current_state==STATE0_IDLE)
//         begin
//             awaddr_m_inf <= 0;
//         end
//     end
// end
always @(*)
begin
    if (FinTrans)
    begin
        awaddr_m_inf = {12'd0,FRAME, cnt_his_num, 8'h00};
    end
    else
    begin
        awaddr_m_inf = {12'd0,FRAME, cnt_his_num, 8'hF0};
    end
end

always @(*)
begin
    if(flag_write)
        awlen_m_inf = 255;
    else
        awlen_m_inf = 0;
end

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        awvalid_m_inf<=0;
    else if (awready_m_inf)
        awvalid_m_inf<=0;
    else if(current_state==STATE6_WAVALID)
        awvalid_m_inf<=1;
    else
        awvalid_m_inf<=0;
end

always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
        flag_write <= 0;
    else if (current_state==STATE2_MAKEhis)
        flag_write <= 1;
    else if(current_state==STATE8_TRANShis)
        flag_write <= 1;
    else if(current_state==STATE3_WRITEhis)
        flag_write <= 0;
    else if (current_state==STATE5_READ)
        flag_write <= 0;
    else if (current_state==STATE0_IDLE)
        flag_write <= 0;
end

always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
        cnt_16_2 <= 0;
    else if(current_state==STATE0_IDLE)
        cnt_16_2 <= 0;
    else if(current_state==STATE3_WRITEhis)
    case (wready_m_inf)
        0:
            if (~flag_write)
            begin
                cnt_16_2 <= cnt_16_2+1;
            end
            else
            begin
                cnt_16_2 <= cnt_16_2;
            end
        1:
            cnt_16_2 <= cnt_16_2+1;

    endcase
end
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
        cnt_16_1 <= 0;
    else if(current_state==STATE0_IDLE)
        cnt_16_1<=0;
    else if(current_state==STATE3_WRITEhis && wready_m_inf)
        if (cnt_16_2==15)
        begin
            cnt_16_1 <= cnt_16_1+1;
        end
end

//==================================================================================
//         Write data channel
//==================================================================================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        wdata_m_inf <= 0;
    end
    else if (current_state==STATE3_WRITEhis)
    begin
        wdata_m_inf <= DataForDram[cnt_16_1+1][cnt_16_2+1];
    end
    else if (current_state==STATE6_WAVALID)
    begin
        if (flag_write)
        begin
            wdata_m_inf <= DataForDram[1][1];
        end
        else if (flag_write==0)
        begin
            wdata_m_inf <= DISTANCE;
        end
    end
end


always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        Smallcnt_2 <= 0;
    end
    else if (current_state==STATE3_WRITEhis)
    begin
        Smallcnt_2 <=  Smallcnt_2+1;
    end
    else if (current_state==STATE0_IDLE)
    begin
        Smallcnt_2 <= 0;
    end
end
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        wlast_m_inf<=0;
    end
    else
    begin
        if(current_state==STATE3_WRITEhis)
        begin
            if (Smallcnt_2==256)
            begin
                wlast_m_inf <=1;
            end
            else
            begin
                wlast_m_inf<=0;
            end
        end
        else if (current_state==STATE7_WRITEdis)
        begin
            if (wready_m_inf)
            begin
                wlast_m_inf<=0;
            end
            else
            begin
                wlast_m_inf<=1;
            end
        end
        else
        begin
            wlast_m_inf<=0;
        end
    end
end
//==================================================================================
//         Read Address Channel
//==================================================================================
always @(*)
begin
    if (current_state == STATE5_READ)
        arvalid_m_inf = 0;
    else if(current_state == STATE4_RAVALID)
        arvalid_m_inf = 1;
    else
        arvalid_m_inf = 0;
end

always @(*)
begin
    araddr_m_inf = {12'd0,FRAME, cnt_his_num, 8'h00}; // 14 + 6 + 4 + 8 = 32
end


//==================================================================================
//         Read Data Channel
//==================================================================================
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        for (i=0;i<23;i=i+1)
        begin
            bin_1[i] <= 0;
        end
    end
    else if(bvalid_m_inf)
    begin
        for (i=0;i<23;i=i+1)
        begin
            bin_1[i] <= 0;
        end
    end
    else if(rvalid_m_inf)
    begin
        if (rlast_m_inf)
        begin
            bin_1[0 ] <= bin_1[16];
            bin_1[1 ] <= bin_1[17];
            bin_1[2 ] <= bin_1[18];
            bin_1[3 ] <= bin_1[19];
            bin_1[4 ] <= bin_1[20];
            bin_1[5 ] <= bin_1[21];
            bin_1[6 ] <= bin_1[22];
            bin_1[7 ] <= rdata_m_inf[7:0];
            bin_1[8 ] <= rdata_m_inf[15:8];
            bin_1[9 ] <= rdata_m_inf[23:16];
            bin_1[10] <= rdata_m_inf[31:24];
            bin_1[11] <= rdata_m_inf[39:32];
            bin_1[12] <= rdata_m_inf[47:40];
            bin_1[13] <= rdata_m_inf[55:48];
            bin_1[14] <= rdata_m_inf[63:56];
            bin_1[15] <= rdata_m_inf[71:64];
            bin_1[16] <= rdata_m_inf[79:72];
            bin_1[17] <= rdata_m_inf[87:80];
            bin_1[18] <= rdata_m_inf[95:88];
            bin_1[19] <= rdata_m_inf[103:96];
            bin_1[20] <= rdata_m_inf[111:104];
            bin_1[21] <= rdata_m_inf[119:112];
            bin_1[22] <= 0;
        end
        else
        begin
            bin_1[0 ] <= bin_1[16];
            bin_1[1 ] <= bin_1[17];
            bin_1[2 ] <= bin_1[18];
            bin_1[3 ] <= bin_1[19];
            bin_1[4 ] <= bin_1[20];
            bin_1[5 ] <= bin_1[21];
            bin_1[6 ] <= bin_1[22];
            bin_1[7 ] <= rdata_m_inf[7:0];
            bin_1[8 ] <= rdata_m_inf[15:8];
            bin_1[9 ] <= rdata_m_inf[23:16];
            bin_1[10] <= rdata_m_inf[31:24];
            bin_1[11] <= rdata_m_inf[39:32];
            bin_1[12] <= rdata_m_inf[47:40];
            bin_1[13] <= rdata_m_inf[55:48];
            bin_1[14] <= rdata_m_inf[63:56];
            bin_1[15] <= rdata_m_inf[71:64];
            bin_1[16] <= rdata_m_inf[79:72];
            bin_1[17] <= rdata_m_inf[87:80];
            bin_1[18] <= rdata_m_inf[95:88];
            bin_1[19] <= rdata_m_inf[103:96];
            bin_1[20] <= rdata_m_inf[111:104];
            bin_1[21] <= rdata_m_inf[119:112];
            bin_1[22] <= rdata_m_inf[127:120];
        end
    end
    else
    begin
        bin_1[0]  <= bin_1[16];
        bin_1[1]  <= bin_1[17];
        bin_1[2]  <= bin_1[18];
        bin_1[3]  <= bin_1[19];
        bin_1[4]  <= bin_1[20];
        bin_1[5]  <= bin_1[21];
        bin_1[6]  <= bin_1[22];
        bin_1[7]  <= 0;
        bin_1[8]  <= 0;
        bin_1[9]  <= 0;
        bin_1[10] <= 0;
        bin_1[11] <= 0;
        bin_1[12] <= 0;
        bin_1[13] <= 0;
        bin_1[14] <= 0;
        bin_1[15] <= 0;
        bin_1[16] <= 0;
        bin_1[17] <= 0;
        bin_1[18] <= 0;
        bin_1[19] <= 0;
        bin_1[20] <= 0;
        bin_1[21] <= 0;
        bin_1[22] <= 0;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        for (i=0;i<23;i=i+1)
        begin
            bin_2[i] <= 0;
        end
    end
    else if(bvalid_m_inf)
    begin
        for (i=0;i<23;i=i+1)
        begin
            bin_2[i] <= 0;
        end
    end
    else if(rvalid_m_inf)
    begin
        if(~rvalid_m_inf_d1)
        begin
            bin_2[0 ] <= 0;
            bin_2[1 ] <= 0;
            bin_2[2 ] <= 0;
            bin_2[3 ] <= 0;
            bin_2[4 ] <= 0;
            bin_2[5 ] <= 0;
            bin_2[6 ] <= 0;
            bin_2[7 ] <= 1;
            bin_2[8 ] <= 2;
            bin_2[9 ] <= 3;
            bin_2[10] <= 4;
            bin_2[11] <= 5;
            bin_2[12] <= 6;
            bin_2[13] <= 7;
            bin_2[14] <= 8;
            bin_2[15] <= 9;
            bin_2[16] <= 10;
            bin_2[17] <= 11;
            bin_2[18] <= 12;
            bin_2[19] <= 13;
            bin_2[20] <= 14;
            bin_2[21] <= 15;
            bin_2[22] <= 16;
        end
        else
        begin
            bin_2[0 ] <= bin_2[16];
            bin_2[1 ] <= bin_2[17];
            bin_2[2 ] <= bin_2[18];
            bin_2[3 ] <= bin_2[19];
            bin_2[4 ] <= bin_2[20];
            bin_2[5 ] <= bin_2[21];
            bin_2[6 ] <= bin_2[22];
            bin_2[7 ] <= bin_2[7 ]+5'd16;
            bin_2[8 ] <= bin_2[8 ]+5'd16;
            bin_2[9 ] <= bin_2[9 ]+5'd16;
            bin_2[10] <= bin_2[10]+5'd16;
            bin_2[11] <= bin_2[11]+5'd16;
            bin_2[12] <= bin_2[12]+5'd16;
            bin_2[13] <= bin_2[13]+5'd16;
            bin_2[14] <= bin_2[14]+5'd16;
            bin_2[15] <= bin_2[15]+5'd16;
            bin_2[16] <= bin_2[16]+5'd16;
            bin_2[17] <= bin_2[17]+5'd16;
            bin_2[18] <= bin_2[18]+5'd16;
            bin_2[19] <= bin_2[19]+5'd16;
            bin_2[20] <= bin_2[20]+5'd16;
            bin_2[21] <= bin_2[21]+5'd16;
            bin_2[22] <= bin_2[22]+5'd16;
        end
    end
    else
    begin
        bin_2[0]  <= bin_2[16];
        bin_2[1]  <= bin_2[17];
        bin_2[2]  <= bin_2[18];
        bin_2[3]  <= bin_2[19];
        bin_2[4]  <= bin_2[20];
        bin_2[5]  <= bin_2[21];
        bin_2[6]  <= bin_2[22];
        bin_2[7 ] <= 0;
        bin_2[8 ] <= 0;
        bin_2[9 ] <= 0;
        bin_2[10] <= 0;
        bin_2[11] <= 0;
        bin_2[12] <= 0;
        bin_2[13] <= 0;
        bin_2[14] <= 0;
        bin_2[15] <= 0;
        bin_2[16] <= 0;
        bin_2[17] <= 0;
        bin_2[18] <= 0;
        bin_2[19] <= 0;
        bin_2[20] <= 0;
        bin_2[21] <= 0;
        bin_2[22] <= 0;
    end
end
//==================================================================================
//         RESULT
//==================================================================================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        bin_for_last <= 0;
    end
    else
    begin
        if (rlast_m_inf)
        begin
            bin_for_last <= rdata_m_inf[119:0];
        end
        else if (current_state==STATE0_IDLE)
        begin
            bin_for_last <= 0;
        end
    end
end
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        DISTANCE <= 0;
    end
    else if (rvalid_m_inf_d3 && rvalid_m_inf_d2==0)
    begin
        DISTANCE[119:0] <= bin_for_last;
        DISTANCE[127:120] <= sum_max_dis;
    end
    else if (current_state==STATE0_IDLE)
    begin
        DISTANCE <= 0;
    end
end

//==================================================================================
//   W    W    W  IIIIIIII  NN      NN  DDDDDDD       oooooo    W    W    W
//   W   W W   W     II     NNNN    NN  DD     DD   oo      oo  W   W W   W
//    W  W W  W      II     NN  NN  NN  DD      DD oo        oo  W  W W  W
//    W W   W W      II     NN    NNNN  DD      DD  oo      oo   W W   W W
//     W     W    IIIIIIII  NN      NN  DDDDDDDD      oooooo      W     W
//==================================================================================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        sum_max     <= 0;
        sum_max_dis <= 0;
    end
    else
    begin
        if (rvalid_m_inf_d3 && rvalid_m_inf_d2==0)
        begin
            sum_max     <= 0;
            sum_max_dis <= 0;
        end
        else if (rvalid_m_inf_d1 || rvalid_m_inf_d2)
        begin
            case (WINDOW)
                0:
                    if (sum_max >= sum1_4)
                    begin
                        if (sum_max_dis==0)
                        begin
                            sum_max     <= sum_max;
                            sum_max_dis <= 1;
                        end
                        else
                        begin
                            sum_max     <= sum_max;
                            sum_max_dis <= sum_max_dis;
                        end
                    end
                    else
                    begin
                        sum_max     <= sum1_4;
                        sum_max_dis <= sum1_4_dis;
                    end
                1:
                    if (sum_max >= sum2_4)
                    begin
                        if (sum_max_dis==0)
                        begin
                            sum_max     <= sum_max;
                            sum_max_dis <= 1;
                        end
                        else
                        begin
                            sum_max     <= sum_max;
                            sum_max_dis <= sum_max_dis;
                        end
                    end
                    else
                    begin
                        sum_max     <= sum2_4;
                        sum_max_dis <= sum2_4_dis;
                    end
                2:
                    if (sum_max >= sum4_4)
                    begin
                        if (sum_max_dis==0)
                        begin
                            sum_max     <= sum_max;
                            sum_max_dis <= 1;
                        end
                        else
                        begin
                            sum_max     <= sum_max;
                            sum_max_dis <= sum_max_dis;
                        end
                    end
                    else
                    begin
                        sum_max     <= sum4_4;
                        sum_max_dis <= sum4_4_dis;
                    end
                3:
                    if (sum_max >= sum8_4)
                    begin
                        if (sum_max_dis==0)
                        begin
                            sum_max     <= sum_max;
                            sum_max_dis <= 1;
                        end
                        else
                        begin
                            sum_max     <= sum_max;
                            sum_max_dis <= sum_max_dis;
                        end
                    end
                    else
                    begin
                        sum_max     <= sum8_4;
                        sum_max_dis <= sum8_4_dis;
                    end
            endcase
        end
    end
end


//==================================================================================
//    COMBINATIONAL CIRCUIT
//==================================================================================
// window=0 size:1
//====================================================
always @(*) //level1
begin
    for ( i=0 ;i<16 ;i=i+2 )
    begin
        if (sum1_o[i]>=sum1_o[i+1])
        begin
            sum1_1[i/2]     = sum1_o[i];
            sum1_1_dis[i/2] = sum1_o_dis[i];
        end
        else
        begin
            sum1_1[i/2]     = sum1_o[i+1];
            sum1_1_dis[i/2] = sum1_o_dis[i+1];
        end
    end
end
always @(*) //level2
begin
    for ( i=0 ;i<8 ;i=i+2 )
    begin
        if (sum1_1[i]>=sum1_1[i+1])
        begin
            sum1_2[i/2] = sum1_1[i];
            sum1_2_dis[i/2] = sum1_1_dis[i];
        end
        else
        begin
            sum1_2[i/2] = sum1_1[i+1];
            sum1_2_dis[i/2] = sum1_1_dis[i+1];
        end
    end
end
always @(*) //level3
begin
    for ( i=0 ;i<4 ;i=i+2 )
    begin
        if (sum1_2[i]>=sum1_2[i+1])
        begin
            sum1_3[i/2] = sum1_2[i];
            sum1_3_dis[i/2] = sum1_2_dis[i];
        end
        else
        begin
            sum1_3[i/2] = sum1_2[i+1];
            sum1_3_dis[i/2] = sum1_2_dis[i+1];
        end
    end
end
always @(*) //level4
begin
    if (sum1_3[0]>=sum1_3[1])
    begin
        sum1_4 = sum1_3[0];
        sum1_4_dis = sum1_3_dis[0];
    end
    else
    begin
        sum1_4 = sum1_3[1];
        sum1_4_dis = sum1_3_dis[1];
    end
end
//====================================================
// window=1 size:2
//====================================================
always @(*) //level1
begin
    for ( i=0 ;i<16 ;i=i+2 )
    begin
        if (sum2_o[i]>=sum2_o[i+1])
        begin
            sum2_1[i/2] = sum2_o[i];
            sum2_1_dis[i/2] = sum2_o_dis[i];
        end
        else
        begin
            sum2_1[i/2] = sum2_o[i+1];
            sum2_1_dis[i/2] = sum2_o_dis[i+1];
        end
    end
end
always @(*) //level2
begin
    for ( i=0 ;i<8 ;i=i+2 )
    begin
        if (sum2_1[i]>=sum2_1[i+1])
        begin
            sum2_2[i/2] = sum2_1[i];
            sum2_2_dis[i/2] = sum2_1_dis[i];
        end
        else
        begin
            sum2_2[i/2] = sum2_1[i+1];
            sum2_2_dis[i/2] = sum2_1_dis[i+1];
        end
    end
end
always @(*) //level3
begin
    for ( i=0 ;i<4 ;i=i+2 )
    begin
        if (sum2_2[i]>=sum2_2[i+1])
        begin
            sum2_3[i/2] = sum2_2[i];
            sum2_3_dis[i/2] = sum2_2_dis[i];
        end
        else
        begin
            sum2_3[i/2] = sum2_2[i+1];
            sum2_3_dis[i/2] = sum2_2_dis[i+1];
        end
    end
end
always @(*) //level4
begin
    if (sum2_3[0]>=sum2_3[1])
    begin
        sum2_4 = sum2_3[0];
        sum2_4_dis = sum2_3_dis[0];
    end
    else
    begin
        sum2_4 = sum2_3[1];
        sum2_4_dis = sum2_3_dis[1];
    end
end
//====================================================
// window=3 size:4
//====================================================
always @(*) //level1
begin
    for ( i=0 ;i<16 ;i=i+2 )
    begin
        if (sum4_o[i]>=sum4_o[i+1])
        begin
            sum4_1[i/2] = sum4_o[i];
            sum4_1_dis[i/2] = sum4_o_dis[i];
        end
        else
        begin
            sum4_1[i/2] = sum4_o[i+1];
            sum4_1_dis[i/2] = sum4_o_dis[i+1];
        end
    end
end
always @(*) //level2
begin
    for ( i=0 ;i<8 ;i=i+2 )
    begin
        if (sum4_1[i]>=sum4_1[i+1])
        begin
            sum4_2[i/2] = sum4_1[i];
            sum4_2_dis[i/2] = sum4_1_dis[i];
        end
        else
        begin
            sum4_2[i/2] = sum4_1[i+1];
            sum4_2_dis[i/2] = sum4_1_dis[i+1];
        end
    end
end
always @(*) //level3
begin
    for ( i=0 ;i<4 ;i=i+2 )
    begin
        if (sum4_2[i]>=sum4_2[i+1])
        begin
            sum4_3[i/2] = sum4_2[i];
            sum4_3_dis[i/2] = sum4_2_dis[i];
        end
        else
        begin
            sum4_3[i/2] = sum4_2[i+1];
            sum4_3_dis[i/2] = sum4_2_dis[i+1];
        end
    end
end
always @(*) //level4
begin
    if (sum4_3[0]>=sum4_3[1])
    begin
        sum4_4 = sum4_3[0];
        sum4_4_dis = sum4_3_dis[0];
    end
    else
    begin
        sum4_4 = sum4_3[1];
        sum4_4_dis = sum4_3_dis[1];
    end
end

//====================================================
// window=4 size:8
//====================================================
always @(*) //level1
begin
    for ( i=0 ;i<16 ;i=i+2 )
    begin
        if (sum8_o[i]>=sum8_o[i+1])
        begin
            sum8_1[i/2] = sum8_o[i];
            sum8_1_dis[i/2] = sum8_o_dis[i];
        end
        else
        begin
            sum8_1[i/2] = sum8_o[i+1];
            sum8_1_dis[i/2] = sum8_o_dis[i+1];
        end
    end
end
always @(*) //level2
begin
    for ( i=0 ;i<8 ;i=i+2 )
    begin
        if (sum8_1[i]>=sum8_1[i+1])
        begin
            sum8_2[i/2] = sum8_1[i];
            sum8_2_dis[i/2] = sum8_1_dis[i];
        end
        else
        begin
            sum8_2[i/2] = sum8_1[i+1];
            sum8_2_dis[i/2] = sum8_1_dis[i+1];
        end
    end
end
always @(*) //level3
begin
    for ( i=0 ;i<4 ;i=i+2 )
    begin
        if (sum8_2[i]>=sum8_2[i+1])
        begin
            sum8_3[i/2] = sum8_2[i];
            sum8_3_dis[i/2] = sum8_2_dis[i];
        end
        else
        begin
            sum8_3[i/2] = sum8_2[i+1];
            sum8_3_dis[i/2] = sum8_2_dis[i+1];
        end
    end
end
always @(*) //level4
begin
    if (sum8_3[0]>=sum8_3[1])
    begin
        sum8_4 = sum8_3[0];
        sum8_4_dis = sum8_3_dis[0];
    end
    else
    begin
        sum8_4 = sum8_3[1];
        sum8_4_dis = sum8_3_dis[1];
    end
end
//-----Sum_o_dis-----------------------------------------------------------------------
always @(*)
begin
    for ( i=0 ;i<16 ; i=i+1 )
    begin
        sum1_o_dis[i] = bin_2[i];
        sum2_o_dis[i] = bin_2[i];
        sum4_o_dis[i] = bin_2[i];
        sum8_o_dis[i] = bin_2[i];
    end
end

//-----Sum_o-----------------------------------------------------------------------
always @(*)
begin
    for ( i=0 ; i<16; i=i+1 )
    begin
        sum8_o[i] =  bin_1[i]+bin_1[i+1]+bin_1[i+2]+bin_1[i+3]+bin_1[i+4]+bin_1[i+5]+bin_1[i+6]+bin_1[i+7];
        sum4_o[i] =  bin_1[i]+bin_1[i+1]+bin_1[i+2]+bin_1[i+3];
        sum2_o[i] =  bin_1[i]+bin_1[i+1];
        sum1_o[i] =  bin_1[i];
    end
end

//==================================================================================
//                   CCCCCC    NN      NN TTTTTTTTTT
//                 CC          NNNN    NN     TT
//                CC           NN  NN  NN     TT
//                 CC      CC  NN    NNNN     TT
//                  CCCCCCCC   NN      NN     TT
//==================================================================================
//     cnt_
//==================================================================================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        Bigcnt_1 <= 0;
    end
    else
    begin
        case (current_state)
            STATE2_MAKEhis:
            begin
                if (in_valid==0 && Bigcnt_1==256)
                begin
                    Bigcnt_1 <= 0;
                end
                else if (Bigcnt_1==257)
                begin
                    Bigcnt_1 <= 0;
                end
                else if (start)
                begin
                    Bigcnt_1 <= Bigcnt_1 + 1;
                end
                else if (Bigcnt_1 > 250)
                begin
                    Bigcnt_1 <= Bigcnt_1 + 1;
                end
            end
            STATE3_WRITEhis:
                if (wready_m_inf)
                begin
                    Bigcnt_1 <= Bigcnt_1 + 1;
                end

            STATE8_TRANShis:
                Bigcnt_1 <= Bigcnt_1 + 1;

            STATE5_READ:
                if (rvalid_m_inf_d1)
                begin
                    Bigcnt_1 <= Bigcnt_1 + 1;
                end

            STATE0_IDLE:
                Bigcnt_1 <= 0;
            default:
                Bigcnt_1 <= 0;
        endcase
    end
end
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        cnt_write_1 <= 0;
    end
    else
    begin
        if (current_state==STATE2_MAKEhis)
        begin
            if (Bigcnt_1==257)
            begin
                cnt_write_1 <= 0;
            end
            else if (Bigcnt_1>0)
            begin
                cnt_write_1 <= cnt_write_1 + 1;
            end
        end
        else if (current_state==STATE3_WRITEhis)
        begin
            if (Bigcnt_1==257)
            begin
                cnt_write_1 <= 0;
            end
            else if (Bigcnt_1>0)
            begin
                cnt_write_1 <= cnt_write_1 + 1;
            end
        end
        else if (current_state==STATE8_TRANShis)
        begin
            if (Bigcnt_1==16)
            begin
                cnt_write_1 <= 0;
            end
            else if (Smallcnt_1>=17)
            begin
                cnt_write_1 <= cnt_write_1+16;
            end
        end
        else if (current_state==STATE0_IDLE)
        begin
            cnt_write_1 <= 0;
        end
    end
end
always @(posedge clk or negedge rst_n) // 1~16
begin
    if (~rst_n)
    begin
        cnt_his_num <= 0;
    end
    else
    begin
        if (bvalid_m_inf)
        begin
            if (current_state==STATE3_WRITEhis)
            begin
                cnt_his_num <= cnt_his_num ;
            end
            else
            begin
                cnt_his_num <= cnt_his_num + 1;
            end
        end
        else if (current_state==STATE0_IDLE)
        begin
            cnt_his_num <= 0;
        end
    end
end



//==================================================================================
//     switch_1
//==================================================================================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        switch_1 <= 0;
    end
    else
    begin
        if (current_state==STATE2_MAKEhis)
        begin
            if (Bigcnt_1==256)
            begin
                switch_1 <= switch_1 + 1;
            end
        end
        else if (current_state==STATE0_IDLE)
        begin
            switch_1 <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
        flag_1stFinish <= 0;
    else if(current_state==STATE0_IDLE)
        flag_1stFinish <= 0;
    else if(current_state==STATE1_HOME)
        flag_1stFinish <= 0;
    else if(current_state==STATE2_MAKEhis)
    begin
        if (Bigcnt_1==257)
        begin
            flag_1stFinish <= 1;
        end
    end
end

//==================================================================================
//    Input
//==================================================================================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        FRAME <= 0;
    end
    else if (in_valid && ~in_valid_d1)
    begin
        if (frame_id[4])
        begin
            FRAME <= {2'b10,frame_id[3:0]};
        end
        else
        begin
            FRAME <= {2'b01,frame_id[3:0]};
        end

    end
    else if(current_state==STATE0_IDLE)
    begin
        FRAME <= 0;
    end
end
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        MODE <= 0;
    end
    else if (in_valid && ~in_valid_d1)
    begin
        MODE <= mode;
    end
    else if(current_state==STATE0_IDLE)
    begin
        MODE <= 0;
    end
end
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        WINDOW <= 0;
    end
    else if (in_valid && ~in_valid_d1)
    begin
        WINDOW <= window;
    end
    else if(current_state==STATE0_IDLE)
    begin
        WINDOW <= 0;
    end
end


//==================================================================================
//    other
//==================================================================================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        Store_1 <= 0;
    end
    else if (current_state==STATE0_IDLE)
    begin
        Store_1 <= 0;
    end
    else if (current_state==STATE2_MAKEhis)
    begin
        if (start)
        begin
            Store_1 <= stop ;
        end
        else
        begin
            Store_1 <= 0;
        end
    end
    else if (current_state==STATE0_IDLE)
    begin
        Store_1 <= 0;
    end
end
//==================================================================================
//     SSSSSS   RRRRRRRR        AAA      MM      MM
//   SS         RR      RR     AA AA     MMM    MMM
//    SSSSSSS   RRRRRRRRR     AA   AA    MM M  M MM
//           SS RR   RRR     AAAAAAAAA   MM  MM  MM
//    SSSSSSS   RR     RRR  AA       AA  MM      MM
//==================================================================================
//    WEN
//==================================================================================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        WEN_1 <= 0;
    end
    else
    begin
        if (current_state==STATE0_IDLE)
        begin
            WEN_1 <= 1;
        end
        else if (current_state==STATE1_HOME)
        begin
            WEN_1 <= 1;
        end
        else if (current_state==STATE2_MAKEhis)
        begin
            if (switch_1==0)
            begin
                if (Bigcnt_1==256)
                begin
                    WEN_1 <= 1;
                end
                else if (start)
                begin
                    WEN_1 <= 0;
                end
            end
            else if (switch_1==1)
            begin
                WEN_1 <= 1;
            end
        end
        else if (current_state==STATE3_WRITEhis)
        begin
            WEN_1 <= 1;
        end
        else if (current_state==STATE8_TRANShis)
        begin
            WEN_1 <= 1;
        end
    end
end
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        WEN_2 <= 0;
    end
    else
    begin
        if (current_state==STATE0_IDLE)
        begin
            WEN_2 <= 1;
        end
        else if (current_state==STATE1_HOME)
        begin
            WEN_2 <= 1;
        end
        else if (current_state==STATE2_MAKEhis)
        begin
            if (switch_1==1)
            begin
                if (Bigcnt_1==256)
                begin
                    WEN_2 <= 1;
                end
                else if (start)
                begin
                    WEN_2 <= 0;
                end
            end
            else if (switch_1==0)
            begin
                WEN_2 <= 1;
            end
        end
        else if (current_state==STATE3_WRITEhis)
        begin
            WEN_2 <= 1;
        end
        else if (current_state==STATE8_TRANShis)
        begin
            WEN_2 <= 1;
        end
    end
end
//==================================================================================
//     DATA
//==================================================================================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        Data_1 <= 0;
    end
    else
    begin
        case (current_state)
            STATE0_IDLE:
                Data_1 <= 0;
            STATE2_MAKEhis:
                if (switch_1==0)
                begin
                    if (flag_1stFinish)
                    begin
                        Data_1[127:120] <= {7'b0000000 , Store_1[15]} + memo_OUT_2[127:120];
                        Data_1[119:112] <= {7'b0000000 , Store_1[14]} + memo_OUT_2[119:112];
                        Data_1[111:104] <= {7'b0000000 , Store_1[13]} + memo_OUT_2[111:104];
                        Data_1[103:96]  <= {7'b0000000 , Store_1[12]} + memo_OUT_2[103:96] ;
                        Data_1[95:88]   <= {7'b0000000 , Store_1[11]} + memo_OUT_2[95:88]  ;
                        Data_1[87:80]   <= {7'b0000000 , Store_1[10]} + memo_OUT_2[87:80]  ;
                        Data_1[79:72]   <= {7'b0000000 , Store_1[9] } + memo_OUT_2[79:72]  ;
                        Data_1[71:64]   <= {7'b0000000 , Store_1[8] } + memo_OUT_2[71:64]  ;
                        Data_1[63:56]   <= {7'b0000000 , Store_1[7] } + memo_OUT_2[63:56]  ;
                        Data_1[55:48]   <= {7'b0000000 , Store_1[6] } + memo_OUT_2[55:48]  ;
                        Data_1[47:40]   <= {7'b0000000 , Store_1[5] } + memo_OUT_2[47:40]  ;
                        Data_1[39:32]   <= {7'b0000000 , Store_1[4] } + memo_OUT_2[39:32]  ;
                        Data_1[31:24]   <= {7'b0000000 , Store_1[3] } + memo_OUT_2[31:24]  ;
                        Data_1[23:16]   <= {7'b0000000 , Store_1[2] } + memo_OUT_2[23:16]  ;
                        Data_1[15:8]    <= {7'b0000000 , Store_1[1] } + memo_OUT_2[15:8]   ;
                        Data_1[7:0]     <= {7'b0000000 , Store_1[0] } + memo_OUT_2[7:0]    ;
                    end
                    else
                    begin
                        Data_1[127:120] <= Store_1[15] ;
                        Data_1[119:112] <= Store_1[14] ;
                        Data_1[111:104] <= Store_1[13] ;
                        Data_1[103:96]  <= Store_1[12] ;
                        Data_1[95:88]   <= Store_1[11] ;
                        Data_1[87:80]   <= Store_1[10] ;
                        Data_1[79:72]   <= Store_1[9]  ;
                        Data_1[71:64]   <= Store_1[8]  ;
                        Data_1[63:56]   <= Store_1[7]  ;
                        Data_1[55:48]   <= Store_1[6]  ;
                        Data_1[47:40]   <= Store_1[5]  ;
                        Data_1[39:32]   <= Store_1[4]  ;
                        Data_1[31:24]   <= Store_1[3]  ;
                        Data_1[23:16]   <= Store_1[2]  ;
                        Data_1[15:8]    <= Store_1[1]  ;
                        Data_1[7:0]     <= Store_1[0]  ;
                    end
                end

        endcase
    end
end
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        Data_2 <= 0;
    end
    else
    begin
        if (current_state==STATE0_IDLE)
        begin
            Data_2 <= 0;
        end
        else if (current_state==STATE2_MAKEhis)
        begin
            if (switch_1==1)
            begin
                if (flag_1stFinish)
                begin
                    Data_2[127:120] <= {7'b0000000 , Store_1[15]} + memo_OUT_1[127:120];
                    Data_2[119:112] <= {7'b0000000 , Store_1[14]} + memo_OUT_1[119:112];
                    Data_2[111:104] <= {7'b0000000 , Store_1[13]} + memo_OUT_1[111:104];
                    Data_2[103:96]  <= {7'b0000000 , Store_1[12]} + memo_OUT_1[103:96] ;
                    Data_2[95:88]   <= {7'b0000000 , Store_1[11]} + memo_OUT_1[95:88]  ;
                    Data_2[87:80]   <= {7'b0000000 , Store_1[10]} + memo_OUT_1[87:80]  ;
                    Data_2[79:72]   <= {7'b0000000 , Store_1[9] } + memo_OUT_1[79:72]  ;
                    Data_2[71:64]   <= {7'b0000000 , Store_1[8] } + memo_OUT_1[71:64]  ;
                    Data_2[63:56]   <= {7'b0000000 , Store_1[7] } + memo_OUT_1[63:56]  ;
                    Data_2[55:48]   <= {7'b0000000 , Store_1[6] } + memo_OUT_1[55:48]  ;
                    Data_2[47:40]   <= {7'b0000000 , Store_1[5] } + memo_OUT_1[47:40]  ;
                    Data_2[39:32]   <= {7'b0000000 , Store_1[4] } + memo_OUT_1[39:32]  ;
                    Data_2[31:24]   <= {7'b0000000 , Store_1[3] } + memo_OUT_1[31:24]  ;
                    Data_2[23:16]   <= {7'b0000000 , Store_1[2] } + memo_OUT_1[23:16]  ;
                    Data_2[15:8]    <= {7'b0000000 , Store_1[1] } + memo_OUT_1[15:8]   ;
                    Data_2[7:0]     <= {7'b0000000 , Store_1[0] } + memo_OUT_1[7:0]    ;
                end
                else
                begin
                    Data_2[127:120] <= Store_1[15] ;
                    Data_2[119:112] <= Store_1[14] ;
                    Data_2[111:104] <= Store_1[13] ;
                    Data_2[103:96]  <= Store_1[12] ;
                    Data_2[95:88]   <= Store_1[11] ;
                    Data_2[87:80]   <= Store_1[10] ;
                    Data_2[79:72]   <= Store_1[9]  ;
                    Data_2[71:64]   <= Store_1[8]  ;
                    Data_2[63:56]   <= Store_1[7]  ;
                    Data_2[55:48]   <= Store_1[6]  ;
                    Data_2[47:40]   <= Store_1[5]  ;
                    Data_2[39:32]   <= Store_1[4]  ;
                    Data_2[31:24]   <= Store_1[3]  ;
                    Data_2[23:16]   <= Store_1[2]  ;
                    Data_2[15:8]    <= Store_1[1]  ;
                    Data_2[7:0]     <= Store_1[0]  ;
                end
            end
        end
    end
end
//==================================================================================
//     Address
//==================================================================================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        address_1 <= 0;
    end
    else
    begin
        if (current_state==STATE0_IDLE)
        begin
            address_1 <= 0;
        end
        else if (current_state==STATE2_MAKEhis)
        begin
            case (switch_1)
                0: //memo1 write & memo2 read
                begin
                    if (Bigcnt_1==256)
                    begin
                        address_1 <= 0;
                    end
                    else
                    begin
                        address_1 <= cnt_write_1;
                    end
                end
                1: //memo1 read & memo2 write
                begin
                    if (Bigcnt_1==257)
                    begin
                        address_1 <= 0;
                    end
                    else if (Bigcnt_1==258)
                    begin
                        address_1 <= 1;
                    end
                    else
                    begin
                        if (start)
                        begin
                            address_1 <= address_1 + 1 ;
                        end
                    end
                end
            endcase
        end
        else if (current_state==STATE8_TRANShis)
        begin
            case (switch_1)
                1: //memo1 read
                    address_1 <= address_1 + 1;
                0: //memo1 write
                    address_1 <= cnt_write_1; //not yet
            endcase
        end
    end
end
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        address_2 <= 0;
    end
    else
    begin
        if (current_state==STATE0_IDLE)
        begin
            address_2 <= 0;
        end
        else if (current_state==STATE2_MAKEhis)
        begin
            case (switch_1)
                0: // memo1 write & memo2 read
                begin
                    if (Bigcnt_1==257)
                    begin
                        address_2 <= 0;
                    end
                    else if (Bigcnt_1==258)
                    begin
                        address_2 <= 1;
                    end
                    else
                    begin
                        if (start)
                        begin
                            address_2 <= address_2 + 1 ;
                        end
                    end
                end
                1: //memo1 read & memo2 write
                begin
                    if (Bigcnt_1==256)
                    begin
                        address_2 <= 0;
                    end
                    else
                    begin
                        address_2 <= cnt_write_1;
                    end
                end
            endcase
        end
        else if (current_state==STATE8_TRANShis)
        begin
            case (switch_1)
                0: //memo2 read
                    address_2 <= address_2 + 1;
                1: //memo2 write
                    address_2 <= 0; //not yet
            endcase
        end
    end
end

//==================================================================================
//    Data_
//==================================================================================

always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        for ( i=1 ; i<17 ;i=i+1 )
        begin
            DataForDram[i][16] <= 0;
        end
    end
    else if (current_state==STATE0_IDLE)
    begin
        for ( i=1 ; i<17 ;i=i+1 )
        begin
            DataForDram[i][16] <= 0;
        end
    end
    else if (current_state==STATE8_TRANShis)
    begin
        if (Bigcnt_1>=1)
        begin
            case (switch_1)
                0:
                begin
                    DataForDram[1] [16][127:120] <= memo_OUT_2[7:0];
                    DataForDram[2] [16][127:120] <= memo_OUT_2[15:8];
                    DataForDram[3] [16][127:120] <= memo_OUT_2[23:16];
                    DataForDram[4] [16][127:120] <= memo_OUT_2[31:24];
                    DataForDram[5] [16][127:120] <= memo_OUT_2[39:32];
                    DataForDram[6] [16][127:120] <= memo_OUT_2[47:40];
                    DataForDram[7] [16][127:120] <= memo_OUT_2[55:48];
                    DataForDram[8] [16][127:120] <= memo_OUT_2[63:56];
                    DataForDram[9] [16][127:120] <= memo_OUT_2[71:64];
                    DataForDram[10][16][127:120] <= memo_OUT_2[79:72];
                    DataForDram[11][16][127:120] <= memo_OUT_2[87:80];
                    DataForDram[12][16][127:120] <= memo_OUT_2[95:88];
                    DataForDram[13][16][127:120] <= memo_OUT_2[103:96];
                    DataForDram[14][16][127:120] <= memo_OUT_2[111:104];
                    DataForDram[15][16][127:120] <= memo_OUT_2[119:112];
                    DataForDram[16][16][127:120] <= memo_OUT_2[127:120];

                    DataForDram[1] [16][119:112] <=  DataForDram[1] [16][127:120];
                    DataForDram[2] [16][119:112] <=  DataForDram[2] [16][127:120];
                    DataForDram[3] [16][119:112] <=  DataForDram[3] [16][127:120];
                    DataForDram[4] [16][119:112] <=  DataForDram[4] [16][127:120];
                    DataForDram[5] [16][119:112] <=  DataForDram[5] [16][127:120];
                    DataForDram[6] [16][119:112] <=  DataForDram[6] [16][127:120];
                    DataForDram[7] [16][119:112] <=  DataForDram[7] [16][127:120];
                    DataForDram[8] [16][119:112] <=  DataForDram[8] [16][127:120];
                    DataForDram[9] [16][119:112] <=  DataForDram[9] [16][127:120];
                    DataForDram[10][16][119:112] <=  DataForDram[10][16][127:120];
                    DataForDram[11][16][119:112] <=  DataForDram[11][16][127:120];
                    DataForDram[12][16][119:112] <=  DataForDram[12][16][127:120];
                    DataForDram[13][16][119:112] <=  DataForDram[13][16][127:120];
                    DataForDram[14][16][119:112] <=  DataForDram[14][16][127:120];
                    DataForDram[15][16][119:112] <=  DataForDram[15][16][127:120];
                    DataForDram[16][16][119:112] <=  DataForDram[16][16][127:120];

                    DataForDram[1] [16][111:104] <=  DataForDram[1] [16][119:112];
                    DataForDram[2] [16][111:104] <=  DataForDram[2] [16][119:112];
                    DataForDram[3] [16][111:104] <=  DataForDram[3] [16][119:112];
                    DataForDram[4] [16][111:104] <=  DataForDram[4] [16][119:112];
                    DataForDram[5] [16][111:104] <=  DataForDram[5] [16][119:112];
                    DataForDram[6] [16][111:104] <=  DataForDram[6] [16][119:112];
                    DataForDram[7] [16][111:104] <=  DataForDram[7] [16][119:112];
                    DataForDram[8] [16][111:104] <=  DataForDram[8] [16][119:112];
                    DataForDram[9] [16][111:104] <=  DataForDram[9] [16][119:112];
                    DataForDram[10][16][111:104] <=  DataForDram[10][16][119:112];
                    DataForDram[11][16][111:104] <=  DataForDram[11][16][119:112];
                    DataForDram[12][16][111:104] <=  DataForDram[12][16][119:112];
                    DataForDram[13][16][111:104] <=  DataForDram[13][16][119:112];
                    DataForDram[14][16][111:104] <=  DataForDram[14][16][119:112];
                    DataForDram[15][16][111:104] <=  DataForDram[15][16][119:112];
                    DataForDram[16][16][111:104] <=  DataForDram[16][16][119:112];

                    DataForDram[1] [16][103:96]  <=  DataForDram[1] [16][111:104];
                    DataForDram[2] [16][103:96]  <=  DataForDram[2] [16][111:104];
                    DataForDram[3] [16][103:96]  <=  DataForDram[3] [16][111:104];
                    DataForDram[4] [16][103:96]  <=  DataForDram[4] [16][111:104];
                    DataForDram[5] [16][103:96]  <=  DataForDram[5] [16][111:104];
                    DataForDram[6] [16][103:96]  <=  DataForDram[6] [16][111:104];
                    DataForDram[7] [16][103:96]  <=  DataForDram[7] [16][111:104];
                    DataForDram[8] [16][103:96]  <=  DataForDram[8] [16][111:104];
                    DataForDram[9] [16][103:96]  <=  DataForDram[9] [16][111:104];
                    DataForDram[10][16][103:96]  <=  DataForDram[10][16][111:104];
                    DataForDram[11][16][103:96]  <=  DataForDram[11][16][111:104];
                    DataForDram[12][16][103:96]  <=  DataForDram[12][16][111:104];
                    DataForDram[13][16][103:96]  <=  DataForDram[13][16][111:104];
                    DataForDram[14][16][103:96]  <=  DataForDram[14][16][111:104];
                    DataForDram[15][16][103:96]  <=  DataForDram[15][16][111:104];
                    DataForDram[16][16][103:96]  <=  DataForDram[16][16][111:104];

                    DataForDram[1] [16][95:88]   <=  DataForDram[1] [16][103:96];
                    DataForDram[2] [16][95:88]   <=  DataForDram[2] [16][103:96];
                    DataForDram[3] [16][95:88]   <=  DataForDram[3] [16][103:96];
                    DataForDram[4] [16][95:88]   <=  DataForDram[4] [16][103:96];
                    DataForDram[5] [16][95:88]   <=  DataForDram[5] [16][103:96];
                    DataForDram[6] [16][95:88]   <=  DataForDram[6] [16][103:96];
                    DataForDram[7] [16][95:88]   <=  DataForDram[7] [16][103:96];
                    DataForDram[8] [16][95:88]   <=  DataForDram[8] [16][103:96];
                    DataForDram[9] [16][95:88]   <=  DataForDram[9] [16][103:96];
                    DataForDram[10][16][95:88]   <=  DataForDram[10][16][103:96];
                    DataForDram[11][16][95:88]   <=  DataForDram[11][16][103:96];
                    DataForDram[12][16][95:88]   <=  DataForDram[12][16][103:96];
                    DataForDram[13][16][95:88]   <=  DataForDram[13][16][103:96];
                    DataForDram[14][16][95:88]   <=  DataForDram[14][16][103:96];
                    DataForDram[15][16][95:88]   <=  DataForDram[15][16][103:96];
                    DataForDram[16][16][95:88]   <=  DataForDram[16][16][103:96];

                    DataForDram[1] [16][87:80]   <=  DataForDram[1] [16][95:88];
                    DataForDram[2] [16][87:80]   <=  DataForDram[2] [16][95:88];
                    DataForDram[3] [16][87:80]   <=  DataForDram[3] [16][95:88];
                    DataForDram[4] [16][87:80]   <=  DataForDram[4] [16][95:88];
                    DataForDram[5] [16][87:80]   <=  DataForDram[5] [16][95:88];
                    DataForDram[6] [16][87:80]   <=  DataForDram[6] [16][95:88];
                    DataForDram[7] [16][87:80]   <=  DataForDram[7] [16][95:88];
                    DataForDram[8] [16][87:80]   <=  DataForDram[8] [16][95:88];
                    DataForDram[9] [16][87:80]   <=  DataForDram[9] [16][95:88];
                    DataForDram[10][16][87:80]   <=  DataForDram[10][16][95:88];
                    DataForDram[11][16][87:80]   <=  DataForDram[11][16][95:88];
                    DataForDram[12][16][87:80]   <=  DataForDram[12][16][95:88];
                    DataForDram[13][16][87:80]   <=  DataForDram[13][16][95:88];
                    DataForDram[14][16][87:80]   <=  DataForDram[14][16][95:88];
                    DataForDram[15][16][87:80]   <=  DataForDram[15][16][95:88];
                    DataForDram[16][16][87:80]   <=  DataForDram[16][16][95:88];

                    DataForDram[1] [16][79:72]   <=  DataForDram[1] [16][87:80];
                    DataForDram[2] [16][79:72]   <=  DataForDram[2] [16][87:80];
                    DataForDram[3] [16][79:72]   <=  DataForDram[3] [16][87:80];
                    DataForDram[4] [16][79:72]   <=  DataForDram[4] [16][87:80];
                    DataForDram[5] [16][79:72]   <=  DataForDram[5] [16][87:80];
                    DataForDram[6] [16][79:72]   <=  DataForDram[6] [16][87:80];
                    DataForDram[7] [16][79:72]   <=  DataForDram[7] [16][87:80];
                    DataForDram[8] [16][79:72]   <=  DataForDram[8] [16][87:80];
                    DataForDram[9] [16][79:72]   <=  DataForDram[9] [16][87:80];
                    DataForDram[10][16][79:72]   <=  DataForDram[10][16][87:80];
                    DataForDram[11][16][79:72]   <=  DataForDram[11][16][87:80];
                    DataForDram[12][16][79:72]   <=  DataForDram[12][16][87:80];
                    DataForDram[13][16][79:72]   <=  DataForDram[13][16][87:80];
                    DataForDram[14][16][79:72]   <=  DataForDram[14][16][87:80];
                    DataForDram[15][16][79:72]   <=  DataForDram[15][16][87:80];
                    DataForDram[16][16][79:72]   <=  DataForDram[16][16][87:80];

                    DataForDram[1] [16][71:64]   <=  DataForDram[1] [16][79:72];
                    DataForDram[2] [16][71:64]   <=  DataForDram[2] [16][79:72];
                    DataForDram[3] [16][71:64]   <=  DataForDram[3] [16][79:72];
                    DataForDram[4] [16][71:64]   <=  DataForDram[4] [16][79:72];
                    DataForDram[5] [16][71:64]   <=  DataForDram[5] [16][79:72];
                    DataForDram[6] [16][71:64]   <=  DataForDram[6] [16][79:72];
                    DataForDram[7] [16][71:64]   <=  DataForDram[7] [16][79:72];
                    DataForDram[8] [16][71:64]   <=  DataForDram[8] [16][79:72];
                    DataForDram[9] [16][71:64]   <=  DataForDram[9] [16][79:72];
                    DataForDram[10][16][71:64]   <=  DataForDram[10][16][79:72];
                    DataForDram[11][16][71:64]   <=  DataForDram[11][16][79:72];
                    DataForDram[12][16][71:64]   <=  DataForDram[12][16][79:72];
                    DataForDram[13][16][71:64]   <=  DataForDram[13][16][79:72];
                    DataForDram[14][16][71:64]   <=  DataForDram[14][16][79:72];
                    DataForDram[15][16][71:64]   <=  DataForDram[15][16][79:72];
                    DataForDram[16][16][71:64]   <=  DataForDram[16][16][79:72];

                    DataForDram[1] [16][63:56]   <=  DataForDram[1] [16][71:64];
                    DataForDram[2] [16][63:56]   <=  DataForDram[2] [16][71:64];
                    DataForDram[3] [16][63:56]   <=  DataForDram[3] [16][71:64];
                    DataForDram[4] [16][63:56]   <=  DataForDram[4] [16][71:64];
                    DataForDram[5] [16][63:56]   <=  DataForDram[5] [16][71:64];
                    DataForDram[6] [16][63:56]   <=  DataForDram[6] [16][71:64];
                    DataForDram[7] [16][63:56]   <=  DataForDram[7] [16][71:64];
                    DataForDram[8] [16][63:56]   <=  DataForDram[8] [16][71:64];
                    DataForDram[9] [16][63:56]   <=  DataForDram[9] [16][71:64];
                    DataForDram[10][16][63:56]   <=  DataForDram[10][16][71:64];
                    DataForDram[11][16][63:56]   <=  DataForDram[11][16][71:64];
                    DataForDram[12][16][63:56]   <=  DataForDram[12][16][71:64];
                    DataForDram[13][16][63:56]   <=  DataForDram[13][16][71:64];
                    DataForDram[14][16][63:56]   <=  DataForDram[14][16][71:64];
                    DataForDram[15][16][63:56]   <=  DataForDram[15][16][71:64];
                    DataForDram[16][16][63:56]   <=  DataForDram[16][16][71:64];

                    DataForDram[1] [16][55:48]   <=  DataForDram[1] [16][63:56];
                    DataForDram[2] [16][55:48]   <=  DataForDram[2] [16][63:56];
                    DataForDram[3] [16][55:48]   <=  DataForDram[3] [16][63:56];
                    DataForDram[4] [16][55:48]   <=  DataForDram[4] [16][63:56];
                    DataForDram[5] [16][55:48]   <=  DataForDram[5] [16][63:56];
                    DataForDram[6] [16][55:48]   <=  DataForDram[6] [16][63:56];
                    DataForDram[7] [16][55:48]   <=  DataForDram[7] [16][63:56];
                    DataForDram[8] [16][55:48]   <=  DataForDram[8] [16][63:56];
                    DataForDram[9] [16][55:48]   <=  DataForDram[9] [16][63:56];
                    DataForDram[10][16][55:48]   <=  DataForDram[10][16][63:56];
                    DataForDram[11][16][55:48]   <=  DataForDram[11][16][63:56];
                    DataForDram[12][16][55:48]   <=  DataForDram[12][16][63:56];
                    DataForDram[13][16][55:48]   <=  DataForDram[13][16][63:56];
                    DataForDram[14][16][55:48]   <=  DataForDram[14][16][63:56];
                    DataForDram[15][16][55:48]   <=  DataForDram[15][16][63:56];
                    DataForDram[16][16][55:48]   <=  DataForDram[16][16][63:56];

                    DataForDram[1] [16][47:40]   <=  DataForDram[1] [16][55:48];
                    DataForDram[2] [16][47:40]   <=  DataForDram[2] [16][55:48];
                    DataForDram[3] [16][47:40]   <=  DataForDram[3] [16][55:48];
                    DataForDram[4] [16][47:40]   <=  DataForDram[4] [16][55:48];
                    DataForDram[5] [16][47:40]   <=  DataForDram[5] [16][55:48];
                    DataForDram[6] [16][47:40]   <=  DataForDram[6] [16][55:48];
                    DataForDram[7] [16][47:40]   <=  DataForDram[7] [16][55:48];
                    DataForDram[8] [16][47:40]   <=  DataForDram[8] [16][55:48];
                    DataForDram[9] [16][47:40]   <=  DataForDram[9] [16][55:48];
                    DataForDram[10][16][47:40]   <=  DataForDram[10][16][55:48];
                    DataForDram[11][16][47:40]   <=  DataForDram[11][16][55:48];
                    DataForDram[12][16][47:40]   <=  DataForDram[12][16][55:48];
                    DataForDram[13][16][47:40]   <=  DataForDram[13][16][55:48];
                    DataForDram[14][16][47:40]   <=  DataForDram[14][16][55:48];
                    DataForDram[15][16][47:40]   <=  DataForDram[15][16][55:48];
                    DataForDram[16][16][47:40]   <=  DataForDram[16][16][55:48];

                    DataForDram[1] [16][39:32]   <=  DataForDram[1] [16][47:40];
                    DataForDram[2] [16][39:32]   <=  DataForDram[2] [16][47:40];
                    DataForDram[3] [16][39:32]   <=  DataForDram[3] [16][47:40];
                    DataForDram[4] [16][39:32]   <=  DataForDram[4] [16][47:40];
                    DataForDram[5] [16][39:32]   <=  DataForDram[5] [16][47:40];
                    DataForDram[6] [16][39:32]   <=  DataForDram[6] [16][47:40];
                    DataForDram[7] [16][39:32]   <=  DataForDram[7] [16][47:40];
                    DataForDram[8] [16][39:32]   <=  DataForDram[8] [16][47:40];
                    DataForDram[9] [16][39:32]   <=  DataForDram[9] [16][47:40];
                    DataForDram[10][16][39:32]   <=  DataForDram[10][16][47:40];
                    DataForDram[11][16][39:32]   <=  DataForDram[11][16][47:40];
                    DataForDram[12][16][39:32]   <=  DataForDram[12][16][47:40];
                    DataForDram[13][16][39:32]   <=  DataForDram[13][16][47:40];
                    DataForDram[14][16][39:32]   <=  DataForDram[14][16][47:40];
                    DataForDram[15][16][39:32]   <=  DataForDram[15][16][47:40];
                    DataForDram[16][16][39:32]   <=  DataForDram[16][16][47:40];

                    DataForDram[1] [16][31:24]   <=  DataForDram[1] [16][39:32];
                    DataForDram[2] [16][31:24]   <=  DataForDram[2] [16][39:32];
                    DataForDram[3] [16][31:24]   <=  DataForDram[3] [16][39:32];
                    DataForDram[4] [16][31:24]   <=  DataForDram[4] [16][39:32];
                    DataForDram[5] [16][31:24]   <=  DataForDram[5] [16][39:32];
                    DataForDram[6] [16][31:24]   <=  DataForDram[6] [16][39:32];
                    DataForDram[7] [16][31:24]   <=  DataForDram[7] [16][39:32];
                    DataForDram[8] [16][31:24]   <=  DataForDram[8] [16][39:32];
                    DataForDram[9] [16][31:24]   <=  DataForDram[9] [16][39:32];
                    DataForDram[10][16][31:24]   <=  DataForDram[10][16][39:32];
                    DataForDram[11][16][31:24]   <=  DataForDram[11][16][39:32];
                    DataForDram[12][16][31:24]   <=  DataForDram[12][16][39:32];
                    DataForDram[13][16][31:24]   <=  DataForDram[13][16][39:32];
                    DataForDram[14][16][31:24]   <=  DataForDram[14][16][39:32];
                    DataForDram[15][16][31:24]   <=  DataForDram[15][16][39:32];
                    DataForDram[16][16][31:24]   <=  DataForDram[16][16][39:32];

                    DataForDram[1] [16][23:16]   <=  DataForDram[1] [16][31:24];
                    DataForDram[2] [16][23:16]   <=  DataForDram[2] [16][31:24];
                    DataForDram[3] [16][23:16]   <=  DataForDram[3] [16][31:24];
                    DataForDram[4] [16][23:16]   <=  DataForDram[4] [16][31:24];
                    DataForDram[5] [16][23:16]   <=  DataForDram[5] [16][31:24];
                    DataForDram[6] [16][23:16]   <=  DataForDram[6] [16][31:24];
                    DataForDram[7] [16][23:16]   <=  DataForDram[7] [16][31:24];
                    DataForDram[8] [16][23:16]   <=  DataForDram[8] [16][31:24];
                    DataForDram[9] [16][23:16]   <=  DataForDram[9] [16][31:24];
                    DataForDram[10][16][23:16]   <=  DataForDram[10][16][31:24];
                    DataForDram[11][16][23:16]   <=  DataForDram[11][16][31:24];
                    DataForDram[12][16][23:16]   <=  DataForDram[12][16][31:24];
                    DataForDram[13][16][23:16]   <=  DataForDram[13][16][31:24];
                    DataForDram[14][16][23:16]   <=  DataForDram[14][16][31:24];
                    DataForDram[15][16][23:16]   <=  DataForDram[15][16][31:24];
                    DataForDram[16][16][23:16]   <=  DataForDram[16][16][31:24];

                    DataForDram[1] [16][15:8]    <=  DataForDram[1] [16][23:16];
                    DataForDram[2] [16][15:8]    <=  DataForDram[2] [16][23:16];
                    DataForDram[3] [16][15:8]    <=  DataForDram[3] [16][23:16];
                    DataForDram[4] [16][15:8]    <=  DataForDram[4] [16][23:16];
                    DataForDram[5] [16][15:8]    <=  DataForDram[5] [16][23:16];
                    DataForDram[6] [16][15:8]    <=  DataForDram[6] [16][23:16];
                    DataForDram[7] [16][15:8]    <=  DataForDram[7] [16][23:16];
                    DataForDram[8] [16][15:8]    <=  DataForDram[8] [16][23:16];
                    DataForDram[9] [16][15:8]    <=  DataForDram[9] [16][23:16];
                    DataForDram[10][16][15:8]    <=  DataForDram[10][16][23:16];
                    DataForDram[11][16][15:8]    <=  DataForDram[11][16][23:16];
                    DataForDram[12][16][15:8]    <=  DataForDram[12][16][23:16];
                    DataForDram[13][16][15:8]    <=  DataForDram[13][16][23:16];
                    DataForDram[14][16][15:8]    <=  DataForDram[14][16][23:16];
                    DataForDram[15][16][15:8]    <=  DataForDram[15][16][23:16];
                    DataForDram[16][16][15:8]    <=  DataForDram[16][16][23:16];

                    DataForDram[1] [16][7:0]     <=  DataForDram[1] [16][15:8];
                    DataForDram[2] [16][7:0]     <=  DataForDram[2] [16][15:8];
                    DataForDram[3] [16][7:0]     <=  DataForDram[3] [16][15:8];
                    DataForDram[4] [16][7:0]     <=  DataForDram[4] [16][15:8];
                    DataForDram[5] [16][7:0]     <=  DataForDram[5] [16][15:8];
                    DataForDram[6] [16][7:0]     <=  DataForDram[6] [16][15:8];
                    DataForDram[7] [16][7:0]     <=  DataForDram[7] [16][15:8];
                    DataForDram[8] [16][7:0]     <=  DataForDram[8] [16][15:8];
                    DataForDram[9] [16][7:0]     <=  DataForDram[9] [16][15:8];
                    DataForDram[10][16][7:0]     <=  DataForDram[10][16][15:8];
                    DataForDram[11][16][7:0]     <=  DataForDram[11][16][15:8];
                    DataForDram[12][16][7:0]     <=  DataForDram[12][16][15:8];
                    DataForDram[13][16][7:0]     <=  DataForDram[13][16][15:8];
                    DataForDram[14][16][7:0]     <=  DataForDram[14][16][15:8];
                    DataForDram[15][16][7:0]     <=  DataForDram[15][16][15:8];
                    DataForDram[16][16][7:0]     <=  DataForDram[16][16][15:8];
                end
                1:
                begin
                    DataForDram[1] [16][127:120] <= memo_OUT_1[7:0];
                    DataForDram[2] [16][127:120] <= memo_OUT_1[15:8];
                    DataForDram[3] [16][127:120] <= memo_OUT_1[23:16];
                    DataForDram[4] [16][127:120] <= memo_OUT_1[31:24];
                    DataForDram[5] [16][127:120] <= memo_OUT_1[39:32];
                    DataForDram[6] [16][127:120] <= memo_OUT_1[47:40];
                    DataForDram[7] [16][127:120] <= memo_OUT_1[55:48];
                    DataForDram[8] [16][127:120] <= memo_OUT_1[63:56];
                    DataForDram[9] [16][127:120] <= memo_OUT_1[71:64];
                    DataForDram[10][16][127:120] <= memo_OUT_1[79:72];
                    DataForDram[11][16][127:120] <= memo_OUT_1[87:80];
                    DataForDram[12][16][127:120] <= memo_OUT_1[95:88];
                    DataForDram[13][16][127:120] <= memo_OUT_1[103:96];
                    DataForDram[14][16][127:120] <= memo_OUT_1[111:104];
                    DataForDram[15][16][127:120] <= memo_OUT_1[119:112];
                    DataForDram[16][16][127:120] <= memo_OUT_1[127:120];

                    DataForDram[1] [16][119:112] <=  DataForDram[1] [16][127:120];
                    DataForDram[2] [16][119:112] <=  DataForDram[2] [16][127:120];
                    DataForDram[3] [16][119:112] <=  DataForDram[3] [16][127:120];
                    DataForDram[4] [16][119:112] <=  DataForDram[4] [16][127:120];
                    DataForDram[5] [16][119:112] <=  DataForDram[5] [16][127:120];
                    DataForDram[6] [16][119:112] <=  DataForDram[6] [16][127:120];
                    DataForDram[7] [16][119:112] <=  DataForDram[7] [16][127:120];
                    DataForDram[8] [16][119:112] <=  DataForDram[8] [16][127:120];
                    DataForDram[9] [16][119:112] <=  DataForDram[9] [16][127:120];
                    DataForDram[10][16][119:112] <=  DataForDram[10][16][127:120];
                    DataForDram[11][16][119:112] <=  DataForDram[11][16][127:120];
                    DataForDram[12][16][119:112] <=  DataForDram[12][16][127:120];
                    DataForDram[13][16][119:112] <=  DataForDram[13][16][127:120];
                    DataForDram[14][16][119:112] <=  DataForDram[14][16][127:120];
                    DataForDram[15][16][119:112] <=  DataForDram[15][16][127:120];
                    DataForDram[16][16][119:112] <=  DataForDram[16][16][127:120];

                    DataForDram[1] [16][111:104] <=  DataForDram[1] [16][119:112];
                    DataForDram[2] [16][111:104] <=  DataForDram[2] [16][119:112];
                    DataForDram[3] [16][111:104] <=  DataForDram[3] [16][119:112];
                    DataForDram[4] [16][111:104] <=  DataForDram[4] [16][119:112];
                    DataForDram[5] [16][111:104] <=  DataForDram[5] [16][119:112];
                    DataForDram[6] [16][111:104] <=  DataForDram[6] [16][119:112];
                    DataForDram[7] [16][111:104] <=  DataForDram[7] [16][119:112];
                    DataForDram[8] [16][111:104] <=  DataForDram[8] [16][119:112];
                    DataForDram[9] [16][111:104] <=  DataForDram[9] [16][119:112];
                    DataForDram[10][16][111:104] <=  DataForDram[10][16][119:112];
                    DataForDram[11][16][111:104] <=  DataForDram[11][16][119:112];
                    DataForDram[12][16][111:104] <=  DataForDram[12][16][119:112];
                    DataForDram[13][16][111:104] <=  DataForDram[13][16][119:112];
                    DataForDram[14][16][111:104] <=  DataForDram[14][16][119:112];
                    DataForDram[15][16][111:104] <=  DataForDram[15][16][119:112];
                    DataForDram[16][16][111:104] <=  DataForDram[16][16][119:112];

                    DataForDram[1] [16][103:96]  <=  DataForDram[1] [16][111:104];
                    DataForDram[2] [16][103:96]  <=  DataForDram[2] [16][111:104];
                    DataForDram[3] [16][103:96]  <=  DataForDram[3] [16][111:104];
                    DataForDram[4] [16][103:96]  <=  DataForDram[4] [16][111:104];
                    DataForDram[5] [16][103:96]  <=  DataForDram[5] [16][111:104];
                    DataForDram[6] [16][103:96]  <=  DataForDram[6] [16][111:104];
                    DataForDram[7] [16][103:96]  <=  DataForDram[7] [16][111:104];
                    DataForDram[8] [16][103:96]  <=  DataForDram[8] [16][111:104];
                    DataForDram[9] [16][103:96]  <=  DataForDram[9] [16][111:104];
                    DataForDram[10][16][103:96]  <=  DataForDram[10][16][111:104];
                    DataForDram[11][16][103:96]  <=  DataForDram[11][16][111:104];
                    DataForDram[12][16][103:96]  <=  DataForDram[12][16][111:104];
                    DataForDram[13][16][103:96]  <=  DataForDram[13][16][111:104];
                    DataForDram[14][16][103:96]  <=  DataForDram[14][16][111:104];
                    DataForDram[15][16][103:96]  <=  DataForDram[15][16][111:104];
                    DataForDram[16][16][103:96]  <=  DataForDram[16][16][111:104];

                    DataForDram[1] [16][95:88]   <=  DataForDram[1] [16][103:96];
                    DataForDram[2] [16][95:88]   <=  DataForDram[2] [16][103:96];
                    DataForDram[3] [16][95:88]   <=  DataForDram[3] [16][103:96];
                    DataForDram[4] [16][95:88]   <=  DataForDram[4] [16][103:96];
                    DataForDram[5] [16][95:88]   <=  DataForDram[5] [16][103:96];
                    DataForDram[6] [16][95:88]   <=  DataForDram[6] [16][103:96];
                    DataForDram[7] [16][95:88]   <=  DataForDram[7] [16][103:96];
                    DataForDram[8] [16][95:88]   <=  DataForDram[8] [16][103:96];
                    DataForDram[9] [16][95:88]   <=  DataForDram[9] [16][103:96];
                    DataForDram[10][16][95:88]   <=  DataForDram[10][16][103:96];
                    DataForDram[11][16][95:88]   <=  DataForDram[11][16][103:96];
                    DataForDram[12][16][95:88]   <=  DataForDram[12][16][103:96];
                    DataForDram[13][16][95:88]   <=  DataForDram[13][16][103:96];
                    DataForDram[14][16][95:88]   <=  DataForDram[14][16][103:96];
                    DataForDram[15][16][95:88]   <=  DataForDram[15][16][103:96];
                    DataForDram[16][16][95:88]   <=  DataForDram[16][16][103:96];

                    DataForDram[1] [16][87:80]   <=  DataForDram[1] [16][95:88];
                    DataForDram[2] [16][87:80]   <=  DataForDram[2] [16][95:88];
                    DataForDram[3] [16][87:80]   <=  DataForDram[3] [16][95:88];
                    DataForDram[4] [16][87:80]   <=  DataForDram[4] [16][95:88];
                    DataForDram[5] [16][87:80]   <=  DataForDram[5] [16][95:88];
                    DataForDram[6] [16][87:80]   <=  DataForDram[6] [16][95:88];
                    DataForDram[7] [16][87:80]   <=  DataForDram[7] [16][95:88];
                    DataForDram[8] [16][87:80]   <=  DataForDram[8] [16][95:88];
                    DataForDram[9] [16][87:80]   <=  DataForDram[9] [16][95:88];
                    DataForDram[10][16][87:80]   <=  DataForDram[10][16][95:88];
                    DataForDram[11][16][87:80]   <=  DataForDram[11][16][95:88];
                    DataForDram[12][16][87:80]   <=  DataForDram[12][16][95:88];
                    DataForDram[13][16][87:80]   <=  DataForDram[13][16][95:88];
                    DataForDram[14][16][87:80]   <=  DataForDram[14][16][95:88];
                    DataForDram[15][16][87:80]   <=  DataForDram[15][16][95:88];
                    DataForDram[16][16][87:80]   <=  DataForDram[16][16][95:88];

                    DataForDram[1] [16][79:72]   <=  DataForDram[1] [16][87:80];
                    DataForDram[2] [16][79:72]   <=  DataForDram[2] [16][87:80];
                    DataForDram[3] [16][79:72]   <=  DataForDram[3] [16][87:80];
                    DataForDram[4] [16][79:72]   <=  DataForDram[4] [16][87:80];
                    DataForDram[5] [16][79:72]   <=  DataForDram[5] [16][87:80];
                    DataForDram[6] [16][79:72]   <=  DataForDram[6] [16][87:80];
                    DataForDram[7] [16][79:72]   <=  DataForDram[7] [16][87:80];
                    DataForDram[8] [16][79:72]   <=  DataForDram[8] [16][87:80];
                    DataForDram[9] [16][79:72]   <=  DataForDram[9] [16][87:80];
                    DataForDram[10][16][79:72]   <=  DataForDram[10][16][87:80];
                    DataForDram[11][16][79:72]   <=  DataForDram[11][16][87:80];
                    DataForDram[12][16][79:72]   <=  DataForDram[12][16][87:80];
                    DataForDram[13][16][79:72]   <=  DataForDram[13][16][87:80];
                    DataForDram[14][16][79:72]   <=  DataForDram[14][16][87:80];
                    DataForDram[15][16][79:72]   <=  DataForDram[15][16][87:80];
                    DataForDram[16][16][79:72]   <=  DataForDram[16][16][87:80];

                    DataForDram[1] [16][71:64]   <=  DataForDram[1] [16][79:72];
                    DataForDram[2] [16][71:64]   <=  DataForDram[2] [16][79:72];
                    DataForDram[3] [16][71:64]   <=  DataForDram[3] [16][79:72];
                    DataForDram[4] [16][71:64]   <=  DataForDram[4] [16][79:72];
                    DataForDram[5] [16][71:64]   <=  DataForDram[5] [16][79:72];
                    DataForDram[6] [16][71:64]   <=  DataForDram[6] [16][79:72];
                    DataForDram[7] [16][71:64]   <=  DataForDram[7] [16][79:72];
                    DataForDram[8] [16][71:64]   <=  DataForDram[8] [16][79:72];
                    DataForDram[9] [16][71:64]   <=  DataForDram[9] [16][79:72];
                    DataForDram[10][16][71:64]   <=  DataForDram[10][16][79:72];
                    DataForDram[11][16][71:64]   <=  DataForDram[11][16][79:72];
                    DataForDram[12][16][71:64]   <=  DataForDram[12][16][79:72];
                    DataForDram[13][16][71:64]   <=  DataForDram[13][16][79:72];
                    DataForDram[14][16][71:64]   <=  DataForDram[14][16][79:72];
                    DataForDram[15][16][71:64]   <=  DataForDram[15][16][79:72];
                    DataForDram[16][16][71:64]   <=  DataForDram[16][16][79:72];

                    DataForDram[1] [16][63:56]   <=  DataForDram[1] [16][71:64];
                    DataForDram[2] [16][63:56]   <=  DataForDram[2] [16][71:64];
                    DataForDram[3] [16][63:56]   <=  DataForDram[3] [16][71:64];
                    DataForDram[4] [16][63:56]   <=  DataForDram[4] [16][71:64];
                    DataForDram[5] [16][63:56]   <=  DataForDram[5] [16][71:64];
                    DataForDram[6] [16][63:56]   <=  DataForDram[6] [16][71:64];
                    DataForDram[7] [16][63:56]   <=  DataForDram[7] [16][71:64];
                    DataForDram[8] [16][63:56]   <=  DataForDram[8] [16][71:64];
                    DataForDram[9] [16][63:56]   <=  DataForDram[9] [16][71:64];
                    DataForDram[10][16][63:56]   <=  DataForDram[10][16][71:64];
                    DataForDram[11][16][63:56]   <=  DataForDram[11][16][71:64];
                    DataForDram[12][16][63:56]   <=  DataForDram[12][16][71:64];
                    DataForDram[13][16][63:56]   <=  DataForDram[13][16][71:64];
                    DataForDram[14][16][63:56]   <=  DataForDram[14][16][71:64];
                    DataForDram[15][16][63:56]   <=  DataForDram[15][16][71:64];
                    DataForDram[16][16][63:56]   <=  DataForDram[16][16][71:64];

                    DataForDram[1] [16][55:48]   <=  DataForDram[1] [16][63:56];
                    DataForDram[2] [16][55:48]   <=  DataForDram[2] [16][63:56];
                    DataForDram[3] [16][55:48]   <=  DataForDram[3] [16][63:56];
                    DataForDram[4] [16][55:48]   <=  DataForDram[4] [16][63:56];
                    DataForDram[5] [16][55:48]   <=  DataForDram[5] [16][63:56];
                    DataForDram[6] [16][55:48]   <=  DataForDram[6] [16][63:56];
                    DataForDram[7] [16][55:48]   <=  DataForDram[7] [16][63:56];
                    DataForDram[8] [16][55:48]   <=  DataForDram[8] [16][63:56];
                    DataForDram[9] [16][55:48]   <=  DataForDram[9] [16][63:56];
                    DataForDram[10][16][55:48]   <=  DataForDram[10][16][63:56];
                    DataForDram[11][16][55:48]   <=  DataForDram[11][16][63:56];
                    DataForDram[12][16][55:48]   <=  DataForDram[12][16][63:56];
                    DataForDram[13][16][55:48]   <=  DataForDram[13][16][63:56];
                    DataForDram[14][16][55:48]   <=  DataForDram[14][16][63:56];
                    DataForDram[15][16][55:48]   <=  DataForDram[15][16][63:56];
                    DataForDram[16][16][55:48]   <=  DataForDram[16][16][63:56];

                    DataForDram[1] [16][47:40]   <=  DataForDram[1] [16][55:48];
                    DataForDram[2] [16][47:40]   <=  DataForDram[2] [16][55:48];
                    DataForDram[3] [16][47:40]   <=  DataForDram[3] [16][55:48];
                    DataForDram[4] [16][47:40]   <=  DataForDram[4] [16][55:48];
                    DataForDram[5] [16][47:40]   <=  DataForDram[5] [16][55:48];
                    DataForDram[6] [16][47:40]   <=  DataForDram[6] [16][55:48];
                    DataForDram[7] [16][47:40]   <=  DataForDram[7] [16][55:48];
                    DataForDram[8] [16][47:40]   <=  DataForDram[8] [16][55:48];
                    DataForDram[9] [16][47:40]   <=  DataForDram[9] [16][55:48];
                    DataForDram[10][16][47:40]   <=  DataForDram[10][16][55:48];
                    DataForDram[11][16][47:40]   <=  DataForDram[11][16][55:48];
                    DataForDram[12][16][47:40]   <=  DataForDram[12][16][55:48];
                    DataForDram[13][16][47:40]   <=  DataForDram[13][16][55:48];
                    DataForDram[14][16][47:40]   <=  DataForDram[14][16][55:48];
                    DataForDram[15][16][47:40]   <=  DataForDram[15][16][55:48];
                    DataForDram[16][16][47:40]   <=  DataForDram[16][16][55:48];

                    DataForDram[1] [16][39:32]   <=  DataForDram[1] [16][47:40];
                    DataForDram[2] [16][39:32]   <=  DataForDram[2] [16][47:40];
                    DataForDram[3] [16][39:32]   <=  DataForDram[3] [16][47:40];
                    DataForDram[4] [16][39:32]   <=  DataForDram[4] [16][47:40];
                    DataForDram[5] [16][39:32]   <=  DataForDram[5] [16][47:40];
                    DataForDram[6] [16][39:32]   <=  DataForDram[6] [16][47:40];
                    DataForDram[7] [16][39:32]   <=  DataForDram[7] [16][47:40];
                    DataForDram[8] [16][39:32]   <=  DataForDram[8] [16][47:40];
                    DataForDram[9] [16][39:32]   <=  DataForDram[9] [16][47:40];
                    DataForDram[10][16][39:32]   <=  DataForDram[10][16][47:40];
                    DataForDram[11][16][39:32]   <=  DataForDram[11][16][47:40];
                    DataForDram[12][16][39:32]   <=  DataForDram[12][16][47:40];
                    DataForDram[13][16][39:32]   <=  DataForDram[13][16][47:40];
                    DataForDram[14][16][39:32]   <=  DataForDram[14][16][47:40];
                    DataForDram[15][16][39:32]   <=  DataForDram[15][16][47:40];
                    DataForDram[16][16][39:32]   <=  DataForDram[16][16][47:40];

                    DataForDram[1] [16][31:24]   <=  DataForDram[1] [16][39:32];
                    DataForDram[2] [16][31:24]   <=  DataForDram[2] [16][39:32];
                    DataForDram[3] [16][31:24]   <=  DataForDram[3] [16][39:32];
                    DataForDram[4] [16][31:24]   <=  DataForDram[4] [16][39:32];
                    DataForDram[5] [16][31:24]   <=  DataForDram[5] [16][39:32];
                    DataForDram[6] [16][31:24]   <=  DataForDram[6] [16][39:32];
                    DataForDram[7] [16][31:24]   <=  DataForDram[7] [16][39:32];
                    DataForDram[8] [16][31:24]   <=  DataForDram[8] [16][39:32];
                    DataForDram[9] [16][31:24]   <=  DataForDram[9] [16][39:32];
                    DataForDram[10][16][31:24]   <=  DataForDram[10][16][39:32];
                    DataForDram[11][16][31:24]   <=  DataForDram[11][16][39:32];
                    DataForDram[12][16][31:24]   <=  DataForDram[12][16][39:32];
                    DataForDram[13][16][31:24]   <=  DataForDram[13][16][39:32];
                    DataForDram[14][16][31:24]   <=  DataForDram[14][16][39:32];
                    DataForDram[15][16][31:24]   <=  DataForDram[15][16][39:32];
                    DataForDram[16][16][31:24]   <=  DataForDram[16][16][39:32];

                    DataForDram[1] [16][23:16]   <=  DataForDram[1] [16][31:24];
                    DataForDram[2] [16][23:16]   <=  DataForDram[2] [16][31:24];
                    DataForDram[3] [16][23:16]   <=  DataForDram[3] [16][31:24];
                    DataForDram[4] [16][23:16]   <=  DataForDram[4] [16][31:24];
                    DataForDram[5] [16][23:16]   <=  DataForDram[5] [16][31:24];
                    DataForDram[6] [16][23:16]   <=  DataForDram[6] [16][31:24];
                    DataForDram[7] [16][23:16]   <=  DataForDram[7] [16][31:24];
                    DataForDram[8] [16][23:16]   <=  DataForDram[8] [16][31:24];
                    DataForDram[9] [16][23:16]   <=  DataForDram[9] [16][31:24];
                    DataForDram[10][16][23:16]   <=  DataForDram[10][16][31:24];
                    DataForDram[11][16][23:16]   <=  DataForDram[11][16][31:24];
                    DataForDram[12][16][23:16]   <=  DataForDram[12][16][31:24];
                    DataForDram[13][16][23:16]   <=  DataForDram[13][16][31:24];
                    DataForDram[14][16][23:16]   <=  DataForDram[14][16][31:24];
                    DataForDram[15][16][23:16]   <=  DataForDram[15][16][31:24];
                    DataForDram[16][16][23:16]   <=  DataForDram[16][16][31:24];

                    DataForDram[1] [16][15:8]    <=  DataForDram[1] [16][23:16];
                    DataForDram[2] [16][15:8]    <=  DataForDram[2] [16][23:16];
                    DataForDram[3] [16][15:8]    <=  DataForDram[3] [16][23:16];
                    DataForDram[4] [16][15:8]    <=  DataForDram[4] [16][23:16];
                    DataForDram[5] [16][15:8]    <=  DataForDram[5] [16][23:16];
                    DataForDram[6] [16][15:8]    <=  DataForDram[6] [16][23:16];
                    DataForDram[7] [16][15:8]    <=  DataForDram[7] [16][23:16];
                    DataForDram[8] [16][15:8]    <=  DataForDram[8] [16][23:16];
                    DataForDram[9] [16][15:8]    <=  DataForDram[9] [16][23:16];
                    DataForDram[10][16][15:8]    <=  DataForDram[10][16][23:16];
                    DataForDram[11][16][15:8]    <=  DataForDram[11][16][23:16];
                    DataForDram[12][16][15:8]    <=  DataForDram[12][16][23:16];
                    DataForDram[13][16][15:8]    <=  DataForDram[13][16][23:16];
                    DataForDram[14][16][15:8]    <=  DataForDram[14][16][23:16];
                    DataForDram[15][16][15:8]    <=  DataForDram[15][16][23:16];
                    DataForDram[16][16][15:8]    <=  DataForDram[16][16][23:16];

                    DataForDram[1] [16][7:0]     <=  DataForDram[1] [16][15:8];
                    DataForDram[2] [16][7:0]     <=  DataForDram[2] [16][15:8];
                    DataForDram[3] [16][7:0]     <=  DataForDram[3] [16][15:8];
                    DataForDram[4] [16][7:0]     <=  DataForDram[4] [16][15:8];
                    DataForDram[5] [16][7:0]     <=  DataForDram[5] [16][15:8];
                    DataForDram[6] [16][7:0]     <=  DataForDram[6] [16][15:8];
                    DataForDram[7] [16][7:0]     <=  DataForDram[7] [16][15:8];
                    DataForDram[8] [16][7:0]     <=  DataForDram[8] [16][15:8];
                    DataForDram[9] [16][7:0]     <=  DataForDram[9] [16][15:8];
                    DataForDram[10][16][7:0]     <=  DataForDram[10][16][15:8];
                    DataForDram[11][16][7:0]     <=  DataForDram[11][16][15:8];
                    DataForDram[12][16][7:0]     <=  DataForDram[12][16][15:8];
                    DataForDram[13][16][7:0]     <=  DataForDram[13][16][15:8];
                    DataForDram[14][16][7:0]     <=  DataForDram[14][16][15:8];
                    DataForDram[15][16][7:0]     <=  DataForDram[15][16][15:8];
                    DataForDram[16][16][7:0]     <=  DataForDram[16][16][15:8];
                end
            endcase
        end
    end
end
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        for ( i=1 ; i<17 ;i=i+1 )
        begin
            for ( j=1 ;j<16 ;j=j+1 )
            begin
                DataForDram[i][j] <= 0;
            end
        end
    end
    else if (current_state==STATE8_TRANShis)
    begin
        if (Smallcnt_1==17)
        begin
            for ( i=1 ;i<17 ; i=i+1)
            begin
                for ( j=1 ;j<16 ; j=j+1)
                begin
                    DataForDram[i][j] <= DataForDram[i][j+1];
                end
            end
        end
    end
    else if (current_state==STATE0_IDLE)
    begin
        for ( i=1 ; i<17 ;i=i+1 )
        begin
            for ( j=1 ;j<16 ;j=j+1 )
            begin
                DataForDram[i][j] <= 0;
            end
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        FinTrans <= 0;
    end
    else
    begin
        if (current_state==STATE8_TRANShis)
        begin
            FinTrans <= 1;
        end
        else if (current_state==STATE3_WRITEhis)
        begin
            FinTrans <= 0;
        end
        else if (current_state==STATE0_IDLE)
        begin
            FinTrans <= 0;
        end
    end
end
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        Smallcnt_1 <= 0;
    end
    else if(current_state==STATE8_TRANShis)
    begin
        if (Smallcnt_1==17)
        begin
            Smallcnt_1 <= 2;
        end
        else
        begin
            Smallcnt_1 <= Smallcnt_1 + 1;
        end
    end
    else if (current_state==STATE0_IDLE)
    begin
        Smallcnt_1 <= 0;
    end
end

endmodule
