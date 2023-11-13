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

// ===============================================================
// Parameter & Integer Declaration
// ===============================================================
reg [1:0]  temp_type;
reg [5:0]  temp_FRAME;

reg [15:0] Store_1 ; //

//cnt
reg [9:0] Bigcnt_1 ;


reg [4:0] Smallcnt_1;
reg [9:0] Smallcnt_2;

reg [3:0] cntX , cntY;


reg [3:0] cnt_his_num;

reg [3:0] cnt_16_1 , cnt_16_2;

// window
reg [10:0] sum_max;
reg [8:0]  sum_max_dis;
//  window=5
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


//  Delay
reg in_valid_d1 , rvalid_m_inf_d1 , rvalid_m_inf_d2 , rvalid_m_inf_d3;

// flag

reg flag_2to3 , flag_3toI , flag_5to6 , flag5to8 , flag_write , flag_bwrite; // use to switch state
reg flag_saveHistFinish , flag_finish;
reg FinTrans , FinWrite , FinRead , FinDIS;


reg [63:0]  Data_16x16 [1:16][1:16];
reg [127:0] distance_4x4 [1:16];

// state
parameter S_IDLE      = 4'd0;
parameter S_HOME      = 4'd1;

parameter S_MAKEhis   = 4'd2;
parameter S_WRITEhis  = 4'd3;

parameter S_RAVALID   = 4'd4;
parameter S_READ      = 4'd5;

parameter S_WAVALID   = 4'd6;
parameter S_WRITEdis  = 4'd7;

// parameter   = 4'd8;
// parameter S_Cal_type1 = 4'd9;
parameter S_Cal_type2 = 4'd8;
parameter S_Cal_type3 = 4'd10;

