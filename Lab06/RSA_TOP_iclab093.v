//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : RSA_TOP.v
//   Module Name : RSA_TOP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

//synopsys translate_off
`include "RSA_IP.v"
//synopsys translate_on

module RSA_TOP (
           // Input signals
           clk, rst_n, in_valid,
           in_p, in_q, in_e, in_c,
           // Output signals
           out_valid, out_m
       );

// ===============================================================
// Input & Output Declaration
// ===============================================================
input clk, rst_n, in_valid;
input [3:0] in_p, in_q;
input [7:0] in_e, in_c;
output reg out_valid;
output reg [7:0] out_m;

// ===============================================================
// Parameter & Integer Declaration
// ===============================================================
// state
parameter IDLE    = 3'd0;
parameter STATE1  = 3'd1; //get the MAP
parameter STATE2  = 3'd2; //save the trap to map1
// parameter STATE3  = 3'd3; //del deadend & make hostage road

reg [2:0] current_state,next_state;
// ===============================================================
// Soft IP
// ===============================================================
reg  [4-1:0]   IN_P, IN_Q;
reg  [4*2-1:0] IN_E;
wire [4*2-1:0] OUT_N, OUT_D;

RSA_IP #(.WIDTH(4)) I_RSA_IP ( .IN_P(IN_P), .IN_Q(IN_Q), .IN_E(IN_E), .OUT_N(OUT_N), .OUT_D(OUT_D) );
//================================================================
// Wire & Reg Declaration
//================================================================
// cnt
reg [9:0] cnt;//counter
reg [2:0] cnt2;
//
reg [7:0] D0 , D1 , D2 , D3 , D4 , D5 , D6 , D7 ;
reg [7:0] A0 , A1 , A2 , A3 , A4 , A5 , A6 , A7 ;
reg [7:0] B0 , B1 , B2 , B3 , B4 , B5 , B6 , B7 ;
reg [7:0] E0 , E1 , E2 , E3 , E4 , E5 , E6 , E7 ;
reg [15:0] anw0 , anw1 , anw2 , anw3 , anw4 , anw5 , anw6 , anw7 ;

reg [7:0] M [0:7] ;

/*-----------------------------------------------------------------------------------
     CCCCCCCC  UU      UU  RRRRRRRR    RRRRRRRR    EEEEEEEEEE  NN      NN  TTTTTTTTTT                                             
    CC         UU      UU  RR      RR  RR      RR  EE          NNNN    NN      TT                                    
   CC          UU      UU  RRRRRRRRR   RRRRRRRRR   EEEEEEEEE   NN  NN  NN      TT                                   
    CC          UU    UU   RR   RRR    RR   RRR    EE          NN    NNNN      TT                                    
     CCCCCCCC    UUUUUU    RR     RRR  RR     RRR  EEEEEEEEEE  NN      NN      TT                                              
*///---------------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        current_state <= IDLE;
    else
        current_state <= next_state;
end
/* -----------------------------------------------------------------------------------
   NN      NN  EEEEEEEEEE  ii      ii  TTTTTTTTTT                                                                         
   NNNN    NN  EE           iii  iii       TT                                                           
   NN  NN  NN  EEEEEEEEE     iiiiii        TT                                                                  
   NN    NNNN  EE           iii  iii       TT                                                      
   NN      NN  EEEEEEEEEE  ii      ii      TT                                                              
*///---------------------------------------------------------------------------------                                                                                         
always @(*)
begin
    case (current_state)
        IDLE:
        begin
            if (in_valid)
                next_state = STATE1;
            else
                next_state = IDLE;
        end

        STATE1:
        begin
            if (D0==OUT_D && cnt>7)
                next_state = STATE2;
            else if (D0>OUT_D && in_valid==0)
            begin
                next_state = STATE2;
            end
            else
                next_state = STATE1;
        end

        STATE2:
        begin
            if (cnt2==7)
                next_state = IDLE;
            else
                next_state = STATE2;
        end

        // STATE3:
        //     if(flagEND)
        //         next_state = IDLE;
        //     else
        //         next_state = STATE3;

        default:
            next_state = IDLE;
    endcase
end
//================================================================
//        INPUT
//================================================================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        IN_P <= 0;
        IN_E <= 0;
        IN_Q <= 0;
    end
    else
    begin
        if (in_valid && cnt==0)
        begin
            IN_Q <= in_q ;
            IN_E <= in_e ;
            IN_P <= in_p ;
        end
        else if (current_state==IDLE)
        begin
            IN_E <= 0;
            IN_P <= 0;
            IN_Q <= 0;
        end
    end
end

// ===============================================================
// Finite State Machine
// ===============================================================
/*      cccccccccc                             cccccccccc
      ccc   c    ccc                         ccc   c    ccc                                  
     cc     c      cc                       cc     c      cc                               
    ccc     c      ccc                     ccc     c      ccc                             
     cc      c     cc                       cc      c     cc                               
      ccc      c ccc                         ccc      c ccc                  
        cccccccccc                             cccccccccc                                       
*/// -----------------Set Counter-----------------------------------
always @(posedge clk or negedge rst_n) //cnt
begin
    //Reset--------------------------------------
    if(~rst_n)
    begin
        cnt <= 0;
    end
    //count-------------------------------------
    else if(in_valid)
    begin
        cnt <= cnt+1;
    end
    else if (current_state==STATE2)
    begin
        cnt <= cnt+1;
    end
    else if (current_state==IDLE)
    begin
        cnt  <= 0;
    end
    else if (current_state==STATE1)
    begin
        cnt <= cnt+1;
    end
end


//========= cnt2 =================================================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        cnt2 <= 0 ;
    end
    else if (current_state==STATE2)
    begin
        cnt2 <= cnt2 + 1;
    end
    else if (current_state==IDLE)
    begin
        cnt2 <= 0 ;
    end

end

//================================================================
//      start calculate
//================================================================


//--------- E------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        E0 <= 0 ;
        E1 <=0 ;
        E2 <=0 ;
        E3 <=0 ;
        E4 <=0 ;
        E5 <=0 ;
        E6 <=0 ;
        E7 <=0 ;
    end
    else
    begin
        if (in_valid)
        begin
            E0 <= OUT_N ;
            E1 <= OUT_N ;
            E2 <= OUT_N ;
            E3 <= OUT_N ;
            E4 <= OUT_N ;
            E5 <= OUT_N ;
            E6 <= OUT_N ;
            E7 <= OUT_N ;
        end
        else if (current_state==IDLE)
        begin
            E0 <= 0 ;
            E1 <=0 ;
            E2 <=0 ;
            E3 <=0 ;
            E4 <=0 ;
            E5 <=0 ;
            E6 <=0 ;
            E7 <=0 ;
        end
    end

end
//--------- D0 ----------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        D0 <= 0;
    end
    else
    begin
        if (cnt==1 && in_valid)
        begin
            D0 <= 1;
        end
        else if (current_state==STATE1)
        begin
            D0 <= D0 + 1 ;
        end
    end
end
//--------------0------------------------------------------
integer j;
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        A0 <= 0;
        B0 <= 0;
        M[0] <= 0;
    end
    else
    begin
        if (next_state==STATE1 || next_state==STATE2)
        begin
            if(cnt==0)
            begin
                B0 <= in_c ;
                A0 <= 1;
            end
            else if (cnt==1)
                A0 <= 1;

            else if (D0 < OUT_D )
                A0 <= anw0;

            else if (D0 == OUT_D )
                M[0] <= anw0;

            else
                M[0] <= M[0] ;
        end
    end
end


//--------- D1 ----------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        D1 <= 0;
    end
    else
    begin
        if (cnt==1)
        begin
            D1 <= 1;
        end
        else if (current_state==STATE1 || current_state==STATE2)
        begin
            D1 <= D1 + 1 ;
        end
    end
end
//--------------1------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        A1 <= 0;
        M[1] <= 0;
    end
    else
    begin
        if (current_state==STATE1)
        begin
            if(cnt==1)
            begin
                B1 <= in_c;
                A1 <= 1;
            end
            else if (D1<OUT_D )
                A1 <= anw1;

            else if (D1==OUT_D )
                M[1] <= anw1;

            else
                M[1] <= M[1];
        end
    end
end


//--------- D2 ----------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        D2 <= 0;
    end
    else
    begin
        if (cnt==2)
        begin
            D2 <= 1;
        end
        else if (current_state==STATE1 || current_state==STATE2)
        begin
            D2 <= D2 + 1 ;
        end
    end
end
//--------------2------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        A2 <= 0;
        M[2] <= 0;
    end
    else
    begin
        if (current_state==STATE1 || current_state==STATE2)
        begin
            if(cnt==2)
            begin
                B2 <= in_c;
                A2 <= 1;
            end
            else if (D2<OUT_D )
            begin
                A2 <= anw2;
            end
            else if (D2==OUT_D )
            begin
                M[2] <= anw2;
            end
        end
    end
end


//--------- D3 ----------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        D3 <= 0;
    end
    else
    begin
        if (cnt==3)
        begin
            D3 <= 1;
        end
        else if (current_state==STATE1 || current_state==STATE2)
        begin
            D3 <= D3 + 1 ;
        end
    end
end
//--------------3------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        A3 <= 0;
        M[3] <= 0;
    end
    else
    begin
        if (current_state==STATE1 || current_state==STATE2)
        begin
            if(cnt==3)
            begin
                B3 <= in_c;
                A3 <= 1;
            end
            else if (D3<OUT_D )
            begin
                A3 <= anw3;
            end
            else if (D3==OUT_D )
            begin
                M[3] <= anw3;
            end
        end
    end
end


//--------- D4 ----------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        D4 <= 0;
    end
    else
    begin
        if (cnt==4)
        begin
            D4 <= 1;
        end
        else if (current_state==STATE1 || current_state==STATE2)
        begin
            D4 <= D4 + 1 ;
        end
    end
end
//--------------4------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        A4 <= 0;
        M[4] <= 0;
    end
    else
    begin
        if (current_state==STATE1 || current_state==STATE2)
        begin
            if(cnt==4)
            begin
                B4 <= in_c;
                A4 <= 1;
            end
            else if (D4<OUT_D )
            begin
                A4 <= anw4;
            end
            else if (D4==OUT_D )
            begin
                M[4] <= anw4;
            end
        end
    end
end


//--------- D5 ----------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        D5 <= 0;
    end
    else
    begin
        if (cnt==5)
        begin
            D5 <= 1;
        end
        else if (current_state==STATE1 || current_state==STATE2)
        begin
            D5 <= D5 + 1 ;
        end
    end
end
//--------------5------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        A5 <= 0;
        M[5] <= 0;
    end
    else
    begin
        if (current_state==STATE1 || current_state==STATE2)
        begin
            if(cnt==5)
            begin
                B5 <= in_c;
                A5 <= 1;
            end
            else if (D5<OUT_D )
                A5 <= anw5;

            else if (D5==OUT_D )
                M[5] <= anw5;

            else
                M[5] <= M[5];
        end
    end
end


//--------- D6 ----------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        D6 <= 0;
    end
    else
    begin
        if (cnt==6)
        begin
            D6 <= 1;
        end
        else if (current_state==STATE1 || current_state==STATE2)
        begin
            D6 <= D6 + 1 ;
        end
    end
end
//--------------6------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        A6 <= 0;
        M[6] <= 0;
    end
    else
    begin
        if (current_state==STATE1 || current_state==STATE2)
        begin
            if(cnt==6)
            begin
                B6 <= in_c;
                A6 <= 1;
            end

            else if (D6<OUT_D )
                A6 <= anw6;

            else if (D6==OUT_D )
                M[6] <= anw6;

            else
                M[6] <= M[6];
        end
    end
end



//--------- D7 ----------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        D7 <= 0;
    end
    else
    begin
        if (cnt==7)
        begin
            D7 <= 1;
        end
        else if (current_state==STATE1 || current_state==STATE2)
        begin
            D7 <= D7 + 1 ;
        end
    end
end
//--------------7------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        A7 <= 0;
        M[7] <= 0;
    end
    else
    begin
        if (current_state==STATE1 || current_state==STATE2)
        begin
            if(cnt==7)
            begin
                B7 <= in_c;
                A7 <= 1;
            end
            else if (D7 < OUT_D )
                A7 <= anw7;

            else if (D7 == OUT_D )
                M[7] <= anw7;

            else
                M[7] <= M[7] ;
        end
    end
end



//================================================================
//       OUTPUT
//================================================================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        out_valid <= 0;
        out_m <= 0;
    end
    else
    begin
        if (current_state==IDLE)
        begin
            out_valid <= 0;
            out_m <= 0;
        end
        else if (current_state==STATE2)
        begin
            out_valid <= 1;
            out_m <= M[cnt2];
        end
    end
end

always @(*)
begin
    anw0 = (A0*B0)%E0 ;
    anw1 = (A1*B1)%E1 ;
    anw2 = (A2*B2)%E2 ;
    anw3 = (A3*B3)%E3 ;
    anw4 = (A4*B4)%E4 ;
    anw5 = (A5*B5)%E5 ;
    anw6 = (A6*B6)%E6 ;
    anw7 = (A7*B7)%E7 ;
end


endmodule
