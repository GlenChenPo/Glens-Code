module TMIP(
           // input signals
           clk,
           rst_n,
           in_valid,
           in_valid_2,
           image,
           img_size,
           template,
           action,

           // output signals
           out_valid,
           out_x,
           out_y,
           out_img_pos,
           out_value
       );
//==================INPUT OUTPUT==================//
input        clk, rst_n, in_valid, in_valid_2;
input signed [15:0] image, template;
input [4:0]  img_size;
input [2:0]  action;

output reg        out_valid;
output reg [3:0]  out_x, out_y;
output reg [7:0]  out_img_pos;
output reg signed[39:0] out_value;

//================================================//
// Genvar & Parameters & Integer Declaration
// ===============================================================
// state
parameter IDLE           = 4'd0 ;
parameter STATE_INPUT1   = 4'd1 ;
parameter STATE_INPUT2   = 4'd2 ;
parameter STATE0_HOME    = 4'd3 ;
parameter STATE1_option1 = 4'd4 ;
parameter STATE2_option2 = 4'd5 ;
parameter STATE3_option3 = 4'd6 ;
parameter STATE4_option4 = 4'd7 ;
parameter STATE5_option5 = 4'd8 ;
parameter STATE6_option6 = 4'd9 ;
parameter STATE7_option7 = 4'd10;
parameter STATE8_option0 = 4'd11;
parameter STATE9_OUTPUT  = 4'd12;

//------- F_some   = Finish something ,use to switch STATE-----------------------------------
reg [0:0] F_IDLE , F_opt1 , F_opt2 , F_opt3 , F_opt4 , F_opt5 , F_opt6 , F_opt7 , F_opt0 , F_OUTP ;
//------- B_some   = Begin something ,use to i switch STATE-----------------------------------
reg [0:0]  B_opt1 , B_opt2 , B_opt3 , B_opt4 , B_opt5 , B_opt6 , B_opt7 , B_opt0;
//--------cache the things read from memory---------------------------------------------------
reg signed [39:0] cache_1 [0:15] ;
reg signed [39:0] cache_2 [0:15] ;
//-------- to know which row & column --------------------------------------------------------
reg[3:0] column , row ;
//---------inputs-----------------------------------------------------------------------------
reg [2:0] Action [0:15] ;
reg signed [15:0] Tenplate [0:8];
reg [1:0] IMAGE_size;
//----counter---------------------------------------------------------------------------------
reg [9:0] cnt;
reg [4:0] cnt_action ;
reg [7:0] cnt_address_1 ;
reg [7:0] cnt_write ,cnt_read;

//----divider---------------------------------------------------------------------------------
reg signed [39:0] di_out , di_inA  , ad_out , ad_in;
reg signed [39:0] mu_out_1 , mu_out_2 , mu_out_3 , mu_out_4 , mu_out_5 , mu_out_6 , mu_out_7 , mu_out_8 , mu_out_9 ;
reg signed [39:0] mu_inB_1 ;
reg signed [39:0] mu_inA_1 , mu_inA_2 , mu_inA_3 , mu_inA_4 , mu_inA_5 , mu_inA_6 , mu_inA_7 , mu_inA_8 , mu_inA_9 ;
reg signed [39:0] sum_out , sum_inA , sum_inB ;

//=======================  memory  ===========================================================
reg signed [39:0] DATA ;
reg [7:0]  ADR_1 , ADR_2 ;
reg [0:0] whichMEMO;
reg signed [39:0] Data_1 , Data_2 , A , B;
reg [7:0]  address_1 , address_2 ;
reg [0:0] WEN_W , WEN_R;
reg [0:0]  WEN_1 , WEN_2 ;
reg signed [39:0] MEMO_OUT;
wire signed [39:0] memo_OUT_1 , memo_OUT_2;
RA1SH memo1( .Q(memo_OUT_1), .CLK(clk), .CEN(1'b0), .WEN(WEN_1), .A(address_1), .D(Data_1), .OEN(1'b0) );
RA1SH memo2( .Q(memo_OUT_2), .CLK(clk), .CEN(1'b0), .WEN(WEN_2), .A(address_2), .D(Data_2), .OEN(1'b0) );

// ===============================================================
// Wire & Reg Declaration
// ===============================================================
reg [3:0] current_state,next_state;//current & next state



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
   NN      NN  EEEEEEEEEE  ii      ii  TTTTTTTTTT                                                                         
   NNNN    NN  EE           iii  iii       TT                                                           
   NN  NN  NN  EEEEEEEEE     iiiiii        TT                                                                  
   NN    NNNN  EE           iii  iii       TT                                                      
   NN      NN  EEEEEEEEEE  ii      ii      TT                                                              
*///---------------------------------------------------------------------------------                                                                                         
always @(*)
begin
    case (current_state) //Current_state
        IDLE:
        begin
            if (in_valid)
                next_state = STATE_INPUT1;
            else
                next_state = IDLE;
        end

        STATE_INPUT1:
        begin
            if(in_valid_2)
                next_state =  STATE_INPUT2 ;
            else
                next_state =  STATE_INPUT1 ;

        end

        STATE_INPUT2:
        begin
            if(in_valid_2 == 0)
                next_state =  STATE0_HOME ;
            else
                next_state =  STATE_INPUT2 ;

        end

        STATE0_HOME: //like a menu
        begin
            if(B_opt1)
                next_state =  STATE1_option1 ;
            else if (B_opt2)
                next_state =  STATE2_option2 ;
            else if (B_opt3)
                next_state =  STATE3_option3 ;
            else if (B_opt4)
                next_state =  STATE4_option4 ;
            else if (B_opt5)
                next_state =  STATE5_option5 ;
            else if (B_opt6)
                next_state =  STATE6_option6 ;
            else if (B_opt7)
                next_state =  STATE7_option7 ;
            else if (B_opt0)
                next_state =  STATE8_option0 ;
            else
                next_state = STATE0_HOME;
        end

        STATE1_option1: //Max Pooling
        begin
            if (F_opt1)
                next_state =  STATE0_HOME;
            else
                next_state = STATE1_option1;
        end

        STATE2_option2: //Horizontal Flip
        begin
            if (F_opt2)
                next_state =  STATE0_HOME;
            else
                next_state = STATE2_option2;
        end

        STATE3_option3: //Vertical Flip
        begin
            if (F_opt3)
                next_state =  STATE0_HOME;
            else
                next_state = STATE3_option3;
        end

        STATE4_option4: //Left-diagonal Flip
        begin
            if (F_opt4)
                next_state =  STATE0_HOME;
            else
                next_state = STATE4_option4;
        end

        STATE5_option5: //Right-diagonal Flip
        begin
            if (F_opt5)
                next_state =  STATE0_HOME;
            else
                next_state = STATE5_option5;
        end

        STATE6_option6: //Zoom in
        begin
            if (F_opt6)
                next_state =  STATE0_HOME;
            else
                next_state = STATE6_option6;
        end

        STATE7_option7: //Shortcut + Brightness Adjustment
        begin
            if(F_opt7)
                next_state =  STATE0_HOME;
            else
                next_state = STATE7_option7;
        end
        STATE8_option0: //Cross Correlation
        begin
            if(F_opt0)
                next_state =  STATE9_OUTPUT;
            else
                next_state = STATE8_option0;
        end
        STATE9_OUTPUT: //output the result
        begin
            if(F_OUTP)
                next_state = IDLE;
            else
                next_state = STATE9_OUTPUT;
        end
        default:
            next_state = IDLE;
    endcase
