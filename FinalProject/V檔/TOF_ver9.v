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
assign arlen_m_inf   = 255;

//  READ data channel

assign rready_m_inf=1;

//  WRITE address channel
assign awid_m_inf    = 'b0;
assign awburst_m_inf = 2'b01;
assign awsize_m_inf  = 3'b100;

//  WRITE data channel
assign wvalid_m_inf = 1;
//  WRITE Response channel

//=======================  memory  ===========================================================

reg [1:0]   Data_1;
reg [3:0]   address_1;
reg [0:0]   WEN_1;
wire [1:0] memo_OUT_1;

SRAISH memo1( .Q(memo_OUT_1), .CLK(clk), .CEN(1'b0), .WEN(WEN_1), .A(address_1), .D(Data_1), .OEN(1'b0) );


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
reg [6:0] sum_max;
reg [7:0]  sum_max_dis;
//  window=5
reg [6:0] sum5_o[15:0];
reg [6:0] sum5_1[7:0];
reg [6:0] sum5_2[3:0];
reg [6:0] sum5_3[1:0];
reg [6:0] sum5_4;
reg [7:0]  sum5_o_dis[15:0];
reg [7:0]  sum5_1_dis[7:0];
reg [7:0]  sum5_2_dis[3:0];
reg [7:0]  sum5_3_dis[1:0];
reg [7:0]  sum5_4_dis;


reg [127:0] DISTANCE;
// Bin
reg [3:0] bin_1 [20:0];
reg [7:0] bin_2 [20:0];


//  Delay
reg in_valid_d1 , rvalid_m_inf_d1 , rvalid_m_inf_d2 , rvalid_m_inf_d3 , bvalid_m_inf_d1 , bvalid_m_inf_d2;

// flag

reg flag_5to6 , flag5to8 , flag_write , flag_bwrite; // use to switch state
reg FinTrans;
// reg  FinWrite , FinRead , FinDIS;

reg [63:0]  Data_16x16 [1:16][1:16];
reg [127:0] distance_4x4 [1:16];

// state
parameter S_IDLE      = 4'd0;
parameter S_HOME      = 4'd1;

parameter S_MAKEhis   = 4'd2;
parameter S_WRITEhis  = 4'd3;

parameter S_RAVALID   = 4'd4;
parameter S_READ      = 4'd5;
parameter S_CAL       = 4'd10;

parameter S_WAVALID   = 4'd6;
parameter S_WRITEdis  = 4'd7;

parameter S_SPATIAL  = 4'd8;
parameter S_BUSY     = 4'd9;


integer i;
integer j;
reg [4:0] current_state,next_state;
// reg [4:0] ,current_state_d;
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

// always @(posedge clk or negedge rst_n)
// begin
//     if (!rst_n)
//         current_state_d <= S_IDLE;
//     else
//         current_state_d <= current_state;
// end

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
            if (Bigcnt_1==255)
                next_state = S_CAL ;
            else
                next_state =  S_READ;
        S_CAL:
            if (Bigcnt_1==261)
                next_state = S_WAVALID ;
            else
                next_state = S_CAL;

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
            if (bvalid_m_inf_d2)
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
                            next_state = S_BUSY;
                        else
                            next_state = S_WAVALID ;
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
    if(!rst_n)
        bvalid_m_inf_d1 <= 0;
    else
        bvalid_m_inf_d1 <= bvalid_m_inf;
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        bvalid_m_inf_d2 <= 0;
    else
        bvalid_m_inf_d2 <= bvalid_m_inf_d1;
end

//==================================================================================
//           SRAM
//==================================================================================
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        Data_1 <= 0;
    else if(current_state==S_READ)
        Data_1 <= 1;
    else if(current_state==S_IDLE)
        Data_1 <= 0;
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        address_1 <= 0;
    else if(current_state==S_READ)
        address_1 <= 1;
    else
        address_1 <= 0;
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        WEN_1 <= 0;
    else if(current_state==S_READ)
        WEN_1 <= 0;
    else
        WEN_1 <= 1;
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
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        awaddr_m_inf <= 0;
    else if (FinTrans)
    begin
        awaddr_m_inf <= {12'd0,temp_FRAME, cnt_his_num, 8'h00};
    end
    else
    begin
        awaddr_m_inf <= {12'd0,temp_FRAME, cnt_his_num, 8'hF0};
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        awlen_m_inf <= 0;
    else if(flag_write)
        awlen_m_inf <= 255;
    else
        awlen_m_inf <= 0;
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
    if (!rst_n)
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
    if (!rst_n)
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
    if (!rst_n)
        cnt_16_1 <= 0;
    else if(current_state==S_IDLE)
        cnt_16_1<=0;
    else if(current_state==S_WRITEhis)// && wready_m_inf
        if (cnt_16_2==15)
            cnt_16_1 <= cnt_16_1+1;
end

