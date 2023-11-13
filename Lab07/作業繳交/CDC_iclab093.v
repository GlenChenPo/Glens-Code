`include "AFIFO.v"

module CDC #(parameter DSIZE = 8,
             parameter ASIZE = 4)(
           //Input Port
           rst_n,
           clk1,
           clk2,
           in_valid,
           in_account,
           in_A,
           in_T,

           //Output Port
           ready,
           out_valid,
           out_account
       );
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------

input 				rst_n, clk1, clk2, in_valid;
input [DSIZE-1:0] 	in_account,in_A,in_T;

output reg				out_valid,ready;
output reg [DSIZE-1:0] 	out_account;

//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION
//---------------------------------------------------------------------
reg flag1 ;
reg [DSIZE-1:0] ACT_1 , ACT_2 , ACT_3 , ACT_4 , ACT_5 , ACT_C , ACT_D;
reg [DSIZE*2-1:0] perf_1 , perf_2 , perf_3 , perf_4 , perf_5;

reg [DSIZE-1:0]   comp_a_1 , comp_a_2 ;
reg [DSIZE*2-1:0] comp_1 , comp_2 ;
reg [DSIZE*2-1:0] temp_perf ;
reg [DSIZE-1:0] temp_account ;

reg [DSIZE*2-1:0] Mult ;
reg [DSIZE-1:0] mult_inA , mult_inB ;

reg [3:0] cnt_forout ;
reg [11:0] cnt_end;//use to cnt 4000 output and switch state
//---------------------------------------------------------------------
//   AFIFO
//---------------------------------------------------------------------
reg R_inc_1,W_inc_1 , R_inc_2,W_inc_2 , R_inc_3,W_inc_3;
reg  [7:0]  W_data_1 , W_data_2 , W_data_3;
wire [7:0]  R_data_1 , R_data_2 , R_data_3;
wire       R_empty_1 , W_full_1 ;
wire       R_empty_2 , W_full_2 ;
wire       R_empty_3 , W_full_3 ;
//---------------------------------------------------------------------
//   DESIGN
//---------------------------------------------------------------------
AFIFO u1_AFIFO(
          .rclk(clk1),
          .rinc(R_inc_1),
          .rempty(R_empty_1),
          .wclk(clk2),
          .winc(W_inc_1),
          .wfull(W_full_1),
          .rst_n(rst_n),
          .rdata(R_data_1),
          .wdata(W_data_1)
      );
AFIFO u2_AFIFO(
          .rclk(clk1),
          .rinc(R_inc_2),
          .rempty(R_empty_2),
          .wclk(clk2),
          .winc(W_inc_2),
          .wfull(W_full_2),
          .rst_n(rst_n),
          .rdata(R_data_2),
          .wdata(W_data_2)
      );
AFIFO u3_AFIFO(
          .rclk(clk1),
          .rinc(R_inc_3),
          .rempty(R_empty_3),
          .wclk(clk2),
          .winc(W_inc_3),
          .wfull(W_full_3),
          .rst_n(rst_n),
          .rdata(R_data_3),
          .wdata(W_data_3)
      );

//============================================================
//               FSM
//============================================================
reg current_state , next_state ;
// state
parameter IDLE      = 1'd0 ;
parameter STATE_1   = 1'd1 ;
//=============================================================
//            Current state
//=============================================================
always @(posedge clk1 or negedge rst_n)
begin
    if (!rst_n)
        current_state <= IDLE;
    else
        current_state <= next_state;
end
//=============================================================
//            Next state
//=============================================================
always @(*)
begin
    case (current_state) //Current_state
        IDLE:
        begin
            if (in_valid)
                next_state = STATE_1;
            else
                next_state = IDLE;
        end
        STATE_1:
        begin
            if(cnt_end==3995)
                next_state =  IDLE ;
            else
                next_state =  STATE_1 ;
        end
        default:
            next_state = IDLE;
    endcase
end
//=============================================================
//            cnt
//=============================================================
reg [9:0] cnt1;
always @(posedge clk1 or negedge rst_n) //
begin
    if(~rst_n)
        cnt1 <= 0;
    else if (cnt1==1000)
    begin
        cnt1 <= 100;
    end
    else if (current_state==STATE_1)
    begin
        cnt1 <= cnt1 + 1;
    end
    else if (current_state==IDLE)
    begin
        cnt1 <= 0;
    end
end
always @(posedge clk2 or negedge rst_n)
begin
    if(~rst_n)
        cnt_end <= 0;
    else if (out_valid)
    begin
        cnt_end <= cnt_end + 1 ;
    end
    else if (current_state==IDLE)
    begin
        cnt_end <= 0;
    end
end

//------------flag1---------------------------------------------
always @(posedge clk2 or negedge rst_n)
begin
    if (~rst_n)
    begin
        flag1 <= 0;
    end
    else
    begin
        if (current_state==STATE_1)
        begin
            flag1 <= R_empty_1;
        end
        else if (current_state==IDLE)
        begin
            flag1 <= 0;
        end
    end
end
//=====================================================================================================================================
//=====================================================================================================================================
//    MM      MM      AAA     IIIIIIII  NN      NN           CCCCCC    IIIIIIII  RRRRRRRR      CCCCCC   UU      UU  IIIIIIII TTTTTTTTTT
//    MMM    MMM     AA AA       II     NNNN    NN         CC             II     RR      RR  CC         UU      UU     II        TT
//    MM M  M MM    AA   AA      II     NN  NN  NN        CC              II     RRRRRRRRR  CC          UU      UU     II        TT
//    MM  MM  MM   AAAAAAAAA     II     NN    NNNN         CC      CC     II     RR   RRR    CC      CC  UU    UU      II        TT
//    MM      MM  AA       AA IIIIIIII  NN      NN          CCCCCCCC   IIIIIIII  RR     RRR   CCCCCCCC    UUUUUU    IIIIIIII     TT
//=====================================================================================================================================
//=====================================================================================================================================
//==========================================================================
//              Store the result to FIFO
//==========================================================================
always @(posedge clk1 or negedge rst_n)
begin
    if (~rst_n)
    begin
        W_inc_1 <= 0;
        W_inc_2 <= 0;
        W_inc_3 <= 0;
    end
    else
    begin
        if (ready && in_valid==0)
        begin
            W_inc_1 <= 0;
            W_inc_2 <= 0;
            W_inc_3 <= 0;
        end
        else if (in_valid)
        begin
            W_inc_1 <= 1;
            W_inc_2 <= 1;
            W_inc_3 <= 1;
        end
        else if (current_state==IDLE)
        begin
            W_inc_1 <= 0;
            W_inc_2 <= 0;
            W_inc_3 <= 0;
        end
    end
end
//==========================================================================
//             ready
//==========================================================================
always @(*)
begin
    if (rst_n==0)
    begin
        ready <= 0;
    end
    else
    begin
        if (W_full_1)
        begin
            ready <= 0;
        end
        else
        begin
            ready <= 1;
        end
    end
end

//==========================================================================
//                W_data
//==========================================================================
always @(posedge clk1 or negedge rst_n)
begin
    if (~rst_n)
    begin
        W_data_1 <=  0;
        W_data_2 <=  0;
        W_data_3 <=  0;
    end
    else
    begin
        if (current_state==STATE_1 || in_valid )
        begin
            if (ready)
            begin
                W_data_1 <= in_account ;
                W_data_2 <= in_A ;
                W_data_3 <= in_T ;
            end
            else
            begin
                W_data_1 <= W_data_1 ;
                W_data_2 <= W_data_2 ;
                W_data_3 <= W_data_3 ;
            end
        end
    end
end
//==========================================================================
//          Compute the performance
//==========================================================================
always @(posedge clk2 or negedge rst_n)
begin
    if (~rst_n)
    begin
        ACT_1 <= 0;
        ACT_2 <= 0;
        ACT_3 <= 0;
        ACT_4 <= 0;
        ACT_5 <= 0;
    end
    else if (current_state==STATE_1)
    begin
        if (R_empty_1)
        begin
            if (cnt_end>3992)
            begin
                ACT_1 <= ACT_2;
                ACT_2 <= ACT_3;
                ACT_3 <= ACT_4;
                ACT_4 <= ACT_5;
                ACT_5 <= R_data_1;
            end
            else
            begin
                ACT_1 <= ACT_1;
                ACT_2 <= ACT_2;
                ACT_3 <= ACT_3;
                ACT_4 <= ACT_4;
                ACT_5 <= ACT_5;
            end
        end
        else if (R_empty_1==0)
        begin
            if (R_inc_1)
            begin
                ACT_1 <= ACT_2;
                ACT_2 <= ACT_3;
                ACT_3 <= ACT_4;
                ACT_4 <= ACT_5;
                ACT_5 <= R_data_1;
            end
        end
    end
    else if (current_state==IDLE)
    begin
        ACT_1 <= 0;
        ACT_2 <= 0;
        ACT_3 <= 0;
        ACT_4 <= 0;
        ACT_5 <= 0;
    end
end
//  PERFORMANCE
always @(posedge clk2 or negedge rst_n)
begin
    if (~rst_n)
    begin
        perf_1 <= 0;
        perf_2 <= 0;
        perf_3 <= 0;
        perf_4 <= 0;
        perf_5 <= 0;
    end
    else if (current_state==STATE_1)
    begin
        if (R_empty_1)
        begin
            if (cnt_end>3992)
            begin
                perf_1 <= perf_2;
                perf_2 <= perf_3;
                perf_3 <= perf_4;
                perf_4 <= perf_5;
                perf_5 <= Mult  ;
            end
            else
            begin
                perf_1 <= perf_1;
                perf_2 <= perf_2;
                perf_3 <= perf_3;
                perf_4 <= perf_4;
                perf_5 <= perf_5;
            end
        end
        else if(R_empty_1==0)
        begin
            if (R_inc_1)
            begin
                perf_1 <= perf_2;
                perf_2 <= perf_3;
                perf_3 <= perf_4;
                perf_4 <= perf_5;
                perf_5 <= Mult  ;
            end
        end
    end
    else if (current_state==IDLE)
    begin
        perf_1 <= 0;
        perf_2 <= 0;
        perf_3 <= 0;
        perf_4 <= 0;
        perf_5 <= 0;
    end
end
//------combination-----------------------------------------------------
always @(*)
begin
    if (perf_1 >= perf_2)
    begin
        comp_1 = perf_2 ;
        comp_a_1 = ACT_2 ;
    end
    else
    begin
        comp_1 = perf_1 ;
        comp_a_1 = ACT_1 ;
    end
end
always @(*)
begin
    if (perf_3 >= perf_4)
    begin
        comp_2 = perf_4 ;
        comp_a_2 = ACT_4 ;
    end
    else
    begin
        comp_2 = perf_3 ;
        comp_a_2 = ACT_3 ;
    end
end
always @(*)
begin
    if (comp_1 >= comp_2)
    begin
        if (comp_2 < perf_5)
        begin
            temp_perf = perf_2 ;
            temp_account = comp_a_2 ;
        end
        else
        begin
            temp_account = ACT_5 ;
            temp_perf = perf_5 ;
        end
    end
    else
    begin
        if (comp_1 < perf_5)
        begin
            temp_account = comp_a_1 ;
            temp_perf = perf_1 ;
        end
        else
        begin
            temp_account = ACT_5 ;
            temp_perf = perf_5 ;
        end
    end
end
//------------- multipler ---------------------------------------------
// always @(*)
// begin
//     mult_inA = R_data_2 ;
//     mult_inB = R_data_3 ;
// end
always @(*)
begin
    Mult = R_data_3 * R_data_2 ;
end

//===========================================================================================
//              OOOOO    UU      UU TTTTTTTTTT
//            OO     OO  UU      UU     TT
//           OO       OO UU      UU     TT
//            OO     OO   UU    UU      TT
//              OOOOO      UUUUUU       TT
//===========================================================================================

always @(posedge clk2 or negedge rst_n)
begin
    if (~rst_n)
    begin
        cnt_forout <= 0 ;
    end
    else if (current_state==IDLE)
    begin
        cnt_forout <= 0;
    end
    else if (cnt_forout==15)
    begin
        cnt_forout <= 10 ;
    end
    else if (R_inc_1 && R_empty_1==0)
    begin
        cnt_forout <= cnt_forout + 1;
    end
end


always @(posedge clk2 or negedge rst_n)
begin
    if (~rst_n)
    begin
        out_valid <= 0;
        out_account <= 0;
    end
    else if (current_state==IDLE)
    begin
        out_valid <= 0;
        out_account <= 0;
    end
    else if (current_state==STATE_1)
    begin
        if (R_empty_1)
        begin
            if (cnt_end>3992)
            begin
                out_valid <= 1;
                out_account <=  temp_account;
            end
            else
            begin
                out_valid <= 0;
                out_account <= 0;
            end
        end
        else if (flag1==0 && cnt_forout>=5 )
        begin
            out_account <= temp_account ;
            out_valid <= 1 ;
        end
    end
end
always @(posedge clk2 or negedge rst_n)
begin
    if (~rst_n)
    begin
        R_inc_1 <= 0;
        R_inc_2 <= 0;
        R_inc_3 <= 0;
    end
    else
    begin
        if (R_empty_1==0)
        begin
            R_inc_1 <= 1 ;
            R_inc_2 <= 1 ;
            R_inc_3 <= 1 ;
        end
        else if(R_empty_1==1)
        begin
            R_inc_1 <= 0;
            R_inc_2 <= 0;
            R_inc_3 <= 0;
        end
    end
end
endmodule