end

// ===============================================================
/*      cccccccccc                             cccccccccc
      ccc   c    ccc                         ccc   c    ccc                                  
     cc     c      cc                       cc     c      cc                               
    ccc     c      ccc                     ccc     c      ccc                             
     cc      c     cc                       cc      c     cc                               
      ccc      c ccc                         ccc      c ccc                  
        cccccccccc                             cccccccccc                                       
*/// -----------------Set Counter---------------------------------
always @(posedge clk or negedge rst_n) //cnt
begin
    if(~rst_n)
    begin
        cnt <= 0;
    end
    else
    begin
        if (in_valid)
        begin
            cnt <= cnt + 1;
        end
        else
        begin
            if (current_state==IDLE || current_state==STATE0_HOME)
            begin
                cnt <= 0;
            end
            else if (current_state==STATE_INPUT1 || current_state==STATE_INPUT2)
            begin
                cnt <= cnt+1;
            end
            //---- option2 = option3 = option4 = option5  cnt in flip is the same--------------------
            else if (current_state==STATE2_option2 || current_state==STATE3_option3 || current_state==STATE4_option4 || current_state==STATE5_option5)
            begin
                case (IMAGE_size)
                    1:
                    begin
                        if (cnt == 18)
                            cnt <= 0 ;
                        else
                            cnt <= cnt + 1 ;
                    end
                    2:
                    begin
                        if (cnt == 66)
                            cnt <= 0 ;
                        else
                            cnt <= cnt + 1 ;
                    end
                    3:
                    begin
                        if (cnt == 258)
                            cnt <= 0 ;
                        else
                            cnt <= cnt + 1 ;
                    end
                endcase
            end
            //---cnt in MAX POOLING--------------------------------
            else if (current_state==STATE1_option1)
            begin

            end
            //---  cnt in ZOOM IN  --------------------------------
            else if (current_state==STATE6_option6)
            begin

            end
            //---  cnt in SHORTCUT --------------------------------
            else if (current_state==STATE7_option7)
            begin
                case (IMAGE_size)
                    1:
                    begin
                        if (cnt == 20)
                            cnt <= 0 ;
                        else
                            cnt <= cnt + 1 ;
                    end
                    2:
                    begin
                        if (cnt == 20)
                            cnt <= 0 ;
                        else
                            cnt <= cnt + 1 ;
                    end
                    3:
                    begin
                        if (cnt == 68)
                            cnt <= 0 ;
                        else
                            cnt <= cnt + 1 ;
                    end
                endcase
            end
            //---cnt in CORRELATION--------------------------------
            else if (current_state==STATE8_option0)
            begin

            end

        end
    end
end
//----- cnt for template -----------------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin

    end
end

//=======================================================================================
//        cnt for read
//=======================================================================================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        cnt_read <= 0;
    end
    else
    begin
        if (current_state==STATE7_option7)
        begin
            case (IMAGE_size)
                1:
                begin
                    if (cnt<15)
                    begin
                        cnt_read <= cnt_read + 1 ;
                    end
                end
                2:
                begin
                    if (cnt==3)
                    begin
                        cnt_read <= 26 ;
                    end
                    else if (cnt==7)
                    begin
                        cnt_read <= 34 ;
                    end
                    else if (cnt==11)
                    begin
                        cnt_read <= 42 ;
                    end
                    else if (cnt < 15)
                    begin
                        cnt_read <= cnt_read + 1 ;
                    end
                end
                3:
                begin
                    if (cnt==7)
                    begin
                        cnt_read <= 84 ;
                    end
                    else if (cnt==15)
                    begin
                        cnt_read <= 100 ;
                    end
                    else if (cnt==23)
                    begin
                        cnt_read <= 116 ;
                    end
                    else if (cnt==31)
                    begin
                        cnt_read <= 132 ;
                    end
                    else if (cnt==39)
                    begin
                        cnt_read <= 148 ;
                    end
                    else if (cnt==47)
                    begin
                        cnt_read <= 164 ;
                    end
                    else if (cnt==55)
                    begin
                        cnt_read <= 180 ;
                    end
                    else if (cnt < 63 )
                    begin
                        cnt_read <= cnt_read + 1 ;
                    end
                end
            endcase
        end
        else if (next_state==STATE7_option7)
        begin
            case (IMAGE_size)
                1:
                begin
                    if (cnt==0)
                        cnt_read <= 0 ;
                end
                2:
                begin
                    if (cnt==0)
                        cnt_read <= 18 ;
                end
                3:
                begin
                    if (cnt==0)
                    begin
                        cnt_read <= 68 ;
                    end
                end
            endcase
        end
    end
