//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Si2 LAB @NYCU ED430
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2022 SPRING
//   Final Proejct              : TOF
//   Author                     : Wen-Yue, Lin
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : TOF.v
//   Module Name : TOF
//   Release version : V1.0 (Release Date: 2022-5)
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
           inputtype,
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
input [1:0]     inputtype;
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
output wire                   wvalid_m_inf;
input  wire                   wready_m_inf;
output reg  [DATA_WIDTH-1:0]   wdata_m_inf;
output reg                     wlast_m_inf;
// -------------------------
// (3)    axi write response channel
input  wire  [ID_WIDTH-1:0]      bid_m_inf;
input  wire                   bvalid_m_inf;
output wire                   bready_m_inf;
input  wire  [1:0]             bresp_m_inf;
// -----------------------------


// --------- default (can't modify) --------------------------
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

reg  [63:0]   Data_1 , Data_2 ;
reg  [7:0]    address_1 , address_2 ;
reg  [0:0]    WEN_1 , WEN_2 ;
wire [63:0]   memo_OUT_1 , memo_OUT_2;

RAISH memo1( .Q(memo_OUT_1), .CLK(clk), .CEN(1'b0), .WEN(WEN_1), .A(address_1), .D(Data_1), .OEN(1'b0) );
RAISH memo2( .Q(memo_OUT_2), .CLK(clk), .CEN(1'b0), .WEN(WEN_2), .A(address_2), .D(Data_2), .OEN(1'b0) );

// ===============================================================
// Parameter & Integer Declaration
// ===============================================================
reg [1:0]  temp_type;
reg [5:0]  temp_FRAME;

reg [15:0] Store_1 ; //



//cnt
reg [9:0] Bigcnt_1 ;

reg [5:0] Smallcnt_1;
reg [9:0] Smallcnt_2;

reg [7:0] cnt_write_1 ;
reg [3:0] cnt_his_num;

reg [3:0] cnt_16_1 , cnt_16_2;

// window
reg [10:0] sum_max;
reg [8:0]  sum_max_dis;
//  window=8
reg [10:0] sum5_o[15:0];
reg [10:0] sum5_1[7:0];
reg [10:0] sum5_2[3:0];
reg [10:0] sum5_3[1:0];
reg [10:0] sum5_4;
reg [8:0]  sum5_o_dis[15:0];
reg [8:0]  sum5_1_dis[7:0];
reg [8:0]  sum5_2_dis[3:0];
reg [8:0]  sum5_3_dis[1:0];
reg [8:0]  sum5_4_dis;


reg [127:0] DISTANCE;
// Bin
reg [3:0] bin_1 [20:0];
reg [7:0] bin_2 [20:0];

// reg [59:0] bin_for_last ;


//  Delay
reg in_valid_d1 , rvalid_m_inf_d1 , rvalid_m_inf_d2 , rvalid_m_inf_d3;

// flag
reg switch_1 , pause;             // use to switch which memo
reg flag_2to3 , flag_3toI , flag_5to6 , flag5to8 , flag_write , flag_bwrite; // use to switch state
reg flag_1stFinish , flag_saveHistFinish , flag_finish;
reg FinTrans , FinWrite , FinRead , FinDIS;


reg [63:0] DataForDram [1:16][1:16];


// state
parameter S_IDLE      = 4'd0;
parameter S_HOME      = 4'd1;

parameter S_MAKEhis   = 4'd2;
parameter S_WRITEhis  = 4'd3;

parameter S_RAVALID   = 4'd4;
parameter S_READ      = 4'd5;

parameter S_WAVALID   = 4'd6;
parameter S_WRITEdis  = 4'd7;

parameter S_TRANShis  = 4'd8;

parameter S_BUSY     = 4'd9;



integer i;
integer j;
reg [4:0] current_state,next_state,current_state_d;
//================================================================
//                FSM
//================================================================
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        current_state <= S_IDLE ;
    else
        current_state <= next_state ;
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        current_state_d <= S_IDLE;
    else
        current_state_d <= current_state;
