
// synopsys translate_off
// `include "/usr/synthesis/dw/sim_ver/DW_fp_mult.v"
// `include "/usr/synthesis/dw/sim_ver/DW_fp_sum3.v"
// `include "/usr/synthesis/dw/sim_ver/DW_fp_add.v"

// synopsys translate_on
module NN(
           // Input signals
           clk,
           rst_n,
           in_valid_i,
           in_valid_k,
           in_valid_o,
           Image1,
           Image2,
           Image3,
           Kernel1,
           Kernel2,
           Kernel3,
           Opt,
           // Output signals
           out_valid,
           out
       );

//---------------------------------------------------------------------
//   PARAMETER
//---------------------------------------------------------------------

// IEEE floating point paramenters
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 1;
parameter inst_arch = 2;

//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION
//---------------------------------------------------------------------
input  clk, rst_n, in_valid_i, in_valid_k, in_valid_o;
input [inst_sig_width+inst_exp_width:0] Image1, Image2, Image3;
input [inst_sig_width+inst_exp_width:0] Kernel1, Kernel2, Kernel3;
input [1:0] Opt;
output reg	out_valid;
output reg [inst_sig_width+inst_exp_width:0] out;

//================================================//
// Genvar & Parameters & Integer Declaration
// ===============================================================
// state
parameter IDLE         = 3'd0;
parameter STATE1_CALC  = 3'd1;
parameter STATE2_      = 3'd2;
parameter STATE3_OUT   = 3'd3;

// ===============================================================
// Wire & Reg Declaration
// ===============================================================
reg [9:0] BigCnt;
reg [3:0] cnt;//counter
reg [2:0] cnt_out;//counter
reg [1:0] cnt_row,cnt_col;//counter

reg [5:0] cntforlong_A,cnt_output;
reg [2:0] current_state,next_state;//current & neit state
reg [1:0] option;
reg [1:0] KernelWhat;
reg [2:0] storeTO;
reg [0:0] flag_ifinish,BeginOUT, flag_cnt , Fincal ,switchS , B1,B2,Fi;
reg [2:0] ROW,COL;
//store image
reg [31:0] image1 [0:5] [0:5];
reg [31:0] image2 [0:5] [0:5];
reg [31:0] image3 [0:5] [0:5];
//store kernel
reg [31:0] kernel1_4[1:3] [1:3];
reg [31:0] kernel1_1[1:3] [1:3];
reg [31:0] kernel1_2[1:3] [1:3];
reg [31:0] kernel1_3[1:3] [1:3];
reg [31:0] kernel2_4[1:3] [1:3];
reg [31:0] kernel2_1[1:3] [1:3];
reg [31:0] kernel2_2[1:3] [1:3];
reg [31:0] kernel2_3[1:3] [1:3];
reg [31:0] kernel3_4[1:3] [1:3];
reg [31:0] kernel3_1[1:3] [1:3];
reg [31:0] kernel3_2[1:3] [1:3];
reg [31:0] kernel3_3[1:3] [1:3];

reg [31:0] result1 [1:2] [1:4];
reg [31:0] result1_d [1:2] [1:4];
reg [31:0] result2 [1:2] [1:4];
reg [31:0] result2_d [1:2] [1:4];
reg [31:0] result3 [1:2] [1:4];
reg [31:0] result3_d [1:2] [1:4];
reg [31:0] result4 [1:2] [1:4];
reg [31:0] result4_d [1:2] [1:4];

reg [31:0] Outlong [1:64];
reg [31:0] Outlong2 [1:64];


//-------------exponential----------------------------------------------------
reg [31:0] exp_in_1,exp_in_2;
wire [31:0] exp_out_1 , exp_out_2;
// //------------multiplier---------------------------------------------------
reg  [31:0] M1_inA,M1_inB,M2_inA,M2_inB,M3_inA,M3_inB,M4_inA,M4_inB,M5_inA,M5_inB,M6_inA,M6_inB,M7_inA,M7_inB,M8_inA,M8_inB,M9_inA,M9_inB,M10_inA,M10_inB,
     M11_inA,M11_inB,M12_inA,M12_inB,M13_inA,M13_inB,M14_inA,M14_inB,M15_inA,M15_inB,M16_inA,M16_inB,M17_inA,M17_inB,M18_inA,M18_inB,M19_inA,M19_inB,M20_inA,
     M20_inB,M21_inA,M21_inB,M22_inA,M22_inB,M23_inA,M23_inB,M24_inA,M24_inB;

wire [31:0] M1_O, M2_O, M3_O, M4_O, M5_O, M6_O, M7_O, M8_O, M9_O, M10_O, M11_O, M12_O,M13_O, M14_O, M15_O,
     M16_O, M17_O, M18_O, M19_O, M20_O, M21_O, M22_O, M23_O, M24_O;

// //------------adder----------------------------------------------------------
reg  [31:0] A1_inA , A1_inB ,
     A2_inA , A2_inB ,
     A3_inA , A3_inB ,
     A4_inA , A4_inB ,
     A5_inA , A5_inB ,
     A6_inA , A6_inB ,
     A7_inA , A7_inB ,
     A8_inA , A8_inB ,
     A9_inA , A9_inB ;

wire [31:0] A1_O, A2_O, A3_O, A4_O, A5_O, A6_O, A7_O, A8_O, A9_O;

// //------------diver-------------------------------------------------------
reg [31:0] div_ina , div_inb , sub_ina , sub_inb;
wire [31:0] div_out , sub_out;

// //------------Summer------------------------------------------------------
reg  [31:0] S1_inA ,S1_inB,S1_inC,
     S2_inA,S2_inB,S2_inC,
     S3_inA,S3_inB,S3_inC,
     S4_inA,S4_inB,S4_inC,
     S5_inA,S5_inB,S5_inC,
     S6_inA,S6_inB,S6_inC,
     S7_inA,S7_inB,S7_inC,
     S8_inA,S8_inB,S8_inC;