end
//=======================================================================================
//        cnt for write
//=======================================================================================
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        cnt_write <= 0;
    end
    else
    begin
        case (current_state)
            //------------Flip-----------------------------------------------------------
            STATE2_option2:
            begin
                case (IMAGE_size)
                    1:
                    begin
                        if (cnt==1)
                        begin
                            cnt_write <= 3 ;
                        end
                        else if (cnt==5)
                        begin
                            cnt_write <= 7 ;
                        end
                        else if (cnt==9)
                        begin
                            cnt_write <= 11 ;
                        end
                        else if (cnt==13)
                        begin
                            cnt_write <= 15 ;
                        end
                        else if (cnt<=17)
                        begin
                            cnt_write <= cnt_write - 1 ;
                        end
                    end
                    2:
                    begin
                        if (cnt==1)
                        begin
                            cnt_write <= 7 ;
                        end
                        else if (cnt==9)
                        begin
                            cnt_write <= 15 ;
                        end
                        else if (cnt==17)
                        begin
                            cnt_write <= 23 ;
                        end
                        else if (cnt==25)
                        begin
                            cnt_write <= 31 ;
                        end
                        else if (cnt==33)
                        begin
                            cnt_write <= 39 ;
                        end
                        else if (cnt==41)
                        begin
                            cnt_write <= 47 ;
                        end
                        else if (cnt==49)
                        begin
                            cnt_write <= 55 ;
                        end
                        else if (cnt==57)
                        begin
                            cnt_write <= 63 ;
                        end
                        else if (cnt<=65)
                        begin
                            cnt_write <= cnt_write - 1 ;
                        end
                    end
                    3:
                    begin
                        if (cnt==1)
                        begin
                            cnt_write <= 15 ;
                        end
                        else if (cnt==17)
                        begin
                            cnt_write <= 31 ;
                        end
                        else if (cnt==33)
                        begin
                            cnt_write <= 47 ;
                        end
                        else if (cnt==49)
                        begin
                            cnt_write <= 63 ;
                        end
                        else if (cnt==65)
                        begin
                            cnt_write <= 79 ;
                        end
                        else if (cnt==81)
                        begin
                            cnt_write <= 95 ;
                        end
                        else if (cnt==97)
                        begin
                            cnt_write <= 111 ;
                        end
                        else if (cnt==113)
                        begin
                            cnt_write <= 127 ;
                        end
                        else if (cnt==129)
                        begin
                            cnt_write <= 143 ;
                        end
                        else if (cnt==145)
                        begin
                            cnt_write <= 159 ;
                        end
                        else if (cnt==161)
                        begin
                            cnt_write <= 175 ;
                        end
                        else if (cnt==177)
                        begin
                            cnt_write <= 191 ;
                        end
                        else if (cnt==193)
                        begin
                            cnt_write <= 207 ;
                        end
                        else if (cnt==209)
                        begin
                            cnt_write <= 223 ;
                        end
                        else if (cnt==225)
                        begin
                            cnt_write <= 239 ;
                        end
                        else if (cnt==241)
                        begin
                            cnt_write <= 255 ;
                        end
                        else if (cnt<=257)
                        begin
                            cnt_write <= cnt_write - 1 ;
                        end
                    end
                endcase
            end
            STATE3_option3:
            begin
                case (IMAGE_size)
                    1:
                    begin
                        if (cnt==1)
                        begin
                            cnt_write <= 12 ;
                        end
                        else if (cnt==5)
                        begin
                            cnt_write <= 8 ;
                        end
                        else if (cnt==9)
                        begin
                            cnt_write <= 4 ;
                        end
                        else if (cnt==13)
                        begin
                            cnt_write <= 0 ;
                        end
                        else if (cnt<=17)
                        begin
                            cnt_write <= cnt_write + 1 ;
                        end
                    end
                    2:
                    begin
                        if (cnt==1)
                        begin
                            cnt_write <= 56 ;
                        end
                        else if (cnt==9)
                        begin
                            cnt_write <= 48 ;
                        end
                        else if (cnt==17)
                        begin
                            cnt_write <= 40 ;
                        end
                        else if (cnt==25)
                        begin
                            cnt_write <= 32 ;
                        end
                        else if (cnt==33)
                        begin
                            cnt_write <= 24 ;
                        end
                        else if (cnt==41)
                        begin
                            cnt_write <= 16 ;
                        end
                        else if (cnt==49)
                        begin
                            cnt_write <= 8 ;
                        end
                        else if (cnt==57)
                        begin
                            cnt_write <= 0 ;
                        end
                        else if (cnt<=65)
                        begin
                            cnt_write <= cnt_write + 1 ;
                        end
                    end
                    3:
                    begin
                        if (cnt==1)
                        begin
                            cnt_write <= 240 ;
                        end
                        else if (cnt==17)
                        begin
                            cnt_write <= 224 ;
                        end
                        else if (cnt==33)
                        begin
                            cnt_write <= 208 ;
                        end
                        else if (cnt==49)
                        begin
                            cnt_write <= 192 ;
                        end
                        else if (cnt==65)
                        begin
                            cnt_write <= 176 ;
                        end
                        else if (cnt==81)
                        begin
                            cnt_write <= 160 ;
                        end
                        else if (cnt==97)
                        begin
                            cnt_write <= 144 ;
                        end
                        else if (cnt==113)
                        begin
                            cnt_write <= 128 ;
                        end
                        else if (cnt==129)
                        begin
                            cnt_write <= 112 ;
                        end
                        else if (cnt==145)
                        begin
                            cnt_write <= 96 ;
                        end
                        else if (cnt==161)
                        begin
                            cnt_write <= 80 ;
                        end
                        else if (cnt==177)
                        begin
                            cnt_write <= 64 ;
                        end
                        else if (cnt==193)
                        begin
                            cnt_write <= 48 ;
                        end
                        else if (cnt==209)
                        begin
                            cnt_write <= 32 ;
                        end
                        else if (cnt==225)
                        begin
                            cnt_write <= 16 ;
                        end
                        else if (cnt==241)
                        begin
                            cnt_write <= 0 ;
                        end
                        else if (cnt<=257)
                        begin
                            cnt_write <= cnt_write + 1 ;
                        end
                    end
                endcase
            end
            STATE4_option4:
            begin
                case (IMAGE_size)
                    1:
                    begin
                        if (cnt==1)
                        begin
                            cnt_write <= 15 ;
                        end
                        else if (cnt==5)
                        begin
                            cnt_write <= 14 ;
                        end
                        else if (cnt==9)
                        begin
                            cnt_write <= 13 ;
                        end
                        else if (cnt==13)
                        begin
                            cnt_write <= 12 ;
                        end
                        else if (cnt<=17)
                        begin
                            cnt_write <= cnt_write - 4 ;
                        end
                    end
                    2:
                    begin
                        if (cnt==1)
                        begin
                            cnt_write <= 63 ;
                        end
                        else if (cnt==9)
                        begin
                            cnt_write <= 62 ;
                        end
                        else if (cnt==17)
                        begin
                            cnt_write <= 61 ;
                        end
                        else if (cnt==25)
                        begin
                            cnt_write <= 60 ;
                        end
                        else if (cnt==33)
                        begin
                            cnt_write <= 59 ;
                        end
                        else if (cnt==41)
                        begin
                            cnt_write <= 58 ;
                        end
                        else if (cnt==49)
                        begin
                            cnt_write <= 57 ;
                        end
                        else if (cnt==57)
                        begin
                            cnt_write <= 56 ;
                        end
                        else if (cnt<=65)
                        begin
                            cnt_write <= cnt_write - 8 ;
                        end
                    end
                    3:
                    begin
                        if (cnt==1)
                        begin
                            cnt_write <= 255 ;
                        end
                        else if (cnt==17)
                        begin
                            cnt_write <= 254 ;
                        end
                        else if (cnt==33)
                        begin
                            cnt_write <= 253 ;
                        end
                        else if (cnt==49)
                        begin
                            cnt_write <= 252 ;
                        end
                        else if (cnt==65)
                        begin
                            cnt_write <= 251 ;
                        end
                        else if (cnt==81)
                        begin
                            cnt_write <= 250 ;
                        end
                        else if (cnt==97)
                        begin
                            cnt_write <= 249 ;
                        end
                        else if (cnt==113)
                        begin
                            cnt_write <= 248 ;
                        end
                        else if (cnt==129)
                        begin
                            cnt_write <= 247 ;
                        end
                        else if (cnt==145)
                        begin
                            cnt_write <= 246 ;
                        end
                        else if (cnt==161)
                        begin
                            cnt_write <= 245 ;
                        end
                        else if (cnt==177)
                        begin
                            cnt_write <= 244 ;
                        end
                        else if (cnt==193)
                        begin
                            cnt_write <= 243 ;
                        end
                        else if (cnt==209)
                        begin
                            cnt_write <= 242 ;
                        end
                        else if (cnt==225)
                        begin
                            cnt_write <= 241 ;
                        end
                        else if (cnt==241)
                        begin
                            cnt_write <= 240 ;
                        end
                        else if (cnt<=257)
                        begin
                            cnt_write <= cnt_write - 16 ;
                        end
                    end
                endcase
            end
            STATE5_option5:
            begin
                case (IMAGE_size)
                    1:
                    begin
                        if (cnt==1)
                        begin
                            cnt_write <= 0 ;
                        end
                        else if (cnt==5)
                        begin
                            cnt_write <= 1 ;
                        end
                        else if (cnt==9)
                        begin
                            cnt_write <= 2 ;
                        end
                        else if (cnt==13)
                        begin
                            cnt_write <= 3 ;
                        end
                        else if (cnt<=17)
                        begin
                            cnt_write <= cnt_write + 4 ;
                        end
                    end
                    2:
                    begin
                        if (cnt==1)
                        begin
                            cnt_write <= 0 ;
                        end
                        else if (cnt==9)
                        begin
                            cnt_write <= 1 ;
                        end
                        else if (cnt==17)
                        begin
                            cnt_write <= 2 ;
                        end
                        else if (cnt==25)
                        begin
                            cnt_write <= 3 ;
                        end
                        else if (cnt==33)
                        begin
                            cnt_write <= 4 ;
                        end
                        else if (cnt==41)
                        begin
                            cnt_write <= 5 ;
                        end
                        else if (cnt==49)
                        begin
                            cnt_write <= 6 ;
                        end
                        else if (cnt==57)
                        begin
                            cnt_write <= 7 ;
                        end
                        else if (cnt<=65)
                        begin
                            cnt_write <= cnt_write + 8 ;
                        end
                    end
                    3:
                    begin
                        if (cnt==1)
                        begin
                            cnt_write <= 0 ;
                        end
                        else if (cnt==17)
                        begin
                            cnt_write <= 1 ;
                        end
                        else if (cnt==33)
                        begin
                            cnt_write <= 2 ;
                        end
                        else if (cnt==49)
                        begin
                            cnt_write <= 3 ;
                        end
                        else if (cnt==65)
                        begin
                            cnt_write <= 4 ;
                        end
                        else if (cnt==81)
                        begin
                            cnt_write <= 5 ;
                        end
                        else if (cnt==97)
                        begin
                            cnt_write <= 6 ;
                        end
                        else if (cnt==113)
                        begin
                            cnt_write <= 7 ;
                        end
                        else if (cnt==129)
                        begin
                            cnt_write <= 8 ;
                        end
                        else if (cnt==145)
                        begin
                            cnt_write <= 9 ;
                        end
                        else if (cnt==161)
                        begin
                            cnt_write <= 10 ;
                        end
                        else if (cnt==177)
                        begin
                            cnt_write <= 11 ;
                        end
                        else if (cnt==193)
                        begin
                            cnt_write <= 12 ;
                        end
                        else if (cnt==209)
                        begin
                            cnt_write <= 13 ;
                        end
                        else if (cnt==225)
                        begin
                            cnt_write <= 14 ;
                        end
                        else if (cnt==241)
                        begin
                            cnt_write <= 15 ;
                        end
                        else if (cnt<=257)
                        begin
                            cnt_write <= cnt_write + 16 ;
                        end
                    end
                endcase
            end
            //===========================================================================

            STATE1_option1:
            begin

            end

            STATE6_option6:
            begin

            end
            STATE7_option7:
            begin
                case (IMAGE_size)
                    1:
                    begin
                        if (cnt==3)
                        begin
                            cnt_write <= 0 ;
                        end
                        else if (cnt<=20)
                        begin
                            cnt_write <= cnt_write + 1 ;
                        end
                    end
                    2:
                    begin
                        if (cnt==3)
                        begin
                            cnt_write <= 0 ;
                        end
                        else if (cnt<=20)
                        begin
                            cnt_write <= cnt_write + 1 ;
                        end
                    end
                    3:
                    begin
                        if (cnt==3)
                        begin
                            cnt_write <= 0 ;
                        end
                        else if (cnt<=68)
                        begin
                            cnt_write <= cnt_write + 1 ;
                        end
                    end
                endcase
            end
            STATE8_option0:
            begin

            end
            IDLE:
            begin
                cnt_write <= 0;
            end
            default:
                cnt_write <= 0;
        endcase
    end