end

always @(*)
begin
    next_state = current_state ;
    case(current_state)
        S_IDLE:
            if (in_valid)
                next_state = S_HOME ;
            else
                next_state = S_IDLE ;
        S_HOME:
        case (temp_type)
            0:
                next_state = S_RAVALID ;//Type0 read DRAM
            1:
                next_state = S_MAKEhis ;
            2:
                next_state = S_MAKEhis ;
            3:
                next_state = S_MAKEhis ;
            default:
                next_state = S_HOME ;
        endcase

        S_MAKEhis:
            if (in_valid==0 && Bigcnt_1==256)
                next_state =  S_TRANShis ;
            else
                next_state = S_MAKEhis ;
        S_WRITEhis:
            if (bvalid_m_inf)
                next_state = S_RAVALID;
            else
                next_state = S_WRITEhis;

        S_RAVALID:
            if (arready_m_inf)
                next_state = S_READ ;
            else
                next_state =  S_RAVALID;
        S_READ:
            if (rvalid_m_inf_d3 && rvalid_m_inf_d2==0)
                next_state = S_WAVALID ;
            else if(flag5to8)
                next_state = S_BUSY;
            else
                next_state =  S_READ;
        S_WAVALID:
            if (awready_m_inf)
            begin
                if(flag_write)
                    next_state = S_WRITEhis;
                else if(flag_write==0)
                    next_state = S_WRITEdis;
            end
            else
            begin
                next_state = S_WAVALID;
            end
        S_WRITEdis:
            if (bvalid_m_inf)
            begin
                if (cnt_his_num==4'hf)
                begin
                    next_state = S_BUSY;
                end
                else
                begin
                    next_state = S_RAVALID ;
                end
            end
            else
                next_state = S_WRITEdis;
        S_TRANShis:
            if (Bigcnt_1==256)
                next_state = S_WAVALID ;
            else
                next_state = S_TRANShis;

        S_BUSY:
            next_state = S_IDLE;
        default:
            next_state = S_IDLE;
    endcase
end
// ===============================================================
//      Busy
// ===============================================================
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        busy<=0;
    else if(current_state==S_IDLE)
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
        if (current_state==S_RAVALID || current_state==S_READ)
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
        current_state_d <= S_IDLE;
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
always @(*)
begin
    if (FinTrans)
    begin
        awaddr_m_inf = {12'd0,temp_FRAME, cnt_his_num, 8'h00};
    end
    else
    begin
        awaddr_m_inf = {12'd0,temp_FRAME, cnt_his_num, 8'hF0};
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
    else if(current_state==S_WAVALID)
        awvalid_m_inf<=1;
    else
        awvalid_m_inf<=0;
end

always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
        flag_write <= 0;
    else if (current_state==S_MAKEhis)
        flag_write <= 1;
    else if(current_state==S_TRANShis)
        flag_write <= 1;
    else if(current_state==S_WRITEhis)
        flag_write <= 0;
    else if (current_state==S_READ)
        flag_write <= 0;
    else if (current_state==S_IDLE)
        flag_write <= 0;
end

always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
        cnt_16_2 <= 0;
    else if(current_state==S_IDLE)
        cnt_16_2 <= 0;
    else if(current_state==S_WRITEhis)
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
    else if(current_state==S_IDLE)
        cnt_16_1<=0;
    else if(current_state==S_WRITEhis && wready_m_inf)
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
    else if (current_state==S_WRITEhis)
    begin
        wdata_m_inf <= DataForDram[cnt_16_1+1][cnt_16_2+1];
    end
    else if (current_state==S_WAVALID)
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
    else if (current_state==S_WRITEhis)
    begin
        Smallcnt_2 <=  Smallcnt_2+1;
    end
    else if (current_state==S_IDLE)
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
        if(current_state==S_WRITEhis)
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
        else if (current_state==S_WRITEdis)
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
    if (current_state == S_READ)
        arvalid_m_inf = 0;
    else if(current_state == S_RAVALID)
        arvalid_m_inf = 1;
    else
        arvalid_m_inf = 0;
end

always @(*)
begin
    araddr_m_inf = {12'd0,temp_FRAME, cnt_his_num, 8'h00}; // 14 + 6 + 4 + 8 = 32
end


//==================================================================================
//         Read Data Channel
//==================================================================================
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        for (i=0;i<21;i=i+1)
        begin
            bin_1[i] <= 0;
        end
    end
    else if(bvalid_m_inf)
    begin
        for (i=0;i<21;i=i+1)
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
            bin_1[5 ] <= rdata_m_inf[3:0];
            bin_1[6 ] <= rdata_m_inf[11:8];
            bin_1[7 ] <= rdata_m_inf[19:16];
            bin_1[8 ] <= rdata_m_inf[27:24];
            bin_1[9 ] <= rdata_m_inf[35:32];
            bin_1[10] <= rdata_m_inf[43:40];
            bin_1[11] <= rdata_m_inf[51:48];
            bin_1[12] <= rdata_m_inf[59:56];
            bin_1[13] <= rdata_m_inf[67:64];
            bin_1[14] <= rdata_m_inf[75:72];
            bin_1[15] <= rdata_m_inf[83:80];
            bin_1[16] <= rdata_m_inf[91:88];
            bin_1[17] <= rdata_m_inf[99:96];
            bin_1[18] <= rdata_m_inf[107:104];
            bin_1[19] <= rdata_m_inf[115:112];
            bin_1[20] <= 0;
        end
        else
        begin
            bin_1[0 ] <= bin_1[16];
            bin_1[1 ] <= bin_1[17];
            bin_1[2 ] <= bin_1[18];
            bin_1[3 ] <= bin_1[19];
            bin_1[4 ] <= bin_1[20];
            bin_1[5 ] <= rdata_m_inf[3:0];
            bin_1[6 ] <= rdata_m_inf[11:8];
            bin_1[7 ] <= rdata_m_inf[19:16];
            bin_1[8 ] <= rdata_m_inf[27:24];
            bin_1[9 ] <= rdata_m_inf[35:32];
            bin_1[10] <= rdata_m_inf[43:40];
            bin_1[11] <= rdata_m_inf[51:48];
            bin_1[12] <= rdata_m_inf[59:56];
            bin_1[13] <= rdata_m_inf[67:64];
            bin_1[14] <= rdata_m_inf[75:72];
            bin_1[15] <= rdata_m_inf[83:80];
            bin_1[16] <= rdata_m_inf[91:88];
            bin_1[17] <= rdata_m_inf[99:96];
            bin_1[18] <= rdata_m_inf[107:104];
            bin_1[19] <= rdata_m_inf[115:112];
            bin_1[20] <= rdata_m_inf[123:120];
        end
    end
    else
    begin
        bin_1[0]  <= bin_1[16];
        bin_1[1]  <= bin_1[17];
        bin_1[2]  <= bin_1[18];
        bin_1[3]  <= bin_1[19];
        bin_1[4]  <= bin_1[20];
        bin_1[5]  <= 0;
        bin_1[6]  <= 0;
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
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        for (i=0;i<21;i=i+1)
        begin
            bin_2[i] <= 0;
        end
    end
    else if(bvalid_m_inf)
    begin
        for (i=0;i<21;i=i+1)
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
            bin_2[5 ] <= 1;
            bin_2[6 ] <= 2;
            bin_2[7 ] <= 3;
            bin_2[8 ] <= 4;
            bin_2[9 ] <= 5;
            bin_2[10] <= 6;
            bin_2[11] <= 7;
            bin_2[12] <= 8;
            bin_2[13] <= 9;
            bin_2[14] <= 10;
            bin_2[15] <= 11;
            bin_2[16] <= 12;
            bin_2[17] <= 13;
            bin_2[18] <= 14;
            bin_2[19] <= 15;
            bin_2[20] <= 16;
        end
        else
        begin
            bin_2[0 ] <= bin_2[16];
            bin_2[1 ] <= bin_2[17];
            bin_2[2 ] <= bin_2[18];
            bin_2[3 ] <= bin_2[19];
            bin_2[4 ] <= bin_2[20];
            bin_2[5 ] <= bin_2[5 ]+5'd16;
            bin_2[6 ] <= bin_2[6 ]+5'd16;
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
        end
    end
    else
    begin
        bin_2[0 ] <= bin_2[16];
        bin_2[1 ] <= bin_2[17];
        bin_2[2 ] <= bin_2[18];
        bin_2[3 ] <= bin_2[19];
        bin_2[4 ] <= bin_2[20];
        bin_2[5 ] <= 0;
        bin_2[6 ] <= 0;
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
    end
end
//==================================================================================
//         RESULT
//==================================================================================

always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        DISTANCE <= 0;
    end
    else if (rlast_m_inf)
    begin
        DISTANCE[119:0] <= rdata_m_inf[119:0];
    end
    else if (rvalid_m_inf_d3 && rvalid_m_inf_d2==0)
    begin
        DISTANCE[127:120] <= sum_max_dis;
    end
    else if (current_state==S_IDLE)
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
            if (sum_max >= sum5_4)
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
                sum_max     <= sum5_4;
                sum_max_dis <= sum5_4_dis;
            end
        end
    end
end

//====================================================
// window=5
//====================================================
always @(*) //level1
begin
    for ( i=0 ;i<16 ;i=i+2 )
    begin
        if (sum5_o[i]>=sum5_o[i+1])
        begin
            sum5_1[i/2] = sum5_o[i];
            sum5_1_dis[i/2] = sum5_o_dis[i];
        end
        else
        begin
            sum5_1[i/2] = sum5_o[i+1];
            sum5_1_dis[i/2] = sum5_o_dis[i+1];
        end
    end
end
always @(*) //level2
begin
    for ( i=0 ;i<8 ;i=i+2 )
    begin
        if (sum5_1[i]>=sum5_1[i+1])
        begin
            sum5_2[i/2] = sum5_1[i];
            sum5_2_dis[i/2] = sum5_1_dis[i];
        end
        else
        begin
            sum5_2[i/2] = sum5_1[i+1];
            sum5_2_dis[i/2] = sum5_1_dis[i+1];
        end
    end
end
always @(*) //level3
begin
    for ( i=0 ;i<4 ;i=i+2 )
    begin
        if (sum5_2[i]>=sum5_2[i+1])
        begin
            sum5_3[i/2] = sum5_2[i];
            sum5_3_dis[i/2] = sum5_2_dis[i];
        end
        else
        begin
            sum5_3[i/2] = sum5_2[i+1];
            sum5_3_dis[i/2] = sum5_2_dis[i+1];
        end
    end
end
always @(*) //level4
begin
    if (sum5_3[0]>=sum5_3[1])
    begin
        sum5_4 = sum5_3[0];
        sum5_4_dis = sum5_3_dis[0];
    end
    else
    begin
        sum5_4 = sum5_3[1];
        sum5_4_dis = sum5_3_dis[1];
    end
end
//-----Sum_o_dis-----------------------------------------------------------------------
always @(*)
begin
    for ( i=0 ;i<16 ; i=i+1 )
    begin
        sum5_o_dis[i] = bin_2[i];
    end
end

//-----Sum_o-----------------------------------------------------------------------
always @(*)
begin
    for ( i=0 ; i<16; i=i+1 )
    begin
        sum5_o[i] =  bin_1[i]+bin_1[i+2]+bin_1[i+4];
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
            S_MAKEhis:
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
            S_WRITEhis:
                if (wready_m_inf)
                begin
                    Bigcnt_1 <= Bigcnt_1 + 1;
                end

            S_TRANShis:
                Bigcnt_1 <= Bigcnt_1 + 1;

            S_READ:
                if (rvalid_m_inf_d1)
                begin
                    Bigcnt_1 <= Bigcnt_1 + 1;
                end

            S_IDLE:
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
        if (current_state==S_MAKEhis)
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
        else if (current_state==S_WRITEhis)
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
        else if (current_state==S_TRANShis)
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
        else if (current_state==S_IDLE)
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
            if (current_state==S_WRITEhis)
            begin
                cnt_his_num <= cnt_his_num ;
            end
            else
            begin
                cnt_his_num <= cnt_his_num + 1;
            end
        end
        else if (current_state==S_IDLE)
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
        if (current_state==S_MAKEhis)
        begin
            if (Bigcnt_1==256)
            begin
                switch_1 <= switch_1 + 1;
            end
        end
        else if (current_state==S_IDLE)
        begin
            switch_1 <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
        flag_1stFinish <= 0;
    else if(current_state==S_IDLE)
        flag_1stFinish <= 0;
    else if(current_state==S_HOME)
        flag_1stFinish <= 0;
    else if(current_state==S_MAKEhis)
    begin
        if (Bigcnt_1==257)
        begin
            flag_1stFinish <= 1;
        end
    end
end

//==================================================================================
//          IIIIIIII  NN      NN  PPPPPPPP   UU      UU TTTTTTTTTT
//             II     NNNN    NN  PP     PP  UU      UU     TT
//             II     NN  NN  NN  PP     PP  UU      UU     TT
//             II     NN    NNNN  PPPPPPPP    UU    UU      TT
//          IIIIIIII  NN      NN  PP           UUUUUU       TT
//==================================================================================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        temp_FRAME <= 0;
    end
    else if (in_valid && ~in_valid_d1)
    begin
        if (frame_id[4])
        begin
            temp_FRAME <= {2'b10,frame_id[3:0]};
        end
        else
        begin
            temp_FRAME <= {2'b01,frame_id[3:0]};
        end
    end
    else if(current_state==S_IDLE)
    begin
        temp_FRAME <= 0;
    end
end
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        temp_type <= 0;
    end
    else if (in_valid && ~in_valid_d1)
    begin
        temp_type <= inputtype;
    end
    else if(current_state==S_IDLE)
    begin
        temp_type <= 0;
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
    else if (current_state==S_IDLE)
    begin
        Store_1 <= 0;
    end
    else if (current_state==S_MAKEhis)
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
    else if (current_state==S_IDLE)
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
        if (current_state==S_IDLE)
        begin
            WEN_1 <= 1;
        end
        else if (current_state==S_HOME)
        begin
            WEN_1 <= 1;
        end
        else if (current_state==S_MAKEhis)
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
        else if (current_state==S_WRITEhis)
        begin
            WEN_1 <= 1;
        end
        else if (current_state==S_TRANShis)
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
        if (current_state==S_IDLE)
        begin
            WEN_2 <= 1;
        end
        else if (current_state==S_HOME)
        begin
            WEN_2 <= 1;
        end
        else if (current_state==S_MAKEhis)
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
        else if (current_state==S_WRITEhis)
        begin
            WEN_2 <= 1;
        end
        else if (current_state==S_TRANShis)
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
            S_IDLE:
                Data_1 <= 0;
            S_MAKEhis:
                if (switch_1==0)
                begin
                    if (flag_1stFinish)
                    begin
                        Data_1[63:60]  <= {3'b000 , Store_1[15]} + memo_OUT_2[63:60];
                        Data_1[59:56]  <= {3'b000 , Store_1[14]} + memo_OUT_2[59:56];
                        Data_1[55:52]  <= {3'b000 , Store_1[13]} + memo_OUT_2[55:52];
                        Data_1[51:48]  <= {3'b000 , Store_1[12]} + memo_OUT_2[51:48];
                        Data_1[47:44]  <= {3'b000 , Store_1[11]} + memo_OUT_2[47:44];
                        Data_1[43:40]  <= {3'b000 , Store_1[10]} + memo_OUT_2[43:40];
                        Data_1[39:36]  <= {3'b000 , Store_1[9] } + memo_OUT_2[39:36];
                        Data_1[35:32]  <= {3'b000 , Store_1[8] } + memo_OUT_2[35:32];
                        Data_1[31:28]  <= {3'b000 , Store_1[7] } + memo_OUT_2[31:28];
                        Data_1[27:24]  <= {3'b000 , Store_1[6] } + memo_OUT_2[27:24];
                        Data_1[23:20]  <= {3'b000 , Store_1[5] } + memo_OUT_2[23:20];
                        Data_1[19:16]  <= {3'b000 , Store_1[4] } + memo_OUT_2[19:16];
                        Data_1[15:12]  <= {3'b000 , Store_1[3] } + memo_OUT_2[15:12];
                        Data_1[11:8]   <= {3'b000 , Store_1[2] } + memo_OUT_2[11:8];
                        Data_1[7:4]    <= {3'b000 , Store_1[1] } + memo_OUT_2[7:4];
                        Data_1[3:0]    <= {3'b000 , Store_1[0] } + memo_OUT_2[3:0];
                    end
                    else
                    begin
                        Data_1[63:60]  <= Store_1[15] ;
                        Data_1[59:56]  <= Store_1[14] ;
                        Data_1[55:52]  <= Store_1[13] ;
                        Data_1[51:48]  <= Store_1[12] ;
                        Data_1[47:44]  <= Store_1[11] ;
                        Data_1[43:40]  <= Store_1[10] ;
                        Data_1[39:36]  <= Store_1[9]  ;
                        Data_1[35:32]  <= Store_1[8]  ;
                        Data_1[31:28]  <= Store_1[7]  ;
                        Data_1[27:24]  <= Store_1[6]  ;
                        Data_1[23:20]  <= Store_1[5]  ;
                        Data_1[19:16]  <= Store_1[4]  ;
                        Data_1[15:12]  <= Store_1[3]  ;
                        Data_1[11:8]   <= Store_1[2]  ;
                        Data_1[7:4]    <= Store_1[1]  ;
                        Data_1[3:0]    <= Store_1[0]  ;
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
        if (current_state==S_IDLE)
        begin
            Data_2 <= 0;
        end
        else if (current_state==S_MAKEhis)
        begin
            if (switch_1==1)
            begin
                if (flag_1stFinish)
                begin
                    Data_2[63:60]  <= {3'b000 , Store_1[15]} + memo_OUT_1[63:60];
                    Data_2[59:56]  <= {3'b000 , Store_1[14]} + memo_OUT_1[59:56];
                    Data_2[55:52]  <= {3'b000 , Store_1[13]} + memo_OUT_1[55:52];
                    Data_2[51:48]  <= {3'b000 , Store_1[12]} + memo_OUT_1[51:48];
                    Data_2[47:44]  <= {3'b000 , Store_1[11]} + memo_OUT_1[47:44];
                    Data_2[43:40]  <= {3'b000 , Store_1[10]} + memo_OUT_1[43:40];
                    Data_2[39:36]  <= {3'b000 , Store_1[9] } + memo_OUT_1[39:36];
                    Data_2[35:32]  <= {3'b000 , Store_1[8] } + memo_OUT_1[35:32];
                    Data_2[31:28]  <= {3'b000 , Store_1[7] } + memo_OUT_1[31:28];
                    Data_2[27:24]  <= {3'b000 , Store_1[6] } + memo_OUT_1[27:24];
                    Data_2[23:20]  <= {3'b000 , Store_1[5] } + memo_OUT_1[23:20];
                    Data_2[19:16]  <= {3'b000 , Store_1[4] } + memo_OUT_1[19:16];
                    Data_2[15:12]  <= {3'b000 , Store_1[3] } + memo_OUT_1[15:12];
                    Data_2[11:8]   <= {3'b000 , Store_1[2] } + memo_OUT_1[11:8];
                    Data_2[7:4]    <= {3'b000 , Store_1[1] } + memo_OUT_1[7:4];
                    Data_2[3:0]    <= {3'b000 , Store_1[0] } + memo_OUT_1[3:0];
                end
                else
                begin
                    Data_2[63:60]  <= Store_1[15] ;
                    Data_2[59:56]  <= Store_1[14] ;
                    Data_2[55:52]  <= Store_1[13] ;
                    Data_2[51:48]  <= Store_1[12] ;
                    Data_2[47:44]  <= Store_1[11] ;
                    Data_2[43:40]  <= Store_1[10] ;
                    Data_2[39:36]  <= Store_1[9]  ;
                    Data_2[35:32]  <= Store_1[8]  ;
                    Data_2[31:28]  <= Store_1[7]  ;
                    Data_2[27:24]  <= Store_1[6]  ;
                    Data_2[23:20]  <= Store_1[5]  ;
                    Data_2[19:16]  <= Store_1[4]  ;
                    Data_2[15:12]  <= Store_1[3]  ;
                    Data_2[11:8]   <= Store_1[2]  ;
                    Data_2[7:4]    <= Store_1[1]  ;
                    Data_2[3:0]    <= Store_1[0]  ;
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
        if (current_state==S_IDLE)
        begin
            address_1 <= 0;
        end
        else if (current_state==S_MAKEhis)
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
        else if (current_state==S_TRANShis)
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
        if (current_state==S_IDLE)
        begin
            address_2 <= 0;
        end
        else if (current_state==S_MAKEhis)
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
        else if (current_state==S_TRANShis)
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
always @(posedge clk or negedge rst_n) // the 16th in everyHistogram
begin
    if (~rst_n)
    begin
        for ( i=1 ; i<17 ;i=i+1 )
        begin
            DataForDram[i][16] <= 0;
        end
    end
    else if (current_state==S_IDLE)
    begin
        for ( i=1 ; i<17 ;i=i+1 )
        begin
            DataForDram[i][16] <= 0;
        end
    end
    else if (current_state==S_TRANShis)
    begin
        if (Bigcnt_1>=1)
        begin
            case (switch_1)
                0:
                begin
                    DataForDram[1] [16][63:60] <= memo_OUT_2[3:0];
                    DataForDram[2] [16][63:60] <= memo_OUT_2[7:4];
                    DataForDram[3] [16][63:60] <= memo_OUT_2[11:8];
                    DataForDram[4] [16][63:60] <= memo_OUT_2[15:12];
                    DataForDram[5] [16][63:60] <= memo_OUT_2[19:16];
                    DataForDram[6] [16][63:60] <= memo_OUT_2[23:20];
                    DataForDram[7] [16][63:60] <= memo_OUT_2[27:24];
                    DataForDram[8] [16][63:60] <= memo_OUT_2[31:28];
                    DataForDram[9] [16][63:60] <= memo_OUT_2[35:32];
                    DataForDram[10][16][63:60] <= memo_OUT_2[39:36];
                    DataForDram[11][16][63:60] <= memo_OUT_2[43:40];
                    DataForDram[12][16][63:60] <= memo_OUT_2[47:44];
                    DataForDram[13][16][63:60] <= memo_OUT_2[51:48];
                    DataForDram[14][16][63:60] <= memo_OUT_2[55:52];
                    DataForDram[15][16][63:60] <= memo_OUT_2[59:56];
                    DataForDram[16][16][63:60] <= memo_OUT_2[63:60];
                    for ( i=1 ; i<=16 ; i=i+1 )
                    begin
                        DataForDram[i] [16][59:56] <=  DataForDram[i] [16][63:60];
                        DataForDram[i] [16][55:52] <=  DataForDram[i] [16][59:56];
                        DataForDram[i] [16][51:48] <=  DataForDram[i] [16][55:52];
                        DataForDram[i] [16][47:44] <=  DataForDram[i] [16][51:48];
                        DataForDram[i] [16][43:40] <=  DataForDram[i] [16][47:44];
                        DataForDram[i] [16][39:36] <=  DataForDram[i] [16][43:40];
                        DataForDram[i] [16][35:32] <=  DataForDram[i] [16][39:36];
                        DataForDram[i] [16][31:28] <=  DataForDram[i] [16][35:32];
                        DataForDram[i] [16][27:24] <=  DataForDram[i] [16][31:28];
                        DataForDram[i] [16][23:20] <=  DataForDram[i] [16][27:24];
                        DataForDram[i] [16][19:16] <=  DataForDram[i] [16][23:20];
                        DataForDram[i] [16][15:12] <=  DataForDram[i] [16][19:16];
                        DataForDram[i] [16][11:8]  <=  DataForDram[i] [16][15:12];
                        DataForDram[i] [16][7:4]   <=  DataForDram[i] [16][11:8];
                        DataForDram[i] [16][3:0]   <=  DataForDram[i] [16][7:4];
                    end
                end
                1:
                begin
                    DataForDram[1] [16][63:60] <= memo_OUT_1[3:0];
                    DataForDram[2] [16][63:60] <= memo_OUT_1[7:4];
                    DataForDram[3] [16][63:60] <= memo_OUT_1[11:8];
                    DataForDram[4] [16][63:60] <= memo_OUT_1[15:12];
                    DataForDram[5] [16][63:60] <= memo_OUT_1[19:16];
                    DataForDram[6] [16][63:60] <= memo_OUT_1[23:20];
                    DataForDram[7] [16][63:60] <= memo_OUT_1[27:24];
                    DataForDram[8] [16][63:60] <= memo_OUT_1[31:28];
                    DataForDram[9] [16][63:60] <= memo_OUT_1[35:32];
                    DataForDram[10][16][63:60] <= memo_OUT_1[39:36];
                    DataForDram[11][16][63:60] <= memo_OUT_1[43:40];
                    DataForDram[12][16][63:60] <= memo_OUT_1[47:44];
                    DataForDram[13][16][63:60] <= memo_OUT_1[51:48];
                    DataForDram[14][16][63:60] <= memo_OUT_1[55:52];
                    DataForDram[15][16][63:60] <= memo_OUT_1[59:56];
                    DataForDram[16][16][63:60] <= memo_OUT_1[63:60];
                    for ( i=1 ; i<=16 ; i=i+1 )
                    begin
                        DataForDram[i] [16][59:56] <=  DataForDram[i] [16][63:60];
                        DataForDram[i] [16][55:52] <=  DataForDram[i] [16][59:56];
                        DataForDram[i] [16][51:48] <=  DataForDram[i] [16][55:52];
                        DataForDram[i] [16][47:44] <=  DataForDram[i] [16][51:48];
                        DataForDram[i] [16][43:40] <=  DataForDram[i] [16][47:44];
                        DataForDram[i] [16][39:36] <=  DataForDram[i] [16][43:40];
                        DataForDram[i] [16][35:32] <=  DataForDram[i] [16][39:36];
                        DataForDram[i] [16][31:28] <=  DataForDram[i] [16][35:32];
                        DataForDram[i] [16][27:24] <=  DataForDram[i] [16][31:28];
                        DataForDram[i] [16][23:20] <=  DataForDram[i] [16][27:24];
                        DataForDram[i] [16][19:16] <=  DataForDram[i] [16][23:20];
                        DataForDram[i] [16][15:12] <=  DataForDram[i] [16][19:16];
                        DataForDram[i] [16][11:8]  <=  DataForDram[i] [16][15:12];
                        DataForDram[i] [16][7:4]   <=  DataForDram[i] [16][11:8];
                        DataForDram[i] [16][3:0]   <=  DataForDram[i] [16][7:4];
                    end
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
    else if (current_state==S_TRANShis)
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
    else if (current_state==S_IDLE)
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
        if (current_state==S_TRANShis)
        begin
            FinTrans <= 1;
        end
        else if (current_state==S_WRITEhis)
        begin
            FinTrans <= 0;
        end
        else if (current_state==S_IDLE)
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
    else if(current_state==S_TRANShis)
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
    else if (current_state==S_IDLE)
    begin
        Smallcnt_1 <= 0;
    end
end


endmodule