//==================================================================================
//         Write data channel
//==================================================================================
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
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
    if (!rst_n)
    begin
        Smallcnt_1 <= 0;
    end
    else if (current_state==S_WRITEhis||current_state==S_CAL)
    begin
        if (Smallcnt_1==16)
            Smallcnt_1 <= 1;
        else
            Smallcnt_1 <= Smallcnt_1 + 1;
    end
    // else if (current_state==S_CAL)
    // begin
    //     if(Smallcnt_1==16)
    //         Smallcnt_1 <= 1;
    //     else if(Bigcnt_1>=1)
    //         Smallcnt_1 <= Smallcnt_1 + 1;
    // end
    else if (current_state==S_IDLE)
    begin
        Smallcnt_1 <= 0;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
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
    else if (current_state==S_WRITEhis ||current_state==S_CAL)
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
    // else if (current_state==S_CAL)
    // begin
    //     if (Bigcnt_1==257)
    //     begin
    //         cntX <= 0;
    //     end
    //     else if (Bigcnt_1>=1)
    //     begin
    //         cntX <= cntX + 1;
    //     end
    // end
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
            2,3:
            begin
                if(Bigcnt_1==0)
                    cntY <= 1;
                else if(Bigcnt_1==240)
                    cntY <= 0;
                else if (cntX==15)
                    cntY <= cntY + 1;
            end
        endcase
    end
    else if (current_state==S_CAL)
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
            2,3:
                if (Bigcnt_1==0 || Smallcnt_1==16)
                begin
                    bin_1[0 ] <= 0;
                    bin_1[1 ] <= 0;
                    bin_1[2 ] <= 0;
                    bin_1[3 ] <= 0;
                    bin_1[4 ] <= 0;
                    bin_1[5 ] <= Data_16x16[cntY+1][cntX+1][3:0]  ;
                    bin_1[6 ] <= Data_16x16[cntY+1][cntX+1][7:4]  ;
                    bin_1[7 ] <= Data_16x16[cntY+1][cntX+1][11:8] ;
                    bin_1[8 ] <= Data_16x16[cntY+1][cntX+1][15:12];
                    bin_1[9 ] <= Data_16x16[cntY+1][cntX+1][19:16];
                    bin_1[10] <= Data_16x16[cntY+1][cntX+1][23:20];
                    bin_1[11] <= Data_16x16[cntY+1][cntX+1][27:24];
                    bin_1[12] <= Data_16x16[cntY+1][cntX+1][31:28];
                    bin_1[13] <= Data_16x16[cntY+1][cntX+1][35:32];
                    bin_1[14] <= Data_16x16[cntY+1][cntX+1][39:36];
                    bin_1[15] <= Data_16x16[cntY+1][cntX+1][43:40];
                    bin_1[16] <= Data_16x16[cntY+1][cntX+1][47:44];
                    bin_1[17] <= Data_16x16[cntY+1][cntX+1][51:48];
                    bin_1[18] <= Data_16x16[cntY+1][cntX+1][55:52];
                    bin_1[19] <= Data_16x16[cntY+1][cntX+1][59:56];
                    bin_1[20] <= Data_16x16[cntY+1][cntX+1][63:60];
                end
                else
                begin
                    bin_1[0 ] <= bin_1[16];
                    bin_1[1 ] <= bin_1[17];
                    bin_1[2 ] <= bin_1[18];
                    bin_1[3 ] <= bin_1[19];
                    bin_1[4 ] <= bin_1[20];
                    bin_1[5 ] <= Data_16x16[cntY+1][cntX+1][3:0]  ;
                    bin_1[6 ] <= Data_16x16[cntY+1][cntX+1][7:4]  ;
                    bin_1[7 ] <= Data_16x16[cntY+1][cntX+1][11:8] ;
                    bin_1[8 ] <= Data_16x16[cntY+1][cntX+1][15:12];
                    bin_1[9 ] <= Data_16x16[cntY+1][cntX+1][19:16];
                    bin_1[10] <= Data_16x16[cntY+1][cntX+1][23:20];
                    bin_1[11] <= Data_16x16[cntY+1][cntX+1][27:24];
                    bin_1[12] <= Data_16x16[cntY+1][cntX+1][31:28];
                    bin_1[13] <= Data_16x16[cntY+1][cntX+1][35:32];
                    bin_1[14] <= Data_16x16[cntY+1][cntX+1][39:36];
                    bin_1[15] <= Data_16x16[cntY+1][cntX+1][43:40];
                    bin_1[16] <= Data_16x16[cntY+1][cntX+1][47:44];
                    bin_1[17] <= Data_16x16[cntY+1][cntX+1][51:48];
                    bin_1[18] <= Data_16x16[cntY+1][cntX+1][55:52];
                    bin_1[19] <= Data_16x16[cntY+1][cntX+1][59:56];
                    bin_1[20] <= Data_16x16[cntY+1][cntX+1][63:60];
                end
        endcase
    end
    else if(current_state==S_CAL)
    begin
        if (Bigcnt_1==0 || Smallcnt_1==16)
        begin
            bin_1[0 ] <= 0;
            bin_1[1 ] <= 0;
            bin_1[2 ] <= 0;
            bin_1[3 ] <= 0;
            bin_1[4 ] <= 0;
            bin_1[5 ] <= Data_16x16[cntY+1][cntX+1][3:0]  ;
            bin_1[6 ] <= Data_16x16[cntY+1][cntX+1][7:4]  ;
            bin_1[7 ] <= Data_16x16[cntY+1][cntX+1][11:8] ;
            bin_1[8 ] <= Data_16x16[cntY+1][cntX+1][15:12];
            bin_1[9 ] <= Data_16x16[cntY+1][cntX+1][19:16];
            bin_1[10] <= Data_16x16[cntY+1][cntX+1][23:20];
            bin_1[11] <= Data_16x16[cntY+1][cntX+1][27:24];
            bin_1[12] <= Data_16x16[cntY+1][cntX+1][31:28];
            bin_1[13] <= Data_16x16[cntY+1][cntX+1][35:32];
            bin_1[14] <= Data_16x16[cntY+1][cntX+1][39:36];
            bin_1[15] <= Data_16x16[cntY+1][cntX+1][43:40];
            bin_1[16] <= Data_16x16[cntY+1][cntX+1][47:44];
            bin_1[17] <= Data_16x16[cntY+1][cntX+1][51:48];
            bin_1[18] <= Data_16x16[cntY+1][cntX+1][55:52];
            bin_1[19] <= Data_16x16[cntY+1][cntX+1][59:56];
            bin_1[20] <= Data_16x16[cntY+1][cntX+1][63:60];
        end
        else
        begin
            bin_1[0 ] <= bin_1[16];
            bin_1[1 ] <= bin_1[17];
            bin_1[2 ] <= bin_1[18];
            bin_1[3 ] <= bin_1[19];
            bin_1[4 ] <= bin_1[20];
            bin_1[5 ] <= Data_16x16[cntY+1][cntX+1][3:0]  ;
            bin_1[6 ] <= Data_16x16[cntY+1][cntX+1][7:4]  ;
            bin_1[7 ] <= Data_16x16[cntY+1][cntX+1][11:8] ;
            bin_1[8 ] <= Data_16x16[cntY+1][cntX+1][15:12];
            bin_1[9 ] <= Data_16x16[cntY+1][cntX+1][19:16];
            bin_1[10] <= Data_16x16[cntY+1][cntX+1][23:20];
            bin_1[11] <= Data_16x16[cntY+1][cntX+1][27:24];
            bin_1[12] <= Data_16x16[cntY+1][cntX+1][31:28];
            bin_1[13] <= Data_16x16[cntY+1][cntX+1][35:32];
            bin_1[14] <= Data_16x16[cntY+1][cntX+1][39:36];
            bin_1[15] <= Data_16x16[cntY+1][cntX+1][43:40];
            bin_1[16] <= Data_16x16[cntY+1][cntX+1][47:44];
            bin_1[17] <= Data_16x16[cntY+1][cntX+1][51:48];
            bin_1[18] <= Data_16x16[cntY+1][cntX+1][55:52];
            bin_1[19] <= Data_16x16[cntY+1][cntX+1][59:56];
            bin_1[20] <= Data_16x16[cntY+1][cntX+1][63:60];
        end
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
    else if (current_state==S_WRITEhis || current_state==S_CAL)
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
    if (!rst_n)
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
                if (current_state==S_WAVALID)
                begin
                    case (cnt_his_num)
                        0:
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
                            DISTANCE[127:120] <= distance_4x4[1];
                        end
                        1:
                        begin
                            DISTANCE[7:0]     <= {4'b0 , Data_16x16[2][16][3:0]  };
                            DISTANCE[15:8]    <= {4'b0 , Data_16x16[2][16][7:4]  };
                            DISTANCE[23:16]   <= {4'b0 , Data_16x16[2][16][11:8] };
                            DISTANCE[31:24]   <= {4'b0 , Data_16x16[2][16][15:12]};
                            DISTANCE[39:32]   <= {4'b0 , Data_16x16[2][16][19:16]};
                            DISTANCE[47:40]   <= {4'b0 , Data_16x16[2][16][23:20]};
                            DISTANCE[55:48]   <= {4'b0 , Data_16x16[2][16][27:24]};
                            DISTANCE[63:56]   <= {4'b0 , Data_16x16[2][16][31:28]};
                            DISTANCE[71:64]   <= {4'b0 , Data_16x16[2][16][35:32]};
                            DISTANCE[79:72]   <= {4'b0 , Data_16x16[2][16][39:36]};
                            DISTANCE[87:80]   <= {4'b0 , Data_16x16[2][16][43:40]};
                            DISTANCE[95:88]   <= {4'b0 , Data_16x16[2][16][47:44]};
                            DISTANCE[103:96]  <= {4'b0 , Data_16x16[2][16][51:48]};
                            DISTANCE[111:104] <= {4'b0 , Data_16x16[2][16][55:52]};
                            DISTANCE[119:112] <= {4'b0 , Data_16x16[2][16][60:56]};
                            DISTANCE[127:120] <= distance_4x4[2];
                        end
                        2:
                        begin
                            DISTANCE[7:0]     <= {4'b0 , Data_16x16[3][16][3:0]  };
                            DISTANCE[15:8]    <= {4'b0 , Data_16x16[3][16][7:4]  };
                            DISTANCE[23:16]   <= {4'b0 , Data_16x16[3][16][11:8] };
                            DISTANCE[31:24]   <= {4'b0 , Data_16x16[3][16][15:12]};
                            DISTANCE[39:32]   <= {4'b0 , Data_16x16[3][16][19:16]};
                            DISTANCE[47:40]   <= {4'b0 , Data_16x16[3][16][23:20]};
                            DISTANCE[55:48]   <= {4'b0 , Data_16x16[3][16][27:24]};
                            DISTANCE[63:56]   <= {4'b0 , Data_16x16[3][16][31:28]};
                            DISTANCE[71:64]   <= {4'b0 , Data_16x16[3][16][35:32]};
                            DISTANCE[79:72]   <= {4'b0 , Data_16x16[3][16][39:36]};
                            DISTANCE[87:80]   <= {4'b0 , Data_16x16[3][16][43:40]};
                            DISTANCE[95:88]   <= {4'b0 , Data_16x16[3][16][47:44]};
                            DISTANCE[103:96]  <= {4'b0 , Data_16x16[3][16][51:48]};
                            DISTANCE[111:104] <= {4'b0 , Data_16x16[3][16][55:52]};
                            DISTANCE[119:112] <= {4'b0 , Data_16x16[3][16][60:56]};
                            DISTANCE[127:120] <= distance_4x4[3];
                        end
                        3:
                        begin
                            DISTANCE[7:0]     <= {4'b0 , Data_16x16[4][16][3:0]  };
                            DISTANCE[15:8]    <= {4'b0 , Data_16x16[4][16][7:4]  };
                            DISTANCE[23:16]   <= {4'b0 , Data_16x16[4][16][11:8] };
                            DISTANCE[31:24]   <= {4'b0 , Data_16x16[4][16][15:12]};
                            DISTANCE[39:32]   <= {4'b0 , Data_16x16[4][16][19:16]};
                            DISTANCE[47:40]   <= {4'b0 , Data_16x16[4][16][23:20]};
                            DISTANCE[55:48]   <= {4'b0 , Data_16x16[4][16][27:24]};
                            DISTANCE[63:56]   <= {4'b0 , Data_16x16[4][16][31:28]};
                            DISTANCE[71:64]   <= {4'b0 , Data_16x16[4][16][35:32]};
                            DISTANCE[79:72]   <= {4'b0 , Data_16x16[4][16][39:36]};
                            DISTANCE[87:80]   <= {4'b0 , Data_16x16[4][16][43:40]};
                            DISTANCE[95:88]   <= {4'b0 , Data_16x16[4][16][47:44]};
                            DISTANCE[103:96]  <= {4'b0 , Data_16x16[4][16][51:48]};
                            DISTANCE[111:104] <= {4'b0 , Data_16x16[4][16][55:52]};
                            DISTANCE[119:112] <= {4'b0 , Data_16x16[4][16][60:56]};
                            DISTANCE[127:120] <= distance_4x4[4];
                        end
                        4:
                        begin
                            DISTANCE[7:0]     <= {4'b0 , Data_16x16[5][16][3:0]  };
                            DISTANCE[15:8]    <= {4'b0 , Data_16x16[5][16][7:4]  };
                            DISTANCE[23:16]   <= {4'b0 , Data_16x16[5][16][11:8] };
                            DISTANCE[31:24]   <= {4'b0 , Data_16x16[5][16][15:12]};
                            DISTANCE[39:32]   <= {4'b0 , Data_16x16[5][16][19:16]};
                            DISTANCE[47:40]   <= {4'b0 , Data_16x16[5][16][23:20]};
                            DISTANCE[55:48]   <= {4'b0 , Data_16x16[5][16][27:24]};
                            DISTANCE[63:56]   <= {4'b0 , Data_16x16[5][16][31:28]};
                            DISTANCE[71:64]   <= {4'b0 , Data_16x16[5][16][35:32]};
                            DISTANCE[79:72]   <= {4'b0 , Data_16x16[5][16][39:36]};
                            DISTANCE[87:80]   <= {4'b0 , Data_16x16[5][16][43:40]};
                            DISTANCE[95:88]   <= {4'b0 , Data_16x16[5][16][47:44]};
                            DISTANCE[103:96]  <= {4'b0 , Data_16x16[5][16][51:48]};
                            DISTANCE[111:104] <= {4'b0 , Data_16x16[5][16][55:52]};
                            DISTANCE[119:112] <= {4'b0 , Data_16x16[5][16][60:56]};
                            DISTANCE[127:120] <= distance_4x4[5];
                        end
                        5:
                        begin
                            DISTANCE[7:0]     <= {4'b0 , Data_16x16[6][16][3:0]  };
                            DISTANCE[15:8]    <= {4'b0 , Data_16x16[6][16][7:4]  };
                            DISTANCE[23:16]   <= {4'b0 , Data_16x16[6][16][11:8] };
                            DISTANCE[31:24]   <= {4'b0 , Data_16x16[6][16][15:12]};
                            DISTANCE[39:32]   <= {4'b0 , Data_16x16[6][16][19:16]};
                            DISTANCE[47:40]   <= {4'b0 , Data_16x16[6][16][23:20]};
                            DISTANCE[55:48]   <= {4'b0 , Data_16x16[6][16][27:24]};
                            DISTANCE[63:56]   <= {4'b0 , Data_16x16[6][16][31:28]};
                            DISTANCE[71:64]   <= {4'b0 , Data_16x16[6][16][35:32]};
                            DISTANCE[79:72]   <= {4'b0 , Data_16x16[6][16][39:36]};
                            DISTANCE[87:80]   <= {4'b0 , Data_16x16[6][16][43:40]};
                            DISTANCE[95:88]   <= {4'b0 , Data_16x16[6][16][47:44]};
                            DISTANCE[103:96]  <= {4'b0 , Data_16x16[6][16][51:48]};
                            DISTANCE[111:104] <= {4'b0 , Data_16x16[6][16][55:52]};
                            DISTANCE[119:112] <= {4'b0 , Data_16x16[6][16][60:56]};
                            DISTANCE[127:120] <= distance_4x4[6];
                        end
                        6:
                        begin
                            DISTANCE[7:0]     <= {4'b0 , Data_16x16[7][16][3:0]  };
                            DISTANCE[15:8]    <= {4'b0 , Data_16x16[7][16][7:4]  };
                            DISTANCE[23:16]   <= {4'b0 , Data_16x16[7][16][11:8] };
                            DISTANCE[31:24]   <= {4'b0 , Data_16x16[7][16][15:12]};
                            DISTANCE[39:32]   <= {4'b0 , Data_16x16[7][16][19:16]};
                            DISTANCE[47:40]   <= {4'b0 , Data_16x16[7][16][23:20]};
                            DISTANCE[55:48]   <= {4'b0 , Data_16x16[7][16][27:24]};
                            DISTANCE[63:56]   <= {4'b0 , Data_16x16[7][16][31:28]};
                            DISTANCE[71:64]   <= {4'b0 , Data_16x16[7][16][35:32]};
                            DISTANCE[79:72]   <= {4'b0 , Data_16x16[7][16][39:36]};
                            DISTANCE[87:80]   <= {4'b0 , Data_16x16[7][16][43:40]};
                            DISTANCE[95:88]   <= {4'b0 , Data_16x16[7][16][47:44]};
                            DISTANCE[103:96]  <= {4'b0 , Data_16x16[7][16][51:48]};
                            DISTANCE[111:104] <= {4'b0 , Data_16x16[7][16][55:52]};
                            DISTANCE[119:112] <= {4'b0 , Data_16x16[7][16][60:56]};
                            DISTANCE[127:120] <= distance_4x4[7];
                        end
                        7:
                        begin
                            DISTANCE[7:0]     <= {4'b0 , Data_16x16[8][16][3:0]  };
                            DISTANCE[15:8]    <= {4'b0 , Data_16x16[8][16][7:4]  };
                            DISTANCE[23:16]   <= {4'b0 , Data_16x16[8][16][11:8] };
                            DISTANCE[31:24]   <= {4'b0 , Data_16x16[8][16][15:12]};
                            DISTANCE[39:32]   <= {4'b0 , Data_16x16[8][16][19:16]};
                            DISTANCE[47:40]   <= {4'b0 , Data_16x16[8][16][23:20]};
                            DISTANCE[55:48]   <= {4'b0 , Data_16x16[8][16][27:24]};
                            DISTANCE[63:56]   <= {4'b0 , Data_16x16[8][16][31:28]};
                            DISTANCE[71:64]   <= {4'b0 , Data_16x16[8][16][35:32]};
                            DISTANCE[79:72]   <= {4'b0 , Data_16x16[8][16][39:36]};
                            DISTANCE[87:80]   <= {4'b0 , Data_16x16[8][16][43:40]};
                            DISTANCE[95:88]   <= {4'b0 , Data_16x16[8][16][47:44]};
                            DISTANCE[103:96]  <= {4'b0 , Data_16x16[8][16][51:48]};
                            DISTANCE[111:104] <= {4'b0 , Data_16x16[8][16][55:52]};
                            DISTANCE[119:112] <= {4'b0 , Data_16x16[8][16][60:56]};
                            DISTANCE[127:120] <= distance_4x4[8];
                        end
                        8:
                        begin
                            DISTANCE[7:0]     <= {4'b0 , Data_16x16[9][16][3:0]  };
                            DISTANCE[15:8]    <= {4'b0 , Data_16x16[9][16][7:4]  };
                            DISTANCE[23:16]   <= {4'b0 , Data_16x16[9][16][11:8] };
                            DISTANCE[31:24]   <= {4'b0 , Data_16x16[9][16][15:12]};
                            DISTANCE[39:32]   <= {4'b0 , Data_16x16[9][16][19:16]};
                            DISTANCE[47:40]   <= {4'b0 , Data_16x16[9][16][23:20]};
                            DISTANCE[55:48]   <= {4'b0 , Data_16x16[9][16][27:24]};
                            DISTANCE[63:56]   <= {4'b0 , Data_16x16[9][16][31:28]};
                            DISTANCE[71:64]   <= {4'b0 , Data_16x16[9][16][35:32]};
                            DISTANCE[79:72]   <= {4'b0 , Data_16x16[9][16][39:36]};
                            DISTANCE[87:80]   <= {4'b0 , Data_16x16[9][16][43:40]};
                            DISTANCE[95:88]   <= {4'b0 , Data_16x16[9][16][47:44]};
                            DISTANCE[103:96]  <= {4'b0 , Data_16x16[9][16][51:48]};
                            DISTANCE[111:104] <= {4'b0 , Data_16x16[9][16][55:52]};
                            DISTANCE[119:112] <= {4'b0 , Data_16x16[9][16][60:56]};
                            DISTANCE[127:120] <= distance_4x4[9];
                        end
                        9:
                        begin
                            DISTANCE[7:0]     <= {4'b0 , Data_16x16[10][16][3:0]  };
                            DISTANCE[15:8]    <= {4'b0 , Data_16x16[10][16][7:4]  };
                            DISTANCE[23:16]   <= {4'b0 , Data_16x16[10][16][11:8] };
                            DISTANCE[31:24]   <= {4'b0 , Data_16x16[10][16][15:12]};
                            DISTANCE[39:32]   <= {4'b0 , Data_16x16[10][16][19:16]};
                            DISTANCE[47:40]   <= {4'b0 , Data_16x16[10][16][23:20]};
                            DISTANCE[55:48]   <= {4'b0 , Data_16x16[10][16][27:24]};
                            DISTANCE[63:56]   <= {4'b0 , Data_16x16[10][16][31:28]};
                            DISTANCE[71:64]   <= {4'b0 , Data_16x16[10][16][35:32]};
                            DISTANCE[79:72]   <= {4'b0 , Data_16x16[10][16][39:36]};
                            DISTANCE[87:80]   <= {4'b0 , Data_16x16[10][16][43:40]};
                            DISTANCE[95:88]   <= {4'b0 , Data_16x16[10][16][47:44]};
                            DISTANCE[103:96]  <= {4'b0 , Data_16x16[10][16][51:48]};
                            DISTANCE[111:104] <= {4'b0 , Data_16x16[10][16][55:52]};
                            DISTANCE[119:112] <= {4'b0 , Data_16x16[10][16][60:56]};
                            DISTANCE[127:120] <= distance_4x4[10];
                        end
                        10:
                        begin
                            DISTANCE[7:0]     <= {4'b0 , Data_16x16[11][16][3:0]  };
                            DISTANCE[15:8]    <= {4'b0 , Data_16x16[11][16][7:4]  };
                            DISTANCE[23:16]   <= {4'b0 , Data_16x16[11][16][11:8] };
                            DISTANCE[31:24]   <= {4'b0 , Data_16x16[11][16][15:12]};
                            DISTANCE[39:32]   <= {4'b0 , Data_16x16[11][16][19:16]};
                            DISTANCE[47:40]   <= {4'b0 , Data_16x16[11][16][23:20]};
                            DISTANCE[55:48]   <= {4'b0 , Data_16x16[11][16][27:24]};
                            DISTANCE[63:56]   <= {4'b0 , Data_16x16[11][16][31:28]};
                            DISTANCE[71:64]   <= {4'b0 , Data_16x16[11][16][35:32]};
                            DISTANCE[79:72]   <= {4'b0 , Data_16x16[11][16][39:36]};
                            DISTANCE[87:80]   <= {4'b0 , Data_16x16[11][16][43:40]};
                            DISTANCE[95:88]   <= {4'b0 , Data_16x16[11][16][47:44]};
                            DISTANCE[103:96]  <= {4'b0 , Data_16x16[11][16][51:48]};
                            DISTANCE[111:104] <= {4'b0 , Data_16x16[11][16][55:52]};
                            DISTANCE[119:112] <= {4'b0 , Data_16x16[11][16][60:56]};
                            DISTANCE[127:120] <= distance_4x4[11];
                        end
                        11:
                        begin
                            DISTANCE[7:0]     <= {4'b0 , Data_16x16[12][16][3:0]  };
                            DISTANCE[15:8]    <= {4'b0 , Data_16x16[12][16][7:4]  };
                            DISTANCE[23:16]   <= {4'b0 , Data_16x16[12][16][11:8] };
                            DISTANCE[31:24]   <= {4'b0 , Data_16x16[12][16][15:12]};
                            DISTANCE[39:32]   <= {4'b0 , Data_16x16[12][16][19:16]};
                            DISTANCE[47:40]   <= {4'b0 , Data_16x16[12][16][23:20]};
                            DISTANCE[55:48]   <= {4'b0 , Data_16x16[12][16][27:24]};
                            DISTANCE[63:56]   <= {4'b0 , Data_16x16[12][16][31:28]};
                            DISTANCE[71:64]   <= {4'b0 , Data_16x16[12][16][35:32]};
                            DISTANCE[79:72]   <= {4'b0 , Data_16x16[12][16][39:36]};
                            DISTANCE[87:80]   <= {4'b0 , Data_16x16[12][16][43:40]};
                            DISTANCE[95:88]   <= {4'b0 , Data_16x16[12][16][47:44]};
                            DISTANCE[103:96]  <= {4'b0 , Data_16x16[12][16][51:48]};
                            DISTANCE[111:104] <= {4'b0 , Data_16x16[12][16][55:52]};
                            DISTANCE[119:112] <= {4'b0 , Data_16x16[12][16][60:56]};
                            DISTANCE[127:120] <= distance_4x4[12];
                        end
                        12:
                        begin
                            DISTANCE[7:0]     <= {4'b0 , Data_16x16[13][16][3:0]  };
                            DISTANCE[15:8]    <= {4'b0 , Data_16x16[13][16][7:4]  };
                            DISTANCE[23:16]   <= {4'b0 , Data_16x16[13][16][11:8] };
                            DISTANCE[31:24]   <= {4'b0 , Data_16x16[13][16][15:12]};
                            DISTANCE[39:32]   <= {4'b0 , Data_16x16[13][16][19:16]};
                            DISTANCE[47:40]   <= {4'b0 , Data_16x16[13][16][23:20]};
                            DISTANCE[55:48]   <= {4'b0 , Data_16x16[13][16][27:24]};
                            DISTANCE[63:56]   <= {4'b0 , Data_16x16[13][16][31:28]};
                            DISTANCE[71:64]   <= {4'b0 , Data_16x16[13][16][35:32]};
                            DISTANCE[79:72]   <= {4'b0 , Data_16x16[13][16][39:36]};
                            DISTANCE[87:80]   <= {4'b0 , Data_16x16[13][16][43:40]};
                            DISTANCE[95:88]   <= {4'b0 , Data_16x16[13][16][47:44]};
                            DISTANCE[103:96]  <= {4'b0 , Data_16x16[13][16][51:48]};
                            DISTANCE[111:104] <= {4'b0 , Data_16x16[13][16][55:52]};
                            DISTANCE[119:112] <= {4'b0 , Data_16x16[13][16][60:56]};
                            DISTANCE[127:120] <= distance_4x4[13];
                        end
                        13:
                        begin
                            DISTANCE[7:0]     <= {4'b0 , Data_16x16[14][16][3:0]  };
                            DISTANCE[15:8]    <= {4'b0 , Data_16x16[14][16][7:4]  };
                            DISTANCE[23:16]   <= {4'b0 , Data_16x16[14][16][11:8] };
                            DISTANCE[31:24]   <= {4'b0 , Data_16x16[14][16][15:12]};
                            DISTANCE[39:32]   <= {4'b0 , Data_16x16[14][16][19:16]};
                            DISTANCE[47:40]   <= {4'b0 , Data_16x16[14][16][23:20]};
                            DISTANCE[55:48]   <= {4'b0 , Data_16x16[14][16][27:24]};
                            DISTANCE[63:56]   <= {4'b0 , Data_16x16[14][16][31:28]};
                            DISTANCE[71:64]   <= {4'b0 , Data_16x16[14][16][35:32]};
                            DISTANCE[79:72]   <= {4'b0 , Data_16x16[14][16][39:36]};
                            DISTANCE[87:80]   <= {4'b0 , Data_16x16[14][16][43:40]};
                            DISTANCE[95:88]   <= {4'b0 , Data_16x16[14][16][47:44]};
                            DISTANCE[103:96]  <= {4'b0 , Data_16x16[14][16][51:48]};
                            DISTANCE[111:104] <= {4'b0 , Data_16x16[14][16][55:52]};
                            DISTANCE[119:112] <= {4'b0 , Data_16x16[14][16][60:56]};
                            DISTANCE[127:120] <= distance_4x4[14];
                        end
                        14:
                        begin
                            DISTANCE[7:0]     <= {4'b0 , Data_16x16[15][16][3:0]  };
                            DISTANCE[15:8]    <= {4'b0 , Data_16x16[15][16][7:4]  };
                            DISTANCE[23:16]   <= {4'b0 , Data_16x16[15][16][11:8] };
                            DISTANCE[31:24]   <= {4'b0 , Data_16x16[15][16][15:12]};
                            DISTANCE[39:32]   <= {4'b0 , Data_16x16[15][16][19:16]};
                            DISTANCE[47:40]   <= {4'b0 , Data_16x16[15][16][23:20]};
                            DISTANCE[55:48]   <= {4'b0 , Data_16x16[15][16][27:24]};
                            DISTANCE[63:56]   <= {4'b0 , Data_16x16[15][16][31:28]};
                            DISTANCE[71:64]   <= {4'b0 , Data_16x16[15][16][35:32]};
                            DISTANCE[79:72]   <= {4'b0 , Data_16x16[15][16][39:36]};
                            DISTANCE[87:80]   <= {4'b0 , Data_16x16[15][16][43:40]};
                            DISTANCE[95:88]   <= {4'b0 , Data_16x16[15][16][47:44]};
                            DISTANCE[103:96]  <= {4'b0 , Data_16x16[15][16][51:48]};
                            DISTANCE[111:104] <= {4'b0 , Data_16x16[15][16][55:52]};
                            DISTANCE[119:112] <= {4'b0 , Data_16x16[15][16][60:56]};
                            DISTANCE[127:120] <= distance_4x4[15];
                        end
                        15:
                        begin
                            DISTANCE[7:0]     <= {4'b0 , Data_16x16[16][16][3:0]  };
                            DISTANCE[15:8]    <= {4'b0 , Data_16x16[16][16][7:4]  };
                            DISTANCE[23:16]   <= {4'b0 , Data_16x16[16][16][11:8] };
                            DISTANCE[31:24]   <= {4'b0 , Data_16x16[16][16][15:12]};
                            DISTANCE[39:32]   <= {4'b0 , Data_16x16[16][16][19:16]};
                            DISTANCE[47:40]   <= {4'b0 , Data_16x16[16][16][23:20]};
                            DISTANCE[55:48]   <= {4'b0 , Data_16x16[16][16][27:24]};
                            DISTANCE[63:56]   <= {4'b0 , Data_16x16[16][16][31:28]};
                            DISTANCE[71:64]   <= {4'b0 , Data_16x16[16][16][35:32]};
                            DISTANCE[79:72]   <= {4'b0 , Data_16x16[16][16][39:36]};
                            DISTANCE[87:80]   <= {4'b0 , Data_16x16[16][16][43:40]};
                            DISTANCE[95:88]   <= {4'b0 , Data_16x16[16][16][47:44]};
                            DISTANCE[103:96]  <= {4'b0 , Data_16x16[16][16][51:48]};
                            DISTANCE[111:104] <= {4'b0 , Data_16x16[16][16][55:52]};
                            DISTANCE[119:112] <= {4'b0 , Data_16x16[16][16][60:56]};
                            DISTANCE[127:120] <= distance_4x4[16];
                        end
                    endcase
                end
            end
            1:
            begin
                if (current_state==S_WRITEhis)
                begin
                    if (Bigcnt_1==21) //17
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
            2,3:
            begin
                if (current_state==S_WRITEhis)
                begin
                    if (Bigcnt_1==261)//
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
    if (!rst_n)
    begin
        sum_max     <= 0;
        sum_max_dis <= 0;
    end
    else
    begin
        if (current_state==S_WRITEhis || current_state==S_CAL)
        begin
            if (Smallcnt_1==5)
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
    end
end

//====================================================
// window=5
//====================================================
always @(posedge clk or negedge rst_n) //level1
begin
    if(!rst_n)
    begin
        for ( i=0 ;i<16 ;i=i+2 )
        begin
            sum5_1[i/2]     <= 0;
            sum5_1_dis[i/2] <= 0;
        end
    end
    else
    begin
        for ( i=0 ;i<16 ;i=i+2 )
        begin
            if (sum5_o[i]>=sum5_o[i+1])
            begin
                sum5_1[i/2]     <= sum5_o[i];
                sum5_1_dis[i/2] <= sum5_o_dis[i];
            end
            else
            begin
                sum5_1[i/2]     <= sum5_o[i+1];
                sum5_1_dis[i/2] <= sum5_o_dis[i+1];
            end
        end
    end
end

always @(posedge clk or negedge rst_n) //level2
begin
    if(!rst_n)
    begin
        for ( i=0 ;i<8 ;i=i+2 )
        begin
            sum5_2[i/2]     <= 0;
            sum5_2_dis[i/2] <= 0;
        end
    end
    else
    begin
        for ( i=0 ;i<8 ;i=i+2 )
        begin
            if (sum5_1[i]>=sum5_1[i+1])
            begin
                sum5_2[i/2]     <= sum5_1[i];
                sum5_2_dis[i/2] <= sum5_1_dis[i];
            end
            else
            begin
                sum5_2[i/2]     <= sum5_1[i+1];
                sum5_2_dis[i/2] <= sum5_1_dis[i+1];
            end
        end
    end
end

always @(posedge clk or negedge rst_n) //level3
begin
    if(!rst_n)
    begin
        sum5_3[0]     <= 0;
        sum5_3[1]     <= 0;
        sum5_3_dis[0] <= 0;
        sum5_3_dis[1] <= 0;
    end
    else
    begin
        for ( i=0 ;i<4 ;i=i+2 )
        begin
            if (sum5_2[i]>=sum5_2[i+1])
            begin
                sum5_3[i/2]     <= sum5_2[i];
                sum5_3_dis[i/2] <= sum5_2_dis[i];
            end
            else
            begin
                sum5_3[i/2]     <= sum5_2[i+1];
                sum5_3_dis[i/2] <= sum5_2_dis[i+1];
            end
        end
    end
end

always @(posedge clk or negedge rst_n) //level4
begin
    if(!rst_n)
    begin
        sum5_4     <= 0;
        sum5_4_dis <= 0;
    end
    else
    begin
        if (sum5_3[0]>=sum5_3[1])
        begin
            sum5_4     <= sum5_3[0];
            sum5_4_dis <= sum5_3_dis[0];
        end
        else
        begin
            sum5_4     <= sum5_3[1];
            sum5_4_dis <= sum5_3_dis[1];
        end
    end
end




//---------------Combinatial circuit---------------------------------------------------
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
    if (!rst_n)
    begin
        Bigcnt_1 <= 0;
    end
    else
    begin
        case (current_state)
            S_MAKEhis:
            begin
                if (in_valid==0 && Bigcnt_1==256)
                    Bigcnt_1 <= 0;
                else if (Bigcnt_1==257)
                    Bigcnt_1 <= 0;
                else if (start)
                    Bigcnt_1 <= Bigcnt_1 + 1;
                else if (Bigcnt_1 > 250)
                    Bigcnt_1 <= Bigcnt_1 + 1;
            end
            S_WRITEhis:
                Bigcnt_1 <= Bigcnt_1 + 1;

            S_READ:
                if(Bigcnt_1==255)
                    Bigcnt_1 <= 0;
                else if(Bigcnt_1>=1)
                    Bigcnt_1 <= Bigcnt_1 + 1;
                else if (rvalid_m_inf)
                    Bigcnt_1 <= Bigcnt_1 + 1;

            S_CAL:
                Bigcnt_1 <= Bigcnt_1 + 1;

            S_IDLE:
                Bigcnt_1 <= 0;
            default:
                Bigcnt_1 <= 0;
        endcase
    end
end

always @(posedge clk or negedge rst_n) // 1~16
begin
    if (!rst_n)
    begin
        cnt_his_num <= 0;
    end
    else
    begin
        if (bvalid_m_inf)
        begin
            if (current_state==S_WRITEhis)
                cnt_his_num <= cnt_his_num ;
            else
                cnt_his_num <= cnt_his_num + 1;
        end
        else if (current_state==S_IDLE)
            cnt_his_num <= 0;
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
    if (!rst_n)
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
    if (!rst_n)
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
    if (!rst_n)
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
always @(posedge clk or negedge rst_n) // 1
begin
    if (!rst_n)
    begin
        for ( j=1 ; j<17 ; j=j+1 )
        begin
            Data_16x16[1][j] <= 0;
        end
    end
    else if (current_state==S_MAKEhis)
    begin
        if ((in_valid || in_valid_d1)&& Bigcnt_1>=1)
        begin
            case(cntX)
                0:
                    Data_16x16[1][cntY+1][3:0]   <= Store_1[0] + Data_16x16[1][cntY+1][3:0];
                1:
                    Data_16x16[1][cntY+1][7:4]   <= Store_1[0] + Data_16x16[1][cntY+1][7:4];
                2:
                    Data_16x16[1][cntY+1][11:8]  <= Store_1[0] + Data_16x16[1][cntY+1][11:8];
                3:
                    Data_16x16[1][cntY+1][15:12] <= Store_1[0] + Data_16x16[1][cntY+1][15:12];
                4:
                    Data_16x16[1][cntY+1][19:16] <= Store_1[0] + Data_16x16[1][cntY+1][19:16];
                5:
                    Data_16x16[1][cntY+1][23:20] <= Store_1[0] + Data_16x16[1][cntY+1][23:20];
                6:
                    Data_16x16[1][cntY+1][27:24] <= Store_1[0] + Data_16x16[1][cntY+1][27:24];
                7:
                    Data_16x16[1][cntY+1][31:28] <= Store_1[0] + Data_16x16[1][cntY+1][31:28];
                8:
                    Data_16x16[1][cntY+1][35:32] <= Store_1[0] + Data_16x16[1][cntY+1][35:32];
                9:
                    Data_16x16[1][cntY+1][39:36] <= Store_1[0] + Data_16x16[1][cntY+1][39:36];
                10:
                    Data_16x16[1][cntY+1][43:40] <= Store_1[0] + Data_16x16[1][cntY+1][43:40];
                11:
                    Data_16x16[1][cntY+1][47:44] <= Store_1[0] + Data_16x16[1][cntY+1][47:44];
                12:
                    Data_16x16[1][cntY+1][51:48] <= Store_1[0] + Data_16x16[1][cntY+1][51:48];
                13:
                    Data_16x16[1][cntY+1][55:52] <= Store_1[0] + Data_16x16[1][cntY+1][55:52];
                14:
                    Data_16x16[1][cntY+1][59:56] <= Store_1[0] + Data_16x16[1][cntY+1][59:56];
                15:
                    Data_16x16[1][cntY+1][63:60] <= Store_1[0] + Data_16x16[1][cntY+1][63:60];
            endcase
        end
    end
    else if (current_state==S_READ)
    begin
        Data_16x16[1][16][3:0]   <= Data_16x16[2][1][3:0]  ;
        Data_16x16[1][16][7:4]   <= Data_16x16[2][1][7:4]  ;
        Data_16x16[1][16][11:8]  <= Data_16x16[2][1][11:8] ;
        Data_16x16[1][16][15:12] <= Data_16x16[2][1][15:12];
        Data_16x16[1][16][19:16] <= Data_16x16[2][1][19:16];
        Data_16x16[1][16][23:20] <= Data_16x16[2][1][23:20];
        Data_16x16[1][16][27:24] <= Data_16x16[2][1][27:24];
        Data_16x16[1][16][31:28] <= Data_16x16[2][1][31:28];
        Data_16x16[1][16][35:32] <= Data_16x16[2][1][35:32];
        Data_16x16[1][16][39:36] <= Data_16x16[2][1][39:36];
        Data_16x16[1][16][43:40] <= Data_16x16[2][1][43:40];
        Data_16x16[1][16][47:44] <= Data_16x16[2][1][47:44];
        Data_16x16[1][16][51:48] <= Data_16x16[2][1][51:48];
        Data_16x16[1][16][55:52] <= Data_16x16[2][1][55:52];
        Data_16x16[1][16][59:56] <= Data_16x16[2][1][59:56];
        Data_16x16[1][16][63:60] <= Data_16x16[2][1][63:60];
        for ( j=1 ;j<16 ;j=j+1 )
        begin
            Data_16x16[1][j][3:0]   <= Data_16x16[1][j+1][3:0]  ;
            Data_16x16[1][j][7:4]   <= Data_16x16[1][j+1][7:4]  ;
            Data_16x16[1][j][11:8]  <= Data_16x16[1][j+1][11:8] ;
            Data_16x16[1][j][15:12] <= Data_16x16[1][j+1][15:12];
            Data_16x16[1][j][19:16] <= Data_16x16[1][j+1][19:16];
            Data_16x16[1][j][23:20] <= Data_16x16[1][j+1][23:20];
            Data_16x16[1][j][27:24] <= Data_16x16[1][j+1][27:24];
            Data_16x16[1][j][31:28] <= Data_16x16[1][j+1][31:28];
            Data_16x16[1][j][35:32] <= Data_16x16[1][j+1][35:32];
            Data_16x16[1][j][39:36] <= Data_16x16[1][j+1][39:36];
            Data_16x16[1][j][43:40] <= Data_16x16[1][j+1][43:40];
            Data_16x16[1][j][47:44] <= Data_16x16[1][j+1][47:44];
            Data_16x16[1][j][51:48] <= Data_16x16[1][j+1][51:48];
            Data_16x16[1][j][55:52] <= Data_16x16[1][j+1][55:52];
            Data_16x16[1][j][59:56] <= Data_16x16[1][j+1][59:56];
            Data_16x16[1][j][63:60] <= Data_16x16[1][j+1][63:60];
        end
    end
    else if (current_state==S_IDLE)
    begin
        for ( j=1 ;j<17 ;j=j+1 )
        begin
            Data_16x16[1][j] <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) // 2
begin
    if (!rst_n)
    begin
        for ( j=1 ; j<17 ; j=j+1 )
        begin
            Data_16x16[2][j] <= 0;
        end
    end
    else if (current_state==S_MAKEhis)
    begin
        if ((in_valid || in_valid_d1)&& Bigcnt_1>=1)
        begin
            case(cntX)
                0:
                    Data_16x16[2][cntY+1][3:0]   <= Store_1[1] + Data_16x16[2][cntY+1][3:0];
                1:
                    Data_16x16[2][cntY+1][7:4]   <= Store_1[1] + Data_16x16[2][cntY+1][7:4];
                2:
                    Data_16x16[2][cntY+1][11:8]  <= Store_1[1] + Data_16x16[2][cntY+1][11:8];
                3:
                    Data_16x16[2][cntY+1][15:12] <= Store_1[1] + Data_16x16[2][cntY+1][15:12];
                4:
                    Data_16x16[2][cntY+1][19:16] <= Store_1[1] + Data_16x16[2][cntY+1][19:16];
                5:
                    Data_16x16[2][cntY+1][23:20] <= Store_1[1] + Data_16x16[2][cntY+1][23:20];
                6:
                    Data_16x16[2][cntY+1][27:24] <= Store_1[1] + Data_16x16[2][cntY+1][27:24];
                7:
                    Data_16x16[2][cntY+1][31:28] <= Store_1[1] + Data_16x16[2][cntY+1][31:28];
                8:
                    Data_16x16[2][cntY+1][35:32] <= Store_1[1] + Data_16x16[2][cntY+1][35:32];
                9:
                    Data_16x16[2][cntY+1][39:36] <= Store_1[1] + Data_16x16[2][cntY+1][39:36];
                10:
                    Data_16x16[2][cntY+1][43:40] <= Store_1[1] + Data_16x16[2][cntY+1][43:40];
                11:
                    Data_16x16[2][cntY+1][47:44] <= Store_1[1] + Data_16x16[2][cntY+1][47:44];
                12:
                    Data_16x16[2][cntY+1][51:48] <= Store_1[1] + Data_16x16[2][cntY+1][51:48];
                13:
                    Data_16x16[2][cntY+1][55:52] <= Store_1[1] + Data_16x16[2][cntY+1][55:52];
                14:
                    Data_16x16[2][cntY+1][59:56] <= Store_1[1] + Data_16x16[2][cntY+1][59:56];
                15:
                    Data_16x16[2][cntY+1][63:60] <= Store_1[1] + Data_16x16[2][cntY+1][63:60];
            endcase
        end
    end
    else if (current_state==S_READ)
    begin
        Data_16x16[2][16][3:0]   <= Data_16x16[3][1][3:0]  ;
        Data_16x16[2][16][7:4]   <= Data_16x16[3][1][7:4]  ;
        Data_16x16[2][16][11:8]  <= Data_16x16[3][1][11:8] ;
        Data_16x16[2][16][15:12] <= Data_16x16[3][1][15:12];
        Data_16x16[2][16][19:16] <= Data_16x16[3][1][19:16];
        Data_16x16[2][16][23:20] <= Data_16x16[3][1][23:20];
        Data_16x16[2][16][27:24] <= Data_16x16[3][1][27:24];
        Data_16x16[2][16][31:28] <= Data_16x16[3][1][31:28];
        Data_16x16[2][16][35:32] <= Data_16x16[3][1][35:32];
        Data_16x16[2][16][39:36] <= Data_16x16[3][1][39:36];
        Data_16x16[2][16][43:40] <= Data_16x16[3][1][43:40];
        Data_16x16[2][16][47:44] <= Data_16x16[3][1][47:44];
        Data_16x16[2][16][51:48] <= Data_16x16[3][1][51:48];
        Data_16x16[2][16][55:52] <= Data_16x16[3][1][55:52];
        Data_16x16[2][16][59:56] <= Data_16x16[3][1][59:56];
        Data_16x16[2][16][63:60] <= Data_16x16[3][1][63:60];
        for ( j=1 ;j<16 ;j=j+1 )
        begin
            Data_16x16[2][j][3:0]   <= Data_16x16[2][j+1][3:0]  ;
            Data_16x16[2][j][7:4]   <= Data_16x16[2][j+1][7:4]  ;
            Data_16x16[2][j][11:8]  <= Data_16x16[2][j+1][11:8] ;
            Data_16x16[2][j][15:12] <= Data_16x16[2][j+1][15:12];
            Data_16x16[2][j][19:16] <= Data_16x16[2][j+1][19:16];
            Data_16x16[2][j][23:20] <= Data_16x16[2][j+1][23:20];
            Data_16x16[2][j][27:24] <= Data_16x16[2][j+1][27:24];
            Data_16x16[2][j][31:28] <= Data_16x16[2][j+1][31:28];
            Data_16x16[2][j][35:32] <= Data_16x16[2][j+1][35:32];
            Data_16x16[2][j][39:36] <= Data_16x16[2][j+1][39:36];
            Data_16x16[2][j][43:40] <= Data_16x16[2][j+1][43:40];
            Data_16x16[2][j][47:44] <= Data_16x16[2][j+1][47:44];
            Data_16x16[2][j][51:48] <= Data_16x16[2][j+1][51:48];
            Data_16x16[2][j][55:52] <= Data_16x16[2][j+1][55:52];
            Data_16x16[2][j][59:56] <= Data_16x16[2][j+1][59:56];
            Data_16x16[2][j][63:60] <= Data_16x16[2][j+1][63:60];
        end
    end
    else if (current_state==S_IDLE)
    begin
        for ( j=1 ;j<17 ;j=j+1 )
        begin
            Data_16x16[2][j] <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) //  3th
begin
    if (!rst_n)
    begin
        for ( j=1 ; j<17 ; j=j+1 )
        begin
            Data_16x16[3][j] <= 0;
        end
    end
    else if (current_state==S_MAKEhis)
    begin
        if ((in_valid || in_valid_d1)&& Bigcnt_1>=1)
        begin
            case(cntX)
                0:
                    Data_16x16[3][cntY+1][3:0]   <= Store_1[2] + Data_16x16[3][cntY+1][3:0];
                1:
                    Data_16x16[3][cntY+1][7:4]   <= Store_1[2] + Data_16x16[3][cntY+1][7:4];
                2:
                    Data_16x16[3][cntY+1][11:8]  <= Store_1[2] + Data_16x16[3][cntY+1][11:8];
                3:
                    Data_16x16[3][cntY+1][15:12] <= Store_1[2] + Data_16x16[3][cntY+1][15:12];
                4:
                    Data_16x16[3][cntY+1][19:16] <= Store_1[2] + Data_16x16[3][cntY+1][19:16];
                5:
                    Data_16x16[3][cntY+1][23:20] <= Store_1[2] + Data_16x16[3][cntY+1][23:20];
                6:
                    Data_16x16[3][cntY+1][27:24] <= Store_1[2] + Data_16x16[3][cntY+1][27:24];
                7:
                    Data_16x16[3][cntY+1][31:28] <= Store_1[2] + Data_16x16[3][cntY+1][31:28];
                8:
                    Data_16x16[3][cntY+1][35:32] <= Store_1[2] + Data_16x16[3][cntY+1][35:32];
                9:
                    Data_16x16[3][cntY+1][39:36] <= Store_1[2] + Data_16x16[3][cntY+1][39:36];
                10:
                    Data_16x16[3][cntY+1][43:40] <= Store_1[2] + Data_16x16[3][cntY+1][43:40];
                11:
                    Data_16x16[3][cntY+1][47:44] <= Store_1[2] + Data_16x16[3][cntY+1][47:44];
                12:
                    Data_16x16[3][cntY+1][51:48] <= Store_1[2] + Data_16x16[3][cntY+1][51:48];
                13:
                    Data_16x16[3][cntY+1][55:52] <= Store_1[2] + Data_16x16[3][cntY+1][55:52];
                14:
                    Data_16x16[3][cntY+1][59:56] <= Store_1[2] + Data_16x16[3][cntY+1][59:56];
                15:
                    Data_16x16[3][cntY+1][63:60] <= Store_1[2] + Data_16x16[3][cntY+1][63:60];
            endcase
        end
    end
    else if (current_state==S_READ)
    begin
        Data_16x16[3][16][3:0]   <= Data_16x16[4][1][3:0]  ;
        Data_16x16[3][16][7:4]   <= Data_16x16[4][1][7:4]  ;
        Data_16x16[3][16][11:8]  <= Data_16x16[4][1][11:8] ;
        Data_16x16[3][16][15:12] <= Data_16x16[4][1][15:12];
        Data_16x16[3][16][19:16] <= Data_16x16[4][1][19:16];
        Data_16x16[3][16][23:20] <= Data_16x16[4][1][23:20];
        Data_16x16[3][16][27:24] <= Data_16x16[4][1][27:24];
        Data_16x16[3][16][31:28] <= Data_16x16[4][1][31:28];
        Data_16x16[3][16][35:32] <= Data_16x16[4][1][35:32];
        Data_16x16[3][16][39:36] <= Data_16x16[4][1][39:36];
        Data_16x16[3][16][43:40] <= Data_16x16[4][1][43:40];
        Data_16x16[3][16][47:44] <= Data_16x16[4][1][47:44];
        Data_16x16[3][16][51:48] <= Data_16x16[4][1][51:48];
        Data_16x16[3][16][55:52] <= Data_16x16[4][1][55:52];
        Data_16x16[3][16][59:56] <= Data_16x16[4][1][59:56];
        Data_16x16[3][16][63:60] <= Data_16x16[4][1][63:60];
        for ( j=1 ;j<16 ;j=j+1 )
        begin
            Data_16x16[3][j][3:0]   <= Data_16x16[3][j+1][3:0]  ;
            Data_16x16[3][j][7:4]   <= Data_16x16[3][j+1][7:4]  ;
            Data_16x16[3][j][11:8]  <= Data_16x16[3][j+1][11:8] ;
            Data_16x16[3][j][15:12] <= Data_16x16[3][j+1][15:12];
            Data_16x16[3][j][19:16] <= Data_16x16[3][j+1][19:16];
            Data_16x16[3][j][23:20] <= Data_16x16[3][j+1][23:20];
            Data_16x16[3][j][27:24] <= Data_16x16[3][j+1][27:24];
            Data_16x16[3][j][31:28] <= Data_16x16[3][j+1][31:28];
            Data_16x16[3][j][35:32] <= Data_16x16[3][j+1][35:32];
            Data_16x16[3][j][39:36] <= Data_16x16[3][j+1][39:36];
            Data_16x16[3][j][43:40] <= Data_16x16[3][j+1][43:40];
            Data_16x16[3][j][47:44] <= Data_16x16[3][j+1][47:44];
            Data_16x16[3][j][51:48] <= Data_16x16[3][j+1][51:48];
            Data_16x16[3][j][55:52] <= Data_16x16[3][j+1][55:52];
            Data_16x16[3][j][59:56] <= Data_16x16[3][j+1][59:56];
            Data_16x16[3][j][63:60] <= Data_16x16[3][j+1][63:60];
        end
    end
    else if (current_state==S_IDLE)
    begin
        for ( j=1 ;j<17 ;j=j+1 )
        begin
            Data_16x16[3][j] <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) // 4th
begin
    if (!rst_n)
    begin
        for ( j=1 ; j<17 ; j=j+1 )
        begin
            Data_16x16[4][j] <= 0;
        end
    end
    else if (current_state==S_MAKEhis)
    begin
        if ((in_valid || in_valid_d1)&& Bigcnt_1>=1)
        begin
            case(cntX)
                0:
                    Data_16x16[4][cntY+1][3:0]   <= Store_1[3] + Data_16x16[4][cntY+1][3:0];
                1:
                    Data_16x16[4][cntY+1][7:4]   <= Store_1[3] + Data_16x16[4][cntY+1][7:4];
                2:
                    Data_16x16[4][cntY+1][11:8]  <= Store_1[3] + Data_16x16[4][cntY+1][11:8];
                3:
                    Data_16x16[4][cntY+1][15:12] <= Store_1[3] + Data_16x16[4][cntY+1][15:12];
                4:
                    Data_16x16[4][cntY+1][19:16] <= Store_1[3] + Data_16x16[4][cntY+1][19:16];
                5:
                    Data_16x16[4][cntY+1][23:20] <= Store_1[3] + Data_16x16[4][cntY+1][23:20];
                6:
                    Data_16x16[4][cntY+1][27:24] <= Store_1[3] + Data_16x16[4][cntY+1][27:24];
                7:
                    Data_16x16[4][cntY+1][31:28] <= Store_1[3] + Data_16x16[4][cntY+1][31:28];
                8:
                    Data_16x16[4][cntY+1][35:32] <= Store_1[3] + Data_16x16[4][cntY+1][35:32];
                9:
                    Data_16x16[4][cntY+1][39:36] <= Store_1[3] + Data_16x16[4][cntY+1][39:36];
                10:
                    Data_16x16[4][cntY+1][43:40] <= Store_1[3] + Data_16x16[4][cntY+1][43:40];
                11:
                    Data_16x16[4][cntY+1][47:44] <= Store_1[3] + Data_16x16[4][cntY+1][47:44];
                12:
                    Data_16x16[4][cntY+1][51:48] <= Store_1[3] + Data_16x16[4][cntY+1][51:48];
                13:
                    Data_16x16[4][cntY+1][55:52] <= Store_1[3] + Data_16x16[4][cntY+1][55:52];
                14:
                    Data_16x16[4][cntY+1][59:56] <= Store_1[3] + Data_16x16[4][cntY+1][59:56];
                15:
                    Data_16x16[4][cntY+1][63:60] <= Store_1[3] + Data_16x16[4][cntY+1][63:60];
            endcase
        end
    end
    else if (current_state==S_READ)
    begin
        Data_16x16[4][16][3:0]   <= Data_16x16[5][1][3:0]  ;
        Data_16x16[4][16][7:4]   <= Data_16x16[5][1][7:4]  ;
        Data_16x16[4][16][11:8]  <= Data_16x16[5][1][11:8] ;
        Data_16x16[4][16][15:12] <= Data_16x16[5][1][15:12];
        Data_16x16[4][16][19:16] <= Data_16x16[5][1][19:16];
        Data_16x16[4][16][23:20] <= Data_16x16[5][1][23:20];
        Data_16x16[4][16][27:24] <= Data_16x16[5][1][27:24];
        Data_16x16[4][16][31:28] <= Data_16x16[5][1][31:28];
        Data_16x16[4][16][35:32] <= Data_16x16[5][1][35:32];
        Data_16x16[4][16][39:36] <= Data_16x16[5][1][39:36];
        Data_16x16[4][16][43:40] <= Data_16x16[5][1][43:40];
        Data_16x16[4][16][47:44] <= Data_16x16[5][1][47:44];
        Data_16x16[4][16][51:48] <= Data_16x16[5][1][51:48];
        Data_16x16[4][16][55:52] <= Data_16x16[5][1][55:52];
        Data_16x16[4][16][59:56] <= Data_16x16[5][1][59:56];
        Data_16x16[4][16][63:60] <= Data_16x16[5][1][63:60];
        for ( j=1 ;j<16 ;j=j+1 )
        begin
            Data_16x16[4][j][3:0]   <= Data_16x16[4][j+1][3:0]  ;
            Data_16x16[4][j][7:4]   <= Data_16x16[4][j+1][7:4]  ;
            Data_16x16[4][j][11:8]  <= Data_16x16[4][j+1][11:8] ;
            Data_16x16[4][j][15:12] <= Data_16x16[4][j+1][15:12];
            Data_16x16[4][j][19:16] <= Data_16x16[4][j+1][19:16];
            Data_16x16[4][j][23:20] <= Data_16x16[4][j+1][23:20];
            Data_16x16[4][j][27:24] <= Data_16x16[4][j+1][27:24];
            Data_16x16[4][j][31:28] <= Data_16x16[4][j+1][31:28];
            Data_16x16[4][j][35:32] <= Data_16x16[4][j+1][35:32];
            Data_16x16[4][j][39:36] <= Data_16x16[4][j+1][39:36];
            Data_16x16[4][j][43:40] <= Data_16x16[4][j+1][43:40];
            Data_16x16[4][j][47:44] <= Data_16x16[4][j+1][47:44];
            Data_16x16[4][j][51:48] <= Data_16x16[4][j+1][51:48];
            Data_16x16[4][j][55:52] <= Data_16x16[4][j+1][55:52];
            Data_16x16[4][j][59:56] <= Data_16x16[4][j+1][59:56];
            Data_16x16[4][j][63:60] <= Data_16x16[4][j+1][63:60];
        end
    end
    else if (current_state==S_IDLE)
    begin
        for ( j=1 ;j<17 ;j=j+1 )
        begin
            Data_16x16[4][j] <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) // 5th
begin
    if (!rst_n)
    begin
        for ( j=1 ; j<17 ; j=j+1 )
        begin
            Data_16x16[5][j] <= 0;
        end
    end
    else if (current_state==S_MAKEhis)
    begin
        if ((in_valid || in_valid_d1)&& Bigcnt_1>=1)
        begin
            case(cntX)
                0:
                    Data_16x16[5][cntY+1][3:0]   <= Store_1[4] + Data_16x16[5][cntY+1][3:0];
                1:
                    Data_16x16[5][cntY+1][7:4]   <= Store_1[4] + Data_16x16[5][cntY+1][7:4];
                2:
                    Data_16x16[5][cntY+1][11:8]  <= Store_1[4] + Data_16x16[5][cntY+1][11:8];
                3:
                    Data_16x16[5][cntY+1][15:12] <= Store_1[4] + Data_16x16[5][cntY+1][15:12];
                4:
                    Data_16x16[5][cntY+1][19:16] <= Store_1[4] + Data_16x16[5][cntY+1][19:16];
                5:
                    Data_16x16[5][cntY+1][23:20] <= Store_1[4] + Data_16x16[5][cntY+1][23:20];
                6:
                    Data_16x16[5][cntY+1][27:24] <= Store_1[4] + Data_16x16[5][cntY+1][27:24];
                7:
                    Data_16x16[5][cntY+1][31:28] <= Store_1[4] + Data_16x16[5][cntY+1][31:28];
                8:
                    Data_16x16[5][cntY+1][35:32] <= Store_1[4] + Data_16x16[5][cntY+1][35:32];
                9:
                    Data_16x16[5][cntY+1][39:36] <= Store_1[4] + Data_16x16[5][cntY+1][39:36];
                10:
                    Data_16x16[5][cntY+1][43:40] <= Store_1[4] + Data_16x16[5][cntY+1][43:40];
                11:
                    Data_16x16[5][cntY+1][47:44] <= Store_1[4] + Data_16x16[5][cntY+1][47:44];
                12:
                    Data_16x16[5][cntY+1][51:48] <= Store_1[4] + Data_16x16[5][cntY+1][51:48];
                13:
                    Data_16x16[5][cntY+1][55:52] <= Store_1[4] + Data_16x16[5][cntY+1][55:52];
                14:
                    Data_16x16[5][cntY+1][59:56] <= Store_1[4] + Data_16x16[5][cntY+1][59:56];
                15:
                    Data_16x16[5][cntY+1][63:60] <= Store_1[4] + Data_16x16[5][cntY+1][63:60];
            endcase
        end
    end
    else if (current_state==S_READ)
    begin
        Data_16x16[5][16][3:0]   <= Data_16x16[6][1][3:0]  ;
        Data_16x16[5][16][7:4]   <= Data_16x16[6][1][7:4]  ;
        Data_16x16[5][16][11:8]  <= Data_16x16[6][1][11:8] ;
        Data_16x16[5][16][15:12] <= Data_16x16[6][1][15:12];
        Data_16x16[5][16][19:16] <= Data_16x16[6][1][19:16];
        Data_16x16[5][16][23:20] <= Data_16x16[6][1][23:20];
        Data_16x16[5][16][27:24] <= Data_16x16[6][1][27:24];
        Data_16x16[5][16][31:28] <= Data_16x16[6][1][31:28];
        Data_16x16[5][16][35:32] <= Data_16x16[6][1][35:32];
        Data_16x16[5][16][39:36] <= Data_16x16[6][1][39:36];
        Data_16x16[5][16][43:40] <= Data_16x16[6][1][43:40];
        Data_16x16[5][16][47:44] <= Data_16x16[6][1][47:44];
        Data_16x16[5][16][51:48] <= Data_16x16[6][1][51:48];
        Data_16x16[5][16][55:52] <= Data_16x16[6][1][55:52];
        Data_16x16[5][16][59:56] <= Data_16x16[6][1][59:56];
        Data_16x16[5][16][63:60] <= Data_16x16[6][1][63:60];
        for ( j=1 ;j<16 ;j=j+1 )
        begin
            Data_16x16[5][j][3:0]   <= Data_16x16[5][j+1][3:0]  ;
            Data_16x16[5][j][7:4]   <= Data_16x16[5][j+1][7:4]  ;
            Data_16x16[5][j][11:8]  <= Data_16x16[5][j+1][11:8] ;
            Data_16x16[5][j][15:12] <= Data_16x16[5][j+1][15:12];
            Data_16x16[5][j][19:16] <= Data_16x16[5][j+1][19:16];
            Data_16x16[5][j][23:20] <= Data_16x16[5][j+1][23:20];
            Data_16x16[5][j][27:24] <= Data_16x16[5][j+1][27:24];
            Data_16x16[5][j][31:28] <= Data_16x16[5][j+1][31:28];
            Data_16x16[5][j][35:32] <= Data_16x16[5][j+1][35:32];
            Data_16x16[5][j][39:36] <= Data_16x16[5][j+1][39:36];
            Data_16x16[5][j][43:40] <= Data_16x16[5][j+1][43:40];
            Data_16x16[5][j][47:44] <= Data_16x16[5][j+1][47:44];
            Data_16x16[5][j][51:48] <= Data_16x16[5][j+1][51:48];
            Data_16x16[5][j][55:52] <= Data_16x16[5][j+1][55:52];
            Data_16x16[5][j][59:56] <= Data_16x16[5][j+1][59:56];
            Data_16x16[5][j][63:60] <= Data_16x16[5][j+1][63:60];
        end
    end
    else if (current_state==S_IDLE)
    begin
        for ( j=1 ;j<17 ;j=j+1 )
        begin
            Data_16x16[5][j] <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) // 6th
begin
    if (!rst_n)
    begin
        for ( j=1 ; j<17 ; j=j+1 )
        begin
            Data_16x16[6][j] <= 0;
        end
    end
    else if (current_state==S_MAKEhis)
    begin
        if ((in_valid || in_valid_d1)&& Bigcnt_1>=1)
        begin
            case(cntX)
                0:
                    Data_16x16[6][cntY+1][3:0]   <= Store_1[5] + Data_16x16[6][cntY+1][3:0];
                1:
                    Data_16x16[6][cntY+1][7:4]   <= Store_1[5] + Data_16x16[6][cntY+1][7:4];
                2:
                    Data_16x16[6][cntY+1][11:8]  <= Store_1[5] + Data_16x16[6][cntY+1][11:8];
                3:
                    Data_16x16[6][cntY+1][15:12] <= Store_1[5] + Data_16x16[6][cntY+1][15:12];
                4:
                    Data_16x16[6][cntY+1][19:16] <= Store_1[5] + Data_16x16[6][cntY+1][19:16];
                5:
                    Data_16x16[6][cntY+1][23:20] <= Store_1[5] + Data_16x16[6][cntY+1][23:20];
                6:
                    Data_16x16[6][cntY+1][27:24] <= Store_1[5] + Data_16x16[6][cntY+1][27:24];
                7:
                    Data_16x16[6][cntY+1][31:28] <= Store_1[5] + Data_16x16[6][cntY+1][31:28];
                8:
                    Data_16x16[6][cntY+1][35:32] <= Store_1[5] + Data_16x16[6][cntY+1][35:32];
                9:
                    Data_16x16[6][cntY+1][39:36] <= Store_1[5] + Data_16x16[6][cntY+1][39:36];
                10:
                    Data_16x16[6][cntY+1][43:40] <= Store_1[5] + Data_16x16[6][cntY+1][43:40];
                11:
                    Data_16x16[6][cntY+1][47:44] <= Store_1[5] + Data_16x16[6][cntY+1][47:44];
                12:
                    Data_16x16[6][cntY+1][51:48] <= Store_1[5] + Data_16x16[6][cntY+1][51:48];
                13:
                    Data_16x16[6][cntY+1][55:52] <= Store_1[5] + Data_16x16[6][cntY+1][55:52];
                14:
                    Data_16x16[6][cntY+1][59:56] <= Store_1[5] + Data_16x16[6][cntY+1][59:56];
                15:
                    Data_16x16[6][cntY+1][63:60] <= Store_1[5] + Data_16x16[6][cntY+1][63:60];
            endcase
        end
    end
    else if (current_state==S_READ)
    begin
        Data_16x16[6][16][3:0]   <= Data_16x16[7][1][3:0]  ;
        Data_16x16[6][16][7:4]   <= Data_16x16[7][1][7:4]  ;
        Data_16x16[6][16][11:8]  <= Data_16x16[7][1][11:8] ;
        Data_16x16[6][16][15:12] <= Data_16x16[7][1][15:12];
        Data_16x16[6][16][19:16] <= Data_16x16[7][1][19:16];
        Data_16x16[6][16][23:20] <= Data_16x16[7][1][23:20];
        Data_16x16[6][16][27:24] <= Data_16x16[7][1][27:24];
        Data_16x16[6][16][31:28] <= Data_16x16[7][1][31:28];
        Data_16x16[6][16][35:32] <= Data_16x16[7][1][35:32];
        Data_16x16[6][16][39:36] <= Data_16x16[7][1][39:36];
        Data_16x16[6][16][43:40] <= Data_16x16[7][1][43:40];
        Data_16x16[6][16][47:44] <= Data_16x16[7][1][47:44];
        Data_16x16[6][16][51:48] <= Data_16x16[7][1][51:48];
        Data_16x16[6][16][55:52] <= Data_16x16[7][1][55:52];
        Data_16x16[6][16][59:56] <= Data_16x16[7][1][59:56];
        Data_16x16[6][16][63:60] <= Data_16x16[7][1][63:60];
        for ( j=1 ;j<16 ;j=j+1 )
        begin
            Data_16x16[6][j][3:0]   <= Data_16x16[6][j+1][3:0]  ;
            Data_16x16[6][j][7:4]   <= Data_16x16[6][j+1][7:4]  ;
            Data_16x16[6][j][11:8]  <= Data_16x16[6][j+1][11:8] ;
            Data_16x16[6][j][15:12] <= Data_16x16[6][j+1][15:12];
            Data_16x16[6][j][19:16] <= Data_16x16[6][j+1][19:16];
            Data_16x16[6][j][23:20] <= Data_16x16[6][j+1][23:20];
            Data_16x16[6][j][27:24] <= Data_16x16[6][j+1][27:24];
            Data_16x16[6][j][31:28] <= Data_16x16[6][j+1][31:28];
            Data_16x16[6][j][35:32] <= Data_16x16[6][j+1][35:32];
            Data_16x16[6][j][39:36] <= Data_16x16[6][j+1][39:36];
            Data_16x16[6][j][43:40] <= Data_16x16[6][j+1][43:40];
            Data_16x16[6][j][47:44] <= Data_16x16[6][j+1][47:44];
            Data_16x16[6][j][51:48] <= Data_16x16[6][j+1][51:48];
            Data_16x16[6][j][55:52] <= Data_16x16[6][j+1][55:52];
            Data_16x16[6][j][59:56] <= Data_16x16[6][j+1][59:56];
            Data_16x16[6][j][63:60] <= Data_16x16[6][j+1][63:60];
        end
    end
    else if (current_state==S_IDLE)
    begin
        for ( j=1 ;j<17 ;j=j+1 )
        begin
            Data_16x16[6][j] <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) // 7th
begin
    if (!rst_n)
    begin
        for ( j=1 ; j<17 ; j=j+1 )
        begin
            Data_16x16[7][j] <= 0;
        end
    end
    else if (current_state==S_MAKEhis)
    begin
        if ((in_valid || in_valid_d1)&& Bigcnt_1>=1)
        begin
            case(cntX)
                0:
                    Data_16x16[7][cntY+1][3:0]   <= Store_1[6] + Data_16x16[7][cntY+1][3:0];
                1:
                    Data_16x16[7][cntY+1][7:4]   <= Store_1[6] + Data_16x16[7][cntY+1][7:4];
                2:
                    Data_16x16[7][cntY+1][11:8]  <= Store_1[6] + Data_16x16[7][cntY+1][11:8];
                3:
                    Data_16x16[7][cntY+1][15:12] <= Store_1[6] + Data_16x16[7][cntY+1][15:12];
                4:
                    Data_16x16[7][cntY+1][19:16] <= Store_1[6] + Data_16x16[7][cntY+1][19:16];
                5:
                    Data_16x16[7][cntY+1][23:20] <= Store_1[6] + Data_16x16[7][cntY+1][23:20];
                6:
                    Data_16x16[7][cntY+1][27:24] <= Store_1[6] + Data_16x16[7][cntY+1][27:24];
                7:
                    Data_16x16[7][cntY+1][31:28] <= Store_1[6] + Data_16x16[7][cntY+1][31:28];
                8:
                    Data_16x16[7][cntY+1][35:32] <= Store_1[6] + Data_16x16[7][cntY+1][35:32];
                9:
                    Data_16x16[7][cntY+1][39:36] <= Store_1[6] + Data_16x16[7][cntY+1][39:36];
                10:
                    Data_16x16[7][cntY+1][43:40] <= Store_1[6] + Data_16x16[7][cntY+1][43:40];
                11:
                    Data_16x16[7][cntY+1][47:44] <= Store_1[6] + Data_16x16[7][cntY+1][47:44];
                12:
                    Data_16x16[7][cntY+1][51:48] <= Store_1[6] + Data_16x16[7][cntY+1][51:48];
                13:
                    Data_16x16[7][cntY+1][55:52] <= Store_1[6] + Data_16x16[7][cntY+1][55:52];
                14:
                    Data_16x16[7][cntY+1][59:56] <= Store_1[6] + Data_16x16[7][cntY+1][59:56];
                15:
                    Data_16x16[7][cntY+1][63:60] <= Store_1[6] + Data_16x16[7][cntY+1][63:60];
            endcase
        end
    end
    else if (current_state==S_READ)
    begin
        Data_16x16[7][16][3:0]   <= Data_16x16[8][1][3:0]  ;
        Data_16x16[7][16][7:4]   <= Data_16x16[8][1][7:4]  ;
        Data_16x16[7][16][11:8]  <= Data_16x16[8][1][11:8] ;
        Data_16x16[7][16][15:12] <= Data_16x16[8][1][15:12];
        Data_16x16[7][16][19:16] <= Data_16x16[8][1][19:16];
        Data_16x16[7][16][23:20] <= Data_16x16[8][1][23:20];
        Data_16x16[7][16][27:24] <= Data_16x16[8][1][27:24];
        Data_16x16[7][16][31:28] <= Data_16x16[8][1][31:28];
        Data_16x16[7][16][35:32] <= Data_16x16[8][1][35:32];
        Data_16x16[7][16][39:36] <= Data_16x16[8][1][39:36];
        Data_16x16[7][16][43:40] <= Data_16x16[8][1][43:40];
        Data_16x16[7][16][47:44] <= Data_16x16[8][1][47:44];
        Data_16x16[7][16][51:48] <= Data_16x16[8][1][51:48];
        Data_16x16[7][16][55:52] <= Data_16x16[8][1][55:52];
        Data_16x16[7][16][59:56] <= Data_16x16[8][1][59:56];
        Data_16x16[7][16][63:60] <= Data_16x16[8][1][63:60];
        for ( j=1 ;j<16 ;j=j+1 )
        begin
            Data_16x16[7][j][3:0]   <= Data_16x16[7][j+1][3:0]  ;
            Data_16x16[7][j][7:4]   <= Data_16x16[7][j+1][7:4]  ;
            Data_16x16[7][j][11:8]  <= Data_16x16[7][j+1][11:8] ;
            Data_16x16[7][j][15:12] <= Data_16x16[7][j+1][15:12];
            Data_16x16[7][j][19:16] <= Data_16x16[7][j+1][19:16];
            Data_16x16[7][j][23:20] <= Data_16x16[7][j+1][23:20];
            Data_16x16[7][j][27:24] <= Data_16x16[7][j+1][27:24];
            Data_16x16[7][j][31:28] <= Data_16x16[7][j+1][31:28];
            Data_16x16[7][j][35:32] <= Data_16x16[7][j+1][35:32];
            Data_16x16[7][j][39:36] <= Data_16x16[7][j+1][39:36];
            Data_16x16[7][j][43:40] <= Data_16x16[7][j+1][43:40];
            Data_16x16[7][j][47:44] <= Data_16x16[7][j+1][47:44];
            Data_16x16[7][j][51:48] <= Data_16x16[7][j+1][51:48];
            Data_16x16[7][j][55:52] <= Data_16x16[7][j+1][55:52];
            Data_16x16[7][j][59:56] <= Data_16x16[7][j+1][59:56];
            Data_16x16[7][j][63:60] <= Data_16x16[7][j+1][63:60];
        end
    end
    else if (current_state==S_IDLE)
    begin
        for ( j=1 ;j<17 ;j=j+1 )
        begin
            Data_16x16[7][j] <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) // 8th
begin
    if (!rst_n)
    begin
        for ( j=1 ; j<17 ; j=j+1 )
        begin
            Data_16x16[8][j] <= 0;
        end
    end
    else if (current_state==S_MAKEhis)
    begin
        if ((in_valid || in_valid_d1)&& Bigcnt_1>=1)
        begin
            case(cntX)
                0:
                    Data_16x16[8][cntY+1][3:0]   <= Store_1[7] + Data_16x16[8][cntY+1][3:0];
                1:
                    Data_16x16[8][cntY+1][7:4]   <= Store_1[7] + Data_16x16[8][cntY+1][7:4];
                2:
                    Data_16x16[8][cntY+1][11:8]  <= Store_1[7] + Data_16x16[8][cntY+1][11:8];
                3:
                    Data_16x16[8][cntY+1][15:12] <= Store_1[7] + Data_16x16[8][cntY+1][15:12];
                4:
                    Data_16x16[8][cntY+1][19:16] <= Store_1[7] + Data_16x16[8][cntY+1][19:16];
                5:
                    Data_16x16[8][cntY+1][23:20] <= Store_1[7] + Data_16x16[8][cntY+1][23:20];
                6:
                    Data_16x16[8][cntY+1][27:24] <= Store_1[7] + Data_16x16[8][cntY+1][27:24];
                7:
                    Data_16x16[8][cntY+1][31:28] <= Store_1[7] + Data_16x16[8][cntY+1][31:28];
                8:
                    Data_16x16[8][cntY+1][35:32] <= Store_1[7] + Data_16x16[8][cntY+1][35:32];
                9:
                    Data_16x16[8][cntY+1][39:36] <= Store_1[7] + Data_16x16[8][cntY+1][39:36];
                10:
                    Data_16x16[8][cntY+1][43:40] <= Store_1[7] + Data_16x16[8][cntY+1][43:40];
                11:
                    Data_16x16[8][cntY+1][47:44] <= Store_1[7] + Data_16x16[8][cntY+1][47:44];
                12:
                    Data_16x16[8][cntY+1][51:48] <= Store_1[7] + Data_16x16[8][cntY+1][51:48];
                13:
                    Data_16x16[8][cntY+1][55:52] <= Store_1[7] + Data_16x16[8][cntY+1][55:52];
                14:
                    Data_16x16[8][cntY+1][59:56] <= Store_1[7] + Data_16x16[8][cntY+1][59:56];
                15:
                    Data_16x16[8][cntY+1][63:60] <= Store_1[7] + Data_16x16[8][cntY+1][63:60];
            endcase
        end
    end
    else if (current_state==S_READ)
    begin
        Data_16x16[8][16][3:0]   <= Data_16x16[9][1][3:0]  ;
        Data_16x16[8][16][7:4]   <= Data_16x16[9][1][7:4]  ;
        Data_16x16[8][16][11:8]  <= Data_16x16[9][1][11:8] ;
        Data_16x16[8][16][15:12] <= Data_16x16[9][1][15:12];
        Data_16x16[8][16][19:16] <= Data_16x16[9][1][19:16];
        Data_16x16[8][16][23:20] <= Data_16x16[9][1][23:20];
        Data_16x16[8][16][27:24] <= Data_16x16[9][1][27:24];
        Data_16x16[8][16][31:28] <= Data_16x16[9][1][31:28];
        Data_16x16[8][16][35:32] <= Data_16x16[9][1][35:32];
        Data_16x16[8][16][39:36] <= Data_16x16[9][1][39:36];
        Data_16x16[8][16][43:40] <= Data_16x16[9][1][43:40];
        Data_16x16[8][16][47:44] <= Data_16x16[9][1][47:44];
        Data_16x16[8][16][51:48] <= Data_16x16[9][1][51:48];
        Data_16x16[8][16][55:52] <= Data_16x16[9][1][55:52];
        Data_16x16[8][16][59:56] <= Data_16x16[9][1][59:56];
        Data_16x16[8][16][63:60] <= Data_16x16[9][1][63:60];
        for ( j=1 ;j<16 ;j=j+1 )
        begin
            Data_16x16[8][j][3:0]   <= Data_16x16[8][j+1][3:0]  ;
            Data_16x16[8][j][7:4]   <= Data_16x16[8][j+1][7:4]  ;
            Data_16x16[8][j][11:8]  <= Data_16x16[8][j+1][11:8] ;
            Data_16x16[8][j][15:12] <= Data_16x16[8][j+1][15:12];
            Data_16x16[8][j][19:16] <= Data_16x16[8][j+1][19:16];
            Data_16x16[8][j][23:20] <= Data_16x16[8][j+1][23:20];
            Data_16x16[8][j][27:24] <= Data_16x16[8][j+1][27:24];
            Data_16x16[8][j][31:28] <= Data_16x16[8][j+1][31:28];
            Data_16x16[8][j][35:32] <= Data_16x16[8][j+1][35:32];
            Data_16x16[8][j][39:36] <= Data_16x16[8][j+1][39:36];
            Data_16x16[8][j][43:40] <= Data_16x16[8][j+1][43:40];
            Data_16x16[8][j][47:44] <= Data_16x16[8][j+1][47:44];
            Data_16x16[8][j][51:48] <= Data_16x16[8][j+1][51:48];
            Data_16x16[8][j][55:52] <= Data_16x16[8][j+1][55:52];
            Data_16x16[8][j][59:56] <= Data_16x16[8][j+1][59:56];
            Data_16x16[8][j][63:60] <= Data_16x16[8][j+1][63:60];
        end
    end
    else if (current_state==S_IDLE)
    begin
        for ( j=1 ;j<17 ;j=j+1 )
        begin
            Data_16x16[8][j] <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) // 9th
begin
    if (!rst_n)
    begin
        for ( j=1 ; j<17 ; j=j+1 )
        begin
            Data_16x16[9][j] <= 0;
        end
    end
    else if (current_state==S_MAKEhis)
    begin
        if ((in_valid || in_valid_d1)&& Bigcnt_1>=1)
        begin
            case(cntX)
                0:
                    Data_16x16[9][cntY+1][3:0]   <= Store_1[8] + Data_16x16[9][cntY+1][3:0];
                1:
                    Data_16x16[9][cntY+1][7:4]   <= Store_1[8] + Data_16x16[9][cntY+1][7:4];
                2:
                    Data_16x16[9][cntY+1][11:8]  <= Store_1[8] + Data_16x16[9][cntY+1][11:8];
                3:
                    Data_16x16[9][cntY+1][15:12] <= Store_1[8] + Data_16x16[9][cntY+1][15:12];
                4:
                    Data_16x16[9][cntY+1][19:16] <= Store_1[8] + Data_16x16[9][cntY+1][19:16];
                5:
                    Data_16x16[9][cntY+1][23:20] <= Store_1[8] + Data_16x16[9][cntY+1][23:20];
                6:
                    Data_16x16[9][cntY+1][27:24] <= Store_1[8] + Data_16x16[9][cntY+1][27:24];
                7:
                    Data_16x16[9][cntY+1][31:28] <= Store_1[8] + Data_16x16[9][cntY+1][31:28];
                8:
                    Data_16x16[9][cntY+1][35:32] <= Store_1[8] + Data_16x16[9][cntY+1][35:32];
                9:
                    Data_16x16[9][cntY+1][39:36] <= Store_1[8] + Data_16x16[9][cntY+1][39:36];
                10:
                    Data_16x16[9][cntY+1][43:40] <= Store_1[8] + Data_16x16[9][cntY+1][43:40];
                11:
                    Data_16x16[9][cntY+1][47:44] <= Store_1[8] + Data_16x16[9][cntY+1][47:44];
                12:
                    Data_16x16[9][cntY+1][51:48] <= Store_1[8] + Data_16x16[9][cntY+1][51:48];
                13:
                    Data_16x16[9][cntY+1][55:52] <= Store_1[8] + Data_16x16[9][cntY+1][55:52];
                14:
                    Data_16x16[9][cntY+1][59:56] <= Store_1[8] + Data_16x16[9][cntY+1][59:56];
                15:
                    Data_16x16[9][cntY+1][63:60] <= Store_1[8] + Data_16x16[9][cntY+1][63:60];
            endcase
        end
    end
    else if (current_state==S_READ)
    begin
        Data_16x16[9][16][3:0]   <= Data_16x16[10][1][3:0]  ;
        Data_16x16[9][16][7:4]   <= Data_16x16[10][1][7:4]  ;
        Data_16x16[9][16][11:8]  <= Data_16x16[10][1][11:8] ;
        Data_16x16[9][16][15:12] <= Data_16x16[10][1][15:12];
        Data_16x16[9][16][19:16] <= Data_16x16[10][1][19:16];
        Data_16x16[9][16][23:20] <= Data_16x16[10][1][23:20];
        Data_16x16[9][16][27:24] <= Data_16x16[10][1][27:24];
        Data_16x16[9][16][31:28] <= Data_16x16[10][1][31:28];
        Data_16x16[9][16][35:32] <= Data_16x16[10][1][35:32];
        Data_16x16[9][16][39:36] <= Data_16x16[10][1][39:36];
        Data_16x16[9][16][43:40] <= Data_16x16[10][1][43:40];
        Data_16x16[9][16][47:44] <= Data_16x16[10][1][47:44];
        Data_16x16[9][16][51:48] <= Data_16x16[10][1][51:48];
        Data_16x16[9][16][55:52] <= Data_16x16[10][1][55:52];
        Data_16x16[9][16][59:56] <= Data_16x16[10][1][59:56];
        Data_16x16[9][16][63:60] <= Data_16x16[10][1][63:60];
        for ( j=1 ;j<16 ;j=j+1 )
        begin
            Data_16x16[9][j][3:0]   <= Data_16x16[9][j+1][3:0]  ;
            Data_16x16[9][j][7:4]   <= Data_16x16[9][j+1][7:4]  ;
            Data_16x16[9][j][11:8]  <= Data_16x16[9][j+1][11:8] ;
            Data_16x16[9][j][15:12] <= Data_16x16[9][j+1][15:12];
            Data_16x16[9][j][19:16] <= Data_16x16[9][j+1][19:16];
            Data_16x16[9][j][23:20] <= Data_16x16[9][j+1][23:20];
            Data_16x16[9][j][27:24] <= Data_16x16[9][j+1][27:24];
            Data_16x16[9][j][31:28] <= Data_16x16[9][j+1][31:28];
            Data_16x16[9][j][35:32] <= Data_16x16[9][j+1][35:32];
            Data_16x16[9][j][39:36] <= Data_16x16[9][j+1][39:36];
            Data_16x16[9][j][43:40] <= Data_16x16[9][j+1][43:40];
            Data_16x16[9][j][47:44] <= Data_16x16[9][j+1][47:44];
            Data_16x16[9][j][51:48] <= Data_16x16[9][j+1][51:48];
            Data_16x16[9][j][55:52] <= Data_16x16[9][j+1][55:52];
            Data_16x16[9][j][59:56] <= Data_16x16[9][j+1][59:56];
            Data_16x16[9][j][63:60] <= Data_16x16[9][j+1][63:60];
        end
    end
    else if (current_state==S_IDLE)
    begin
        for ( j=1 ;j<17 ;j=j+1 )
        begin
            Data_16x16[9][j] <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) // 10th
begin
    if (!rst_n)
    begin
        for ( j=1 ; j<17 ; j=j+1 )
        begin
            Data_16x16[10][j] <= 0;
        end
    end
    else if (current_state==S_MAKEhis)
    begin
        if ((in_valid || in_valid_d1)&& Bigcnt_1>=1)
        begin
            case(cntX)
                0:
                    Data_16x16[10][cntY+1][3:0]   <= Store_1[9] + Data_16x16[10][cntY+1][3:0];
                1:
                    Data_16x16[10][cntY+1][7:4]   <= Store_1[9] + Data_16x16[10][cntY+1][7:4];
                2:
                    Data_16x16[10][cntY+1][11:8]  <= Store_1[9] + Data_16x16[10][cntY+1][11:8];
                3:
                    Data_16x16[10][cntY+1][15:12] <= Store_1[9] + Data_16x16[10][cntY+1][15:12];
                4:
                    Data_16x16[10][cntY+1][19:16] <= Store_1[9] + Data_16x16[10][cntY+1][19:16];
                5:
                    Data_16x16[10][cntY+1][23:20] <= Store_1[9] + Data_16x16[10][cntY+1][23:20];
                6:
                    Data_16x16[10][cntY+1][27:24] <= Store_1[9] + Data_16x16[10][cntY+1][27:24];
                7:
                    Data_16x16[10][cntY+1][31:28] <= Store_1[9] + Data_16x16[10][cntY+1][31:28];
                8:
                    Data_16x16[10][cntY+1][35:32] <= Store_1[9] + Data_16x16[10][cntY+1][35:32];
                9:
                    Data_16x16[10][cntY+1][39:36] <= Store_1[9] + Data_16x16[10][cntY+1][39:36];
                10:
                    Data_16x16[10][cntY+1][43:40] <= Store_1[9] + Data_16x16[10][cntY+1][43:40];
                11:
                    Data_16x16[10][cntY+1][47:44] <= Store_1[9] + Data_16x16[10][cntY+1][47:44];
                12:
                    Data_16x16[10][cntY+1][51:48] <= Store_1[9] + Data_16x16[10][cntY+1][51:48];
                13:
                    Data_16x16[10][cntY+1][55:52] <= Store_1[9] + Data_16x16[10][cntY+1][55:52];
                14:
                    Data_16x16[10][cntY+1][59:56] <= Store_1[9] + Data_16x16[10][cntY+1][59:56];
                15:
                    Data_16x16[10][cntY+1][63:60] <= Store_1[9] + Data_16x16[10][cntY+1][63:60];
            endcase
        end
    end
    else if (current_state==S_READ)
    begin
        Data_16x16[10][16][3:0]   <= Data_16x16[11][1][3:0]  ;
        Data_16x16[10][16][7:4]   <= Data_16x16[11][1][7:4]  ;
        Data_16x16[10][16][11:8]  <= Data_16x16[11][1][11:8] ;
        Data_16x16[10][16][15:12] <= Data_16x16[11][1][15:12];
        Data_16x16[10][16][19:16] <= Data_16x16[11][1][19:16];
        Data_16x16[10][16][23:20] <= Data_16x16[11][1][23:20];
        Data_16x16[10][16][27:24] <= Data_16x16[11][1][27:24];
        Data_16x16[10][16][31:28] <= Data_16x16[11][1][31:28];
        Data_16x16[10][16][35:32] <= Data_16x16[11][1][35:32];
        Data_16x16[10][16][39:36] <= Data_16x16[11][1][39:36];
        Data_16x16[10][16][43:40] <= Data_16x16[11][1][43:40];
        Data_16x16[10][16][47:44] <= Data_16x16[11][1][47:44];
        Data_16x16[10][16][51:48] <= Data_16x16[11][1][51:48];
        Data_16x16[10][16][55:52] <= Data_16x16[11][1][55:52];
        Data_16x16[10][16][59:56] <= Data_16x16[11][1][59:56];
        Data_16x16[10][16][63:60] <= Data_16x16[11][1][63:60];
        for ( j=1 ;j<16 ;j=j+1 )
        begin
            Data_16x16[10][j][3:0]   <= Data_16x16[10][j+1][3:0]  ;
            Data_16x16[10][j][7:4]   <= Data_16x16[10][j+1][7:4]  ;
            Data_16x16[10][j][11:8]  <= Data_16x16[10][j+1][11:8] ;
            Data_16x16[10][j][15:12] <= Data_16x16[10][j+1][15:12];
            Data_16x16[10][j][19:16] <= Data_16x16[10][j+1][19:16];
            Data_16x16[10][j][23:20] <= Data_16x16[10][j+1][23:20];
            Data_16x16[10][j][27:24] <= Data_16x16[10][j+1][27:24];
            Data_16x16[10][j][31:28] <= Data_16x16[10][j+1][31:28];
            Data_16x16[10][j][35:32] <= Data_16x16[10][j+1][35:32];
            Data_16x16[10][j][39:36] <= Data_16x16[10][j+1][39:36];
            Data_16x16[10][j][43:40] <= Data_16x16[10][j+1][43:40];
            Data_16x16[10][j][47:44] <= Data_16x16[10][j+1][47:44];
            Data_16x16[10][j][51:48] <= Data_16x16[10][j+1][51:48];
            Data_16x16[10][j][55:52] <= Data_16x16[10][j+1][55:52];
            Data_16x16[10][j][59:56] <= Data_16x16[10][j+1][59:56];
            Data_16x16[10][j][63:60] <= Data_16x16[10][j+1][63:60];
        end
    end
    else if (current_state==S_IDLE)
    begin
        for ( j=1 ;j<17 ;j=j+1 )
        begin
            Data_16x16[10][j] <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) // 11th
begin
    if (!rst_n)
    begin
        for ( j=1 ; j<17 ; j=j+1 )
        begin
            Data_16x16[11][j] <= 0;
        end
    end
    else if (current_state==S_MAKEhis)
    begin
        if ((in_valid || in_valid_d1)&& Bigcnt_1>=1)
        begin
            case(cntX)
                0:
                    Data_16x16[11][cntY+1][3:0]   <= Store_1[10] + Data_16x16[11][cntY+1][3:0];
                1:
                    Data_16x16[11][cntY+1][7:4]   <= Store_1[10] + Data_16x16[11][cntY+1][7:4];
                2:
                    Data_16x16[11][cntY+1][11:8]  <= Store_1[10] + Data_16x16[11][cntY+1][11:8];
                3:
                    Data_16x16[11][cntY+1][15:12] <= Store_1[10] + Data_16x16[11][cntY+1][15:12];
                4:
                    Data_16x16[11][cntY+1][19:16] <= Store_1[10] + Data_16x16[11][cntY+1][19:16];
                5:
                    Data_16x16[11][cntY+1][23:20] <= Store_1[10] + Data_16x16[11][cntY+1][23:20];
                6:
                    Data_16x16[11][cntY+1][27:24] <= Store_1[10] + Data_16x16[11][cntY+1][27:24];
                7:
                    Data_16x16[11][cntY+1][31:28] <= Store_1[10] + Data_16x16[11][cntY+1][31:28];
                8:
                    Data_16x16[11][cntY+1][35:32] <= Store_1[10] + Data_16x16[11][cntY+1][35:32];
                9:
                    Data_16x16[11][cntY+1][39:36] <= Store_1[10] + Data_16x16[11][cntY+1][39:36];
                10:
                    Data_16x16[11][cntY+1][43:40] <= Store_1[10] + Data_16x16[11][cntY+1][43:40];
                11:
                    Data_16x16[11][cntY+1][47:44] <= Store_1[10] + Data_16x16[11][cntY+1][47:44];
                12:
                    Data_16x16[11][cntY+1][51:48] <= Store_1[10] + Data_16x16[11][cntY+1][51:48];
                13:
                    Data_16x16[11][cntY+1][55:52] <= Store_1[10] + Data_16x16[11][cntY+1][55:52];
                14:
                    Data_16x16[11][cntY+1][59:56] <= Store_1[10] + Data_16x16[11][cntY+1][59:56];
                15:
                    Data_16x16[11][cntY+1][63:60] <= Store_1[10] + Data_16x16[11][cntY+1][63:60];
            endcase
        end
    end
    else if (current_state==S_READ)
    begin
        Data_16x16[11][16][3:0]   <= Data_16x16[12][1][3:0]  ;
        Data_16x16[11][16][7:4]   <= Data_16x16[12][1][7:4]  ;
        Data_16x16[11][16][11:8]  <= Data_16x16[12][1][11:8] ;
        Data_16x16[11][16][15:12] <= Data_16x16[12][1][15:12];
        Data_16x16[11][16][19:16] <= Data_16x16[12][1][19:16];
        Data_16x16[11][16][23:20] <= Data_16x16[12][1][23:20];
        Data_16x16[11][16][27:24] <= Data_16x16[12][1][27:24];
        Data_16x16[11][16][31:28] <= Data_16x16[12][1][31:28];
        Data_16x16[11][16][35:32] <= Data_16x16[12][1][35:32];
        Data_16x16[11][16][39:36] <= Data_16x16[12][1][39:36];
        Data_16x16[11][16][43:40] <= Data_16x16[12][1][43:40];
        Data_16x16[11][16][47:44] <= Data_16x16[12][1][47:44];
        Data_16x16[11][16][51:48] <= Data_16x16[12][1][51:48];
        Data_16x16[11][16][55:52] <= Data_16x16[12][1][55:52];
        Data_16x16[11][16][59:56] <= Data_16x16[12][1][59:56];
        Data_16x16[11][16][63:60] <= Data_16x16[12][1][63:60];
        for ( j=1 ;j<16 ;j=j+1 )
        begin
            Data_16x16[11][j][3:0]   <= Data_16x16[11][j+1][3:0]  ;
            Data_16x16[11][j][7:4]   <= Data_16x16[11][j+1][7:4]  ;
            Data_16x16[11][j][11:8]  <= Data_16x16[11][j+1][11:8] ;
            Data_16x16[11][j][15:12] <= Data_16x16[11][j+1][15:12];
            Data_16x16[11][j][19:16] <= Data_16x16[11][j+1][19:16];
            Data_16x16[11][j][23:20] <= Data_16x16[11][j+1][23:20];
            Data_16x16[11][j][27:24] <= Data_16x16[11][j+1][27:24];
            Data_16x16[11][j][31:28] <= Data_16x16[11][j+1][31:28];
            Data_16x16[11][j][35:32] <= Data_16x16[11][j+1][35:32];
            Data_16x16[11][j][39:36] <= Data_16x16[11][j+1][39:36];
            Data_16x16[11][j][43:40] <= Data_16x16[11][j+1][43:40];
            Data_16x16[11][j][47:44] <= Data_16x16[11][j+1][47:44];
            Data_16x16[11][j][51:48] <= Data_16x16[11][j+1][51:48];
            Data_16x16[11][j][55:52] <= Data_16x16[11][j+1][55:52];
            Data_16x16[11][j][59:56] <= Data_16x16[11][j+1][59:56];
            Data_16x16[11][j][63:60] <= Data_16x16[11][j+1][63:60];
        end
    end
    else if (current_state==S_IDLE)
    begin
        for ( j=1 ;j<17 ;j=j+1 )
        begin
            Data_16x16[11][j] <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) // 12th
begin
    if (!rst_n)
    begin
        for ( j=1 ; j<17 ; j=j+1 )
        begin
            Data_16x16[12][j] <= 0;
        end
    end
    else if (current_state==S_MAKEhis)
    begin
        if ((in_valid || in_valid_d1)&& Bigcnt_1>=1)
        begin
            case(cntX)
                0:
                    Data_16x16[12][cntY+1][3:0]   <= Store_1[11] + Data_16x16[12][cntY+1][3:0];
                1:
                    Data_16x16[12][cntY+1][7:4]   <= Store_1[11] + Data_16x16[12][cntY+1][7:4];
                2:
                    Data_16x16[12][cntY+1][11:8]  <= Store_1[11] + Data_16x16[12][cntY+1][11:8];
                3:
                    Data_16x16[12][cntY+1][15:12] <= Store_1[11] + Data_16x16[12][cntY+1][15:12];
                4:
                    Data_16x16[12][cntY+1][19:16] <= Store_1[11] + Data_16x16[12][cntY+1][19:16];
                5:
                    Data_16x16[12][cntY+1][23:20] <= Store_1[11] + Data_16x16[12][cntY+1][23:20];
                6:
                    Data_16x16[12][cntY+1][27:24] <= Store_1[11] + Data_16x16[12][cntY+1][27:24];
                7:
                    Data_16x16[12][cntY+1][31:28] <= Store_1[11] + Data_16x16[12][cntY+1][31:28];
                8:
                    Data_16x16[12][cntY+1][35:32] <= Store_1[11] + Data_16x16[12][cntY+1][35:32];
                9:
                    Data_16x16[12][cntY+1][39:36] <= Store_1[11] + Data_16x16[12][cntY+1][39:36];
                10:
                    Data_16x16[12][cntY+1][43:40] <= Store_1[11] + Data_16x16[12][cntY+1][43:40];
                11:
                    Data_16x16[12][cntY+1][47:44] <= Store_1[11] + Data_16x16[12][cntY+1][47:44];
                12:
                    Data_16x16[12][cntY+1][51:48] <= Store_1[11] + Data_16x16[12][cntY+1][51:48];
                13:
                    Data_16x16[12][cntY+1][55:52] <= Store_1[11] + Data_16x16[12][cntY+1][55:52];
                14:
                    Data_16x16[12][cntY+1][59:56] <= Store_1[11] + Data_16x16[12][cntY+1][59:56];
                15:
                    Data_16x16[12][cntY+1][63:60] <= Store_1[11] + Data_16x16[12][cntY+1][63:60];
            endcase
        end
    end
    else if (current_state==S_READ)
    begin
        Data_16x16[12][16][3:0]   <= Data_16x16[13][1][3:0]  ;
        Data_16x16[12][16][7:4]   <= Data_16x16[13][1][7:4]  ;
        Data_16x16[12][16][11:8]  <= Data_16x16[13][1][11:8] ;
        Data_16x16[12][16][15:12] <= Data_16x16[13][1][15:12];
        Data_16x16[12][16][19:16] <= Data_16x16[13][1][19:16];
        Data_16x16[12][16][23:20] <= Data_16x16[13][1][23:20];
        Data_16x16[12][16][27:24] <= Data_16x16[13][1][27:24];
        Data_16x16[12][16][31:28] <= Data_16x16[13][1][31:28];
        Data_16x16[12][16][35:32] <= Data_16x16[13][1][35:32];
        Data_16x16[12][16][39:36] <= Data_16x16[13][1][39:36];
        Data_16x16[12][16][43:40] <= Data_16x16[13][1][43:40];
        Data_16x16[12][16][47:44] <= Data_16x16[13][1][47:44];
        Data_16x16[12][16][51:48] <= Data_16x16[13][1][51:48];
        Data_16x16[12][16][55:52] <= Data_16x16[13][1][55:52];
        Data_16x16[12][16][59:56] <= Data_16x16[13][1][59:56];
        Data_16x16[12][16][63:60] <= Data_16x16[13][1][63:60];
        for ( j=1 ;j<16 ;j=j+1 )
        begin
            Data_16x16[12][j][3:0]   <= Data_16x16[12][j+1][3:0]  ;
            Data_16x16[12][j][7:4]   <= Data_16x16[12][j+1][7:4]  ;
            Data_16x16[12][j][11:8]  <= Data_16x16[12][j+1][11:8] ;
            Data_16x16[12][j][15:12] <= Data_16x16[12][j+1][15:12];
            Data_16x16[12][j][19:16] <= Data_16x16[12][j+1][19:16];
            Data_16x16[12][j][23:20] <= Data_16x16[12][j+1][23:20];
            Data_16x16[12][j][27:24] <= Data_16x16[12][j+1][27:24];
            Data_16x16[12][j][31:28] <= Data_16x16[12][j+1][31:28];
            Data_16x16[12][j][35:32] <= Data_16x16[12][j+1][35:32];
            Data_16x16[12][j][39:36] <= Data_16x16[12][j+1][39:36];
            Data_16x16[12][j][43:40] <= Data_16x16[12][j+1][43:40];
            Data_16x16[12][j][47:44] <= Data_16x16[12][j+1][47:44];
            Data_16x16[12][j][51:48] <= Data_16x16[12][j+1][51:48];
            Data_16x16[12][j][55:52] <= Data_16x16[12][j+1][55:52];
            Data_16x16[12][j][59:56] <= Data_16x16[12][j+1][59:56];
            Data_16x16[12][j][63:60] <= Data_16x16[12][j+1][63:60];
        end
    end
    else if (current_state==S_IDLE)
    begin
        for ( j=1 ;j<17 ;j=j+1 )
        begin
            Data_16x16[12][j] <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) // 13th
begin
    if (!rst_n)
    begin
        for ( j=1 ; j<17 ; j=j+1 )
        begin
            Data_16x16[13][j] <= 0;
        end
    end
    else if (current_state==S_MAKEhis)
    begin
        if ((in_valid || in_valid_d1)&& Bigcnt_1>=1)
        begin
            case(cntX)
                0:
                    Data_16x16[13][cntY+1][3:0]   <= Store_1[12] + Data_16x16[13][cntY+1][3:0];
                1:
                    Data_16x16[13][cntY+1][7:4]   <= Store_1[12] + Data_16x16[13][cntY+1][7:4];
                2:
                    Data_16x16[13][cntY+1][11:8]  <= Store_1[12] + Data_16x16[13][cntY+1][11:8];
                3:
                    Data_16x16[13][cntY+1][15:12] <= Store_1[12] + Data_16x16[13][cntY+1][15:12];
                4:
                    Data_16x16[13][cntY+1][19:16] <= Store_1[12] + Data_16x16[13][cntY+1][19:16];
                5:
                    Data_16x16[13][cntY+1][23:20] <= Store_1[12] + Data_16x16[13][cntY+1][23:20];
                6:
                    Data_16x16[13][cntY+1][27:24] <= Store_1[12] + Data_16x16[13][cntY+1][27:24];
                7:
                    Data_16x16[13][cntY+1][31:28] <= Store_1[12] + Data_16x16[13][cntY+1][31:28];
                8:
                    Data_16x16[13][cntY+1][35:32] <= Store_1[12] + Data_16x16[13][cntY+1][35:32];
                9:
                    Data_16x16[13][cntY+1][39:36] <= Store_1[12] + Data_16x16[13][cntY+1][39:36];
                10:
                    Data_16x16[13][cntY+1][43:40] <= Store_1[12] + Data_16x16[13][cntY+1][43:40];
                11:
                    Data_16x16[13][cntY+1][47:44] <= Store_1[12] + Data_16x16[13][cntY+1][47:44];
                12:
                    Data_16x16[13][cntY+1][51:48] <= Store_1[12] + Data_16x16[13][cntY+1][51:48];
                13:
                    Data_16x16[13][cntY+1][55:52] <= Store_1[12] + Data_16x16[13][cntY+1][55:52];
                14:
                    Data_16x16[13][cntY+1][59:56] <= Store_1[12] + Data_16x16[13][cntY+1][59:56];
                15:
                    Data_16x16[13][cntY+1][63:60] <= Store_1[12] + Data_16x16[13][cntY+1][63:60];
            endcase
        end
    end
    else if (current_state==S_READ)
    begin
        Data_16x16[13][16][3:0]   <= Data_16x16[14][1][3:0]  ;
        Data_16x16[13][16][7:4]   <= Data_16x16[14][1][7:4]  ;
        Data_16x16[13][16][11:8]  <= Data_16x16[14][1][11:8] ;
        Data_16x16[13][16][15:12] <= Data_16x16[14][1][15:12];
        Data_16x16[13][16][19:16] <= Data_16x16[14][1][19:16];
        Data_16x16[13][16][23:20] <= Data_16x16[14][1][23:20];
        Data_16x16[13][16][27:24] <= Data_16x16[14][1][27:24];
        Data_16x16[13][16][31:28] <= Data_16x16[14][1][31:28];
        Data_16x16[13][16][35:32] <= Data_16x16[14][1][35:32];
        Data_16x16[13][16][39:36] <= Data_16x16[14][1][39:36];
        Data_16x16[13][16][43:40] <= Data_16x16[14][1][43:40];
        Data_16x16[13][16][47:44] <= Data_16x16[14][1][47:44];
        Data_16x16[13][16][51:48] <= Data_16x16[14][1][51:48];
        Data_16x16[13][16][55:52] <= Data_16x16[14][1][55:52];
        Data_16x16[13][16][59:56] <= Data_16x16[14][1][59:56];
        Data_16x16[13][16][63:60] <= Data_16x16[14][1][63:60];
        for ( j=1 ;j<16 ;j=j+1 )
        begin
            Data_16x16[13][j][3:0]   <= Data_16x16[13][j+1][3:0]  ;
            Data_16x16[13][j][7:4]   <= Data_16x16[13][j+1][7:4]  ;
            Data_16x16[13][j][11:8]  <= Data_16x16[13][j+1][11:8] ;
            Data_16x16[13][j][15:12] <= Data_16x16[13][j+1][15:12];
            Data_16x16[13][j][19:16] <= Data_16x16[13][j+1][19:16];
            Data_16x16[13][j][23:20] <= Data_16x16[13][j+1][23:20];
            Data_16x16[13][j][27:24] <= Data_16x16[13][j+1][27:24];
            Data_16x16[13][j][31:28] <= Data_16x16[13][j+1][31:28];
            Data_16x16[13][j][35:32] <= Data_16x16[13][j+1][35:32];
            Data_16x16[13][j][39:36] <= Data_16x16[13][j+1][39:36];
            Data_16x16[13][j][43:40] <= Data_16x16[13][j+1][43:40];
            Data_16x16[13][j][47:44] <= Data_16x16[13][j+1][47:44];
            Data_16x16[13][j][51:48] <= Data_16x16[13][j+1][51:48];
            Data_16x16[13][j][55:52] <= Data_16x16[13][j+1][55:52];
            Data_16x16[13][j][59:56] <= Data_16x16[13][j+1][59:56];
            Data_16x16[13][j][63:60] <= Data_16x16[13][j+1][63:60];
        end
    end
    else if (current_state==S_IDLE)
    begin
        for ( j=1 ;j<17 ;j=j+1 )
        begin
            Data_16x16[13][j] <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) // 14th
begin
    if (!rst_n)
    begin
        for ( j=1 ; j<17 ; j=j+1 )
        begin
            Data_16x16[14][j] <= 0;
        end
    end
    else if (current_state==S_MAKEhis)
    begin
        if ((in_valid || in_valid_d1)&& Bigcnt_1>=1)
        begin
            case(cntX)
                0:
                    Data_16x16[14][cntY+1][3:0]   <= Store_1[13] + Data_16x16[14][cntY+1][3:0];
                1:
                    Data_16x16[14][cntY+1][7:4]   <= Store_1[13] + Data_16x16[14][cntY+1][7:4];
                2:
                    Data_16x16[14][cntY+1][11:8]  <= Store_1[13] + Data_16x16[14][cntY+1][11:8];
                3:
                    Data_16x16[14][cntY+1][15:12] <= Store_1[13] + Data_16x16[14][cntY+1][15:12];
                4:
                    Data_16x16[14][cntY+1][19:16] <= Store_1[13] + Data_16x16[14][cntY+1][19:16];
                5:
                    Data_16x16[14][cntY+1][23:20] <= Store_1[13] + Data_16x16[14][cntY+1][23:20];
                6:
                    Data_16x16[14][cntY+1][27:24] <= Store_1[13] + Data_16x16[14][cntY+1][27:24];
                7:
                    Data_16x16[14][cntY+1][31:28] <= Store_1[13] + Data_16x16[14][cntY+1][31:28];
                8:
                    Data_16x16[14][cntY+1][35:32] <= Store_1[13] + Data_16x16[14][cntY+1][35:32];
                9:
                    Data_16x16[14][cntY+1][39:36] <= Store_1[13] + Data_16x16[14][cntY+1][39:36];
                10:
                    Data_16x16[14][cntY+1][43:40] <= Store_1[13] + Data_16x16[14][cntY+1][43:40];
                11:
                    Data_16x16[14][cntY+1][47:44] <= Store_1[13] + Data_16x16[14][cntY+1][47:44];
                12:
                    Data_16x16[14][cntY+1][51:48] <= Store_1[13] + Data_16x16[14][cntY+1][51:48];
                13:
                    Data_16x16[14][cntY+1][55:52] <= Store_1[13] + Data_16x16[14][cntY+1][55:52];
                14:
                    Data_16x16[14][cntY+1][59:56] <= Store_1[13] + Data_16x16[14][cntY+1][59:56];
                15:
                    Data_16x16[14][cntY+1][63:60] <= Store_1[13] + Data_16x16[14][cntY+1][63:60];
            endcase
        end
    end
    else if (current_state==S_READ)
    begin
        Data_16x16[14][16][3:0]   <= Data_16x16[15][1][3:0]  ;
        Data_16x16[14][16][7:4]   <= Data_16x16[15][1][7:4]  ;
        Data_16x16[14][16][11:8]  <= Data_16x16[15][1][11:8] ;
        Data_16x16[14][16][15:12] <= Data_16x16[15][1][15:12];
        Data_16x16[14][16][19:16] <= Data_16x16[15][1][19:16];
        Data_16x16[14][16][23:20] <= Data_16x16[15][1][23:20];
        Data_16x16[14][16][27:24] <= Data_16x16[15][1][27:24];
        Data_16x16[14][16][31:28] <= Data_16x16[15][1][31:28];
        Data_16x16[14][16][35:32] <= Data_16x16[15][1][35:32];
        Data_16x16[14][16][39:36] <= Data_16x16[15][1][39:36];
        Data_16x16[14][16][43:40] <= Data_16x16[15][1][43:40];
        Data_16x16[14][16][47:44] <= Data_16x16[15][1][47:44];
        Data_16x16[14][16][51:48] <= Data_16x16[15][1][51:48];
        Data_16x16[14][16][55:52] <= Data_16x16[15][1][55:52];
        Data_16x16[14][16][59:56] <= Data_16x16[15][1][59:56];
        Data_16x16[14][16][63:60] <= Data_16x16[15][1][63:60];
        for ( j=1 ;j<16 ;j=j+1 )
        begin
            Data_16x16[14][j][3:0]   <= Data_16x16[14][j+1][3:0]  ;
            Data_16x16[14][j][7:4]   <= Data_16x16[14][j+1][7:4]  ;
            Data_16x16[14][j][11:8]  <= Data_16x16[14][j+1][11:8] ;
            Data_16x16[14][j][15:12] <= Data_16x16[14][j+1][15:12];
            Data_16x16[14][j][19:16] <= Data_16x16[14][j+1][19:16];
            Data_16x16[14][j][23:20] <= Data_16x16[14][j+1][23:20];
            Data_16x16[14][j][27:24] <= Data_16x16[14][j+1][27:24];
            Data_16x16[14][j][31:28] <= Data_16x16[14][j+1][31:28];
            Data_16x16[14][j][35:32] <= Data_16x16[14][j+1][35:32];
            Data_16x16[14][j][39:36] <= Data_16x16[14][j+1][39:36];
            Data_16x16[14][j][43:40] <= Data_16x16[14][j+1][43:40];
            Data_16x16[14][j][47:44] <= Data_16x16[14][j+1][47:44];
            Data_16x16[14][j][51:48] <= Data_16x16[14][j+1][51:48];
            Data_16x16[14][j][55:52] <= Data_16x16[14][j+1][55:52];
            Data_16x16[14][j][59:56] <= Data_16x16[14][j+1][59:56];
            Data_16x16[14][j][63:60] <= Data_16x16[14][j+1][63:60];
        end
    end
    else if (current_state==S_IDLE)
    begin
        for ( j=1 ;j<17 ;j=j+1 )
        begin
            Data_16x16[14][j] <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) // 15th
begin
    if (!rst_n)
    begin
        for ( j=1 ; j<17 ; j=j+1 )
        begin
            Data_16x16[15][j] <= 0;
        end
    end
    else if (current_state==S_MAKEhis)
    begin
        if ((in_valid || in_valid_d1)&& Bigcnt_1>=1)
        begin
            case(cntX)
                0:
                    Data_16x16[15][cntY+1][3:0]   <= Store_1[14] + Data_16x16[15][cntY+1][3:0];
                1:
                    Data_16x16[15][cntY+1][7:4]   <= Store_1[14] + Data_16x16[15][cntY+1][7:4];
                2:
                    Data_16x16[15][cntY+1][11:8]  <= Store_1[14] + Data_16x16[15][cntY+1][11:8];
                3:
                    Data_16x16[15][cntY+1][15:12] <= Store_1[14] + Data_16x16[15][cntY+1][15:12];
                4:
                    Data_16x16[15][cntY+1][19:16] <= Store_1[14] + Data_16x16[15][cntY+1][19:16];
                5:
                    Data_16x16[15][cntY+1][23:20] <= Store_1[14] + Data_16x16[15][cntY+1][23:20];
                6:
                    Data_16x16[15][cntY+1][27:24] <= Store_1[14] + Data_16x16[15][cntY+1][27:24];
                7:
                    Data_16x16[15][cntY+1][31:28] <= Store_1[14] + Data_16x16[15][cntY+1][31:28];
                8:
                    Data_16x16[15][cntY+1][35:32] <= Store_1[14] + Data_16x16[15][cntY+1][35:32];
                9:
                    Data_16x16[15][cntY+1][39:36] <= Store_1[14] + Data_16x16[15][cntY+1][39:36];
                10:
                    Data_16x16[15][cntY+1][43:40] <= Store_1[14] + Data_16x16[15][cntY+1][43:40];
                11:
                    Data_16x16[15][cntY+1][47:44] <= Store_1[14] + Data_16x16[15][cntY+1][47:44];
                12:
                    Data_16x16[15][cntY+1][51:48] <= Store_1[14] + Data_16x16[15][cntY+1][51:48];
                13:
                    Data_16x16[15][cntY+1][55:52] <= Store_1[14] + Data_16x16[15][cntY+1][55:52];
                14:
                    Data_16x16[15][cntY+1][59:56] <= Store_1[14] + Data_16x16[15][cntY+1][59:56];
                15:
                    Data_16x16[15][cntY+1][63:60] <= Store_1[14] + Data_16x16[15][cntY+1][63:60];
            endcase
        end
    end
    else if (current_state==S_READ)
    begin
        Data_16x16[15][16][3:0]   <= Data_16x16[16][1][3:0]  ;
        Data_16x16[15][16][7:4]   <= Data_16x16[16][1][7:4]  ;
        Data_16x16[15][16][11:8]  <= Data_16x16[16][1][11:8] ;
        Data_16x16[15][16][15:12] <= Data_16x16[16][1][15:12];
        Data_16x16[15][16][19:16] <= Data_16x16[16][1][19:16];
        Data_16x16[15][16][23:20] <= Data_16x16[16][1][23:20];
        Data_16x16[15][16][27:24] <= Data_16x16[16][1][27:24];
        Data_16x16[15][16][31:28] <= Data_16x16[16][1][31:28];
        Data_16x16[15][16][35:32] <= Data_16x16[16][1][35:32];
        Data_16x16[15][16][39:36] <= Data_16x16[16][1][39:36];
        Data_16x16[15][16][43:40] <= Data_16x16[16][1][43:40];
        Data_16x16[15][16][47:44] <= Data_16x16[16][1][47:44];
        Data_16x16[15][16][51:48] <= Data_16x16[16][1][51:48];
        Data_16x16[15][16][55:52] <= Data_16x16[16][1][55:52];
        Data_16x16[15][16][59:56] <= Data_16x16[16][1][59:56];
        Data_16x16[15][16][63:60] <= Data_16x16[16][1][63:60];
        for ( j=1 ;j<16 ;j=j+1 )
        begin
            Data_16x16[15][j][3:0]   <= Data_16x16[15][j+1][3:0]  ;
            Data_16x16[15][j][7:4]   <= Data_16x16[15][j+1][7:4]  ;
            Data_16x16[15][j][11:8]  <= Data_16x16[15][j+1][11:8] ;
            Data_16x16[15][j][15:12] <= Data_16x16[15][j+1][15:12];
            Data_16x16[15][j][19:16] <= Data_16x16[15][j+1][19:16];
            Data_16x16[15][j][23:20] <= Data_16x16[15][j+1][23:20];
            Data_16x16[15][j][27:24] <= Data_16x16[15][j+1][27:24];
            Data_16x16[15][j][31:28] <= Data_16x16[15][j+1][31:28];
            Data_16x16[15][j][35:32] <= Data_16x16[15][j+1][35:32];
            Data_16x16[15][j][39:36] <= Data_16x16[15][j+1][39:36];
            Data_16x16[15][j][43:40] <= Data_16x16[15][j+1][43:40];
            Data_16x16[15][j][47:44] <= Data_16x16[15][j+1][47:44];
            Data_16x16[15][j][51:48] <= Data_16x16[15][j+1][51:48];
            Data_16x16[15][j][55:52] <= Data_16x16[15][j+1][55:52];
            Data_16x16[15][j][59:56] <= Data_16x16[15][j+1][59:56];
            Data_16x16[15][j][63:60] <= Data_16x16[15][j+1][63:60];
        end
    end
    else if (current_state==S_IDLE)
    begin
        for ( j=1 ;j<17 ;j=j+1 )
        begin
            Data_16x16[15][j] <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) //  16th
begin
    if (!rst_n)
    begin
        for ( j=1 ; j<17 ; j=j+1 )
        begin
            Data_16x16[16][j] <= 0;
        end
    end
    else if (current_state==S_MAKEhis)
    begin
        if ((in_valid || in_valid_d1)&& Bigcnt_1>=1)
        begin
            case(cntX)
                0:
                    Data_16x16[16][cntY+1][3:0]   <= Store_1[15] + Data_16x16[16][cntY+1][3:0];
                1:
                    Data_16x16[16][cntY+1][7:4]   <= Store_1[15] + Data_16x16[16][cntY+1][7:4];
                2:
                    Data_16x16[16][cntY+1][11:8]  <= Store_1[15] + Data_16x16[16][cntY+1][11:8];
                3:
                    Data_16x16[16][cntY+1][15:12] <= Store_1[15] + Data_16x16[16][cntY+1][15:12];
                4:
                    Data_16x16[16][cntY+1][19:16] <= Store_1[15] + Data_16x16[16][cntY+1][19:16];
                5:
                    Data_16x16[16][cntY+1][23:20] <= Store_1[15] + Data_16x16[16][cntY+1][23:20];
                6:
                    Data_16x16[16][cntY+1][27:24] <= Store_1[15] + Data_16x16[16][cntY+1][27:24];
                7:
                    Data_16x16[16][cntY+1][31:28] <= Store_1[15] + Data_16x16[16][cntY+1][31:28];
                8:
                    Data_16x16[16][cntY+1][35:32] <= Store_1[15] + Data_16x16[16][cntY+1][35:32];
                9:
                    Data_16x16[16][cntY+1][39:36] <= Store_1[15] + Data_16x16[16][cntY+1][39:36];
                10:
                    Data_16x16[16][cntY+1][43:40] <= Store_1[15] + Data_16x16[16][cntY+1][43:40];
                11:
                    Data_16x16[16][cntY+1][47:44] <= Store_1[15] + Data_16x16[16][cntY+1][47:44];
                12:
                    Data_16x16[16][cntY+1][51:48] <= Store_1[15] + Data_16x16[16][cntY+1][51:48];
                13:
                    Data_16x16[16][cntY+1][55:52] <= Store_1[15] + Data_16x16[16][cntY+1][55:52];
                14:
                    Data_16x16[16][cntY+1][59:56] <= Store_1[15] + Data_16x16[16][cntY+1][59:56];
                15:
                    Data_16x16[16][cntY+1][63:60] <= Store_1[15] + Data_16x16[16][cntY+1][63:60];
            endcase
        end
    end
    else if (current_state==S_READ)
    begin
        if(Bigcnt_1<=255)
        begin
            Data_16x16[16][16][3:0]   <= rdata_m_inf[3:0];
            Data_16x16[16][16][7:4]   <= rdata_m_inf[15:8];
            Data_16x16[16][16][11:8]  <= rdata_m_inf[23:16];
            Data_16x16[16][16][15:12] <= rdata_m_inf[31:24];
            Data_16x16[16][16][19:16] <= rdata_m_inf[39:32];
            Data_16x16[16][16][23:20] <= rdata_m_inf[47:40];
            Data_16x16[16][16][27:24] <= rdata_m_inf[55:48];
            Data_16x16[16][16][31:28] <= rdata_m_inf[63:56];
            Data_16x16[16][16][35:32] <= rdata_m_inf[71:64];
            Data_16x16[16][16][39:36] <= rdata_m_inf[79:72];
            Data_16x16[16][16][43:40] <= rdata_m_inf[87:80];
            Data_16x16[16][16][47:44] <= rdata_m_inf[95:88];
            Data_16x16[16][16][51:48] <= rdata_m_inf[103:96];
            Data_16x16[16][16][55:52] <= rdata_m_inf[111:104];
            Data_16x16[16][16][59:56] <= rdata_m_inf[119:112];
            Data_16x16[16][16][63:60] <= rdata_m_inf[127:120];
            for(j=1 ;j<16 ;j=j+1)
            begin
                Data_16x16[16][j][3:0]   <= Data_16x16[16][j+1][3:0]  ;
                Data_16x16[16][j][7:4]   <= Data_16x16[16][j+1][7:4]  ;
                Data_16x16[16][j][11:8]  <= Data_16x16[16][j+1][11:8] ;
                Data_16x16[16][j][15:12] <= Data_16x16[16][j+1][15:12];
                Data_16x16[16][j][19:16] <= Data_16x16[16][j+1][19:16];
                Data_16x16[16][j][23:20] <= Data_16x16[16][j+1][23:20];
                Data_16x16[16][j][27:24] <= Data_16x16[16][j+1][27:24];
                Data_16x16[16][j][31:28] <= Data_16x16[16][j+1][31:28];
                Data_16x16[16][j][35:32] <= Data_16x16[16][j+1][35:32];
                Data_16x16[16][j][39:36] <= Data_16x16[16][j+1][39:36];
                Data_16x16[16][j][43:40] <= Data_16x16[16][j+1][43:40];
                Data_16x16[16][j][47:44] <= Data_16x16[16][j+1][47:44];
                Data_16x16[16][j][51:48] <= Data_16x16[16][j+1][51:48];
                Data_16x16[16][j][55:52] <= Data_16x16[16][j+1][55:52];
                Data_16x16[16][j][59:56] <= Data_16x16[16][j+1][59:56];
                Data_16x16[16][j][63:60] <= Data_16x16[16][j+1][63:60];
            end
        end
    end
    else if (current_state==S_IDLE)
    begin
        for ( j=1 ;j<17 ;j=j+1 )
        begin
            Data_16x16[16][j] <= 0;
        end
    end
end



always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
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
            0:
            begin
                if (current_state==S_CAL)
                begin
                    case (Bigcnt_1)
                        21:
                            distance_4x4[1]  <= sum_max_dis;
                        37:
                            distance_4x4[2]  <= sum_max_dis;
                        53:
                            distance_4x4[3]  <= sum_max_dis;
                        69:
                            distance_4x4[4]  <= sum_max_dis;
                        85:
                            distance_4x4[5]  <= sum_max_dis;
                        101:
                            distance_4x4[6]  <= sum_max_dis;
                        117:
                            distance_4x4[7]  <= sum_max_dis;
                        133:
                            distance_4x4[8]  <= sum_max_dis;
                        149:
                            distance_4x4[9]  <= sum_max_dis;
                        165:
                            distance_4x4[10] <= sum_max_dis;
                        181:
                            distance_4x4[11] <= sum_max_dis;
                        197:
                            distance_4x4[12] <= sum_max_dis;
                        213:
                            distance_4x4[13] <= sum_max_dis;
                        229:
                            distance_4x4[14] <= sum_max_dis;
                        245:
                            distance_4x4[15] <= sum_max_dis;
                        261:
                            distance_4x4[16] <= sum_max_dis;
                    endcase
                end
            end
            1:
            begin
                if (current_state==S_WRITEhis)
                begin
                    if (Bigcnt_1==21)//17
                    begin
                        distance_4x4[1] <= sum_max_dis;
                        distance_4x4[2] <= sum_max_dis;
                        distance_4x4[5] <= sum_max_dis;
                        distance_4x4[6] <= sum_max_dis;
                    end
                    else if (Bigcnt_1==37)//33
                    begin
                        distance_4x4[3] <= sum_max_dis;
                        distance_4x4[4] <= sum_max_dis;
                        distance_4x4[7] <= sum_max_dis;
                        distance_4x4[8] <= sum_max_dis;
                    end
                    else if (Bigcnt_1==53)//49
                    begin
                        distance_4x4[9 ] <= sum_max_dis;
                        distance_4x4[10] <= sum_max_dis;
                        distance_4x4[13] <= sum_max_dis;
                        distance_4x4[14] <= sum_max_dis;
                    end
                    else if (Bigcnt_1==69)//65
                    begin
                        distance_4x4[11] <= sum_max_dis;
                        distance_4x4[12] <= sum_max_dis;
                        distance_4x4[15] <= sum_max_dis;
                        distance_4x4[16] <= sum_max_dis;
                    end
                end
            end
            2,3:
            begin
                if (current_state==S_WRITEhis)
                begin
                    case (Bigcnt_1)
                        21:
                            distance_4x4[2] <= sum_max_dis;
                        37:
                            distance_4x4[3] <= sum_max_dis;
                        53:
                            distance_4x4[4] <= sum_max_dis;
                        69:
                            distance_4x4[5] <= sum_max_dis;
                        85:
                            distance_4x4[6] <= sum_max_dis;
                        101:
                            distance_4x4[7] <= sum_max_dis;
                        117:
                            distance_4x4[8] <= sum_max_dis;
                        133:
                            distance_4x4[9] <= sum_max_dis;
                        149 :
                            distance_4x4[10] <= sum_max_dis;
                        165:
                            distance_4x4[11] <= sum_max_dis;
                        181:
                            distance_4x4[12] <= sum_max_dis;
                        197:
                            distance_4x4[13] <= sum_max_dis;
                        213:
                            distance_4x4[14] <= sum_max_dis;
                        229:
                            distance_4x4[15] <= sum_max_dis;
                        245:
                            distance_4x4[16] <= sum_max_dis;
                        261:
                            distance_4x4[1] <= sum_max_dis;
                    endcase
                end
            end
        endcase
    end
end



endmodule