end

// comparator
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        A <= 0;
    end
    else
    begin
        if (current_state==STATE1_option1)
        begin
            case (img_size)
                2:
                begin
                    if (cnt==1)
                        A <= 0;
                    else if (cnt==6)
                    begin
                        A <= MEMO_OUT;
                    end
                    else if (cnt==10)
                    begin
                        A <= MEMO_OUT;
                    end
                    else if (cnt==14)
                    begin
                        A <= MEMO_OUT;
                    end
                    else if (cnt==18)
                    begin
                        A <= MEMO_OUT;
                    end
                    else if (cnt==22)
                    begin
                        A <= MEMO_OUT;
                    end
                    else if (cnt==26)
                    begin
                        A <= MEMO_OUT;
                    end
                    else if (cnt==30)
                    begin
                        A <= MEMO_OUT;
                    end
                    else if (cnt==34)
                    begin
                        A <= MEMO_OUT;
                    end
                    else if (cnt==38)
                    begin
                        A <= MEMO_OUT;
                    end
                    else if (cnt==42)
                    begin
                        A <= MEMO_OUT;
                    end
                    else if (cnt==46)
                    begin
                        A <= MEMO_OUT;
                    end
                    else if (cnt==50)
                    begin
                        A <= MEMO_OUT;
                    end
                    else if (cnt==54)
                    begin
                        A <= MEMO_OUT;
                    end
                    else if (cnt==58)
                    begin
                        A <= MEMO_OUT;
                    end
                    else if (cnt==62)
                    begin
                        A <= MEMO_OUT;
                    end
                    else if (cnt < 66)
                    begin
                        if (MEMO_OUT >= A)
                        begin
                            A <= MEMO_OUT;
                        end
                    end
                end
                3:
                begin

                end
            endcase
        end
        else
        begin
            A <= 0;
        end
    end