wire [31:0] S1_O, S2_O , S3_O , S4_O , S5_O , S6_O , S7_O , S8_O ;
//-------Sub-----------------------*------------------------------------------------
DW_fp_sub #(23, 8, 1)
          sub1 ( .a(sub_ina), .b(sub_inb), .rnd(3'b000), .z(sub_out) );

//-------Diver---------------------------------------------------------------------
DW_fp_div #(23, 8, 1, 1)
          div1 ( .a(div_ina), .b(div_inb), .rnd(3'b000), .z(div_out) );
//--------Exp------------------------------------------------------------------------------
DW_fp_exp #(23, 8, 1, 1)
          exp1 ( .a(exp_in_1), .z(exp_out_1) ),
          exp2 ( .a(exp_in_2), .z(exp_out_2) );
//--------Sum3----------------------------------------------------------------------------------
DW_fp_sum3 #(23,8,1)  S1( .a(S1_inA), .b(S1_inB), .c(S1_inC), .z(S1_O), .rnd(3'b000) );
DW_fp_sum3 #(23,8,1)   S2( .a(S2_inA),.b(S2_inB),.c(S2_inC),.z(S2_O),.rnd(3'b000) );
DW_fp_sum3 #(23,8,1)   S3( .a(S3_inA),.b(S3_inB),.c(S3_inC),.z(S3_O),.rnd(3'b000) );
DW_fp_sum3 #(23,8,1)   S4( .a(S4_inA),.b(S4_inB),.c(S4_inC),.z(S4_O),.rnd(3'b000) );
DW_fp_sum3 #(23,8,1)   S5( .a(S5_inA),.b(S5_inB),.c(S5_inC),.z(S5_O),.rnd(3'b000) );
DW_fp_sum3 #(23,8,1)   S6( .a(S6_inA),.b(S6_inB),.c(S6_inC),.z(S6_O),.rnd(3'b000) );
DW_fp_sum3 #(23,8,1)   S7( .a(S7_inA),.b(S7_inB),.c(S7_inC),.z(S7_O),.rnd(3'b000) );
DW_fp_sum3 #(23,8,1)   S8( .a(S8_inA),.b(S8_inB),.c(S8_inC),.z(S8_O),.rnd(3'b000) );


//-------multplier------------------------------------------------------------------------------
DW_fp_mult #(23,8,1) mult1   ( .a(M1_inA),.b(M1_inB),.rnd(3'b000),.z(M1_O) );
DW_fp_mult #(23,8,1) mult2   ( .a(M2_inA),.b(M2_inB),.rnd(3'b000),.z(M2_O) );
DW_fp_mult #(23,8,1) mult3   ( .a(M3_inA),.b(M3_inB),.rnd(3'b000),.z(M3_O) );
DW_fp_mult #(23,8,1) mult4   ( .a(M4_inA),.b(M4_inB),.rnd(3'b000),.z(M4_O) );
DW_fp_mult #(23,8,1) mult5   ( .a(M5_inA),.b(M5_inB),.rnd(3'b000),.z(M5_O) );
DW_fp_mult #(23,8,1) mult6   ( .a(M6_inA),.b(M6_inB),.rnd(3'b000),.z(M6_O) );
DW_fp_mult #(23,8,1) mult7   ( .a(M7_inA),.b(M7_inB),.rnd(3'b000),.z(M7_O) );
DW_fp_mult #(23,8,1) mult8   ( .a(M8_inA),.b(M8_inB),.rnd(3'b000),.z(M8_O) );
DW_fp_mult #(23,8,1) mult9   ( .a(M9_inA),.b(M9_inB),.rnd(3'b000),.z(M9_O) );
DW_fp_mult #(23,8,1) mult10  ( .a(M10_inA),.b(M10_inB),.rnd(3'b000),.z(M10_O) );
DW_fp_mult #(23,8,1) mult11  ( .a(M11_inA),.b(M11_inB),.rnd(3'b000),.z(M11_O) );
DW_fp_mult #(23,8,1) mult12  ( .a(M12_inA),.b(M12_inB),.rnd(3'b000),.z(M12_O) );
DW_fp_mult #(23,8,1) mult13  ( .a(M13_inA),.b(M13_inB),.rnd(3'b000),.z(M13_O) );
DW_fp_mult #(23,8,1) mult14  ( .a(M14_inA),.b(M14_inB),.rnd(3'b000),.z(M14_O) );
DW_fp_mult #(23,8,1) mult15  ( .a(M15_inA),.b(M15_inB),.rnd(3'b000),.z(M15_O) );
DW_fp_mult #(23,8,1) mult16  ( .a(M16_inA),.b(M16_inB),.rnd(3'b000),.z(M16_O) );
DW_fp_mult #(23,8,1) mult17  ( .a(M17_inA),.b(M17_inB),.rnd(3'b000),.z(M17_O) );
DW_fp_mult #(23,8,1) mult18  ( .a(M18_inA),.b(M18_inB),.rnd(3'b000),.z(M18_O) );
DW_fp_mult #(23,8,1) mult19  ( .a(M19_inA),.b(M19_inB),.rnd(3'b000),.z(M19_O) );
DW_fp_mult #(23,8,1) mult20  ( .a(M20_inA),.b(M20_inB),.rnd(3'b000),.z(M20_O) );
DW_fp_mult #(23,8,1) mult21  ( .a(M21_inA),.b(M21_inB),.rnd(3'b000),.z(M21_O) );
DW_fp_mult #(23,8,1) mult22  ( .a(M22_inA),.b(M22_inB),.rnd(3'b000),.z(M22_O) );
DW_fp_mult #(23,8,1) mult23  ( .a(M23_inA),.b(M23_inB),.rnd(3'b000),.z(M23_O) );
DW_fp_mult #(23,8,1) mult24  ( .a(M24_inA),.b(M24_inB),.rnd(3'b000),.z(M24_O) );

//-------adder---------------------------------------------------------------------------
DW_fp_add  #(23,8,1)
           A1  ( .a(A1_inA),.b(A1_inB),.z(A1_O),.rnd(3'b000) ),
           A2  ( .a(A2_inA),.b(A2_inB),.z(A2_O),.rnd(3'b000) ),
           A3  ( .a(A3_inA),.b(A3_inB),.z(A3_O),.rnd(3'b000) ),
           A4  ( .a(A4_inA),.b(A4_inB),.z(A4_O),.rnd(3'b000) ),
           A5  ( .a(A5_inA),.b(A5_inB),.z(A5_O),.rnd(3'b000) ),
           A6  ( .a(A6_inA),.b(A6_inB),.z(A6_O),.rnd(3'b000) ),
           A7  ( .a(A7_inA),.b(A7_inB),.z(A7_O),.rnd(3'b000) ),
           A8  ( .a(A8_inA),.b(A8_inB),.z(A8_O),.rnd(3'b000) ),
           A9  ( .a(A9_inA),.b(A9_inB),.z(A9_O),.rnd(3'b000) );

//---------Instance------------------------------------------------


// ===============================================================
// Finite State Machine
// ===============================================================
/*-----------------------------------------------------------------------------------
  CCCCCCCC  UU      UU  RRRRRRRR    RRRRRRRR    EEEEEEEEEE  NN      NN  TTTTTTTTTT
 CC         UU      UU  RR      RR  RR      RR  EE          NNNN    NN      TT
CC          UU      UU  RRRRRRRRR   RRRRRRRRR   EEEEEEEEE   NN  NN  NN      TT
 CC          UU    UU   RR   RRR    RR   RRR    EE          NN    NNNN      TT
  CCCCCCCC    UUUUUU    RR     RRR  RR     RRR  EEEEEEEEEE  NN      NN      TT
*///---------------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n) // rst_n=0(idle)  rst_n=1(neit state)
        current_state <= IDLE;
    else
        current_state <= next_state;
end
/* -----------------------------------------------------------------------------------
NN      NN  EEEEEEEEEE  XX      XX  TTTTTTTTTT
NNNN    NN  EE           XXX  XXX       TT
NN  NN  NN  EEEEEEEEE     XXXXXX        TT
NN    NNNN  EE           XXX  XXX       TT
NN      NN  EEEEEEEEEE  XX      XX      TT
*///---------------------------------------------------------------------------------
always @(*)
begin
    case (current_state) //Current_state
        IDLE:
        begin
            if (in_valid_k)
                next_state = STATE1_CALC;
            else
                next_state = IDLE;
        end

        STATE1_CALC: //GET THE MAP
        begin
            if ( Fi )
            begin
                next_state = IDLE;
            end
            else
                next_state = STATE1_CALC;
        end

        default:
            next_state = IDLE;
    endcase
end

always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        Fi <= 0;
    end
    else
    begin
        if (current_state==STATE1_CALC)
        begin
            if (BigCnt>99 && out_valid==0)
            begin
                Fi <= 1;
            end
        end
        else if (current_state==IDLE)
        begin
            Fi <= 0;
        end
    end
end




/*-----------------------------------------------------------------------------------
        IIIIIIII  NN      NN  PPPPPPPP  UU      UU TTTTTTTTTT
           II     NNNN    NN  PP     PP UU      UU     TT
           II     NN  NN  NN  PP     PP UU      UU     TT
           II     NN    NNNN  PPPPPPPP   UU    UU      TT
        IIIIIIII  NN      NN  PP          UUUUUU       TT
*///---------------------------------------------------------------------------------
integer i,j;
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        flag_ifinish <= 0;
        option <= 0 ;
        for ( i=0 ; i<=5;i=i+1 )
        begin
            for ( j=0 ; j<=5 ; j=j+1 )
            begin
                image1[i][j]  <=0 ;
                image2[i][j]  <=0 ;
                image3[i][j]  <=0 ;
            end
        end
    end
    else
    begin
        if ( in_valid_o )
        begin
            option <= Opt ;
        end
        else if ( in_valid_i )
        begin
            image1[4][4] <= Image1;
            image2[4][4] <= Image2;
            image3[4][4] <= Image3;
            for ( i = 1 ; i<=4 ; i=i+1 )
            begin
                for ( j = 2 ; j<=4 ; j=j+1 )
                begin
                    image1[i][j-1] <= image1[i][j];
                    image1[j-1][4] <= image1[j][1];

                    image2[i][j-1] <= image2[i][j];
                    image2[j-1][4] <= image2[j][1];

                    image3[i][j-1] <= image3[i][j];
                    image3[j-1][4] <= image3[j][1];
                end
                flag_ifinish <= 1 ;
            end
        end

        else if (BigCnt==100)
        begin
            flag_ifinish <=0;
            // option <= 0 ;
            for ( i=0 ; i<=5;i=i+1 )
            begin
                for ( j=0 ; j<=5 ; j=j+1 )
                begin
                    image1[i][j]  <=0 ;
                    image2[i][j]  <=0 ;
                    image3[i][j]  <=0 ;
                end
            end
        end

        else if (in_valid_i==0 && flag_ifinish==1)
        begin
            if (option==0 || option==1)
            begin
                for ( i= 1;i<=4;i=i+1 )
                begin
                    image1[0][i] <= image1[1][i];
                    image1[i][0] <= image1[i][1];
                    image1[5][i] <= image1[4][i];
                    image1[i][5] <= image1[i][4];
                    image1[0][0] <= image1[1][1];
                    image1[0][5] <= image1[1][4];
                    image1[5][0] <= image1[4][1];
                    image1[5][5] <= image1[4][4];

                    image2[0][i] <= image2[1][i];
                    image2[i][0] <= image2[i][1];
                    image2[5][i] <= image2[4][i];
                    image2[i][5] <= image2[i][4];
                    image2[0][0] <= image2[1][1];
                    image2[0][5] <= image2[1][4];
                    image2[5][0] <= image2[4][1];
                    image2[5][5] <= image2[4][4];


                    image3[0][i] <= image3[1][i];
                    image3[i][0] <= image3[i][1];
                    image3[5][i] <= image3[4][i];
                    image3[i][5] <= image3[i][4];
                    image3[0][0] <= image3[1][1];
                    image3[0][5] <= image3[1][4];
                    image3[5][0] <= image3[4][1];
                    image3[5][5] <= image3[4][4];
                end
            end
        end

    end
end


/*---------------------------------------------------------------------------------------------
      KK    KKK  EEEEEEEEEE  RRRRRRRR    NN      NN  EEEEEEEEEE LL                     44
      KK   KKK   EE          RR      RR  NNNN    NN  EE         LL                  44 44
      KKKKKK     EEEEEEEEE   RRRRRRRRR   NN  NN  NN  EEEEEEEEE  LL                44   44
      KK   KKK   EE          RR   RRR    NN    NNNN  EE         LL               44444444444
      KK     KKK EEEEEEEEEE  RR     RRR  NN      NN  EEEEEEEEEE LLLLLLLLL ==========   44
  *///-----------------------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        for ( i=1 ; i<=3;i=i+1 )
        begin
            for ( j=1 ; j<=3 ; j=j+1 )
            begin
                kernel1_4[i][j] <=0 ;
                kernel2_4[i][j] <=0 ;
                kernel3_4[i][j] <=0 ;
            end
        end
    end

    else if (in_valid_k)
    begin
        kernel1_4[3][3] <= Kernel1;
        kernel2_4[3][3] <= Kernel2;
        kernel3_4[3][3] <= Kernel3;
        for ( i=1 ; i<=3 ; i=i+1 )
        begin
            for ( j=2 ; j<=3 ; j=j+1 )
            begin
                kernel1_4[i][j-1] <= kernel1_4[i][j];
                kernel1_4[j-1][3] <= kernel1_4[j][1];

                kernel2_4[i][j-1] <= kernel2_4[i][j];
                kernel2_4[j-1][3] <= kernel2_4[j][1];

                kernel3_4[i][j-1] <= kernel3_4[i][j];
                kernel3_4[j-1][3] <= kernel3_4[j][1];
            end
        end
    end
    else if (BigCnt==100)
    begin
        for ( i=1 ; i<=3;i=i+1 )
        begin
            for ( j=1 ; j<=3 ; j=j+1 )
            begin
                kernel1_4[i][j] <=0 ;
                kernel2_4[i][j] <=0 ;
                kernel3_4[i][j] <=0 ;
            end
        end
    end
end
/*---------------------------------------------------------------------------------------------------------------------
     KK    KKK  EEEEEEEEEE  RRRRRRRR    NN      NN  EEEEEEEEEE LL                       11       222222      33333
     KK   KKK   EE          RR      RR  NNNN    NN  EE         LL                     1 11      2      2    3     3
     KKKKKK     EEEEEEEEE   RRRRRRRRR   NN  NN  NN  EEEEEEEEE  LL                       11            2         333
     KK   KKK   EE          RR   RRR    NN    NNNN  EE         LL                       11           2      3     3
     KK     KKK EEEEEEEEEE  RR     RRR  NN      NN  EEEEEEEEEE LLLLLLLLL ==========  11111111   222222222    33333 
 *///--------------------------------------------------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        for ( i=1 ; i<=3;i=i+1 )
        begin
            for ( j=1 ; j<=3 ; j=j+1 )
            begin
                kernel1_1[i][j] <=0 ;
                kernel2_1[i][j] <=0 ;
                kernel3_1[i][j] <=0 ;
                kernel1_2[i][j] <=0 ;
                kernel2_2[i][j] <=0 ;
                kernel3_2[i][j] <=0 ;
                kernel1_3[i][j] <=0 ;
                kernel2_3[i][j] <=0 ;
                kernel3_3[i][j] <=0 ;
            end
        end
    end
    else
    begin
        if (in_valid_k==1)
        begin
            if (cnt==5)
            begin
                for ( i=1 ; i<=3 ; i=i+1 )
                begin
                    for ( j=1 ; j<=3 ; j=j+1 )
                    begin
                        kernel1_3[i][j] <= kernel1_4[i][j];
                        kernel2_3[i][j] <= kernel2_4[i][j];
                        kernel3_3[i][j] <= kernel3_4[i][j];

                        kernel1_2[i][j] <= kernel1_3[i][j];
                        kernel2_2[i][j] <= kernel2_3[i][j];
                        kernel3_2[i][j] <= kernel3_3[i][j];

                        kernel1_1[i][j] <= kernel1_2[i][j];
                        kernel2_1[i][j] <= kernel2_2[i][j];
                        kernel3_1[i][j] <= kernel3_2[i][j];
                    end
                end
            end
        end
    end
end

//-------------KernelWhat------------------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        KernelWhat<=0;
    end
    else
    begin
        if (BigCnt==44)
        begin
            KernelWhat<=1;
        end
        else if (BigCnt==53)
        begin
            KernelWhat<=2;
        end
        else if (BigCnt==62)
        begin
            KernelWhat<=3;
        end
        // else if (BigCnt==71)
        // begin
        //     KernelWhat<=4;
        // end
        else if (current_state==IDLE)
        begin
            KernelWhat <=0 ;
        end
    end

end


/*----------------------------------------------------------------------------------------------------------
         IIIIIIII  MM      MM      AAA                       KK    KKK  EEEEEEEEEE  RRRRRRRR  
            II     MMM    MMM     AA AA         XX  XX       KK   KKK   EE          RR      RR
            II     MM M  M MM    AA   AA          XX         KKKKKK     EEEEEEEEE   RRRRRRRRR 
            II     MM  MM  MM   AAAAAAAAA       XX  XX       KK   KKK   EE          RR   RRR  
         IIIIIIII  MM      MM  AA       AA                   KK     KKK EEEEEEEEEE  RR     RRR
  *///-------------------------------------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        M1_inA <= 0;
        M2_inA <= 0;
        M3_inA <= 0;
        M4_inA <= 0;
        M5_inA <= 0;
        M6_inA <= 0;
        M7_inA <= 0;
        M8_inA <= 0;
        M1_inB <= 0;
        M2_inB <= 0;
        M3_inB <= 0;
        M4_inB <= 0;
        M5_inB <= 0;
        M6_inB <= 0;
        M7_inB <= 0;
        M8_inB <= 0;
        M9_inA <= 0;
        M10_inA<= 0;
        M11_inA<= 0;
        M12_inA<= 0;
        M13_inA<= 0;
        M14_inA<= 0;
        M15_inA<= 0;
        M16_inA<= 0;
        M9_inB <= 0;
        M10_inB<= 0;
        M11_inB<= 0;
        M12_inB<= 0;
        M13_inB<= 0;
        M14_inB<= 0;
        M15_inB<= 0;
        M16_inB<= 0;
        M17_inA<= 0;
        M18_inA<= 0;
        M19_inA<= 0;
        M20_inA<= 0;
        M21_inA<= 0;
        M22_inA<= 0;
        M23_inA<= 0;
        M24_inA<= 0;
        M17_inB<= 0;
        M18_inB<= 0;
        M19_inB<= 0;
        M20_inB<= 0;
        M21_inB<= 0;
        M22_inB<= 0;
        M23_inB<= 0;
        M24_inB<= 0;
        S1_inA <= 0;
        S2_inA <= 0;
        S3_inA <= 0;
        S4_inA <= 0;
        S5_inA <= 0;
        S6_inA <= 0;
        S7_inA <= 0;
        S8_inA <= 0;
        S1_inB <= 0;
        S2_inB <= 0;
        S3_inB <= 0;
        S4_inB <= 0;
        S5_inB <= 0;
        S6_inB <= 0;
        S7_inB <= 0;
        S8_inB <= 0;
        S1_inC <= 0;
        S2_inC <= 0;
        S3_inC <= 0;
        S4_inC <= 0;
        S5_inC <= 0;
        S6_inC <= 0;
        S7_inC <= 0;
        S8_inC <= 0;
    end
    else
    begin
        if (next_state==STATE1_CALC)
        begin
            if (BigCnt<=35)
            begin
                M1_inA <= kernel1_4[3][3] ;
                M2_inA <= kernel1_4[3][3] ;
                M3_inA <= kernel1_4[3][3] ;
                M4_inA <= kernel1_4[3][3] ;
                M5_inA <= kernel1_4[3][3] ;
                M6_inA <= kernel1_4[3][3] ;
                M7_inA <= kernel1_4[3][3] ;
                M8_inA <= kernel1_4[3][3] ;

                M1_inB <= image1 [cnt_row][cnt_col];
                M2_inB <= image1 [cnt_row][cnt_col+1];
                M3_inB <= image1 [cnt_row][cnt_col+2];
                M4_inB <= image1 [cnt_row][cnt_col+3];
                M5_inB <= image1 [cnt_row+1][cnt_col];
                M6_inB <= image1 [cnt_row+1][cnt_col+1];
                M7_inB <= image1 [cnt_row+1][cnt_col+2];
                M8_inB <= image1 [cnt_row+1][cnt_col+3];

                M9_inA  <=  kernel2_4[3][3];
                M10_inA <=  kernel2_4[3][3];
                M11_inA <=  kernel2_4[3][3];
                M12_inA <=  kernel2_4[3][3];
                M13_inA <=  kernel2_4[3][3];
                M14_inA <=  kernel2_4[3][3];
                M15_inA <=  kernel2_4[3][3];
                M16_inA <=  kernel2_4[3][3];

                M9_inB <= image2  [cnt_row][cnt_col];
                M10_inB <= image2 [cnt_row][cnt_col+1];
                M11_inB <= image2 [cnt_row][cnt_col+2];
                M12_inB <= image2 [cnt_row][cnt_col+3];
                M13_inB <= image2 [cnt_row+1][cnt_col];
                M14_inB <= image2 [cnt_row+1][cnt_col+1];
                M15_inB <= image2 [cnt_row+1][cnt_col+2];
                M16_inB <= image2 [cnt_row+1][cnt_col+3];

                M17_inA <=  kernel3_4[3][3];
                M18_inA <=  kernel3_4[3][3];
                M19_inA <=  kernel3_4[3][3];
                M20_inA <=  kernel3_4[3][3];
                M21_inA <=  kernel3_4[3][3];
                M22_inA <=  kernel3_4[3][3];
                M23_inA <=  kernel3_4[3][3];
                M24_inA <=  kernel3_4[3][3];

                M17_inB <= image3 [cnt_row][cnt_col];
                M18_inB <= image3 [cnt_row][cnt_col+1];
                M19_inB <= image3 [cnt_row][cnt_col+2];
                M20_inB <= image3 [cnt_row][cnt_col+3];
                M21_inB <= image3 [cnt_row+1][cnt_col];
                M22_inB <= image3 [cnt_row+1][cnt_col+1];
                M23_inB <= image3 [cnt_row+1][cnt_col+2];
                M24_inB <= image3 [cnt_row+1][cnt_col+3];

                S1_inA <= M1_O;
                S2_inA <= M2_O;
                S3_inA <= M3_O;
                S4_inA <= M4_O;
                S5_inA <= M5_O;
                S6_inA <= M6_O;
                S7_inA <= M7_O;
                S8_inA <= M8_O;

                S1_inB <= M9_O;
                S2_inB <= M10_O;
                S3_inB <= M11_O;
                S4_inB <= M12_O;
                S5_inB <= M13_O;
                S6_inB <= M14_O;
                S7_inB <= M15_O;
                S8_inB <= M16_O;

                S1_inC <= M17_O;
                S2_inC <= M18_O;
                S3_inC <= M19_O;
                S4_inC <= M20_O;
                S5_inC <= M21_O;
                S6_inC <= M22_O;
                S7_inC <= M23_O;
                S8_inC <= M24_O;
            end
            else
            begin
                case (KernelWhat)
                    0:
                    begin
                        M1_inA <= kernel1_1[cnt_row+1][cnt_col+1] ;
                        M2_inA <= kernel1_1[cnt_row+1][cnt_col+1] ;
                        M3_inA <= kernel1_1[cnt_row+1][cnt_col+1] ;
                        M4_inA <= kernel1_1[cnt_row+1][cnt_col+1] ;
                        M5_inA <= kernel1_1[cnt_row+1][cnt_col+1] ;
                        M6_inA <= kernel1_1[cnt_row+1][cnt_col+1] ;
                        M7_inA <= kernel1_1[cnt_row+1][cnt_col+1] ;
                        M8_inA <= kernel1_1[cnt_row+1][cnt_col+1] ;

                        M1_inB <= image1 [cnt_row+2][cnt_col];
                        M2_inB <= image1 [cnt_row+2][cnt_col+1];
                        M3_inB <= image1 [cnt_row+2][cnt_col+2];
                        M4_inB <= image1 [cnt_row+2][cnt_col+3];
                        M5_inB <= image1 [cnt_row+3][cnt_col];
                        M6_inB <= image1 [cnt_row+3][cnt_col+1];
                        M7_inB <= image1 [cnt_row+3][cnt_col+2];
                        M8_inB <= image1 [cnt_row+3][cnt_col+3];

                        M9_inA  <=  kernel2_1[cnt_row+1][cnt_col+1];
                        M10_inA <=  kernel2_1[cnt_row+1][cnt_col+1];
                        M11_inA <=  kernel2_1[cnt_row+1][cnt_col+1];
                        M12_inA <=  kernel2_1[cnt_row+1][cnt_col+1];
                        M13_inA <=  kernel2_1[cnt_row+1][cnt_col+1];
                        M14_inA <=  kernel2_1[cnt_row+1][cnt_col+1];
                        M15_inA <=  kernel2_1[cnt_row+1][cnt_col+1];
                        M16_inA <=  kernel2_1[cnt_row+1][cnt_col+1];

                        M9_inB <= image2  [cnt_row+2][cnt_col];
                        M10_inB <= image2 [cnt_row+2][cnt_col+1];
                        M11_inB <= image2 [cnt_row+2][cnt_col+2];
                        M12_inB <= image2 [cnt_row+2][cnt_col+3];
                        M13_inB <= image2 [cnt_row+3][cnt_col];
                        M14_inB <= image2 [cnt_row+3][cnt_col+1];
                        M15_inB <= image2 [cnt_row+3][cnt_col+2];
                        M16_inB <= image2 [cnt_row+3][cnt_col+3];

                        M17_inA <=  kernel3_1[cnt_row+1][cnt_col+1];
                        M18_inA <=  kernel3_1[cnt_row+1][cnt_col+1];
                        M19_inA <=  kernel3_1[cnt_row+1][cnt_col+1];
                        M20_inA <=  kernel3_1[cnt_row+1][cnt_col+1];
                        M21_inA <=  kernel3_1[cnt_row+1][cnt_col+1];
                        M22_inA <=  kernel3_1[cnt_row+1][cnt_col+1];
                        M23_inA <=  kernel3_1[cnt_row+1][cnt_col+1];
                        M24_inA <=  kernel3_1[cnt_row+1][cnt_col+1];

                        M17_inB <= image3 [cnt_row+2][cnt_col];
                        M18_inB <= image3 [cnt_row+2][cnt_col+1];
                        M19_inB <= image3 [cnt_row+2][cnt_col+2];
                        M20_inB <= image3 [cnt_row+2][cnt_col+3];
                        M21_inB <= image3 [cnt_row+3][cnt_col];
                        M22_inB <= image3 [cnt_row+3][cnt_col+1];
                        M23_inB <= image3 [cnt_row+3][cnt_col+2];
                        M24_inB <= image3 [cnt_row+3][cnt_col+3];

                        S1_inA <= M1_O;
                        S2_inA <= M2_O;
                        S3_inA <= M3_O;
                        S4_inA <= M4_O;
                        S5_inA <= M5_O;
                        S6_inA <= M6_O;
                        S7_inA <= M7_O;
                        S8_inA <= M8_O;

                        S1_inB <= M9_O;
                        S2_inB <= M10_O;
                        S3_inB <= M11_O;
                        S4_inB <= M12_O;
                        S5_inB <= M13_O;
                        S6_inB <= M14_O;
                        S7_inB <= M15_O;
                        S8_inB <= M16_O;

                        S1_inC <= M17_O;
                        S2_inC <= M18_O;
                        S3_inC <= M19_O;
                        S4_inC <= M20_O;
                        S5_inC <= M21_O;
                        S6_inC <= M22_O;
                        S7_inC <= M23_O;
                        S8_inC <= M24_O;
                    end
                    1:
                    begin
                        M1_inA <= kernel1_2[cnt_row+1][cnt_col+1] ;
                        M2_inA <= kernel1_2[cnt_row+1][cnt_col+1] ;
                        M3_inA <= kernel1_2[cnt_row+1][cnt_col+1] ;
                        M4_inA <= kernel1_2[cnt_row+1][cnt_col+1] ;
                        M5_inA <= kernel1_2[cnt_row+1][cnt_col+1] ;
                        M6_inA <= kernel1_2[cnt_row+1][cnt_col+1] ;
                        M7_inA <= kernel1_2[cnt_row+1][cnt_col+1] ;
                        M8_inA <= kernel1_2[cnt_row+1][cnt_col+1] ;

                        M1_inB <= image1 [cnt_row+2][cnt_col];
                        M2_inB <= image1 [cnt_row+2][cnt_col+1];
                        M3_inB <= image1 [cnt_row+2][cnt_col+2];
                        M4_inB <= image1 [cnt_row+2][cnt_col+3];
                        M5_inB <= image1 [cnt_row+3][cnt_col];
                        M6_inB <= image1 [cnt_row+3][cnt_col+1];
                        M7_inB <= image1 [cnt_row+3][cnt_col+2];
                        M8_inB <= image1 [cnt_row+3][cnt_col+3];

                        M9_inA  <=  kernel2_2[cnt_row+1][cnt_col+1];
                        M10_inA <=  kernel2_2[cnt_row+1][cnt_col+1];
                        M11_inA <=  kernel2_2[cnt_row+1][cnt_col+1];
                        M12_inA <=  kernel2_2[cnt_row+1][cnt_col+1];
                        M13_inA <=  kernel2_2[cnt_row+1][cnt_col+1];
                        M14_inA <=  kernel2_2[cnt_row+1][cnt_col+1];
                        M15_inA <=  kernel2_2[cnt_row+1][cnt_col+1];
                        M16_inA <=  kernel2_2[cnt_row+1][cnt_col+1];

                        M9_inB <= image2  [cnt_row+2][cnt_col];
                        M10_inB <= image2 [cnt_row+2][cnt_col+1];
                        M11_inB <= image2 [cnt_row+2][cnt_col+2];
                        M12_inB <= image2 [cnt_row+2][cnt_col+3];
                        M13_inB <= image2 [cnt_row+3][cnt_col];
                        M14_inB <= image2 [cnt_row+3][cnt_col+1];
                        M15_inB <= image2 [cnt_row+3][cnt_col+2];
                        M16_inB <= image2 [cnt_row+3][cnt_col+3];

                        M17_inA <=  kernel3_2[cnt_row+1][cnt_col+1];
                        M18_inA <=  kernel3_2[cnt_row+1][cnt_col+1];
                        M19_inA <=  kernel3_2[cnt_row+1][cnt_col+1];
                        M20_inA <=  kernel3_2[cnt_row+1][cnt_col+1];
                        M21_inA <=  kernel3_2[cnt_row+1][cnt_col+1];
                        M22_inA <=  kernel3_2[cnt_row+1][cnt_col+1];
                        M23_inA <=  kernel3_2[cnt_row+1][cnt_col+1];
                        M24_inA <=  kernel3_2[cnt_row+1][cnt_col+1];

                        M17_inB <= image3 [cnt_row+2][cnt_col];
                        M18_inB <= image3 [cnt_row+2][cnt_col+1];
                        M19_inB <= image3 [cnt_row+2][cnt_col+2];
                        M20_inB <= image3 [cnt_row+2][cnt_col+3];
                        M21_inB <= image3 [cnt_row+3][cnt_col];
                        M22_inB <= image3 [cnt_row+3][cnt_col+1];
                        M23_inB <= image3 [cnt_row+3][cnt_col+2];
                        M24_inB <= image3 [cnt_row+3][cnt_col+3];

                        S1_inA <= M1_O;
                        S2_inA <= M2_O;
                        S3_inA <= M3_O;
                        S4_inA <= M4_O;
                        S5_inA <= M5_O;
                        S6_inA <= M6_O;
                        S7_inA <= M7_O;
                        S8_inA <= M8_O;

                        S1_inB <= M9_O;
                        S2_inB <= M10_O;
                        S3_inB <= M11_O;
                        S4_inB <= M12_O;
                        S5_inB <= M13_O;
                        S6_inB <= M14_O;
                        S7_inB <= M15_O;
                        S8_inB <= M16_O;

                        S1_inC <= M17_O;
                        S2_inC <= M18_O;
                        S3_inC <= M19_O;
                        S4_inC <= M20_O;
                        S5_inC <= M21_O;
                        S6_inC <= M22_O;
                        S7_inC <= M23_O;
                        S8_inC <= M24_O;
                    end
                    2:
                    begin
                        M1_inA <= kernel1_3[cnt_row+1][cnt_col+1] ;
                        M2_inA <= kernel1_3[cnt_row+1][cnt_col+1] ;
                        M3_inA <= kernel1_3[cnt_row+1][cnt_col+1] ;
                        M4_inA <= kernel1_3[cnt_row+1][cnt_col+1] ;
                        M5_inA <= kernel1_3[cnt_row+1][cnt_col+1] ;
                        M6_inA <= kernel1_3[cnt_row+1][cnt_col+1] ;
                        M7_inA <= kernel1_3[cnt_row+1][cnt_col+1] ;
                        M8_inA <= kernel1_3[cnt_row+1][cnt_col+1] ;

                        M1_inB <= image1 [cnt_row+2][cnt_col];
                        M2_inB <= image1 [cnt_row+2][cnt_col+1];
                        M3_inB <= image1 [cnt_row+2][cnt_col+2];
                        M4_inB <= image1 [cnt_row+2][cnt_col+3];
                        M5_inB <= image1 [cnt_row+3][cnt_col];
                        M6_inB <= image1 [cnt_row+3][cnt_col+1];
                        M7_inB <= image1 [cnt_row+3][cnt_col+2];
                        M8_inB <= image1 [cnt_row+3][cnt_col+3];

                        M9_inA  <=  kernel2_3[cnt_row+1][cnt_col+1];
                        M10_inA <=  kernel2_3[cnt_row+1][cnt_col+1];
                        M11_inA <=  kernel2_3[cnt_row+1][cnt_col+1];
                        M12_inA <=  kernel2_3[cnt_row+1][cnt_col+1];
                        M13_inA <=  kernel2_3[cnt_row+1][cnt_col+1];
                        M14_inA <=  kernel2_3[cnt_row+1][cnt_col+1];
                        M15_inA <=  kernel2_3[cnt_row+1][cnt_col+1];
                        M16_inA <=  kernel2_3[cnt_row+1][cnt_col+1];

                        M9_inB <= image2  [cnt_row+2][cnt_col];
                        M10_inB <= image2 [cnt_row+2][cnt_col+1];
                        M11_inB <= image2 [cnt_row+2][cnt_col+2];
                        M12_inB <= image2 [cnt_row+2][cnt_col+3];
                        M13_inB <= image2 [cnt_row+3][cnt_col];
                        M14_inB <= image2 [cnt_row+3][cnt_col+1];
                        M15_inB <= image2 [cnt_row+3][cnt_col+2];
                        M16_inB <= image2 [cnt_row+3][cnt_col+3];

                        M17_inA <=  kernel3_3[cnt_row+1][cnt_col+1];
                        M18_inA <=  kernel3_3[cnt_row+1][cnt_col+1];
                        M19_inA <=  kernel3_3[cnt_row+1][cnt_col+1];
                        M20_inA <=  kernel3_3[cnt_row+1][cnt_col+1];
                        M21_inA <=  kernel3_3[cnt_row+1][cnt_col+1];
                        M22_inA <=  kernel3_3[cnt_row+1][cnt_col+1];
                        M23_inA <=  kernel3_3[cnt_row+1][cnt_col+1];
                        M24_inA <=  kernel3_3[cnt_row+1][cnt_col+1];

                        M17_inB <= image3 [cnt_row+2][cnt_col];
                        M18_inB <= image3 [cnt_row+2][cnt_col+1];
                        M19_inB <= image3 [cnt_row+2][cnt_col+2];
                        M20_inB <= image3 [cnt_row+2][cnt_col+3];
                        M21_inB <= image3 [cnt_row+3][cnt_col];
                        M22_inB <= image3 [cnt_row+3][cnt_col+1];
                        M23_inB <= image3 [cnt_row+3][cnt_col+2];
                        M24_inB <= image3 [cnt_row+3][cnt_col+3];

                        S1_inA <= M1_O;
                        S2_inA <= M2_O;
                        S3_inA <= M3_O;
                        S4_inA <= M4_O;
                        S5_inA <= M5_O;
                        S6_inA <= M6_O;
                        S7_inA <= M7_O;
                        S8_inA <= M8_O;

                        S1_inB <= M9_O;
                        S2_inB <= M10_O;
                        S3_inB <= M11_O;
                        S4_inB <= M12_O;
                        S5_inB <= M13_O;
                        S6_inB <= M14_O;
                        S7_inB <= M15_O;
                        S8_inB <= M16_O;

                        S1_inC <= M17_O;
                        S2_inC <= M18_O;
                        S3_inC <= M19_O;
                        S4_inC <= M20_O;
                        S5_inC <= M21_O;
                        S6_inC <= M22_O;
                        S7_inC <= M23_O;
                        S8_inC <= M24_O;
                    end
                    3:
                    begin
                        M1_inA <= kernel1_4[cnt_row+1][cnt_col+1] ;
                        M2_inA <= kernel1_4[cnt_row+1][cnt_col+1] ;
                        M3_inA <= kernel1_4[cnt_row+1][cnt_col+1] ;
                        M4_inA <= kernel1_4[cnt_row+1][cnt_col+1] ;
                        M5_inA <= kernel1_4[cnt_row+1][cnt_col+1] ;
                        M6_inA <= kernel1_4[cnt_row+1][cnt_col+1] ;
                        M7_inA <= kernel1_4[cnt_row+1][cnt_col+1] ;
                        M8_inA <= kernel1_4[cnt_row+1][cnt_col+1] ;

                        M1_inB <= image1 [cnt_row+2][cnt_col];
                        M2_inB <= image1 [cnt_row+2][cnt_col+1];
                        M3_inB <= image1 [cnt_row+2][cnt_col+2];
                        M4_inB <= image1 [cnt_row+2][cnt_col+3];
                        M5_inB <= image1 [cnt_row+3][cnt_col];
                        M6_inB <= image1 [cnt_row+3][cnt_col+1];
                        M7_inB <= image1 [cnt_row+3][cnt_col+2];
                        M8_inB <= image1 [cnt_row+3][cnt_col+3];

                        M9_inA  <=  kernel2_4[cnt_row+1][cnt_col+1];
                        M10_inA <=  kernel2_4[cnt_row+1][cnt_col+1];
                        M11_inA <=  kernel2_4[cnt_row+1][cnt_col+1];
                        M12_inA <=  kernel2_4[cnt_row+1][cnt_col+1];
                        M13_inA <=  kernel2_4[cnt_row+1][cnt_col+1];
                        M14_inA <=  kernel2_4[cnt_row+1][cnt_col+1];
                        M15_inA <=  kernel2_4[cnt_row+1][cnt_col+1];
                        M16_inA <=  kernel2_4[cnt_row+1][cnt_col+1];

                        M9_inB <= image2  [cnt_row+2][cnt_col];
                        M10_inB <= image2 [cnt_row+2][cnt_col+1];
                        M11_inB <= image2 [cnt_row+2][cnt_col+2];
                        M12_inB <= image2 [cnt_row+2][cnt_col+3];
                        M13_inB <= image2 [cnt_row+3][cnt_col];
                        M14_inB <= image2 [cnt_row+3][cnt_col+1];
                        M15_inB <= image2 [cnt_row+3][cnt_col+2];
                        M16_inB <= image2 [cnt_row+3][cnt_col+3];

                        M17_inA <=  kernel3_4[cnt_row+1][cnt_col+1];
                        M18_inA <=  kernel3_4[cnt_row+1][cnt_col+1];
                        M19_inA <=  kernel3_4[cnt_row+1][cnt_col+1];
                        M20_inA <=  kernel3_4[cnt_row+1][cnt_col+1];
                        M21_inA <=  kernel3_4[cnt_row+1][cnt_col+1];
                        M22_inA <=  kernel3_4[cnt_row+1][cnt_col+1];
                        M23_inA <=  kernel3_4[cnt_row+1][cnt_col+1];
                        M24_inA <=  kernel3_4[cnt_row+1][cnt_col+1];

                        M17_inB <= image3 [cnt_row+2][cnt_col];
                        M18_inB <= image3 [cnt_row+2][cnt_col+1];
                        M19_inB <= image3 [cnt_row+2][cnt_col+2];
                        M20_inB <= image3 [cnt_row+2][cnt_col+3];
                        M21_inB <= image3 [cnt_row+3][cnt_col];
                        M22_inB <= image3 [cnt_row+3][cnt_col+1];
                        M23_inB <= image3 [cnt_row+3][cnt_col+2];
                        M24_inB <= image3 [cnt_row+3][cnt_col+3];

                        S1_inA <= M1_O;
                        S2_inA <= M2_O;
                        S3_inA <= M3_O;
                        S4_inA <= M4_O;
                        S5_inA <= M5_O;
                        S6_inA <= M6_O;
                        S7_inA <= M7_O;
                        S8_inA <= M8_O;

                        S1_inB <= M9_O;
                        S2_inB <= M10_O;
                        S3_inB <= M11_O;
                        S4_inB <= M12_O;
                        S5_inB <= M13_O;
                        S6_inB <= M14_O;
                        S7_inB <= M15_O;
                        S8_inB <= M16_O;

                        S1_inC <= M17_O;
                        S2_inC <= M18_O;
                        S3_inC <= M19_O;
                        S4_inC <= M20_O;
                        S5_inC <= M21_O;
                        S6_inC <= M22_O;
                        S7_inC <= M23_O;
                        S8_inC <= M24_O;
                    end

                endcase
            end
        end
        else if (current_state==IDLE)
        begin
            M1_inA <= 0;
            M2_inA <= 0;
            M3_inA <= 0;
            M4_inA <= 0;
            M5_inA <= 0;
            M6_inA <= 0;
            M7_inA <= 0;
            M8_inA <= 0;
            M1_inB <= 0;
            M2_inB <= 0;
            M3_inB <= 0;
            M4_inB <= 0;
            M5_inB <= 0;
            M6_inB <= 0;
            M7_inB <= 0;
            M8_inB <= 0;
            M9_inA <= 0;
            M10_inA<= 0;
            M11_inA<= 0;
            M12_inA<= 0;
            M13_inA<= 0;
            M14_inA<= 0;
            M15_inA<= 0;
            M16_inA<= 0;
            M9_inB <= 0;
            M10_inB<= 0;
            M11_inB<= 0;
            M12_inB<= 0;
            M13_inB<= 0;
            M14_inB<= 0;
            M15_inB<= 0;
            M16_inB<= 0;
            M17_inA<= 0;
            M18_inA<= 0;
            M19_inA<= 0;
            M20_inA<= 0;
            M21_inA<= 0;
            M22_inA<= 0;
            M23_inA<= 0;
            M24_inA<= 0;
            M17_inB<= 0;
            M18_inB<= 0;
            M19_inB<= 0;
            M20_inB<= 0;
            M21_inB<= 0;
            M22_inB<= 0;
            M23_inB<= 0;
            M24_inB<= 0;
            S1_inA <= 0;
            S2_inA <= 0;
            S3_inA <= 0;
            S4_inA <= 0;
            S5_inA <= 0;
            S6_inA <= 0;
            S7_inA <= 0;
            S8_inA <= 0;
            S1_inB <= 0;
            S2_inB <= 0;
            S3_inB <= 0;
            S4_inB <= 0;
            S5_inB <= 0;
            S6_inB <= 0;
            S7_inB <= 0;
            S8_inB <= 0;
            S1_inC <= 0;
            S2_inC <= 0;
            S3_inC <= 0;
            S4_inC <= 0;
            S5_inC <= 0;
            S6_inC <= 0;
            S7_inC <= 0;
            S8_inC <= 0;
        end
    end
end
// end


/*----------------------------------------------------------------------------------------
      CCCCCC        AAA      LL         CCCCCC  UU      UU     11
    CC             AA AA     LL       CC        UU      UU    111 
   CC             AA   AA    LL      CC         UU      UU     11 
    CC       C   AAAAAAAAA   LL       CC         UU    UU      11 
     CCCCCCCC   AA       AA  LLLLLLLLL CCCCCCCC   UUUUUU    11111111
*///--------------------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        div_ina <= 0 ;
        div_inb <= 0 ;
        for ( i=1 ;i<=64 ;i=i+1 )
        begin
            Outlong2[i] <= 0;
        end
    end
    else
    begin
        // if (BigCnt==102)
        // begin
        //     cntforlong <= 0;
        // end
        //-------------------OPTION  3 ---------------------
        if (option==3)
        begin
            if (BigCnt>36)
            begin
                div_ina <= sub_out;
                div_inb <= A9_O;
            end
        end
        //-------------------OPTION  2 ---------------------
        else if (option==2)
        begin
            if (BigCnt>36)
            begin
                div_ina <= 32'b0_01111111_00000000000000000000000;
                div_inb <= A9_O;
            end
        end
        //-------------------OPTION  1 ---------------------
        else if (option==1)
        begin
            if (BigCnt>34)
            begin
                if ( Outlong[cntforlong_A+1][31]==1 )
                begin
                    div_ina <= Outlong[cntforlong_A+1];
                    div_inb <= 32'b0_10000010_01000000000000000000000;
                end
                else if (Outlong[cntforlong_A+1][31]==0)
                begin
                    div_ina <= Outlong[cntforlong_A+1];
                    div_inb <= 32'b0_01111111_00000000000000000000000;
                end
            end
        end
        //-------------------OPTION  0 ---------------------
        else if (option==0)
        begin
            if (BigCnt>34)
            begin
                if ( Outlong[cntforlong_A+1][31]==1 )
                begin
                    Outlong2[cntforlong_A+1] <= 0;
                end
                else if (Outlong[cntforlong_A+1][31]==0)
                begin
                    Outlong2[cntforlong_A+1] <= Outlong[cntforlong_A+1];
                end
            end
        end
    end

end

//--------cntforlong_A----------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        cntforlong_A <= 0;
    end
    else
    begin
        if (BigCnt>34 && BigCnt<=99)
        begin
            cntforlong_A <= cntforlong_A + 1;
        end
        else
        begin
            cntforlong_A <= 0;
        end
    end
end

/*----------------------------------------------------------------------------------------
      CCCCCC        AAA      LL         CCCCCC  UU      UU    2222222          
    CC             AA AA     LL       CC        UU      UU   2       22    
   CC             AA   AA    LL      CC         UU      UU         22     
    CC       C   AAAAAAAAA   LL       CC         UU    UU        222       
     CCCCCCCC   AA       AA  LLLLLLLLL CCCCCCCC   UUUUUU      222222222          
*///--------------------------------------------------------------------------------------

//========================EXP========================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        exp_in_1 <=0;
        exp_in_2 <=0;
    end
    else
    begin
        if(option==2 || option==3)
        begin
            if (current_state==STATE1_CALC)
            begin
                if (BigCnt>34)
                begin
                    if ( Outlong[cntforlong_A+1][31]==0 )
                    begin
                        exp_in_1 <= Outlong[cntforlong_A+1];
                        exp_in_2 <= { 1'b1 , Outlong[cntforlong_A+1][30:0] };
                    end
                    else if (Outlong[cntforlong_A+1][31]==1)
                    begin
                        exp_in_1 <= Outlong[cntforlong_A+1];
                        exp_in_2 <= { 1'b0 , Outlong[cntforlong_A+1][30:0] };
                    end
                end
            end

            else if (current_state==IDLE)
            begin
                exp_in_1    <=0;
                exp_in_2    <=0;
            end
        end
    end
end
//==============adder===================================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        A9_inA <= 0;
        A9_inB <= 0;
        sub_ina <= 0;
        sub_inb <= 0;
    end
    else
    begin
        //-------------------OPTION  3 ---------------------
        if (option==3)
        begin
            if (BigCnt>35)
            begin
                A9_inA <=exp_out_1 ;
                A9_inB <=exp_out_2 ;
                sub_ina <= exp_out_1 ;
                sub_inb <= exp_out_2 ;
            end
        end
        //-------------------OPTION  2 ---------------------
        else if (option==2)
        begin
            if (BigCnt>35)
            begin
                A9_inA <= 32'b0_01111111_00000000000000000000000;
                A9_inB <= exp_out_2;
            end
        end
        else
        begin
            A9_inA <= 0 ;
            A9_inB <= 0 ;
            sub_ina <= 0;
            sub_inb <= 0;
        end
    end
end


/*---------------------------------------------------------------------------------------------------------
     SSSSSS   TTTTTTTTTT    oooooo     RRRRRRRR    EEEEEEEEEE
   SS             TT      oo      oo   RR      RR  EE        
    SSSSSSS       TT     oo        oo  RRRRRRRRR   EEEEEEEEE 
           SS     TT      oo      oo   RR   RRR    EE        
    SSSSSSS       TT        oooooo     RR     RRR  EEEEEEEEEE
*///-------------------------------------------------------------------------------------------------------
integer a,b;
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        A1_inA <= 0;
        A2_inA <= 0;
        A3_inA <= 0;
        A4_inA <= 0;
        A5_inA <= 0;
        A6_inA <= 0;
        A7_inA <= 0;
        A8_inA <= 0;
        A1_inB <= 0;
        A2_inB <= 0;
        A3_inB <= 0;
        A4_inB <= 0;
        A5_inB <= 0;
        A6_inB <= 0;
        A7_inB <= 0;
        A8_inB <= 0;
        flag_cnt <= 0;
    end
    else
    begin
        if (current_state==STATE1_CALC && cnt==8 )
        begin
            A1_inA <= S1_O ;
            A2_inA <= S2_O ;
            A3_inA <= S3_O ;
            A4_inA <= S4_O ;
            A5_inA <= S5_O ;
            A6_inA <= S6_O ;
            A7_inA <= S7_O ;
            A8_inA <= S8_O ;

            A1_inB <= 0 ;
            A2_inB <= 0 ;
            A3_inB <= 0 ;
            A4_inB <= 0 ;
            A5_inB <= 0 ;
            A6_inB <= 0 ;
            A7_inB <= 0 ;
            A8_inB <= 0 ;

        end
        else if (current_state==STATE1_CALC)
        begin
            A1_inA <= S1_O ;
            A2_inA <= S2_O ;
            A3_inA <= S3_O ;
            A4_inA <= S4_O ;
            A5_inA <= S5_O ;
            A6_inA <= S6_O ;
            A7_inA <= S7_O ;
            A8_inA <= S8_O ;

            A1_inB <= A1_O ;
            A2_inB <= A2_O ;
            A3_inB <= A3_O ;
            A4_inB <= A4_O ;
            A5_inB <= A5_O ;
            A6_inB <= A6_O ;
            A7_inB <= A7_O ;
            A8_inB <= A8_O ;
        end
        else if (current_state==IDLE)
        begin
            A1_inA <= 0;
            A2_inA <= 0;
            A3_inA <= 0;
            A4_inA <= 0;
            A5_inA <= 0;
            A6_inA <= 0;
            A7_inA <= 0;
            A8_inA <= 0;
            A1_inB <= 0;
            A2_inB <= 0;
            A3_inB <= 0;
            A4_inB <= 0;
            A5_inB <= 0;
            A6_inB <= 0;
            A7_inB <= 0;
            A8_inB <= 0;
            flag_cnt <= 0;
        end
    end
end


/*----------------------------------------------------------------------------------------------------------
            oooooo     UU      UU   TTTTTTTTTT
          oo      oo   UU      UU       TT    
         oo        oo  UU      UU       TT    
          oo      oo    UU    UU        TT       Outlong
            oooooo       UUUUUU         TT    
  *///-------------------------------------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        for ( i=1 ; i<=64 ; i=i+1 )
        begin
            Outlong[i]<=0;
        end
    end
    else
    begin
        Outlong[1]  <= result1 [1][1];
        Outlong[2]  <= result2 [1][1];
        Outlong[3]  <= result1 [1][2];
        Outlong[4]  <= result2 [1][2];
        Outlong[5]  <= result1 [1][3];
        Outlong[6]  <= result2 [1][3];
        Outlong[7]  <= result1 [1][4];
        Outlong[8]  <= result2 [1][4];
        //---------------------------
        Outlong[9]  <= result3 [1][1];
        Outlong[10] <= result4 [1][1];
        Outlong[11] <= result3 [1][2];
        Outlong[12] <= result4 [1][2];
        Outlong[13] <= result3 [1][3];
        Outlong[14] <= result4 [1][3];
        Outlong[15] <= result3 [1][4];
        Outlong[16] <= result4 [1][4];
        //---------------------------
        Outlong[17] <= result1 [2][1];
        Outlong[18] <= result2 [2][1];
        Outlong[19] <= result1 [2][2];
        Outlong[20] <= result2 [2][2];
        Outlong[21] <= result1 [2][3];
        Outlong[22] <= result2 [2][3];
        Outlong[23] <= result1 [2][4];
        Outlong[24] <= result2 [2][4];
        //---------------------------
        Outlong[25] <= result3 [2][1];
        Outlong[26] <= result4 [2][1];
        Outlong[27] <= result3 [2][2];
        Outlong[28] <= result4 [2][2];
        Outlong[29] <= result3 [2][3];
        Outlong[30] <= result4 [2][3];
        Outlong[31] <= result3 [2][4];
        Outlong[32] <= result4 [2][4];
        //---------------------------
        Outlong[33] <= result1_d [1][1];
        Outlong[34] <= result2_d [1][1];
        Outlong[35] <= result1_d [1][2];
        Outlong[36] <= result2_d [1][2];
        Outlong[37] <= result1_d [1][3];
        Outlong[38] <= result2_d [1][3];
        Outlong[39] <= result1_d [1][4];
        Outlong[40] <= result2_d [1][4];
        //---------------------------
        Outlong[41] <= result3_d [1][1];
        Outlong[42] <= result4_d [1][1];
        Outlong[43] <= result3_d [1][2];
        Outlong[44] <= result4_d [1][2];
        Outlong[45] <= result3_d [1][3];
        Outlong[46] <= result4_d [1][3];
        Outlong[47] <= result3_d [1][4];
        Outlong[48] <= result4_d [1][4];
        //---------------------------
        Outlong[49] <= result1_d [2][1];
        Outlong[50] <= result2_d [2][1];
        Outlong[51] <= result1_d [2][2];
        Outlong[52] <= result2_d [2][2];
        Outlong[53] <= result1_d [2][3];
        Outlong[54] <= result2_d [2][3];
        Outlong[55] <= result1_d [2][4];
        Outlong[56] <= result2_d [2][4];
        //---------------------------
        Outlong[57] <= result3_d [2][1];
        Outlong[58] <= result4_d [2][1];
        Outlong[59] <= result3_d [2][2];
        Outlong[60] <= result4_d [2][2];
        Outlong[61] <= result3_d [2][3];
        Outlong[62] <= result4_d [2][3];
        Outlong[63] <= result3_d [2][4];
        Outlong[64] <= result4_d [2][4];

    end
end


/*----------------------------------------------------------------------------------------------------------
      RRRRRRRR    EEEEEEEEEE   SSSSSS   UU      UU  LL      TTTTTTTTTT
      RR      RR  EE         SS         UU      UU  LL          TT    
      RRRRRRRRR   EEEEEEEEE   SSSSSSS   UU      UU  LL          TT    
      RR   RRR    EE                 SS  UU    UU   LL          TT    
      RR     RRR  EEEEEEEEEE  SSSSSSS     UUUUUU    LLLLLLLL    TT    
*///------------------------------------------------------------------------------------------------------- 
//--------out [1][1]------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        for ( i=1 ;i<=2 ;i=i+1 )
        begin
            for ( j=1 ;j<=4 ;j=j+1 )
            begin
                result1[i][j] <= 0;
                result2[i][j] <= 0;
                result3[i][j] <= 0;
                result4[i][j] <= 0;
                result1_d[i][j] <= 0;
                result2_d[i][j] <= 0;
                result3_d[i][j] <= 0;
                result4_d[i][j] <= 0;
            end
        end
        storeTO <=0 ;
    end
    else
    begin
        if (current_state == STATE1_CALC && cnt==8)
        begin
            if (BigCnt<46)
            begin
                case (storeTO)
                    0:
                    begin
                        storeTO <= storeTO+1;
                        result1[1][1] <= A1_O;
                        result1[1][2] <= A2_O;
                        result1[1][3] <= A3_O;
                        result1[1][4] <= A4_O;
                        result1[2][1] <= A5_O;
                        result1[2][2] <= A6_O;
                        result1[2][3] <= A7_O;
                        result1[2][4] <= A8_O;
                    end
                    1:
                    begin
                        storeTO <= storeTO+1;
                        result2[1][1] <= A1_O;
                        result2[1][2] <= A2_O;
                        result2[1][3] <= A3_O;
                        result2[1][4] <= A4_O;
                        result2[2][1] <= A5_O;
                        result2[2][2] <= A6_O;
                        result2[2][3] <= A7_O;
                        result2[2][4] <= A8_O;
                    end
                    2:
                    begin
                        storeTO <= storeTO+1;
                        result3[1][1] <= A1_O;
                        result3[1][2] <= A2_O;
                        result3[1][3] <= A3_O;
                        result3[1][4] <= A4_O;
                        result3[2][1] <= A5_O;
                        result3[2][2] <= A6_O;
                        result3[2][3] <= A7_O;
                        result3[2][4] <= A8_O;
                    end
                    3:
                    begin
                        storeTO <= 0;
                        result4[1][1] <= A1_O;
                        result4[1][2] <= A2_O;
                        result4[1][3] <= A3_O;
                        result4[1][4] <= A4_O;
                        result4[2][1] <= A5_O;
                        result4[2][2] <= A6_O;
                        result4[2][3] <= A7_O;
                        result4[2][4] <= A8_O;
                    end
                endcase
            end
            else if (BigCnt<82)
            begin
                case (storeTO)
                    0:
                    begin
                        storeTO <= storeTO+1;
                        result1_d[1][1] <= A1_O;
                        result1_d[1][2] <= A2_O;
                        result1_d[1][3] <= A3_O;
                        result1_d[1][4] <= A4_O;
                        result1_d[2][1] <= A5_O;
                        result1_d[2][2] <= A6_O;
                        result1_d[2][3] <= A7_O;
                        result1_d[2][4] <= A8_O;
                    end
                    1:
                    begin
                        storeTO <= storeTO+1;
                        result2_d[1][1] <= A1_O;
                        result2_d[1][2] <= A2_O;
                        result2_d[1][3] <= A3_O;
                        result2_d[1][4] <= A4_O;
                        result2_d[2][1] <= A5_O;
                        result2_d[2][2] <= A6_O;
                        result2_d[2][3] <= A7_O;
                        result2_d[2][4] <= A8_O;
                    end
                    2:
                    begin
                        storeTO <= storeTO+1;
                        result3_d[1][1] <= A1_O;
                        result3_d[1][2] <= A2_O;
                        result3_d[1][3] <= A3_O;
                        result3_d[1][4] <= A4_O;
                        result3_d[2][1] <= A5_O;
                        result3_d[2][2] <= A6_O;
                        result3_d[2][3] <= A7_O;
                        result3_d[2][4] <= A8_O;
                    end
                    3:
                    begin
                        storeTO <= 0;
                        result4_d[1][1] <= A1_O;
                        result4_d[1][2] <= A2_O;
                        result4_d[1][3] <= A3_O;
                        result4_d[1][4] <= A4_O;
                        result4_d[2][1] <= A5_O;
                        result4_d[2][2] <= A6_O;
                        result4_d[2][3] <= A7_O;
                        result4_d[2][4] <= A8_O;
                    end
                endcase
            end
        end
        else if (current_state==IDLE)
        begin
            for ( i=1 ;i<=2 ;i=i+1 )
            begin
                for ( j=1 ;j<=4 ;j=j+1 )
                begin
                    result1[i][j] <= 0;
                    result2[i][j] <= 0;
                    result3[i][j] <= 0;
                    result4[i][j] <= 0;
                    result1_d[i][j] <= 0;
                    result2_d[i][j] <= 0;
                    result3_d[i][j] <= 0;
                    result4_d[i][j] <= 0;
                end
                storeTO <=0 ;
            end
        end
    end
end


// ===============================================================
/*      cccccccccc                             cccccccccc
      ccc   c    ccc                         ccc   c    ccc
     cc     c      cc                       cc     c      cc
    ccc     c      ccc                     ccc     c      ccc
     cc      c     cc                       cc      c     cc
      ccc      c ccc                         ccc      c ccc
        cccccccccc                             cccccccccc
*///-----------------Set BigCnt-----------------------------------
always @(posedge clk or negedge rst_n) //cnt
begin
    //Reset--------------------------------------
    if(~rst_n)
    begin
        BigCnt <= 0;
    end

    else if (current_state==IDLE)//cnt = output cycle
    begin
        BigCnt  <= 0;
    end

    //count-------------------------------------
    else if (current_state==STATE1_CALC)
    begin
        BigCnt <= BigCnt+1;
    end
    else if (in_valid_k)
    begin
        BigCnt <= BigCnt+1;
    end

end

// -----------------Set Cnt-----------------------------------
always @(posedge clk or negedge rst_n) //cnt
begin
    //Reset--------------------------------------
    if(~rst_n)
    begin
        cnt <= 0;
    end
    else if( current_state == STATE1_CALC && cnt==8)
    begin
        cnt <= 0;
    end
    else if (BigCnt==2)
    begin
        cnt <= 0;
    end
    else if (current_state==IDLE)//cnt = output cycle
    begin
        cnt  <= 0;
    end
    //count--------------------------------------------
    else if( current_state == STATE1_CALC)
    begin
        cnt <= cnt+1;
    end
end

// -----------------Set Cnt_col-----------------------------------
always @(posedge clk or negedge rst_n) //cnt
begin
    //Reset--------------------------------------
    if(~rst_n)
    begin
        cnt_col <= 0;
    end
    else
    begin
        if (current_state==IDLE)//cnt = output cycle
        begin
            cnt_col <= 0;
        end
        else if (cnt_col==2)
        begin
            cnt_col <= 0;
        end
        //count-------------------------------------

        else if (next_state==STATE1_CALC)
        begin
            cnt_col <= cnt_col+1;
        end
        else if (current_state==STATE1_CALC)
        begin
            cnt_col <= cnt_col+1;
        end
    end


end
//-----------------Set Cnt_row-----------------------------------
always @(posedge clk or negedge rst_n) //cnt
begin
    if(~rst_n)
    begin
        cnt_row <= 0;
    end
    else if (current_state==IDLE)
    begin
        cnt_row <=  0;
    end
    else if (current_state==STATE1_CALC)
    begin
        if (cnt_col==2)
        begin
            if (cnt_row==2)
            begin
                cnt_row <= 0;
            end
            else
            begin
                cnt_row <= cnt_row+1;
            end
        end
    end
end
//-----------------Set Cnt_out-----------------------------------
always @(posedge clk or negedge rst_n) //cnt
begin
    if(~rst_n)
    begin
        cnt_out <= 0;
    end
    else if (current_state==IDLE)
    begin
        cnt_out <= 0;
    end
    else if (BeginOUT)
    begin
        cnt_out <= cnt_out+1;
    end
end
//-------------------BeginOUT------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        BeginOUT <= 0;
    end
    else
    begin
        if (option==0)
        begin
            if (BigCnt==35)
            begin
                BeginOUT<=1;
            end
            else if (BigCnt==99)
            begin
                BeginOUT<=0;
            end
        end
        else if (option==1)
        begin
            if (BigCnt==35)
            begin
                BeginOUT<=1;
            end
            else if (BigCnt==99)
            begin
                BeginOUT<=0;
            end
        end
        else if (option==2 || option==3)
        begin
            if (BigCnt==37)
            begin
                BeginOUT<=1;
            end
            else if (BigCnt==101)
            begin
                BeginOUT<=0;
            end
        end

    end
end




//=======================================================================
/*   FFFFFFFFFFFFFFF   IIIIIIIIIIIIIIIII    NNN          NNN
     FFFFFFFFFFFFFFF   IIIIIIIIIIIIIIIII    NNNNN        NNN                                                 
     FFF                     IIII           NNN NNN      NNN                         
     FFFFFFFFFFFFFFF         IIII           NNN  NNNN    NNN                                     
     FFFFFFFFFFFFFFF         IIII           NNN    NNNN  NNN                                     
     FFF                     IIII           NNN      NNN NNN                         
     FFF               IIIIIIIIIIIIIIIII    NNN        NNNNN                    
     FFF               IIIIIIIIIIIIIIIII    NNN          NNN                                                                                                                                
*///-----------------Out the result---------------------------------------

always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        out <=0 ;
        out_valid <=0 ;
        ROW <= 0;
        COL <= 0;
        cnt_output<=0;
    end
    else
    begin
        if (current_state==IDLE)
        begin
            out <=0 ;
            out_valid <=0 ;
            ROW <= 0;
            COL <= 0;
            cnt_output <= 0 ;
            switchS<=0;
        end
        else if (current_state==STATE1_CALC)
        begin
            //-------------------OPTION  0 ---------------------
            if (option==0)
            begin
                if (BeginOUT)
                begin
                    out_valid <= 1;
                    out <= Outlong2[cnt_output+1];
                    cnt_output <= cnt_output+1 ;
                end
                else if (BeginOUT==0)
                begin
                    out_valid <= 0;
                    out <= 0;
                    cnt_output <= 0;
                end
            end
            //-------------------OPTION  1 ---------------------
            else if (option==1)
            begin
                if (BeginOUT)
                begin
                    out_valid <= 1;
                    out <= div_out;
                end
                else if (BeginOUT==0)
                begin
                    out_valid <= 0;
                    out <= 0;
                end
            end
            //-------------------OPTION  2 ---------------------
            else if (option==2)
            begin
                if (BeginOUT)
                begin
                    out_valid <= 1;
                    out <= div_out;
                end
                else if (BeginOUT==0)
                begin
                    out_valid <= 0;
                    out <= 0;

                end
            end
            //-------------------OPTION  3 ---------------------
            else if (option==3)
            begin
                if (BeginOUT)
                begin
                    out_valid <= 1;
                    out <= div_out;
                end
                else if (BeginOUT==0)
                begin
                    out_valid <= 0;
                    out <= 0;

                end
            end
        end

    end
end




endmodule