parameter S_BUSY      = 4'd11;



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

        //-------------READ DRAM---------------------
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

        //------------type 1,2,3---------------------
        S_MAKEhis:
            if (in_valid==0 && Bigcnt_1==256)
                next_state =  S_WAVALID ;
            else
                next_state = S_MAKEhis ;

        //-------------WRITE DRAM-------------------
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

        S_WRITEhis:
            if (bvalid_m_inf)
            begin
                case (temp_type)
                    1,2,3:
                        next_state = S_WAVALID;
                    default:
                        next_state = S_WRITEhis;
                endcase
            end
            else
                next_state = S_WRITEhis;

        S_WRITEdis:
            if (bvalid_m_inf)
            begin
                case (temp_type)
                    0:
                        if (cnt_his_num==4'hf)
                        begin
                            next_state = S_BUSY;
                        end
                        else
                        begin
                            next_state = S_RAVALID ;
                        end
                    1:
                        if (cnt_his_num==4'h0)
                            next_state = S_BUSY;
                        else
                            next_state = S_WRITEdis;
                    2:
                        if (cnt_his_num==4'h0)
                            next_state = S_BUSY;
                        else
                            next_state = S_WRITEdis;
                    3:
                        if (cnt_his_num==4'h0)
                            next_state = S_BUSY;
                        else
                            next_state = S_WRITEdis;
                    default:
                        next_state = S_WRITEdis;
                endcase

            end
            else
                next_state = S_WRITEdis;


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
        case (temp_type)
            1:
            begin
                if (cnt_16_2+1==16)
                begin
                    if ((cnt_16_1+1)==2 || (cnt_16_1+1)==5 || (cnt_16_1+1)==6)
                    begin
                        wdata_m_inf[127:120] <=  distance_4x4[1];
                        wdata_m_inf[119:112] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][59:56]};
                        wdata_m_inf[111:104] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][55:52]};
                        wdata_m_inf[103:96]  <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][51:48]};
                        wdata_m_inf[95:88]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][47:44]};
                        wdata_m_inf[87:80]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][43:40]};
                        wdata_m_inf[79:72]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][39:36]};
                        wdata_m_inf[71:64]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][35:32]};
                        wdata_m_inf[63:56]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][31:28]};
                        wdata_m_inf[55:48]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][27:24]};
                        wdata_m_inf[47:40]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][23:20]};
                        wdata_m_inf[39:32]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][19:16]};
                        wdata_m_inf[31:24]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][15:12]};
                        wdata_m_inf[23:16]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][11:8] };
                        wdata_m_inf[15:8]    <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][7:4]  };
                        wdata_m_inf[7:0]     <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][3:0]  };
                    end
                    else if ((cnt_16_1+1)==3 || (cnt_16_1+1)==4 || (cnt_16_1+1)==7 || (cnt_16_1+1)==8)
                    begin
                        wdata_m_inf[127:120] <=  distance_4x4[3];
                        wdata_m_inf[119:112] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][59:56]};
                        wdata_m_inf[111:104] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][55:52]};
                        wdata_m_inf[103:96]  <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][51:48]};
                        wdata_m_inf[95:88]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][47:44]};
                        wdata_m_inf[87:80]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][43:40]};
                        wdata_m_inf[79:72]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][39:36]};
                        wdata_m_inf[71:64]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][35:32]};
                        wdata_m_inf[63:56]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][31:28]};
                        wdata_m_inf[55:48]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][27:24]};
                        wdata_m_inf[47:40]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][23:20]};
                        wdata_m_inf[39:32]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][19:16]};
                        wdata_m_inf[31:24]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][15:12]};
                        wdata_m_inf[23:16]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][11:8] };
                        wdata_m_inf[15:8]    <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][7:4]  };
                        wdata_m_inf[7:0]     <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][3:0]  };
                    end
                    else if ((cnt_16_1+1)==9 || (cnt_16_1+1)==10 || (cnt_16_1+1)==13 || (cnt_16_1+1)==14)
                    begin
                        wdata_m_inf[127:120] <=  distance_4x4[9];
                        wdata_m_inf[119:112] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][59:56]};
                        wdata_m_inf[111:104] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][55:52]};
                        wdata_m_inf[103:96]  <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][51:48]};
                        wdata_m_inf[95:88]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][47:44]};
                        wdata_m_inf[87:80]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][43:40]};
                        wdata_m_inf[79:72]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][39:36]};
                        wdata_m_inf[71:64]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][35:32]};
                        wdata_m_inf[63:56]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][31:28]};
                        wdata_m_inf[55:48]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][27:24]};
                        wdata_m_inf[47:40]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][23:20]};
                        wdata_m_inf[39:32]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][19:16]};
                        wdata_m_inf[31:24]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][15:12]};
                        wdata_m_inf[23:16]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][11:8] };
                        wdata_m_inf[15:8]    <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][7:4]  };
                        wdata_m_inf[7:0]     <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][3:0]  };
                    end
                    else if ((cnt_16_1+1)==11 || (cnt_16_1+1)==12 || (cnt_16_1+1)==15 || (cnt_16_1+1)==16)
                    begin
                        wdata_m_inf[127:120] <=  distance_4x4[11];
                        wdata_m_inf[119:112] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][59:56]};
                        wdata_m_inf[111:104] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][55:52]};
                        wdata_m_inf[103:96]  <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][51:48]};
                        wdata_m_inf[95:88]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][47:44]};
                        wdata_m_inf[87:80]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][43:40]};
                        wdata_m_inf[79:72]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][39:36]};
                        wdata_m_inf[71:64]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][35:32]};
                        wdata_m_inf[63:56]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][31:28]};
                        wdata_m_inf[55:48]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][27:24]};
                        wdata_m_inf[47:40]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][23:20]};
                        wdata_m_inf[39:32]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][19:16]};
                        wdata_m_inf[31:24]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][15:12]};
                        wdata_m_inf[23:16]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][11:8] };
                        wdata_m_inf[15:8]    <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][7:4]  };
                        wdata_m_inf[7:0]     <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][3:0]  };
                    end
                end
                else
                begin
                    wdata_m_inf[127:120] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][63:60]};
                    wdata_m_inf[119:112] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][59:56]};
                    wdata_m_inf[111:104] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][55:52]};
                    wdata_m_inf[103:96]  <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][51:48]};
                    wdata_m_inf[95:88]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][47:44]};
                    wdata_m_inf[87:80]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][43:40]};
                    wdata_m_inf[79:72]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][39:36]};
                    wdata_m_inf[71:64]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][35:32]};
                    wdata_m_inf[63:56]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][31:28]};
                    wdata_m_inf[55:48]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][27:24]};
                    wdata_m_inf[47:40]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][23:20]};
                    wdata_m_inf[39:32]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][19:16]};
                    wdata_m_inf[31:24]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][15:12]};
                    wdata_m_inf[23:16]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][11:8] };
                    wdata_m_inf[15:8]    <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][7:4]  };
                    wdata_m_inf[7:0]     <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][3:0]  };
                end
            end
            2:
            begin
                if (cnt_16_2+1==16)
                begin
                    case (cnt_16_1)
                        1:
                            wdata_m_inf[127:120] <=  distance_4x4[2];
                        2:
                            wdata_m_inf[127:120] <=  distance_4x4[3];
                        3:
                            wdata_m_inf[127:120] <=  distance_4x4[4];
                        4:
                            wdata_m_inf[127:120] <=  distance_4x4[5];
                        5:
                            wdata_m_inf[127:120] <=  distance_4x4[6];
                        6:
                            wdata_m_inf[127:120] <=  distance_4x4[7];
                        7:
                            wdata_m_inf[127:120] <=  distance_4x4[8];
                        8:
                            wdata_m_inf[127:120] <=  distance_4x4[9];
                        9:
                            wdata_m_inf[127:120] <=  distance_4x4[10];
                        10:
                            wdata_m_inf[127:120] <=  distance_4x4[11];
                        11:
                            wdata_m_inf[127:120] <=  distance_4x4[12];
                        12:
                            wdata_m_inf[127:120] <=  distance_4x4[13];
                        13:
                            wdata_m_inf[127:120] <=  distance_4x4[14];
                        14:
                            wdata_m_inf[127:120] <=  distance_4x4[15];
                        15:
                            wdata_m_inf[127:120] <=  distance_4x4[16];
                    endcase
                    wdata_m_inf[119:112] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][59:56]};
                    wdata_m_inf[111:104] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][55:52]};
                    wdata_m_inf[103:96]  <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][51:48]};
                    wdata_m_inf[95:88]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][47:44]};
                    wdata_m_inf[87:80]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][43:40]};
                    wdata_m_inf[79:72]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][39:36]};
                    wdata_m_inf[71:64]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][35:32]};
                    wdata_m_inf[63:56]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][31:28]};
                    wdata_m_inf[55:48]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][27:24]};
                    wdata_m_inf[47:40]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][23:20]};
                    wdata_m_inf[39:32]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][19:16]};
                    wdata_m_inf[31:24]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][15:12]};
                    wdata_m_inf[23:16]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][11:8] };
                    wdata_m_inf[15:8]    <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][7:4]  };
                    wdata_m_inf[7:0]     <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][3:0]  };
                end
                else
                begin
                    wdata_m_inf[127:120] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][63:60]};
                    wdata_m_inf[119:112] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][59:56]};
                    wdata_m_inf[111:104] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][55:52]};
                    wdata_m_inf[103:96]  <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][51:48]};
                    wdata_m_inf[95:88]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][47:44]};
                    wdata_m_inf[87:80]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][43:40]};
                    wdata_m_inf[79:72]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][39:36]};
                    wdata_m_inf[71:64]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][35:32]};
                    wdata_m_inf[63:56]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][31:28]};
                    wdata_m_inf[55:48]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][27:24]};
                    wdata_m_inf[47:40]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][23:20]};
                    wdata_m_inf[39:32]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][19:16]};
                    wdata_m_inf[31:24]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][15:12]};
                    wdata_m_inf[23:16]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][11:8] };
                    wdata_m_inf[15:8]    <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][7:4]  };
                    wdata_m_inf[7:0]     <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][3:0]  };
                end
            end
            3:
            begin
                if (cnt_16_2+1==16)
                begin
                    case (cnt_16_1)
                        1:
                            wdata_m_inf[127:120] <=  distance_4x4[2];
                        2:
                            wdata_m_inf[127:120] <=  distance_4x4[3];
                        3:
                            wdata_m_inf[127:120] <=  distance_4x4[4];
                        4:
                            wdata_m_inf[127:120] <=  distance_4x4[5];
                        5:
                            wdata_m_inf[127:120] <=  distance_4x4[6];
                        6:
                            wdata_m_inf[127:120] <=  distance_4x4[7];
                        7:
                            wdata_m_inf[127:120] <=  distance_4x4[8];
                        8:
                            wdata_m_inf[127:120] <=  distance_4x4[9];
                        9:
                            wdata_m_inf[127:120] <=  distance_4x4[10];
                        10:
                            wdata_m_inf[127:120] <=  distance_4x4[11];
                        11:
                            wdata_m_inf[127:120] <=  distance_4x4[12];
                        12:
                            wdata_m_inf[127:120] <=  distance_4x4[13];
                        13:
                            wdata_m_inf[127:120] <=  distance_4x4[14];
                        14:
                            wdata_m_inf[127:120] <=  distance_4x4[15];
                        15:
                            wdata_m_inf[127:120] <=  distance_4x4[16];
                    endcase
                    wdata_m_inf[119:112] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][59:56]};
                    wdata_m_inf[111:104] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][55:52]};
                    wdata_m_inf[103:96]  <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][51:48]};
                    wdata_m_inf[95:88]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][47:44]};
                    wdata_m_inf[87:80]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][43:40]};
                    wdata_m_inf[79:72]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][39:36]};
                    wdata_m_inf[71:64]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][35:32]};
                    wdata_m_inf[63:56]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][31:28]};
                    wdata_m_inf[55:48]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][27:24]};
                    wdata_m_inf[47:40]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][23:20]};
                    wdata_m_inf[39:32]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][19:16]};
                    wdata_m_inf[31:24]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][15:12]};
                    wdata_m_inf[23:16]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][11:8] };
                    wdata_m_inf[15:8]    <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][7:4]  };
                    wdata_m_inf[7:0]     <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][3:0]  };
                end
                else
                begin
                    wdata_m_inf[127:120] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][63:60]};
                    wdata_m_inf[119:112] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][59:56]};
                    wdata_m_inf[111:104] <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][55:52]};
                    wdata_m_inf[103:96]  <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][51:48]};
                    wdata_m_inf[95:88]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][47:44]};
                    wdata_m_inf[87:80]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][43:40]};
                    wdata_m_inf[79:72]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][39:36]};
                    wdata_m_inf[71:64]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][35:32]};
                    wdata_m_inf[63:56]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][31:28]};
                    wdata_m_inf[55:48]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][27:24]};
                    wdata_m_inf[47:40]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][23:20]};
                    wdata_m_inf[39:32]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][19:16]};
                    wdata_m_inf[31:24]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][15:12]};
                    wdata_m_inf[23:16]   <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][11:8] };
                    wdata_m_inf[15:8]    <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][7:4]  };
                    wdata_m_inf[7:0]     <=  {4'b0 , Data_16x16[cnt_16_1+1][cnt_16_2+1][3:0]  };
                end
            end

        endcase
    end
    else if (current_state==S_WAVALID)
    begin
        if (flag_write)
        begin
            wdata_m_inf[127:120] <=  {4'b0 , Data_16x16[1][1][63:60]};
            wdata_m_inf[119:112] <=  {4'b0 , Data_16x16[1][1][59:56]};
            wdata_m_inf[111:104] <=  {4'b0 , Data_16x16[1][1][55:52]};
            wdata_m_inf[103:96]  <=  {4'b0 , Data_16x16[1][1][51:48]};
            wdata_m_inf[95:88]   <=  {4'b0 , Data_16x16[1][1][47:44]};
            wdata_m_inf[87:80]   <=  {4'b0 , Data_16x16[1][1][43:40]};
            wdata_m_inf[79:72]   <=  {4'b0 , Data_16x16[1][1][39:36]};
            wdata_m_inf[71:64]   <=  {4'b0 , Data_16x16[1][1][35:32]};
            wdata_m_inf[63:56]   <=  {4'b0 , Data_16x16[1][1][31:28]};
            wdata_m_inf[55:48]   <=  {4'b0 , Data_16x16[1][1][27:24]};
            wdata_m_inf[47:40]   <=  {4'b0 , Data_16x16[1][1][23:20]};
            wdata_m_inf[39:32]   <=  {4'b0 , Data_16x16[1][1][19:16]};
            wdata_m_inf[31:24]   <=  {4'b0 , Data_16x16[1][1][15:12]};
            wdata_m_inf[23:16]   <=  {4'b0 , Data_16x16[1][1][11:8] };
            wdata_m_inf[15:8]    <=  {4'b0 , Data_16x16[1][1][7:4]  };
            wdata_m_inf[7:0]     <=  {4'b0 , Data_16x16[1][1][3:0]  };
        end
        else if (flag_write==0)
        begin
            wdata_m_inf <= DISTANCE;
        end
    end
end

//==================================================================================
//    Smallcnt_
//==================================================================================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        Smallcnt_1 <= 0;
    end
    else if (current_state==S_WRITEhis)
    begin
        if (Smallcnt_1==16)
        begin
            Smallcnt_1 <= 1;
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

always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        Smallcnt_2 <= 0;
    end
    else if (current_state==S_WRITEhis)
    begin
        if (wready_m_inf)
        begin
            Smallcnt_2 <=  Smallcnt_2+1;
        end
    end
    else if (current_state==S_IDLE)
    begin
        Smallcnt_2 <= 0;
    end
end
//==================================================================================
//==================================================================================

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
            if (Bigcnt_1==256)
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
//---- cntX , cntY -------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        cntX <= 0;
    end
    else if (current_state == S_MAKEhis)
    begin
        if (Bigcnt_1==257)
        begin
            cntX <= 0;
        end
        else if (Bigcnt_1>=1)
        begin
            cntX <= cntX + 1;
        end
    end
    else if (current_state == S_WRITEhis)
    begin
        if (Bigcnt_1==257)
        begin
            cntX <= 0;
        end
        else
        begin
            cntX <= cntX+1;
        end
    end
    else if (current_state == S_IDLE)
    begin
        cntX <= 0;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        cntY <= 0;
    end
    else if (current_state == S_MAKEhis)
    begin
        if (Bigcnt_1==257)
        begin
            cntY <= 0;
        end
        else if (cntX == 15)
        begin
            cntY <= cntY + 1;
        end
    end
    else if (current_state==S_WAVALID)
    begin
        if (temp_type==1)
        begin
            cntY <= 1;
        end
    end
    else if (current_state == S_WRITEhis)
    begin
        case (temp_type)
            1:
            begin
                if (Bigcnt_1 == 15)
                begin
                    cntY <= 3;
                end
                else if (Bigcnt_1 == 31)
                begin
                    cntY <= 9;
                end
                else if (Bigcnt_1 == 47)
                begin
                    cntY <= 11;
                end
                else if (Bigcnt_1==63)
                begin
                    cntY <= 0;
                end
            end
            2:
            begin
                if(Bigcnt_1==0)
                    cntY <= 2;
                else if(Bigcnt_1==240)
                    cntY <= 0;
                else if (cntX==15)
                    cntY <= cntY + 1;
            end
            3:
            begin
                if(Bigcnt_1==0)
                    cntY <= 2;
                else if(Bigcnt_1==240)
                    cntY <= 0;
                else if (cntX==15)
                    cntY <= cntY + 1;
            end

        endcase
    end
    else if (current_state == S_IDLE)
    begin
        cntY <= 0;
    end
end

//-------bin--------------------------------------------
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
    else if (current_state==S_WRITEhis)
    begin
        case (temp_type)
            1:
                if (Bigcnt_1==0 || Smallcnt_1==16)
                begin
                    bin_1[0 ] <= 0;
                    bin_1[1 ] <= 0;
                    bin_1[2 ] <= 0;
                    bin_1[3 ] <= 0;
                    bin_1[4 ] <= 0;
                    bin_1[5 ] <= Data_16x16[cntY][cntX+1][3:0]   + Data_16x16[cntY+1][cntX+1][3:0]   + Data_16x16[cntY+4][cntX+1][3:0]   + Data_16x16[cntY+5][cntX+1][3:0]  ;
                    bin_1[6 ] <= Data_16x16[cntY][cntX+1][7:4]   + Data_16x16[cntY+1][cntX+1][7:4]   + Data_16x16[cntY+4][cntX+1][7:4]   + Data_16x16[cntY+5][cntX+1][7:4]  ;
                    bin_1[7 ] <= Data_16x16[cntY][cntX+1][11:8]  + Data_16x16[cntY+1][cntX+1][11:8]  + Data_16x16[cntY+4][cntX+1][11:8]  + Data_16x16[cntY+5][cntX+1][11:8] ;
                    bin_1[8 ] <= Data_16x16[cntY][cntX+1][15:12] + Data_16x16[cntY+1][cntX+1][15:12] + Data_16x16[cntY+4][cntX+1][15:12] + Data_16x16[cntY+5][cntX+1][15:12];
                    bin_1[9 ] <= Data_16x16[cntY][cntX+1][19:16] + Data_16x16[cntY+1][cntX+1][19:16] + Data_16x16[cntY+4][cntX+1][19:16] + Data_16x16[cntY+5][cntX+1][19:16];
                    bin_1[10] <= Data_16x16[cntY][cntX+1][23:20] + Data_16x16[cntY+1][cntX+1][23:20] + Data_16x16[cntY+4][cntX+1][23:20] + Data_16x16[cntY+5][cntX+1][23:20];
                    bin_1[11] <= Data_16x16[cntY][cntX+1][27:24] + Data_16x16[cntY+1][cntX+1][27:24] + Data_16x16[cntY+4][cntX+1][27:24] + Data_16x16[cntY+5][cntX+1][27:24];
                    bin_1[12] <= Data_16x16[cntY][cntX+1][31:28] + Data_16x16[cntY+1][cntX+1][31:28] + Data_16x16[cntY+4][cntX+1][31:28] + Data_16x16[cntY+5][cntX+1][31:28];
                    bin_1[13] <= Data_16x16[cntY][cntX+1][35:32] + Data_16x16[cntY+1][cntX+1][35:32] + Data_16x16[cntY+4][cntX+1][35:32] + Data_16x16[cntY+5][cntX+1][35:32];
                    bin_1[14] <= Data_16x16[cntY][cntX+1][39:36] + Data_16x16[cntY+1][cntX+1][39:36] + Data_16x16[cntY+4][cntX+1][39:36] + Data_16x16[cntY+5][cntX+1][39:36];
                    bin_1[15] <= Data_16x16[cntY][cntX+1][43:40] + Data_16x16[cntY+1][cntX+1][43:40] + Data_16x16[cntY+4][cntX+1][43:40] + Data_16x16[cntY+5][cntX+1][43:40];
                    bin_1[16] <= Data_16x16[cntY][cntX+1][47:44] + Data_16x16[cntY+1][cntX+1][47:44] + Data_16x16[cntY+4][cntX+1][47:44] + Data_16x16[cntY+5][cntX+1][47:44];
                    bin_1[17] <= Data_16x16[cntY][cntX+1][51:48] + Data_16x16[cntY+1][cntX+1][51:48] + Data_16x16[cntY+4][cntX+1][51:48] + Data_16x16[cntY+5][cntX+1][51:48];
                    bin_1[18] <= Data_16x16[cntY][cntX+1][55:52] + Data_16x16[cntY+1][cntX+1][55:52] + Data_16x16[cntY+4][cntX+1][55:52] + Data_16x16[cntY+5][cntX+1][55:52];
                    bin_1[19] <= Data_16x16[cntY][cntX+1][59:56] + Data_16x16[cntY+1][cntX+1][59:56] + Data_16x16[cntY+4][cntX+1][59:56] + Data_16x16[cntY+5][cntX+1][59:56];
                    bin_1[20] <= Data_16x16[cntY][cntX+1][63:60] + Data_16x16[cntY+1][cntX+1][63:60] + Data_16x16[cntY+4][cntX+1][63:60] + Data_16x16[cntY+5][cntX+1][63:60];
                end
                else
                begin
                    bin_1[0 ] <= bin_1[16];
                    bin_1[1 ] <= bin_1[17];
                    bin_1[2 ] <= bin_1[18];
                    bin_1[3 ] <= bin_1[19];
                    bin_1[4 ] <= bin_1[20];
                    bin_1[5 ] <= Data_16x16[cntY][cntX+1][3:0]   + Data_16x16[cntY+1][cntX+1][3:0]   + Data_16x16[cntY+4][cntX+1][3:0]   + Data_16x16[cntY+5][cntX+1][3:0]  ;
                    bin_1[6 ] <= Data_16x16[cntY][cntX+1][7:4]   + Data_16x16[cntY+1][cntX+1][7:4]   + Data_16x16[cntY+4][cntX+1][7:4]   + Data_16x16[cntY+5][cntX+1][7:4]  ;
                    bin_1[7 ] <= Data_16x16[cntY][cntX+1][11:8]  + Data_16x16[cntY+1][cntX+1][11:8]  + Data_16x16[cntY+4][cntX+1][11:8]  + Data_16x16[cntY+5][cntX+1][11:8] ;
                    bin_1[8 ] <= Data_16x16[cntY][cntX+1][15:12] + Data_16x16[cntY+1][cntX+1][15:12] + Data_16x16[cntY+4][cntX+1][15:12] + Data_16x16[cntY+5][cntX+1][15:12];
                    bin_1[9 ] <= Data_16x16[cntY][cntX+1][19:16] + Data_16x16[cntY+1][cntX+1][19:16] + Data_16x16[cntY+4][cntX+1][19:16] + Data_16x16[cntY+5][cntX+1][19:16];
                    bin_1[10] <= Data_16x16[cntY][cntX+1][23:20] + Data_16x16[cntY+1][cntX+1][23:20] + Data_16x16[cntY+4][cntX+1][23:20] + Data_16x16[cntY+5][cntX+1][23:20];
                    bin_1[11] <= Data_16x16[cntY][cntX+1][27:24] + Data_16x16[cntY+1][cntX+1][27:24] + Data_16x16[cntY+4][cntX+1][27:24] + Data_16x16[cntY+5][cntX+1][27:24];
                    bin_1[12] <= Data_16x16[cntY][cntX+1][31:28] + Data_16x16[cntY+1][cntX+1][31:28] + Data_16x16[cntY+4][cntX+1][31:28] + Data_16x16[cntY+5][cntX+1][31:28];
                    bin_1[13] <= Data_16x16[cntY][cntX+1][35:32] + Data_16x16[cntY+1][cntX+1][35:32] + Data_16x16[cntY+4][cntX+1][35:32] + Data_16x16[cntY+5][cntX+1][35:32];
                    bin_1[14] <= Data_16x16[cntY][cntX+1][39:36] + Data_16x16[cntY+1][cntX+1][39:36] + Data_16x16[cntY+4][cntX+1][39:36] + Data_16x16[cntY+5][cntX+1][39:36];
                    bin_1[15] <= Data_16x16[cntY][cntX+1][43:40] + Data_16x16[cntY+1][cntX+1][43:40] + Data_16x16[cntY+4][cntX+1][43:40] + Data_16x16[cntY+5][cntX+1][43:40];
                    bin_1[16] <= Data_16x16[cntY][cntX+1][47:44] + Data_16x16[cntY+1][cntX+1][47:44] + Data_16x16[cntY+4][cntX+1][47:44] + Data_16x16[cntY+5][cntX+1][47:44];
                    bin_1[17] <= Data_16x16[cntY][cntX+1][51:48] + Data_16x16[cntY+1][cntX+1][51:48] + Data_16x16[cntY+4][cntX+1][51:48] + Data_16x16[cntY+5][cntX+1][51:48];
                    bin_1[18] <= Data_16x16[cntY][cntX+1][55:52] + Data_16x16[cntY+1][cntX+1][55:52] + Data_16x16[cntY+4][cntX+1][55:52] + Data_16x16[cntY+5][cntX+1][55:52];
                    bin_1[19] <= Data_16x16[cntY][cntX+1][59:56] + Data_16x16[cntY+1][cntX+1][59:56] + Data_16x16[cntY+4][cntX+1][59:56] + Data_16x16[cntY+5][cntX+1][59:56];
                    bin_1[20] <= Data_16x16[cntY][cntX+1][63:60] + Data_16x16[cntY+1][cntX+1][63:60] + Data_16x16[cntY+4][cntX+1][63:60] + Data_16x16[cntY+5][cntX+1][63:60];
                end
            2:
                if (Bigcnt_1==0 || Smallcnt_1==16)
                begin
                    bin_1[0 ] <= 0;
                    bin_1[1 ] <= 0;
                    bin_1[2 ] <= 0;
                    bin_1[3 ] <= 0;
                    bin_1[4 ] <= 0;
                    bin_1[5 ] <= Data_16x16[cntY][cntX+1][3:0]  ;
                    bin_1[6 ] <= Data_16x16[cntY][cntX+1][7:4]  ;
                    bin_1[7 ] <= Data_16x16[cntY][cntX+1][11:8] ;
                    bin_1[8 ] <= Data_16x16[cntY][cntX+1][15:12];
                    bin_1[9 ] <= Data_16x16[cntY][cntX+1][19:16];
                    bin_1[10] <= Data_16x16[cntY][cntX+1][23:20];
                    bin_1[11] <= Data_16x16[cntY][cntX+1][27:24];
                    bin_1[12] <= Data_16x16[cntY][cntX+1][31:28];
                    bin_1[13] <= Data_16x16[cntY][cntX+1][35:32];
                    bin_1[14] <= Data_16x16[cntY][cntX+1][39:36];
                    bin_1[15] <= Data_16x16[cntY][cntX+1][43:40];
                    bin_1[16] <= Data_16x16[cntY][cntX+1][47:44];
                    bin_1[17] <= Data_16x16[cntY][cntX+1][51:48];
                    bin_1[18] <= Data_16x16[cntY][cntX+1][55:52];
                    bin_1[19] <= Data_16x16[cntY][cntX+1][59:56];
                    bin_1[20] <= Data_16x16[cntY][cntX+1][63:60];
                end
                else
                begin
                    bin_1[0 ] <= bin_1[16];
                    bin_1[1 ] <= bin_1[17];
                    bin_1[2 ] <= bin_1[18];
                    bin_1[3 ] <= bin_1[19];
                    bin_1[4 ] <= bin_1[20];
                    bin_1[5 ] <= Data_16x16[cntY][cntX+1][3:0]  ;
                    bin_1[6 ] <= Data_16x16[cntY][cntX+1][7:4]  ;
                    bin_1[7 ] <= Data_16x16[cntY][cntX+1][11:8] ;
                    bin_1[8 ] <= Data_16x16[cntY][cntX+1][15:12];
                    bin_1[9 ] <= Data_16x16[cntY][cntX+1][19:16];
                    bin_1[10] <= Data_16x16[cntY][cntX+1][23:20];
                    bin_1[11] <= Data_16x16[cntY][cntX+1][27:24];
                    bin_1[12] <= Data_16x16[cntY][cntX+1][31:28];
                    bin_1[13] <= Data_16x16[cntY][cntX+1][35:32];
                    bin_1[14] <= Data_16x16[cntY][cntX+1][39:36];
                    bin_1[15] <= Data_16x16[cntY][cntX+1][43:40];
                    bin_1[16] <= Data_16x16[cntY][cntX+1][47:44];
                    bin_1[17] <= Data_16x16[cntY][cntX+1][51:48];
                    bin_1[18] <= Data_16x16[cntY][cntX+1][55:52];
                    bin_1[19] <= Data_16x16[cntY][cntX+1][59:56];
                    bin_1[20] <= Data_16x16[cntY][cntX+1][63:60];
                end
            3:
                if (Bigcnt_1==0 || Smallcnt_1==16)
                begin
                    bin_1[0 ] <= 0;
                    bin_1[1 ] <= 0;
                    bin_1[2 ] <= 0;
                    bin_1[3 ] <= 0;
                    bin_1[4 ] <= 0;
                    bin_1[5 ] <= Data_16x16[cntY][cntX+1][3:0]  ;
                    bin_1[6 ] <= Data_16x16[cntY][cntX+1][7:4]  ;
                    bin_1[7 ] <= Data_16x16[cntY][cntX+1][11:8] ;
                    bin_1[8 ] <= Data_16x16[cntY][cntX+1][15:12];
                    bin_1[9 ] <= Data_16x16[cntY][cntX+1][19:16];
                    bin_1[10] <= Data_16x16[cntY][cntX+1][23:20];
                    bin_1[11] <= Data_16x16[cntY][cntX+1][27:24];
                    bin_1[12] <= Data_16x16[cntY][cntX+1][31:28];
                    bin_1[13] <= Data_16x16[cntY][cntX+1][35:32];
                    bin_1[14] <= Data_16x16[cntY][cntX+1][39:36];
                    bin_1[15] <= Data_16x16[cntY][cntX+1][43:40];
                    bin_1[16] <= Data_16x16[cntY][cntX+1][47:44];
                    bin_1[17] <= Data_16x16[cntY][cntX+1][51:48];
                    bin_1[18] <= Data_16x16[cntY][cntX+1][55:52];
                    bin_1[19] <= Data_16x16[cntY][cntX+1][59:56];
                    bin_1[20] <= Data_16x16[cntY][cntX+1][63:60];
                end
                else
                begin
                    bin_1[0 ] <= bin_1[16];
                    bin_1[1 ] <= bin_1[17];
                    bin_1[2 ] <= bin_1[18];
                    bin_1[3 ] <= bin_1[19];
                    bin_1[4 ] <= bin_1[20];
                    bin_1[5 ] <= Data_16x16[cntY][cntX+1][3:0]  ;
                    bin_1[6 ] <= Data_16x16[cntY][cntX+1][7:4]  ;
                    bin_1[7 ] <= Data_16x16[cntY][cntX+1][11:8] ;
                    bin_1[8 ] <= Data_16x16[cntY][cntX+1][15:12];
                    bin_1[9 ] <= Data_16x16[cntY][cntX+1][19:16];
                    bin_1[10] <= Data_16x16[cntY][cntX+1][23:20];
                    bin_1[11] <= Data_16x16[cntY][cntX+1][27:24];
                    bin_1[12] <= Data_16x16[cntY][cntX+1][31:28];
                    bin_1[13] <= Data_16x16[cntY][cntX+1][35:32];
                    bin_1[14] <= Data_16x16[cntY][cntX+1][39:36];
                    bin_1[15] <= Data_16x16[cntY][cntX+1][43:40];
                    bin_1[16] <= Data_16x16[cntY][cntX+1][47:44];
                    bin_1[17] <= Data_16x16[cntY][cntX+1][51:48];
                    bin_1[18] <= Data_16x16[cntY][cntX+1][55:52];
                    bin_1[19] <= Data_16x16[cntY][cntX+1][59:56];
                    bin_1[20] <= Data_16x16[cntY][cntX+1][63:60];
                end

        endcase
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
        bin_1[0]  <= 0;
        bin_1[1]  <= 0;
        bin_1[2]  <= 0;
        bin_1[3]  <= 0;
        bin_1[4]  <= 0;
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
    else if (current_state==S_WRITEhis)
    begin
        if (Bigcnt_1==0 || Smallcnt_1==16)
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
    else if (current_state==S_IDLE)
    begin
        DISTANCE <= 0;
    end
    else
    begin
        case (temp_type)
            0:
            begin
                if (rlast_m_inf)
                begin
                    DISTANCE[119:0] <= rdata_m_inf[119:0];
                end
                else if (rvalid_m_inf_d3 && rvalid_m_inf_d2==0)
                begin
                    DISTANCE[127:120] <= sum_max_dis;
                end
            end
            1:
            begin
                if (current_state==S_WRITEhis)
                begin
                    if (Bigcnt_1==17)
                    begin
                        DISTANCE[7:0]     <= {4'b0 , Data_16x16[1][16][3:0]  };
                        DISTANCE[15:8]    <= {4'b0 , Data_16x16[1][16][7:4]  };
                        DISTANCE[23:16]   <= {4'b0 , Data_16x16[1][16][11:8] };
                        DISTANCE[31:24]   <= {4'b0 , Data_16x16[1][16][15:12]};
                        DISTANCE[39:32]   <= {4'b0 , Data_16x16[1][16][19:16]};
                        DISTANCE[47:40]   <= {4'b0 , Data_16x16[1][16][23:20]};
                        DISTANCE[55:48]   <= {4'b0 , Data_16x16[1][16][27:24]};
                        DISTANCE[63:56]   <= {4'b0 , Data_16x16[1][16][31:28]};
                        DISTANCE[71:64]   <= {4'b0 , Data_16x16[1][16][35:32]};
                        DISTANCE[79:72]   <= {4'b0 , Data_16x16[1][16][39:36]};
                        DISTANCE[87:80]   <= {4'b0 , Data_16x16[1][16][43:40]};
                        DISTANCE[95:88]   <= {4'b0 , Data_16x16[1][16][47:44]};
                        DISTANCE[103:96]  <= {4'b0 , Data_16x16[1][16][51:48]};
                        DISTANCE[111:104] <= {4'b0 , Data_16x16[1][16][55:52]};
                        DISTANCE[119:112] <= {4'b0 , Data_16x16[1][16][60:56]};
                        DISTANCE[127:120] <= sum_max_dis;
                    end
                end
            end
            2:
            begin
                if (current_state==S_WRITEhis)
                begin
                    if (Bigcnt_1==257)
                    begin
                        DISTANCE[7:0]     <= {4'b0 , Data_16x16[1][16][3:0]  };
                        DISTANCE[15:8]    <= {4'b0 , Data_16x16[1][16][7:4]  };
                        DISTANCE[23:16]   <= {4'b0 , Data_16x16[1][16][11:8] };
                        DISTANCE[31:24]   <= {4'b0 , Data_16x16[1][16][15:12]};
                        DISTANCE[39:32]   <= {4'b0 , Data_16x16[1][16][19:16]};
                        DISTANCE[47:40]   <= {4'b0 , Data_16x16[1][16][23:20]};
                        DISTANCE[55:48]   <= {4'b0 , Data_16x16[1][16][27:24]};
                        DISTANCE[63:56]   <= {4'b0 , Data_16x16[1][16][31:28]};
                        DISTANCE[71:64]   <= {4'b0 , Data_16x16[1][16][35:32]};
                        DISTANCE[79:72]   <= {4'b0 , Data_16x16[1][16][39:36]};
                        DISTANCE[87:80]   <= {4'b0 , Data_16x16[1][16][43:40]};
                        DISTANCE[95:88]   <= {4'b0 , Data_16x16[1][16][47:44]};
                        DISTANCE[103:96]  <= {4'b0 , Data_16x16[1][16][51:48]};
                        DISTANCE[111:104] <= {4'b0 , Data_16x16[1][16][55:52]};
                        DISTANCE[119:112] <= {4'b0 , Data_16x16[1][16][60:56]};
                        DISTANCE[127:120] <= sum_max_dis;
                    end
                end
            end
            3:
            begin
                if (current_state==S_WRITEhis)
                begin
                    if (Bigcnt_1==257)
                    begin
                        DISTANCE[7:0]     <= {4'b0 , Data_16x16[1][16][3:0]  };
                        DISTANCE[15:8]    <= {4'b0 , Data_16x16[1][16][7:4]  };
                        DISTANCE[23:16]   <= {4'b0 , Data_16x16[1][16][11:8] };
                        DISTANCE[31:24]   <= {4'b0 , Data_16x16[1][16][15:12]};
                        DISTANCE[39:32]   <= {4'b0 , Data_16x16[1][16][19:16]};
                        DISTANCE[47:40]   <= {4'b0 , Data_16x16[1][16][23:20]};
                        DISTANCE[55:48]   <= {4'b0 , Data_16x16[1][16][27:24]};
                        DISTANCE[63:56]   <= {4'b0 , Data_16x16[1][16][31:28]};
                        DISTANCE[71:64]   <= {4'b0 , Data_16x16[1][16][35:32]};
                        DISTANCE[79:72]   <= {4'b0 , Data_16x16[1][16][39:36]};
                        DISTANCE[87:80]   <= {4'b0 , Data_16x16[1][16][43:40]};
                        DISTANCE[95:88]   <= {4'b0 , Data_16x16[1][16][47:44]};
                        DISTANCE[103:96]  <= {4'b0 , Data_16x16[1][16][51:48]};
                        DISTANCE[111:104] <= {4'b0 , Data_16x16[1][16][55:52]};
                        DISTANCE[119:112] <= {4'b0 , Data_16x16[1][16][60:56]};
                        DISTANCE[127:120] <= sum_max_dis;
                    end
                end
            end
        endcase
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
        if (current_state==S_WRITEhis)
        begin
            if (Smallcnt_1==1)
            begin
                sum_max     <= sum5_4;
                sum_max_dis <= sum5_4_dis;
            end
            else if (sum_max >= sum5_4)
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
        else if (rvalid_m_inf_d3 && rvalid_m_inf_d2==0)
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
    case (temp_type)
        2,3:
        begin
            for ( i=0 ; i<16; i=i+1 )
            begin
                sum5_o[i] =  bin_1[i]+bin_1[i+1]*4+bin_1[i+2]*3+bin_1[i+3]*2+bin_1[i+4];
            end
        end

        default:
        begin
            for ( i=0 ; i<16; i=i+1 )
            begin
                sum5_o[i] =  bin_1[i]+bin_1[i+2]+bin_1[i+4];
            end
        end
    endcase
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
//          IIIIIIII  NN      NN  PPPPPPPP   UU      UU  TTTTTTTTTT
//             II     NNNN    NN  PP     PP  UU      UU      TT
//             II     NN  NN  NN  PP     PP  UU      UU      TT
//             II     NN    NNNN  PPPPPPPP    UU    UU       TT
//          IIIIIIII  NN      NN  PP           UUUUUU        TT
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
    // else if(current_state==S_IDLE)
    // begin
    //     temp_FRAME <= 0;
    // end

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
//    Data_16x16
//==================================================================================
always @(posedge clk or negedge rst_n) // the 16th in everyHistogram
begin
    if (~rst_n)
    begin
        for ( i=1 ; i<17 ;i=i+1 )
        begin
            for ( j=1 ; j<17 ; j=j+1 )
            begin
                Data_16x16[i][j] <= 0;
            end
        end
    end
    else if (current_state==S_MAKEhis)
    begin
        if (Bigcnt_1==256 && in_valid==0)
        begin
            for ( i=1 ;i<17 ;i=i+1 )
            begin
                //------------------------------------------------------------------
                Data_16x16[1][i][3:0]   <= Data_16x16[i][1][3:0];
                Data_16x16[1][i][7:4]   <= Data_16x16[i][2][3:0];
                Data_16x16[1][i][11:8]  <= Data_16x16[i][3][3:0];
                Data_16x16[1][i][15:12] <= Data_16x16[i][4][3:0];
                Data_16x16[1][i][19:16] <= Data_16x16[i][5][3:0];
                Data_16x16[1][i][23:20] <= Data_16x16[i][6][3:0];
                Data_16x16[1][i][27:24] <= Data_16x16[i][7][3:0];
                Data_16x16[1][i][31:28] <= Data_16x16[i][8][3:0];
                Data_16x16[1][i][35:32] <= Data_16x16[i][9][3:0];
                Data_16x16[1][i][39:36] <= Data_16x16[i][10][3:0];
                Data_16x16[1][i][43:40] <= Data_16x16[i][11][3:0];
                Data_16x16[1][i][47:44] <= Data_16x16[i][12][3:0];
                Data_16x16[1][i][51:48] <= Data_16x16[i][13][3:0];
                Data_16x16[1][i][55:52] <= Data_16x16[i][14][3:0];
                Data_16x16[1][i][59:56] <= Data_16x16[i][15][3:0];
                Data_16x16[1][i][63:60] <= Data_16x16[i][16][3:0];
                //------------------------------------------------------------------
                Data_16x16[2][i][3:0]   <= Data_16x16[i][1] [7:4];
                Data_16x16[2][i][7:4]   <= Data_16x16[i][2] [7:4];
                Data_16x16[2][i][11:8]  <= Data_16x16[i][3] [7:4];
                Data_16x16[2][i][15:12] <= Data_16x16[i][4] [7:4];
                Data_16x16[2][i][19:16] <= Data_16x16[i][5] [7:4];
                Data_16x16[2][i][23:20] <= Data_16x16[i][6] [7:4];
                Data_16x16[2][i][27:24] <= Data_16x16[i][7] [7:4];
                Data_16x16[2][i][31:28] <= Data_16x16[i][8] [7:4];
                Data_16x16[2][i][35:32] <= Data_16x16[i][9] [7:4];
                Data_16x16[2][i][39:36] <= Data_16x16[i][10][7:4];
                Data_16x16[2][i][43:40] <= Data_16x16[i][11][7:4];
                Data_16x16[2][i][47:44] <= Data_16x16[i][12][7:4];
                Data_16x16[2][i][51:48] <= Data_16x16[i][13][7:4];
                Data_16x16[2][i][55:52] <= Data_16x16[i][14][7:4];
                Data_16x16[2][i][59:56] <= Data_16x16[i][15][7:4];
                Data_16x16[2][i][63:60] <= Data_16x16[i][16][7:4];
                //------------------------------------------------------------------
                Data_16x16[3][i][3:0]   <= Data_16x16[i][1] [11:8];
                Data_16x16[3][i][7:4]   <= Data_16x16[i][2] [11:8];
                Data_16x16[3][i][11:8]  <= Data_16x16[i][3] [11:8];
                Data_16x16[3][i][15:12] <= Data_16x16[i][4] [11:8];
                Data_16x16[3][i][19:16] <= Data_16x16[i][5] [11:8];
                Data_16x16[3][i][23:20] <= Data_16x16[i][6] [11:8];
                Data_16x16[3][i][27:24] <= Data_16x16[i][7] [11:8];
                Data_16x16[3][i][31:28] <= Data_16x16[i][8] [11:8];
                Data_16x16[3][i][35:32] <= Data_16x16[i][9] [11:8];
                Data_16x16[3][i][39:36] <= Data_16x16[i][10][11:8];
                Data_16x16[3][i][43:40] <= Data_16x16[i][11][11:8];
                Data_16x16[3][i][47:44] <= Data_16x16[i][12][11:8];
                Data_16x16[3][i][51:48] <= Data_16x16[i][13][11:8];
                Data_16x16[3][i][55:52] <= Data_16x16[i][14][11:8];
                Data_16x16[3][i][59:56] <= Data_16x16[i][15][11:8];
                Data_16x16[3][i][63:60] <= Data_16x16[i][16][11:8];
                //------------------------------------------------------------------
                Data_16x16[4][i][3:0]   <= Data_16x16[i][1] [15:12];
                Data_16x16[4][i][7:4]   <= Data_16x16[i][2] [15:12];
                Data_16x16[4][i][11:8]  <= Data_16x16[i][3] [15:12];
                Data_16x16[4][i][15:12] <= Data_16x16[i][4] [15:12];
                Data_16x16[4][i][19:16] <= Data_16x16[i][5] [15:12];
                Data_16x16[4][i][23:20] <= Data_16x16[i][6] [15:12];
                Data_16x16[4][i][27:24] <= Data_16x16[i][7] [15:12];
                Data_16x16[4][i][31:28] <= Data_16x16[i][8] [15:12];
                Data_16x16[4][i][35:32] <= Data_16x16[i][9] [15:12];
                Data_16x16[4][i][39:36] <= Data_16x16[i][10][15:12];
                Data_16x16[4][i][43:40] <= Data_16x16[i][11][15:12];
                Data_16x16[4][i][47:44] <= Data_16x16[i][12][15:12];
                Data_16x16[4][i][51:48] <= Data_16x16[i][13][15:12];
                Data_16x16[4][i][55:52] <= Data_16x16[i][14][15:12];
                Data_16x16[4][i][59:56] <= Data_16x16[i][15][15:12];
                Data_16x16[4][i][63:60] <= Data_16x16[i][16][15:12];
                //------------------------------------------------------------------
                Data_16x16[5][i][3:0]   <= Data_16x16[i][1] [19:16];
                Data_16x16[5][i][7:4]   <= Data_16x16[i][2] [19:16];
                Data_16x16[5][i][11:8]  <= Data_16x16[i][3] [19:16];
                Data_16x16[5][i][15:12] <= Data_16x16[i][4] [19:16];
                Data_16x16[5][i][19:16] <= Data_16x16[i][5] [19:16];
                Data_16x16[5][i][23:20] <= Data_16x16[i][6] [19:16];
                Data_16x16[5][i][27:24] <= Data_16x16[i][7] [19:16];
                Data_16x16[5][i][31:28] <= Data_16x16[i][8] [19:16];
                Data_16x16[5][i][35:32] <= Data_16x16[i][9] [19:16];
                Data_16x16[5][i][39:36] <= Data_16x16[i][10][19:16];
                Data_16x16[5][i][43:40] <= Data_16x16[i][11][19:16];
                Data_16x16[5][i][47:44] <= Data_16x16[i][12][19:16];
                Data_16x16[5][i][51:48] <= Data_16x16[i][13][19:16];
                Data_16x16[5][i][55:52] <= Data_16x16[i][14][19:16];
                Data_16x16[5][i][59:56] <= Data_16x16[i][15][19:16];
                Data_16x16[5][i][63:60] <= Data_16x16[i][16][19:16];
                //------------------------------------------------------------------
                Data_16x16[6][i][3:0]   <= Data_16x16[i][1] [23:20];
                Data_16x16[6][i][7:4]   <= Data_16x16[i][2] [23:20];
                Data_16x16[6][i][11:8]  <= Data_16x16[i][3] [23:20];
                Data_16x16[6][i][15:12] <= Data_16x16[i][4] [23:20];
                Data_16x16[6][i][19:16] <= Data_16x16[i][5] [23:20];
                Data_16x16[6][i][23:20] <= Data_16x16[i][6] [23:20];
                Data_16x16[6][i][27:24] <= Data_16x16[i][7] [23:20];
                Data_16x16[6][i][31:28] <= Data_16x16[i][8] [23:20];
                Data_16x16[6][i][35:32] <= Data_16x16[i][9] [23:20];
                Data_16x16[6][i][39:36] <= Data_16x16[i][10][23:20];
                Data_16x16[6][i][43:40] <= Data_16x16[i][11][23:20];
                Data_16x16[6][i][47:44] <= Data_16x16[i][12][23:20];
                Data_16x16[6][i][51:48] <= Data_16x16[i][13][23:20];
                Data_16x16[6][i][55:52] <= Data_16x16[i][14][23:20];
                Data_16x16[6][i][59:56] <= Data_16x16[i][15][23:20];
                Data_16x16[6][i][63:60] <= Data_16x16[i][16][23:20];
                //------------------------------------------------------------------
                Data_16x16[7][i][3:0]   <= Data_16x16[i][1] [27:24];
                Data_16x16[7][i][7:4]   <= Data_16x16[i][2] [27:24];
                Data_16x16[7][i][11:8]  <= Data_16x16[i][3] [27:24];
                Data_16x16[7][i][15:12] <= Data_16x16[i][4] [27:24];
                Data_16x16[7][i][19:16] <= Data_16x16[i][5] [27:24];
                Data_16x16[7][i][23:20] <= Data_16x16[i][6] [27:24];
                Data_16x16[7][i][27:24] <= Data_16x16[i][7] [27:24];
                Data_16x16[7][i][31:28] <= Data_16x16[i][8] [27:24];
                Data_16x16[7][i][35:32] <= Data_16x16[i][9] [27:24];
                Data_16x16[7][i][39:36] <= Data_16x16[i][10][27:24];
                Data_16x16[7][i][43:40] <= Data_16x16[i][11][27:24];
                Data_16x16[7][i][47:44] <= Data_16x16[i][12][27:24];
                Data_16x16[7][i][51:48] <= Data_16x16[i][13][27:24];
                Data_16x16[7][i][55:52] <= Data_16x16[i][14][27:24];
                Data_16x16[7][i][59:56] <= Data_16x16[i][15][27:24];
                Data_16x16[7][i][63:60] <= Data_16x16[i][16][27:24];
                //------------------------------------------------------------------
                Data_16x16[8][i][3:0]   <= Data_16x16[i][1] [31:28];
                Data_16x16[8][i][7:4]   <= Data_16x16[i][2] [31:28];
                Data_16x16[8][i][11:8]  <= Data_16x16[i][3] [31:28];
                Data_16x16[8][i][15:12] <= Data_16x16[i][4] [31:28];
                Data_16x16[8][i][19:16] <= Data_16x16[i][5] [31:28];
                Data_16x16[8][i][23:20] <= Data_16x16[i][6] [31:28];
                Data_16x16[8][i][27:24] <= Data_16x16[i][7] [31:28];
                Data_16x16[8][i][31:28] <= Data_16x16[i][8] [31:28];
                Data_16x16[8][i][35:32] <= Data_16x16[i][9] [31:28];
                Data_16x16[8][i][39:36] <= Data_16x16[i][10][31:28];
                Data_16x16[8][i][43:40] <= Data_16x16[i][11][31:28];
                Data_16x16[8][i][47:44] <= Data_16x16[i][12][31:28];
                Data_16x16[8][i][51:48] <= Data_16x16[i][13][31:28];
                Data_16x16[8][i][55:52] <= Data_16x16[i][14][31:28];
                Data_16x16[8][i][59:56] <= Data_16x16[i][15][31:28];
                Data_16x16[8][i][63:60] <= Data_16x16[i][16][31:28];
                //------------------------------------------------------------------
                Data_16x16[9][i][3:0]   <= Data_16x16[i][1] [35:32];
                Data_16x16[9][i][7:4]   <= Data_16x16[i][2] [35:32];
                Data_16x16[9][i][11:8]  <= Data_16x16[i][3] [35:32];
                Data_16x16[9][i][15:12] <= Data_16x16[i][4] [35:32];
                Data_16x16[9][i][19:16] <= Data_16x16[i][5] [35:32];
                Data_16x16[9][i][23:20] <= Data_16x16[i][6] [35:32];
                Data_16x16[9][i][27:24] <= Data_16x16[i][7] [35:32];
                Data_16x16[9][i][31:28] <= Data_16x16[i][8] [35:32];
                Data_16x16[9][i][35:32] <= Data_16x16[i][9] [35:32];
                Data_16x16[9][i][39:36] <= Data_16x16[i][10][35:32];
                Data_16x16[9][i][43:40] <= Data_16x16[i][11][35:32];
                Data_16x16[9][i][47:44] <= Data_16x16[i][12][35:32];
                Data_16x16[9][i][51:48] <= Data_16x16[i][13][35:32];
                Data_16x16[9][i][55:52] <= Data_16x16[i][14][35:32];
                Data_16x16[9][i][59:56] <= Data_16x16[i][15][35:32];
                Data_16x16[9][i][63:60] <= Data_16x16[i][16][35:32];
                //------------------------------------------------------------------
                Data_16x16[10][i][3:0]   <= Data_16x16[i][1] [39:36];
                Data_16x16[10][i][7:4]   <= Data_16x16[i][2] [39:36];
                Data_16x16[10][i][11:8]  <= Data_16x16[i][3] [39:36];
                Data_16x16[10][i][15:12] <= Data_16x16[i][4] [39:36];
                Data_16x16[10][i][19:16] <= Data_16x16[i][5] [39:36];
                Data_16x16[10][i][23:20] <= Data_16x16[i][6] [39:36];
                Data_16x16[10][i][27:24] <= Data_16x16[i][7] [39:36];
                Data_16x16[10][i][31:28] <= Data_16x16[i][8] [39:36];
                Data_16x16[10][i][35:32] <= Data_16x16[i][9] [39:36];
                Data_16x16[10][i][39:36] <= Data_16x16[i][10][39:36];
                Data_16x16[10][i][43:40] <= Data_16x16[i][11][39:36];
                Data_16x16[10][i][47:44] <= Data_16x16[i][12][39:36];
                Data_16x16[10][i][51:48] <= Data_16x16[i][13][39:36];
                Data_16x16[10][i][55:52] <= Data_16x16[i][14][39:36];
                Data_16x16[10][i][59:56] <= Data_16x16[i][15][39:36];
                Data_16x16[10][i][63:60] <= Data_16x16[i][16][39:36];
                //---------------------11---------------------------------------------
                Data_16x16[11][i][3:0]   <= Data_16x16[i][1] [43:40];
                Data_16x16[11][i][7:4]   <= Data_16x16[i][2] [43:40];
                Data_16x16[11][i][11:8]  <= Data_16x16[i][3] [43:40];
                Data_16x16[11][i][15:12] <= Data_16x16[i][4] [43:40];
                Data_16x16[11][i][19:16] <= Data_16x16[i][5] [43:40];
                Data_16x16[11][i][23:20] <= Data_16x16[i][6] [43:40];
                Data_16x16[11][i][27:24] <= Data_16x16[i][7] [43:40];
                Data_16x16[11][i][31:28] <= Data_16x16[i][8] [43:40];
                Data_16x16[11][i][35:32] <= Data_16x16[i][9] [43:40];
                Data_16x16[11][i][39:36] <= Data_16x16[i][10][43:40];
                Data_16x16[11][i][43:40] <= Data_16x16[i][11][43:40];
                Data_16x16[11][i][47:44] <= Data_16x16[i][12][43:40];
                Data_16x16[11][i][51:48] <= Data_16x16[i][13][43:40];
                Data_16x16[11][i][55:52] <= Data_16x16[i][14][43:40];
                Data_16x16[11][i][59:56] <= Data_16x16[i][15][43:40];
                Data_16x16[11][i][63:60] <= Data_16x16[i][16][43:40];
                //----------------------12-------------------------------------------
                Data_16x16[12][i][3:0]   <= Data_16x16[i][1] [47:44];
                Data_16x16[12][i][7:4]   <= Data_16x16[i][2] [47:44];
                Data_16x16[12][i][11:8]  <= Data_16x16[i][3] [47:44];
                Data_16x16[12][i][15:12] <= Data_16x16[i][4] [47:44];
                Data_16x16[12][i][19:16] <= Data_16x16[i][5] [47:44];
                Data_16x16[12][i][23:20] <= Data_16x16[i][6] [47:44];
                Data_16x16[12][i][27:24] <= Data_16x16[i][7] [47:44];
                Data_16x16[12][i][31:28] <= Data_16x16[i][8] [47:44];
                Data_16x16[12][i][35:32] <= Data_16x16[i][9] [47:44];
                Data_16x16[12][i][39:36] <= Data_16x16[i][10][47:44];
                Data_16x16[12][i][43:40] <= Data_16x16[i][11][47:44];
                Data_16x16[12][i][47:44] <= Data_16x16[i][12][47:44];
                Data_16x16[12][i][51:48] <= Data_16x16[i][13][47:44];
                Data_16x16[12][i][55:52] <= Data_16x16[i][14][47:44];
                Data_16x16[12][i][59:56] <= Data_16x16[i][15][47:44];
                Data_16x16[12][i][63:60] <= Data_16x16[i][16][47:44];
                //-----------------------13-------------------------------------------
                Data_16x16[13][i][3:0]   <= Data_16x16[i][1] [51:48];
                Data_16x16[13][i][7:4]   <= Data_16x16[i][2] [51:48];
                Data_16x16[13][i][11:8]  <= Data_16x16[i][3] [51:48];
                Data_16x16[13][i][15:12] <= Data_16x16[i][4] [51:48];
                Data_16x16[13][i][19:16] <= Data_16x16[i][5] [51:48];
                Data_16x16[13][i][23:20] <= Data_16x16[i][6] [51:48];
                Data_16x16[13][i][27:24] <= Data_16x16[i][7] [51:48];
                Data_16x16[13][i][31:28] <= Data_16x16[i][8] [51:48];
                Data_16x16[13][i][35:32] <= Data_16x16[i][9] [51:48];
                Data_16x16[13][i][39:36] <= Data_16x16[i][10][51:48];
                Data_16x16[13][i][43:40] <= Data_16x16[i][11][51:48];
                Data_16x16[13][i][47:44] <= Data_16x16[i][12][51:48];
                Data_16x16[13][i][51:48] <= Data_16x16[i][13][51:48];
                Data_16x16[13][i][55:52] <= Data_16x16[i][14][51:48];
                Data_16x16[13][i][59:56] <= Data_16x16[i][15][51:48];
                Data_16x16[13][i][63:60] <= Data_16x16[i][16][51:48];
                //-------------------------14-----------------------------------------
                Data_16x16[14][i][3:0]   <= Data_16x16[i][1] [55:52];
                Data_16x16[14][i][7:4]   <= Data_16x16[i][2] [55:52];
                Data_16x16[14][i][11:8]  <= Data_16x16[i][3] [55:52];
                Data_16x16[14][i][15:12] <= Data_16x16[i][4] [55:52];
                Data_16x16[14][i][19:16] <= Data_16x16[i][5] [55:52];
                Data_16x16[14][i][23:20] <= Data_16x16[i][6] [55:52];
                Data_16x16[14][i][27:24] <= Data_16x16[i][7] [55:52];
                Data_16x16[14][i][31:28] <= Data_16x16[i][8] [55:52];
                Data_16x16[14][i][35:32] <= Data_16x16[i][9] [55:52];
                Data_16x16[14][i][39:36] <= Data_16x16[i][10][55:52];
                Data_16x16[14][i][43:40] <= Data_16x16[i][11][55:52];
                Data_16x16[14][i][47:44] <= Data_16x16[i][12][55:52];
                Data_16x16[14][i][51:48] <= Data_16x16[i][13][55:52];
                Data_16x16[14][i][55:52] <= Data_16x16[i][14][55:52];
                Data_16x16[14][i][59:56] <= Data_16x16[i][15][55:52];
                Data_16x16[14][i][63:60] <= Data_16x16[i][16][55:52];
                //-------------------------15-----------------------------------------
                Data_16x16[15][i][3:0]   <= Data_16x16[i][1] [59:56];
                Data_16x16[15][i][7:4]   <= Data_16x16[i][2] [59:56];
                Data_16x16[15][i][11:8]  <= Data_16x16[i][3] [59:56];
                Data_16x16[15][i][15:12] <= Data_16x16[i][4] [59:56];
                Data_16x16[15][i][19:16] <= Data_16x16[i][5] [59:56];
                Data_16x16[15][i][23:20] <= Data_16x16[i][6] [59:56];
                Data_16x16[15][i][27:24] <= Data_16x16[i][7] [59:56];
                Data_16x16[15][i][31:28] <= Data_16x16[i][8] [59:56];
                Data_16x16[15][i][35:32] <= Data_16x16[i][9] [59:56];
                Data_16x16[15][i][39:36] <= Data_16x16[i][10][59:56];
                Data_16x16[15][i][43:40] <= Data_16x16[i][11][59:56];
                Data_16x16[15][i][47:44] <= Data_16x16[i][12][59:56];
                Data_16x16[15][i][51:48] <= Data_16x16[i][13][59:56];
                Data_16x16[15][i][55:52] <= Data_16x16[i][14][59:56];
                Data_16x16[15][i][59:56] <= Data_16x16[i][15][59:56];
                Data_16x16[15][i][63:60] <= Data_16x16[i][16][59:56];
                //------------------------16------------------------------------------
                Data_16x16[16][i][3:0]   <= Data_16x16[i][1] [63:60];
                Data_16x16[16][i][7:4]   <= Data_16x16[i][2] [63:60];
                Data_16x16[16][i][11:8]  <= Data_16x16[i][3] [63:60];
                Data_16x16[16][i][15:12] <= Data_16x16[i][4] [63:60];
                Data_16x16[16][i][19:16] <= Data_16x16[i][5] [63:60];
                Data_16x16[16][i][23:20] <= Data_16x16[i][6] [63:60];
                Data_16x16[16][i][27:24] <= Data_16x16[i][7] [63:60];
                Data_16x16[16][i][31:28] <= Data_16x16[i][8] [63:60];
                Data_16x16[16][i][35:32] <= Data_16x16[i][9] [63:60];
                Data_16x16[16][i][39:36] <= Data_16x16[i][10][63:60];
                Data_16x16[16][i][43:40] <= Data_16x16[i][11][63:60];
                Data_16x16[16][i][47:44] <= Data_16x16[i][12][63:60];
                Data_16x16[16][i][51:48] <= Data_16x16[i][13][63:60];
                Data_16x16[16][i][55:52] <= Data_16x16[i][14][63:60];
                Data_16x16[16][i][59:56] <= Data_16x16[i][15][63:60];
                Data_16x16[16][i][63:60] <= Data_16x16[i][16][63:60];
            end
        end
        else if (Bigcnt_1>=1)
        begin
            begin
                Data_16x16[cntY+1][cntX+1][63:60] <= Store_1[15] + Data_16x16[cntY+1][cntX+1][63:60];
                Data_16x16[cntY+1][cntX+1][59:56] <= Store_1[14] + Data_16x16[cntY+1][cntX+1][59:56];
                Data_16x16[cntY+1][cntX+1][55:52] <= Store_1[13] + Data_16x16[cntY+1][cntX+1][55:52];
                Data_16x16[cntY+1][cntX+1][51:48] <= Store_1[12] + Data_16x16[cntY+1][cntX+1][51:48];
                Data_16x16[cntY+1][cntX+1][47:44] <= Store_1[11] + Data_16x16[cntY+1][cntX+1][47:44];
                Data_16x16[cntY+1][cntX+1][43:40] <= Store_1[10] + Data_16x16[cntY+1][cntX+1][43:40];
                Data_16x16[cntY+1][cntX+1][39:36] <= Store_1[9]  + Data_16x16[cntY+1][cntX+1][39:36];
                Data_16x16[cntY+1][cntX+1][35:32] <= Store_1[8]  + Data_16x16[cntY+1][cntX+1][35:32];
                Data_16x16[cntY+1][cntX+1][31:28] <= Store_1[7]  + Data_16x16[cntY+1][cntX+1][31:28];
                Data_16x16[cntY+1][cntX+1][27:24] <= Store_1[6]  + Data_16x16[cntY+1][cntX+1][27:24];
                Data_16x16[cntY+1][cntX+1][23:20] <= Store_1[5]  + Data_16x16[cntY+1][cntX+1][23:20];
                Data_16x16[cntY+1][cntX+1][19:16] <= Store_1[4]  + Data_16x16[cntY+1][cntX+1][19:16];
                Data_16x16[cntY+1][cntX+1][15:12] <= Store_1[3]  + Data_16x16[cntY+1][cntX+1][15:12];
                Data_16x16[cntY+1][cntX+1][11:8]  <= Store_1[2]  + Data_16x16[cntY+1][cntX+1][11:8] ;
                Data_16x16[cntY+1][cntX+1][7:4]   <= Store_1[1]  + Data_16x16[cntY+1][cntX+1][7:4]  ;
                Data_16x16[cntY+1][cntX+1][3:0]   <= Store_1[0]  + Data_16x16[cntY+1][cntX+1][3:0]  ;
            end
        end
    end

    else if (current_state==S_IDLE)
    begin
        for ( i=1 ; i<17 ;i=i+1 )
        begin
            for ( j=1 ;j<17 ;j=j+1 )
            begin
                Data_16x16[i][j] <= 0;
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
        if (current_state==S_MAKEhis)
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


//==================================================================================
//    distance_4x4
//==================================================================================
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        for ( i=1 ;i<17 ; i=i+1)
        begin
            distance_4x4[i] <= 0;
        end
    end
    else if (current_state==S_IDLE)
    begin
        for ( i=1 ;i<17 ; i=i+1)
        begin
            distance_4x4[i] <= 0;
        end
    end
    else
    begin
        case (temp_type)
            1:
            begin
                if (current_state==S_WRITEhis)
                begin
                    if (Bigcnt_1==17)
                    begin
                        distance_4x4[1] <= sum_max_dis;
                        distance_4x4[2] <= sum_max_dis;
                        distance_4x4[5] <= sum_max_dis;
                        distance_4x4[6] <= sum_max_dis;
                    end
                    else if (Bigcnt_1==33)
                    begin
                        distance_4x4[3] <= sum_max_dis;
                        distance_4x4[4] <= sum_max_dis;
                        distance_4x4[7] <= sum_max_dis;
                        distance_4x4[8] <= sum_max_dis;
                    end
                    else if (Bigcnt_1==49)
                    begin
                        distance_4x4[9 ] <= sum_max_dis;
                        distance_4x4[10] <= sum_max_dis;
                        distance_4x4[13] <= sum_max_dis;
                        distance_4x4[14] <= sum_max_dis;
                    end
                    else if (Bigcnt_1==65)
                    begin
                        distance_4x4[11] <= sum_max_dis;
                        distance_4x4[12] <= sum_max_dis;
                        distance_4x4[15] <= sum_max_dis;
                        distance_4x4[16] <= sum_max_dis;
                    end
                end
            end
            2:
            begin
                if (current_state==S_WRITEhis)
                begin
                    case (Bigcnt_1)
                        17:
                            distance_4x4[2] <= sum_max_dis;
                        33:
                            distance_4x4[3] <= sum_max_dis;
                        49:
                            distance_4x4[4] <= sum_max_dis;
                        65:
                            distance_4x4[5] <= sum_max_dis;
                        81:
                            distance_4x4[6] <= sum_max_dis;
                        97:
                            distance_4x4[7] <= sum_max_dis;
                        113:
                            distance_4x4[8] <= sum_max_dis;
                        129:
                            distance_4x4[9] <= sum_max_dis;
                        145:
                            distance_4x4[10] <= sum_max_dis;
                        161:
                            distance_4x4[11] <= sum_max_dis;
                        177:
                            distance_4x4[12] <= sum_max_dis;
                        193:
                            distance_4x4[13] <= sum_max_dis;
                        209:
                            distance_4x4[14] <= sum_max_dis;
                        225:
                            distance_4x4[15] <= sum_max_dis;
                        241:
                            distance_4x4[16] <= sum_max_dis;
                        257:
                            distance_4x4[1] <= sum_max_dis;
                    endcase
                end
            end
            3:
            begin
                if (current_state==S_WRITEhis)
                begin
                    case (Bigcnt_1)
                        17:
                            distance_4x4[2] <= sum_max_dis;
                        33:
                            distance_4x4[3] <= sum_max_dis;
                        49:
                            distance_4x4[4] <= sum_max_dis;
                        65:
                            distance_4x4[5] <= sum_max_dis;
                        81:
                            distance_4x4[6] <= sum_max_dis;
                        97:
                            distance_4x4[7] <= sum_max_dis;
                        113:
                            distance_4x4[8] <= sum_max_dis;
                        129:
                            distance_4x4[9] <= sum_max_dis;
                        145:
                            distance_4x4[10] <= sum_max_dis;
                        161:
                            distance_4x4[11] <= sum_max_dis;
                        177:
                            distance_4x4[12] <= sum_max_dis;
                        193:
                            distance_4x4[13] <= sum_max_dis;
                        209:
                            distance_4x4[14] <= sum_max_dis;
                        225:
                            distance_4x4[15] <= sum_max_dis;
                        241:
                            distance_4x4[16] <= sum_max_dis;
                        257:
                            distance_4x4[1] <= sum_max_dis;
                    endcase
                end
            end
        endcase
    end
end



endmodule