end


//====================================================================================================================================
/*====================================================================================================================================
   MM      MM      AAA     IIIIIIII  NN      NN           CCCCCC    IIIIIIII  RRRRRRRR      CCCCCC   UU      UU  IIIIIIII TTTTTTTTTT
   MMM    MMM     AA AA       II     NNNN    NN         CC             II     RR      RR  CC         UU      UU     II        TT            
   MM M  M MM    AA   AA      II     NN  NN  NN        CC              II     RRRRRRRRR  CC          UU      UU     II        TT            
   MM  MM  MM   AAAAAAAAA     II     NN    NNNN         CC      CC     II     RR   RRR    CC      CC  UU    UU      II        TT                      
   MM      MM  AA       AA IIIIIIII  NN      NN          CCCCCCCC   IIIIIIII  RR     RRR   CCCCCCCC    UUUUUU    IIIIIIII     TT           
*///===================================================================================================================================
//=====================================================================================================================================
integer i,j;
always@(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        DATA  <= 0;
        address_1 <= 0;
        address_2 <= 0;
        IMAGE_size <= 0;
        B_opt0 <= 0 ;
        B_opt1 <= 0 ;
        B_opt2 <= 0 ;
        B_opt3 <= 0 ;
        B_opt4 <= 0 ;
        B_opt5 <= 0 ;
        B_opt6 <= 0 ;
        B_opt7 <= 0 ;
        cnt_action <= 0 ;

        ADR_1 <= 0 ;
        ADR_2 <= 0 ;

        WEN_W <= 0;
        WEN_R <= 0;
        whichMEMO <= 0;

        sum_inA <= 0;
        sum_inB <= 0;
        mu_inA_1 <= 0;
        mu_inB_1 <= 0;
        ad_in    <= 0;
        di_inA   <= 0;

        B <= 0;
        for ( i=0 ; i<=31 ; i=i+1 )
        begin
            Action[i] <= 0;
        end
        for ( j=0 ;j<=8 ; j=j+1 )
        begin
            Tenplate[j] <= 0;
        end
    end
    else
    begin
        /*-----------------------------------------------------------------------------------
            IIIIIIII  NN      NN  PPPPPPPP   UU      UU  TTTTTTTTTT
               II     NNNN    NN  PP     PP  UU      UU      TT              
               II     NN  NN  NN  PP     PP  UU      UU      TT              
               II     NN    NNNN  PPPPPPPP    UU    UU       TT                        
            IIIIIIII  NN      NN  PP           UUUUUU        TT             
        *///---------------------------------------------------------------------------------
        if (in_valid)
        begin
            whichMEMO <= 1;
            WEN_W <= 0 ;
            WEN_R <= 1 ;
            ADR_2  <= cnt;
            DATA <= image ;
            Tenplate[cnt] <= template;
            case (img_size)
                4:
                begin
                    IMAGE_size <= 1;
                end
                8:
                begin
                    IMAGE_size <= 2;
                end
                16:
                begin
                    IMAGE_size <= 3;
                end
            endcase
        end
        else if (in_valid_2)
        begin
            whichMEMO <= 0;
            WEN_W <= 1;
            Data_1 <= 0;
            Action[15] <= action ;
            for ( i=0 ; i<=14 ; i=i+1 )
            begin
                Action[i] <= Action[i+1] ;
            end
        end
        else
        begin
            case (current_state)
                /*-----------------------------------------------------------------------------------
                         HH      HH    oooooo    MM      MM  EEEEEEEEEE                                    
                         HH      HH  oo      oo  MMM    MMM  EE                                            
                         HHHHHHHHHH oo        oo MM M  M MM  EEEEEEEEE                                     
                         HH      HH  oo      oo  MM  MM  MM  EE                                            
                         HH      HH    oooooo    MM      MM  EEEEEEEEEE                                    
                *///--------------------------------------------------------------------------------- 
                STATE0_HOME:
                begin
                    F_opt0 <= 0;
                    F_opt1 <= 0;
                    F_opt2 <= 0;
                    F_opt3 <= 0;
                    F_opt4 <= 0;
                    F_opt5 <= 0;
                    F_opt6 <= 0;
                    F_opt7 <= 0;
                    if (cnt_action==16)
                        B_opt0 <= 1;
                    else if (Action[cnt_action]==1)
                    begin
                        B_opt1 <= 1;
                    end
                    else if (Action[cnt_action]==2)
                    begin
                        B_opt2 <= 1;
                    end
                    else if (Action[cnt_action]==3)
                    begin
                        B_opt3 <= 1;
                    end
                    else if (Action[cnt_action]==4)
                    begin
                        B_opt4 <= 1;
                    end
                    else if (Action[cnt_action]==5)
                    begin
                        B_opt5 <= 1;
                    end
                    else if (Action[cnt_action]==6)
                    begin
                        B_opt6 <= 1;
                    end
                    else if (Action[cnt_action]==7)
                    begin
                        B_opt7 <= 1;
                    end
                    else if (Action[cnt_action]==0)
                        cnt_action <= cnt_action + 1;
                end



                /*-----------------------------------------------------------------------------------
                               oooooo     PPPPPPPP  TTTTTTTTTT     11                   
                             oo      oo   PP     PP     TT        111 
                            oo        oo  PP     PP     TT         11        
                             oo      oo   PPPPPPPP      TT         11 
                               oooooo     PP            TT      11111111       Max Pooling
                *///--------------------------------------------------------------------------------- 
                STATE1_option1:
                begin
                    B_opt1 <= 0;
                    if (F_opt1)
                    begin
                        cnt_action <= cnt_action + 1;
                    end
                    else if (IMAGE_size==1) // Image is 4*4
                    begin
                        F_opt1 <= 1;
                    end

                    else if (IMAGE_size==2) // Image is 8*8
                    begin
                        if (cnt<=1)
                        begin
                            ADR_1 <= cnt_read;
                        end
                        else if (cnt == 5)
                        begin
                            ADR_1 <= cnt_read;
                            ADR_2 <= 0;
                        end
                        else if (cnt==)
                        begin

                        end
                        else if (cnt <= 70)
                        begin
                            WEN_W <= 0;
                            ADR_1 <= cnt_read;
                        end

                        else if (cnt==66)
                        begin
                            F_opt1 <= 1;
                            WEN_R <= 1;
                            WEN_W <= 1;
                            whichMEMO <= whichMEMO + 1 ;
                        end



                    end
                    else if (IMAGE_size==3) // Image is 16*16
                    begin

                    end

                end
            end
            /*-----------------------------------------------------------------------------------
                oooooo     PPPPPPPP  TTTTTTTTTT   2222222          1 2 3 4       4 3 2 1                             
              oo      oo   PP     PP     TT      2       22        1 2 3 4       4 3 2 1           
             oo        oo  PP     PP     TT            222         1 2 3 4   =>  4 3 2 1             
              oo      oo   PPPPPPPP      TT         222            1 2 3 4       4 3 2 1                
                oooooo     PP            TT      22222222222      Horizontal Flip
            *///--------------------------------------------------------------------------------- 
            STATE2_option2:
            begin
                B_opt2 <= 0;
                if (F_opt2)
                begin
                    cnt_action <= cnt_action + 1;
                end
                else if (IMAGE_size==1) // Image is 4*4
                begin
                    if (cnt<=1)
                    begin
                        ADR_1 <= cnt;
                    end
                    else if (cnt <= 17)
                    begin
                        WEN_W <= 0;
                        ADR_1 <= cnt;
                        ADR_2 <= cnt_write ;
                        DATA <= MEMO_OUT ;

                    end

                    else if (cnt==18)
                    begin
                        F_opt2 <= 1;
                        WEN_R <= 1;
                        WEN_W <= 1;
                        whichMEMO <= whichMEMO + 1 ;
                    end
                end
                else if (IMAGE_size==2) // Image is 8*8
                begin
                    if (cnt<=1)
                    begin
                        ADR_1 <= cnt;
                    end
                    else if (cnt <= 65)
                    begin
                        WEN_W <= 0;
                        ADR_1 <= cnt;
                        ADR_2 <= cnt_write ;
                        DATA <= MEMO_OUT ;

                    end

                    else if (cnt==66)
                    begin
                        F_opt2 <= 1;
                        WEN_R <= 1;
                        WEN_W <= 1;
                        whichMEMO <= whichMEMO + 1 ;
                    end
                end
                else if (IMAGE_size==3) // Image is 16*16
                begin
                    if (cnt<=1)
                    begin
                        ADR_1 <= cnt;
                    end
                    else if (cnt <= 257)
                    begin
                        WEN_W <= 0;
                        ADR_1 <= cnt;
                        ADR_2 <= cnt_write ;
                        DATA <= MEMO_OUT ;

                    end

                    else if (cnt==258)
                    begin
                        F_opt2 <= 1;
                        WEN_R <= 1;
                        WEN_W <= 1;
                        whichMEMO <= whichMEMO + 1 ;
                    end
                end
            end
            /*-----------------------------------------------------------------------------------
                oooooo     PPPPPPPP  TTTTTTTTTT    3333333                         
              oo      oo   PP     PP     TT       3      333                     
             oo        oo  PP     PP     TT           33333                     
              oo      oo   PPPPPPPP      TT       3      333                    
                oooooo     PP            TT        33333333      Vertical Flip     
            *///--------------------------------------------------------------------------------- 
            STATE3_option3:
            begin
                B_opt3 <= 0;
                if (F_opt3)
                begin
                    cnt_action <= cnt_action + 1;
                end
                else if (IMAGE_size==1) // Image is 4*4
                begin
                    if (cnt<=1)
                    begin
                        ADR_1 <= cnt;
                    end
                    else if (cnt <= 17)
                    begin
                        WEN_W <= 0;
                        ADR_1 <= cnt;
                        ADR_2 <= cnt_write ;
                        DATA <= MEMO_OUT ;

                    end
                    else if (cnt==18)
                    begin
                        F_opt3 <= 1;
                        WEN_R <= 1;
                        WEN_W <= 1;
                        whichMEMO <= whichMEMO + 1 ;
                    end
                end
                else if (IMAGE_size==2) // Image is 8*8
                begin
                    if (cnt<=1)
                    begin
                        ADR_1 <= cnt;
                    end
                    else if (cnt <= 65)
                    begin
                        WEN_W <= 0;
                        ADR_1 <= cnt;
                        ADR_2 <= cnt_write ;
                        DATA <= MEMO_OUT ;
                    end
                    else if (cnt==66)
                    begin
                        F_opt3 <= 1;
                        WEN_R <= 1;
                        WEN_W <= 1;
                        whichMEMO <= whichMEMO + 1 ;
                    end
                end
                else if (IMAGE_size==3) // Image is 16*16
                begin
                    if (cnt<=1)
                    begin
                        ADR_1 <= cnt;
                    end
                    else if (cnt <= 257)
                    begin
                        WEN_W <= 0;
                        ADR_1 <= cnt;
                        ADR_2 <= cnt_write ;
                        DATA <= MEMO_OUT ;

                    end
                    else if (cnt==258)
                    begin
                        F_opt3 <= 1;
                        WEN_R <= 1;
                        WEN_W <= 1;
                        whichMEMO <= whichMEMO + 1 ;
                    end
                end
            end
            /*-----------------------------------------------------------------------------------
                oooooo     PPPPPPPP  TTTTTTTTTT       44          1 2 3     9 6 3               
              oo      oo   PP     PP     TT          444          4 5 6  => 8 5 2               
             oo        oo  PP     PP     TT        44 44          7 8 9     7 4 1         
              oo      oo   PPPPPPPP      TT       444444444                                               
                oooooo     PP            TT           44        Left-diagonal Flip             
            *///---------------------------------------------------------------------------------- 
            STATE4_option4:
            begin
                B_opt4 <= 0;
                if (F_opt4)
                begin
                    cnt_action <= cnt_action + 1;
                end
                else if (IMAGE_size==1) // Image is 4*4
                begin
                    if (cnt<=1)
                    begin
                        ADR_1 <= cnt;
                    end
                    else if (cnt <= 17)
                    begin
                        WEN_W <= 0;
                        ADR_1 <= cnt;
                        ADR_2 <= cnt_write ;
                        DATA <= MEMO_OUT ;

                    end
                    else if (cnt==18)
                    begin
                        F_opt4 <= 1;
                        WEN_R <= 1;
                        WEN_W <= 1;
                        whichMEMO <= whichMEMO + 1 ;
                    end
                end
                else if (IMAGE_size==2) // Image is 8*8
                begin
                    if (cnt<=1)
                    begin
                        ADR_1 <= cnt;
                    end
                    else if (cnt <= 65)
                    begin
                        WEN_W <= 0;
                        ADR_1 <= cnt;
                        ADR_2 <= cnt_write ;
                        DATA <= MEMO_OUT ;

                    end
                    else if (cnt==66)
                    begin
                        F_opt4 <= 1;
                        WEN_R <= 1;
                        WEN_W <= 1;
                        whichMEMO <= whichMEMO + 1 ;
                    end
                end
                else if (IMAGE_size==3) // Image is 16*16
                begin
                    if (cnt<=1)
                    begin
                        ADR_1 <= cnt;
                    end
                    else if (cnt <= 257)
                    begin
                        WEN_W <= 0;
                        ADR_1 <= cnt;
                        ADR_2 <= cnt_write ;
                        DATA <= MEMO_OUT ;

                    end
                    else if (cnt==258)
                    begin
                        F_opt4 <= 1;
                        WEN_R <= 1;
                        WEN_W <= 1;
                        whichMEMO <= whichMEMO + 1 ;
                    end
                end
            end
            /*------------------------------------------------------------------------------------
                oooooo     PPPPPPPP  TTTTTTTTTT    5555555        1 2 3     1 4 6         
              oo      oo   PP     PP     TT        55             4 5 6  => 2 5 8   
             oo        oo  PP     PP     TT        5555555        7 8 9     3 6 9 
              oo      oo   PPPPPPPP      TT               55  
                oooooo     PP            TT       555555555     Right-diagonal Flip
            *///-----------------------------------------------------------------------------------
            STATE5_option5:
            begin
                B_opt5 <= 0;
                if (F_opt5)
                begin
                    cnt_action <= cnt_action + 1;
                end
                else if (IMAGE_size==1) // Image is 4*4
                begin
                    if (cnt<=1)
                    begin
                        ADR_1 <= cnt;
                    end
                    else if (cnt <= 17)
                    begin
                        WEN_W <= 0;
                        ADR_1 <= cnt;
                        ADR_2 <= cnt_write ;
                        DATA <= MEMO_OUT ;

                    end
                    else if (cnt==18)
                    begin
                        F_opt5 <= 1;
                        WEN_R <= 1;
                        WEN_W <= 1;
                        whichMEMO <= whichMEMO + 1 ;
                    end

                end
                else if (IMAGE_size==2) // Image is 8*8
                begin
                    if (cnt<=1)
                    begin
                        ADR_1 <= cnt;
                    end
                    else if (cnt <= 65)
                    begin
                        WEN_W <= 0;
                        ADR_1 <= cnt;
                        ADR_2 <= cnt_write ;
                        DATA <= MEMO_OUT ;

                    end
                    else if (cnt==66)
                    begin
                        F_opt5 <= 1;
                        WEN_R <= 1;
                        WEN_W <= 1;
                        whichMEMO <= whichMEMO + 1 ;
                    end
                end
                else if (IMAGE_size==3) // Image is 16*16
                begin
                    if (cnt<=1)
                    begin
                        ADR_1 <= cnt;
                    end
                    else if (cnt <= 257)
                    begin
                        WEN_W <= 0;
                        ADR_1 <= cnt;
                        ADR_2 <= cnt_write ;
                        DATA <= MEMO_OUT ;

                    end
                    else if (cnt==258)
                    begin
                        F_opt5 <= 1;
                        WEN_R <= 1;
                        WEN_W <= 1;
                        whichMEMO <= whichMEMO + 1 ;
                    end

                end
            end

            /*-----------------------------------------------------------------------------------
                oooooo     PPPPPPPP  TTTTTTTTTT    6666666                                              
              oo      oo   PP     PP     TT       66                                              
             oo        oo  PP     PP     TT       666666666                                        
              oo      oo   PPPPPPPP      TT       66      66                                                  
                oooooo     PP            TT        66666666         Zoom-in
            *///----------------------------------------------------------------------------------
            STATE6_option6:
            begin

            end
            /*-----------------------------------------------------------------------------------------
                 oooooo     PPPPPPPP  TTTTTTTTTT  777777777             
               oo      oo   PP     PP     TT            77      
              oo        oo  PP     PP     TT           77 
               oo      oo   PPPPPPPP      TT          77                  
                 oooooo     PP            TT         77      Shortcut + Brightness Adjustment
            *///----------------------------------------------------------------------------------------
            STATE7_option7:
            begin
                B_opt7 <= 0;
                if (F_opt7)
                begin
                    cnt_action <= cnt_action + 1;
                end
                else if (IMAGE_size==1) // Image is 4*4
                begin
                    if (cnt==4)
                    begin
                        ADR_1 <= cnt_read;
                        ADR_2 <= cnt_write;
                        di_inA <= MEMO_OUT;
                        ad_in  <= di_out;
                        DATA <= ad_out ;
                        WEN_W <= 0;
                    end
                    else if (cnt<=17)
                    begin
                        ADR_1 <= cnt_read;
                        ADR_2 <= cnt_write;
                        di_inA <= MEMO_OUT;
                        ad_in  <= di_out;
                        DATA <= ad_out ;
                    end
                    else if (cnt<=19)
                    begin
                        ADR_2 <= cnt_read;
                        ad_in  <= di_out;
                        DATA  <= ad_out ;
                    end
                    else if (cnt==20)
                    begin
                        F_opt7 <= 1;
                        WEN_R <= 1;
                        WEN_W <= 1;
                        whichMEMO <= whichMEMO + 1 ;
                    end
                end
                else if (IMAGE_size==2) // Image is 8*8
                begin
                    if (cnt==4)
                    begin
                        ADR_1 <= cnt_read;
                        ADR_2 <= cnt_write;
                        di_inA <= MEMO_OUT;
                        ad_in  <= di_out;
                        DATA <= ad_out ;
                        WEN_W <= 0;
                    end
                    else if (cnt<=17)
                    begin
                        ADR_1 <= cnt_read;
                        ADR_2 <= cnt_write;
                        di_inA <= MEMO_OUT;
                        ad_in  <= di_out;
                        DATA <= ad_out ;
                    end
                    else if (cnt<=19)
                    begin
                        ADR_2 <= cnt_write;
                        ad_in  <= di_out;
                        DATA  <= ad_out ;
                    end
                    else if (cnt==20)
                    begin
                        F_opt7 <= 1;
                        WEN_R <= 1;
                        WEN_W <= 1;
                        whichMEMO <= whichMEMO + 1 ;
                    end
                end
                else if (IMAGE_size==3) // Image is 16*16
                begin
                    if (cnt==4)
                    begin
                        ADR_1 <= cnt_read;
                        ADR_2 <= cnt_write;
                        di_inA <= MEMO_OUT;
                        ad_in  <= di_out;
                        DATA <= ad_out ;
                        WEN_W <= 0;
                    end
                    else if (cnt<=65)
                    begin
                        ADR_1 <= cnt_read;
                        ADR_2 <= cnt_write;
                        di_inA <= MEMO_OUT;
                        ad_in  <= di_out;
                        DATA <= ad_out ;
                    end
                    else if (cnt<=67)
                    begin
                        ADR_2 <= cnt_write;
                        ad_in  <= di_out;
                        DATA  <= ad_out ;
                    end
                    else if (cnt==68)
                    begin
                        F_opt7 <= 1;
                        WEN_R <= 1;
                        WEN_W <= 1;
                        whichMEMO <= whichMEMO + 1 ;
                    end
                end
            end

            /*-----------------------------------------------------------------------------------------
                 oooooo     PPPPPPPP  TTTTTTTTTT   000000                                              
               oo      oo   PP     PP     TT      00    00                                       
              oo        oo  PP     PP     TT      00    00                                        
               oo      oo   PPPPPPPP      TT      00    00                                        
                 oooooo     PP            TT       000000                                             
            *///----------------------------------------------------------------------------------------
            STATE8_option0:
            begin
                B_opt0 <= 0;
                if (F_opt0)
                begin
                    cnt_action <= 0;
                end
                else if (IMAGE_size==1) // Image is 4*4
                begin
                    if (cnt<=1)
                    begin
                        ADR_1 <= cnt;
                    end
                    else if (cnt<=2)
                    begin
                        mu_inA_1 <= MEMO_OUT;
                        ADR_1    <= cnt;
                        mu_inB_1 <= Tenplate[cnt+5] ;
                    end
                    else if (cnt<=3)
                    begin
                        ADR_1 <= 4;
                    end

                    else if (cnt==145)
                    begin
                        F_opt0 <= 1;
                        WEN_R <= 1;
                        WEN_W <= 1;
                        whichMEMO <= whichMEMO + 1 ;
                    end

                end
                else if (IMAGE_size==2) // Image is 8*8
                begin

                end
                else if (IMAGE_size==3) // Image is 16*16
                begin

                end
            end

            STATE9_OUTPUT:
            begin

            end
        endcase

    end

end
end



// Output Assignment
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        out_valid   <= 0 ;
        out_x       <= 0 ;
        out_y       <= 0 ;
        out_img_pos <= 0 ;
        out_value   <= 0 ;
    end

    else if( current_state == STATE9_OUTPUT )
    begin
        out_valid   <= 0 ;
        out_x       <= 0 ;
        out_y       <= 0 ;
        out_img_pos <= 0 ;
        out_value   <= 0 ;
    end

    else
    begin
        out_valid   <= 0 ;
        out_x       <= 0 ;
        out_y       <= 0 ;
        out_img_pos <= 0 ;
        out_value   <= 0 ;
    end
end

/*-----------------------------------------------------------------------------------------
     CCCCCC      oooooo     MM      MM   BBBBBBB    IIIIIIII  NN      NN  EEEEEEEEEE                                         
   CC          oo      oo   MMM    MMM   BB     BB     II     NNNN    NN  EE                                            
  CC          oo        oo  MM M  M MM   BBBBBBBB      II     NN  NN  NN  EEEEEEEEE                                      
   CC      CC  oo      oo   MM  MM  MM   BB      BB    II     NN    NNNN  EE                                             
    CCCCCCCC     oooooo     MM      MM   BBBBBBBBB  IIIIIIII  NN      NN  EEEEEEEEEE                                        
*///----------------------------------------------------------------------------------------

always @(*)
begin
    case (whichMEMO)
        0: // means I read MEMO1 and write MEMO2
        begin
            Data_2 = DATA ;
            Data_1 = 0 ;
            MEMO_OUT = memo_OUT_1;
            address_1 =  ADR_1 ;
            address_2 = ADR_2 ;
            WEN_1 = WEN_R ;
            WEN_2 = WEN_W ;
        end
        1:
        begin
            Data_1 = DATA ;
            Data_2 = 0 ;
            MEMO_OUT = memo_OUT_2;
            address_1 = ADR_2 ;
            address_2 = ADR_1 ;
            WEN_2 = WEN_R ;
            WEN_1 = WEN_W ;
        end
    endcase

end

//the divider & adder use in Option7
always @(*)
begin
    di_out = (di_inA+1)/2 ;
    ad_out = ad_in + 49 ;

    mu_out_1= mu_inA_1 * mu_inB_1 ;


    sum_out = sum_inA + sum_inB ;
end



endmodule
