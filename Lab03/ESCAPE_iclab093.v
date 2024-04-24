module ESCAPE(
           //Input Port
           clk,
           rst_n,
           in_valid1,
           in_valid2,
           in,
           in_data,
           //Output Port
           out_valid1,
           out_valid2,
           out,
           out_data
       );

//==================INPUT OUTPUT==================//
input clk, rst_n, in_valid1, in_valid2;
input [1:0] in;
input [8:0] in_data;
output reg	out_valid1, out_valid2;
output reg [2:0] out;
output reg [8:0] out_data;
//================================================//
// Genvar & Parameters & Integer Declaration
// ===============================================================
// state
parameter IDLE         = 3'd0;
parameter STATE1_MAPP  = 3'd1; //get the MAP
parameter STATE2_TRAP  = 3'd2; //save the trap to map1
parameter STATE3_D_H_  = 3'd3; //del deadend & make hostage road
parameter STATE4_COMB  = 3'd4; //hostage make the road
parameter STATE5_WALK  = 3'd5; //walk to the goal
parameter STATE6_CALC  = 3'd6; //count
parameter STATE7_OUTPUT  = 3'd7; //output the result
//genvar

// ===============================================================
// Wire & Reg Declaration
// ===============================================================
reg [9:0] cnt;//counter
reg [2:0] countHostage;
reg [6:0] count1_1,count1_2;
reg [8:0] count2_1,count2_2;
reg [2:0] countSA ;

reg [2:0] current_state,next_state;//current & next state
reg [2:0] map [0:18] [0:18];//y,x origin
reg [0:0] map1 [0:16] [0:16];//   store traps
reg [0:0] map2 [0:18] [0:18];//   hostage road
reg [10:0] pathx,pathy;//
reg  flag_2to3,flag_3to4,flag_4to5,flag_5to6,flag_6to7,flag_6to5,flag_5to7;
reg  flag_finishD,flag_finishC,flagFinish,flagEND;//end the store trap
reg flag_save_all;
reg  [1:0] Last_step;//
reg  flagB,flagSTALL;
reg       data;
reg signed [8:0] data1,data2,data3,data4;


//use to caculate
reg signed [8:0] H3_s_1,H3_s_2,H3_s_3;//store sorting
reg signed [8:0] H3_h_1,H3_h_2,H3_h_3,H3_h_4,H2_h_1,H2_h_2,H2_1,H2_2,H4_1,H4_2,H4_3,H4_4 ;//store subract half of range
reg signed [8:0] Res1,Res2,Res3,Res4;//store the final
reg signed [8:0] half2,half3,half4;
reg [7:0] H2_value_1,H2_value_2     , H4_value_1,H4_value_2,H4_value_3,H4_value_4;
reg [0:0] H2_e_1_sign , H2_e_2_sign , H4_e_1_sign,H4_e_2_sign,H4_e_3_sign,H4_e_4_sign;
reg [3:0] H2_e_1_1 , H2_e_1_2, H2_e_2_1 , H2_e_2_2 ;
reg [3:0] H4_e_1_1 , H4_e_1_2, H4_e_2_1 , H4_e_2_2 , H4_e_4_1 , H4_e_4_2 , H4_e_3_1 , H4_e_3_2 ;
reg signed [8:0] H2_s_1,H2_s_2 ;

reg signed [8:0] H4_h_1,H4_h_2,H4_h_3,H4_h_4 ;
reg signed [8:0] H4_com1_1,H4_com1_2,H4_com1_3,H4_com1_4,H4_com2_1,H4_com2_2,H4_com2_3,H4_com2_4,H4_com3_1,H4_com3_2;
reg signed [8:0]  H4_h_b1,H4_h_s1,H4_h_b2,H4_h_s2,H4_Big ,H4_Sma ;



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
    else if(in_valid1 && cnt==288)
    begin
        cnt <= 0;
    end
    else if (current_state==STATE5_WALK)
    begin
        cnt <= 0;
    end

    //count-------------------------------------
    else if(in_valid1)
    begin
        cnt <= cnt+1;
    end
    else if (current_state == STATE1_MAPP || current_state == STATE2_TRAP)
    begin
        cnt <= cnt+1;
    end
    else if (current_state == STATE7_OUTPUT)
    begin
        cnt <= cnt+1;
    end
    else if (out_valid2)
    begin
        cnt <= cnt+1;
    end
    else if (current_state==IDLE)//cnt = output cycle
    begin
        cnt  <= 0;
    end
end
/*-----------------------------------------------------------------------------------
     FFFFFFFFF LLL           AAAA       GGGGGGG          ------------
     FF        LLL          AA  AA     G                 |          |          
     FFFFFFF   LLL         AA    AA   G     GGGGG        |          |          
     FF        LLL        AAAAAAAAAA   G     GGG         |-----------                    
     FF        LLLLLLLLL AA        AA   GGGGGGG          |                    
*///---------------------------------------------------------------------------------
//  always @(posedge clk or negedge rst_n)
// begin
//   if (~rst_n)
//   begin
//   flag_4to5 <= 0;
//   end
//   else
//   begin
STATE2_TRAP



    //   end


    // end
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
                if (in_valid1)
                    next_state = STATE1_MAPP;
                else
                    next_state = IDLE;
            end

            STATE1_MAPP: //GET THE MAP
            begin
                if (cnt == 288 && in_valid1)
                    next_state = STATE2_TRAP;
                else
                    next_state = STATE1_MAPP;
            end

            STATE2_TRAP: //SAVE THE TRAP
            begin
                if (flag_2to3==1)
                    next_state = STATE3_D_H_;
                else
                    next_state = STATE2_TRAP;
            end

            STATE3_D_H_: //Del the deadend
                if (flag_3to4==1) // have to estimate how cycles the STATE need?
                    next_state = STATE4_COMB;
                else
                    next_state = STATE3_D_H_;

            STATE4_COMB: //combine the 3 maps
                if (flag_4to5==1)
                    next_state = STATE5_WALK;
                else
                    next_state = STATE4_COMB;

            STATE5_WALK: //Walk to the goal
                if (flag_5to7==1)
                    next_state = STATE7_OUTPUT;
                else if(flag_5to6==1)
                    next_state = STATE6_CALC;
                else
                    next_state = STATE5_WALK;

            STATE6_CALC: //Walk to the goal
                // if(flag_6to7==1)
                //   next_state = STATE7_OUTPUT;
                if(flag_6to5==1)
                    next_state = STATE5_WALK;
                else
                    next_state = STATE6_CALC;

            STATE7_OUTPUT: //GET THE OUPUT
                if(flagEND)
                    next_state = IDLE;
                else
                    next_state = STATE7_OUTPUT;

            default:
                next_state = IDLE;
        endcase
    end

    /*-----------------------------------------------------------------------------------              0 0 0 0 0 0 0         0 5 0 0 0 0 0
            MM       MM      AAAA      PPPPPPPP                                                        0 1 2 1 1 3 0         0 1 1 1 1 3 0
            MMM     MMM     AA  AA     PP     PP                                                       0 1 0 0 0 0 0         0 1 0 0 0 0 0
            MM MM MM MM    AA    AA    PP     PP                                                       0 1 0 1 2 1 0   =>    0 1 0 1 1 1 0
            MM  MMM  MM   AAAAAAAAAA   PPPPPPPP                                                        0 1 0 1 0 0 0         0 1 0 1 0 0 0
            MM       MM  AA        AA  PP                                                              0 2 1 1 1 1 0         0 1 1 1 1 1 0
    *///---------------------------------------------------------------------------------              0 0 0 0 0 0 0         0 0 0 0 0 5 0
    integer i,j;
always @(posedge clk or negedge rst_n)
begin : mapping
    if(~rst_n)
    begin

        flag_finishC <= 0;
        flag_4to5    <= 0;
        count1_1     <= 0;
        countHostage <= 0;
        //use in STATE5_WALK
        pathx <= 0;
        pathy <= 0;
        out   <= 0;
        flagB <= 0;
        flagSTALL <= 0;
        flag_5to6 <= 0;
        flag_5to7 <= 0;
        Last_step <= 0;
        //------------------
        //out
        out_valid2 <= 0;
        flag_6to5 <= 0;
        flagFinish <= 0;
        flagEND <= 0;
        data1 <=0;
        data2 <=0;
        data3 <=0;
        data4 <=0;

        out_valid1 <=0;
        out_data   <=0;

        //------------------
        for (i=0;i<=18;i=i+1)
        begin
            for (j=0;j<=18;j=j+1)
            begin
                map[i][j]<=0;
            end
        end
    end
    // IDLE IDLE IDLE IDLE IDLE IDLE IDLE IDLE IDLE IDLE IDLE IDLE IDLE IDLE IDLE IDLE
    else if (next_state == IDLE)
    begin
        out_valid1 <= 0;
        out_data   <= 0;


        flag_finishC <= 0;
        flag_4to5    <= 0;
        count1_1     <= 0;
        countHostage <= 0;
        countSA      <= 0;
        //use in STATE5_WALK
        pathx <= 0;
        pathy <= 0;
        out   <= 0;
        flagB <= 0;
        flagSTALL <= 0;
        flag_5to6 <= 0;
        flag_6to5 <= 0;
        flag_5to7 <= 0;
        Last_step <= 0;
        //------------------
        //out
        out_valid2 <= 0;
        flag_6to5 <= 0;
        flagFinish <= 0;
        data1 <=0;
        data2 <=0;
        data3 <=0;
        data4 <=0;


        out_data   <=0;
        flagEND <= 0;
        flagFinish <= 0;


    end
    //IDLE IDLE IDLE IDLE IDLE IDLE IDLE IDLE IDLE IDLE IDLE IDLE IDLE IDLE IDLE IDLE
    else
    begin
        if(in_valid1 && cnt<289)
        begin
            if (map[17][17]==3)
            begin
                countHostage<=1+countHostage;
            end
            map[18][17]<=5;
            map[0][1]  <=5;
            for (i=1;i<=17;i=i+1)
            begin
                for (j=2;j<=17;j=j+1)
                begin
                    map[i][j-1]  <= map[i][j];
                    map[j-1][17] <= map[j][1];
                    map[17][17]  <= in ;
                end
            end
        end
        else if (current_state==STATE2_TRAP)
        begin
            for ( i=1 ; i<=17 ; i=i+1 )
            begin
                for ( j=1 ;j<=17 ;j=j+1 )
                begin
                    if (map[i][j]==2) //let traps to be road
                    begin
                        map[i][j]<=1;
                    end
                end
            end
        end
        /*-------------------------------------------------------------------------------------------------------    0 5 0 0 0 0 0            0 5 0 0 0 0 0
          MM       MM      AAAA      KK    KKK   EEEEEEEEEE      RRRRRRRR      oooooo        AAAA     DDDDDDD        0 1 1 1 1 3 0            0 4 4 4 4 3 0                                                                                                                                
          MMM     MMM     AA  AA     KK   KKK    EE              RR      RR  oo      oo     AA  AA    DD     DD      0 1 0 0 0 0 0            0 4 0 0 0 0 0                                                                                                                          
          MM MM MM MM    AA    AA    KKKKKK      EEEEEEEEE       RRRRRRRRR  oo        oo   AA    AA   DD      DD     0 1 0 0 0 0 0     =>     0 4 0 0 0 0 0                                                                                                                         
          MM  MMM  MM   AAAAAAAAAA   KK   KKK    EE              RR   RRR    oo      oo   AAAAAAAAAA  DD      DD     0 1 0 0 0 0 0            0 4 0 0 0 0 0                                                                                                                           
          MM       MM  AA        AA  KK     KKK  EEEEEEEEEE      RR     RRR    oooooo    AA        AA DDDDDDDD       0 1 1 1 1 1 0            0 4 4 4 4 4 0                                                                                                                                
        *///----------after del deadend--------------------------------------------------------------------------    0 0 0 0 0 5 0            0 0 0 0 0 5 0 
        else if (current_state==STATE3_D_H_ && flag_finishD == 1)
        begin
            count1_1 <= 0;
            for ( i=1 ; i<=17 ; i=i+1 )
            begin
                for ( j=1 ;j<=17 ;j=j+1 )
                begin
                    if (map[i][j]==1) //
                    begin
                        map[i][j] <= 4;
                    end
                end
            end
        end
        /*--------------------------------------------------------------------------------------    0 5 0 0 0 0 0           0 5 0 0 0 0 0
        DDDDDDD     EEEEEEEEEE  LLL            DDDDDDD     EEEEEEEEEE      AAAA      DDDDDDD        0 1 1 1 1 3 0           0 1 1 1 1 3 0
        DD     DD   EE          LLL            DD     DD   EE             AA  AA     DD     DD      0 1 0 0 0 0 0           0 1 0 0 0 0 0
        DD      DD  EEEEEEEEE   LLL            DD      DD  EEEEEEEEE     AA    AA    DD      DD     0 1 0 1 1 1 0    =>     0 1 0 0 0 0 0
        DD      DD  EE          LLL            DD      DD  EE           AAAAAAAAAA   DD      DD     0 1 0 1 0 0 0           0 1 0 0 0 0 0
        DDDDDDDD    EEEEEEEEEE  LLLLLLLLL      DDDDDDDD    EEEEEEEEEE  AA        AA  DDDDDDDD       0 1 1 1 1 1 0           0 1 1 1 1 1 0
        *///-------------------------------------------------------------------------------------   0 0 0 0 0 5 0           0 0 0 0 0 5 0
        else if (current_state==STATE3_D_H_)
        begin
            for ( i=1 ; i<=17 ; i=i+1 )
            begin
                for ( j=1 ;j<=17 ;j=j+1 )
                begin
                    if (map[i][j]==1) //del the deadend
                    begin
                        if (map[i+1][j]+map[i-1][j]+map[i][j+1]+map[i][j-1] == 1)
                        begin
                            map[i][j]<=0;
                            count1_1 <= count1_1 + 1;
                        end
                    end
                end
            end
        end
        /*-------------------------------------------------------------------------------------  0 5 0 0 0 0 0                       0 1 0 0 0 0 0
            CCCCCCCC    oooooo     MM       MM  BBBBBBB    IIIIIIII  NNN     NN  EEEEEEEEEE      0 4 4 4 4 3 0       0 1 0 0 0       1 1 0 0 0 0 0                                                                                                                                 
           CC         oo      oo   MMM     MMM  BB     BB     II     NNNN    NN  EE              0 4 0 0 0 0 0       0 0 0 0 0       0 1 0 0 0 0 0                                                                                                                           
          CC         oo        oo  MM MM MM MM  BBBBBBBB      II     NN  NN  NN  EEEEEEEEE       0 4 0 0 0 0 0    +  0 0 0 1 0   +   0 1 0 0 0 0 0                                                                                                                          
           CC         oo      oo   MM  MMM  MM  BB      BB    II     NN    NNNN  EE              0 4 0 0 0 0 0       0 0 0 0 0       0 1 0 0 0 0 0                                                                                                                            
            CCCCCCCC    oooooo     MM       MM  BBBBBBBBB  IIIIIIII  NN      NN  EEEEEEEEEE      0 4 4 4 4 4 0       1 0 0 0 0       0 1 1 1 1 1 1                                                                                                                                 
        *///-----------------------------------------------------------------------------------  0 0 0 0 0 5 0                       0 0 0 0 0 1 0  
        //                                                                                           map                map1              map2
        else if (current_state == STATE4_COMB && flag_finishC==1)
        begin
            for ( i=1 ; i<=17 ; i=i+1 )
            begin
                for ( j=1 ;j<=17 ;j=j+1 )
                begin
                    if (map1[i-1][j-1]==1 && map[i][j]==1)
                    begin
                        map[i][j] <= 2 ;
                    end
                    else if (map1[i-1][j-1]==1 && map[i][j]==4)
                    begin
                        map[i][j] <= 6 ;
                    end
                end
                flag_4to5 <= 1;
            end
        end

        else if (current_state == STATE4_COMB)
        begin
            map[0][1] <= 0;
            map[18][17] <= 0;

            pathx <= 1;
            pathy <= 1;
            out   <= 0;
            flagB <= 0;
            for ( i=1 ; i<=17 ; i=i+1 )
            begin
                for ( j=1 ;j<=17 ;j=j+1 )
                begin
                    if (map2[i][j]==1)
                    begin
                        map[i][j] <= 1 ;
                        flag_finishC <= 1;
                    end
                end
            end
        end
        /*-------------------------------------------------------------------------------------------------------------
                                                                                        |         |           
                                                                                        |    3    |
                                                                                        |         |
                 WW   W   WW      AAAA      LLL        KK    KKK              ----------|---------|----------     
                 WW  W W  WW     AA  AA     LLL        KK   KKK              |          |         |         |
                 WW  W W  WW    AA    AA    LLL        KKKKKK                |     2    |    4    |    0    |
                 WW W   W WW   AAAAAAAAAA   LLL        KK   KKK              |          |         |         |
                  WW     WW   AA        AA  LLLLLLLLLL KK     KKK             ----------|---------|----------         
                                                                                        |         |                        
                                                                                        |    1    | 
                                                                                        |         |                                                                  
        *///----------------------------------------------------------------------------------------------------------
        else if (current_state == STATE5_WALK && flag_5to6)
        begin
            out_valid2 <= 0;
            out <= 0;
        end
        else if (next_state == STATE5_WALK)
        begin
            out_valid2<=1;
            if (pathx==17 && pathy==17 && flag_save_all==1)
            begin
                out_valid2 <= 0;
                out <= 0 ;
                flag_5to7 <= 1;
                countSA <= 0;
            end
            else if (flagB==0)
            begin : the_first_step
                if (map[pathy+1][pathx]==6)
                begin
                    pathy<=pathy+1;
                    pathx<=pathx ;
                    Last_step <= 1;
                    out <=  1; //walk down
                    flagB <= 1;
                    flagSTALL <= 1;
                    map[pathy+1][pathx]<=2;
                end
                else if (map[pathy+1][pathx]==4)
                begin
                    pathy<=pathy+1;
                    pathx<=pathx ;
                    Last_step <= 1;
                    out <=  1; //walk down
                    flagB <= 1;
                    map[pathy+1][pathx]<=1;
                end
                else if (map[pathy][pathx+1]==6)
                begin
                    pathy<=pathy;
                    pathx<=pathx+1 ;
                    Last_step <= 0;
                    out <=  0; //walk right
                    flagB <= 1;
                    flagSTALL <= 1;
                    map[pathy][pathx+1]<=2;
                end
                else if (map[pathy][pathx+1]==4)
                begin
                    pathy<=pathy;
                    pathx<=pathx+1 ;
                    Last_step <= 0;
                    out <=  0; //walk right
                    flagB <= 1;
                    map[pathy][pathx+1]<=1;
                end
                else if (map[pathy+1][pathx]==2)
                begin
                    pathy<=pathy+1;
                    pathx<=pathx ;
                    Last_step <= 1;
                    out <=  1; //walk down
                    flagB <= 1;
                    flagSTALL <= 1;
                end
                else if (map[pathy+1][pathx]==1)
                begin
                    pathy<=pathy+1;
                    pathx<=pathx ;
                    Last_step <= 1;
                    out <=  1; //walk down
                    flagB <= 1;
                end
                else if (map[pathy][pathx+1]==2)
                begin
                    pathy<=pathy;
                    pathx<=pathx+1 ;
                    Last_step <= 0;
                    out <=  0; //walk right
                    flagB <= 1;
                    flagSTALL <= 1;
                end
                else if (map[pathy][pathx+1]==1)
                begin
                    pathy     <= pathy ;
                    pathx     <= pathx+1 ;
                    Last_step <= 0;
                    out <=  0; //walk Right
                    flagB <= 1;
                end
            end
            else if(flagB==1)
            begin
                case (Last_step)
                    /*-------------------------------------------------------------------
                                       last step is Right,so can't go left
                    ---------------------------------------------------------------------*/
                    0:
                        if (flagSTALL == 1)
                        begin
                            flagSTALL <= 0;
                            out <= 4;
                        end
                        else
                        begin
                            flag_6to5 <= 0;
                            if (map[pathy+1][pathx]==5)
                            begin
                                Last_step<=5;
                            end
                            else if (map[pathy+1][pathx]==3)
                            begin
                                pathx     <= pathx ;
                                pathy     <= pathy+1 ;
                                Last_step <= 1;
                                out <=  1; //walk down
                                map[pathy+1][pathx]<=1;
                                flag_5to6 <= 1;
                                map[pathy+1][pathx]<=0;
                                countSA <= countSA+1;
                            end
                            else if (map[pathy][pathx+1]==3)
                            begin
                                pathx     <= pathx+1 ;
                                pathy     <= pathy ;
                                Last_step <= 0;
                                out <=  0; //walk right
                                flag_5to6 <= 1;
                                map[pathy][pathx+1]<= 0;
                                countSA <= countSA+1;
                            end
                            else if (map[pathy-1][pathx]==3)
                            begin
                                pathx     <= pathx ;
                                pathy     <= pathy-1 ;
                                Last_step <= 3;
                                out <=  3; //walk up
                                flag_5to6 <= 1;
                                map[pathy-1][pathx]<=0;
                                countSA <= countSA+1;
                            end

                            else if (map[pathy+1][pathx]==6)
                            begin : R2
                                pathx     <= pathx ;
                                pathy     <= pathy+1 ;
                                Last_step <= 1;
                                out <=  1; //walk down
                                flagSTALL <= 1;//flagggggggggggggggg
                                map[pathy+1][pathx]<=2;
                            end
                            else if (map[pathy+1][pathx]==4)
                            begin : R3
                                pathx     <= pathx ;
                                pathy     <= pathy+1 ;
                                Last_step <= 1;
                                out <=  1; //walk down
                                map[pathy+1][pathx]<=1;
                            end
                            else if (map[pathy][pathx+1]==6)
                            begin : R4
                                pathx     <= pathx+1 ;
                                pathy     <= pathy ;
                                Last_step <= 0;
                                out <=  0; //walk right
                                flagSTALL <= 1;//flagggggggggggggggg
                                map[pathy][pathx+1]<=2;
                            end
                            else if (map[pathy][pathx+1]==4)
                            begin : R5
                                pathx     <= pathx+1 ;
                                pathy     <= pathy ;
                                Last_step <= 0;
                                out <=  0; //walk right
                                map[pathy][pathx+1]<=1;
                            end
                            else if (map[pathy-1][pathx]==6)
                            begin : R6
                                pathx     <= pathx ;
                                pathy     <= pathy-1 ;
                                Last_step <= 3;
                                out <=  3; //walk up
                                flagSTALL <= 1;//flagggggggggggggggg
                                map[pathy-1][pathx]<=2;
                            end
                            else if (map[pathy-1][pathx]==4)
                            begin : R7
                                pathx     <= pathx ;
                                pathy     <= pathy-1 ;
                                Last_step <= 3;
                                out <=  3; //walk up
                                map[pathy-1][pathx]<=1;
                            end
                            //---------------up is road to hostage------------
                            else if (map[pathy+1][pathx]==2)
                            begin : R8
                                pathx     <= pathx ;
                                pathy     <= pathy+1 ;
                                Last_step <= 1;
                                out <=  1; //walk down
                                flagSTALL <= 1;//flagggggggggggggggg
                            end
                            else if (map[pathy+1][pathx]==1)
                            begin : R9
                                pathx     <= pathx ;
                                pathy     <= pathy+1 ;
                                Last_step <= 1;
                                out <=  1; //walk down
                            end
                            else if (map[pathy][pathx+1]==2)
                            begin : R10
                                pathx     <= pathx+1 ;
                                pathy     <= pathy ;
                                Last_step <= 0;
                                out <=  0; //walk right
                                flagSTALL <= 1;//flagggggggggggggggg
                            end
                            else if (map[pathy][pathx+1]==1)
                            begin :R11
                                pathx     <= pathx+1 ;
                                pathy     <= pathy ;
                                Last_step <= 0;
                                out <=  0; //walk right
                            end
                            else if (map[pathy-1][pathx]==2)
                            begin : R12
                                pathx     <= pathx ;
                                pathy     <= pathy-1 ;
                                Last_step <= 3;
                                out <=  3; //walk up
                                flagSTALL <= 1;//flagggggggggggggggg
                            end
                            else if (map[pathy-1][pathx]==1)
                            begin : R13
                                pathx     <= pathx ;
                                pathy     <= pathy-1 ;
                                Last_step <= 3;
                                out <=  3; //walk up
                            end
                            else if (map[pathy][pathx-1]==2)//no road ,i only can turn around
                            begin : R14
                                pathx     <= pathx-1 ;
                                pathy     <= pathy ;
                                Last_step <= 2;
                                out <=  2; //walk left
                                flagSTALL <= 1;//flagggggggggggggggg
                            end
                            else
                            begin : R15
                                pathx     <= pathx-1 ;
                                pathy     <= pathy ;
                                Last_step <= 2;
                                out <=  2; //walk left
                            end
                        end
                    /*-------------------------------------------------------------------
                                       last step is Down,so can't go up
                     ---------------------------------------------------------------------*/
                    1:
                        if (flagSTALL == 1)
                        begin
                            flagSTALL <= 0;
                            out <= 4;
                        end
                        else
                        begin
                            flag_6to5 <= 0;
                            if (map[pathy+1][pathx]==5)
                            begin
                                Last_step<=5;
                            end
                            else if (map[pathy][pathx-1]==3)
                            begin
                                pathx     <= pathx-1 ;
                                pathy     <= pathy ;
                                Last_step <= 2;
                                out <=  2; //walk left
                                map[pathy][pathx-1] <= 0;
                                flag_5to6 <= 1;
                                countSA <= countSA+1;
                            end
                            else if (map[pathy+1][pathx]==3)
                            begin
                                pathx     <= pathx ;
                                pathy     <= pathy+1 ;
                                Last_step <= 1;
                                out <=  1; //walk down
                                map[pathy+1][pathx] <= 0;
                                flag_5to6 <= 1;
                                countSA <= countSA+1;
                            end
                            else if (map[pathy][pathx+1]==3)
                            begin
                                pathx     <= pathx+1 ;
                                pathy     <= pathy ;
                                Last_step <= 0;
                                out <=  0; //walk right
                                map[pathy][pathx+1] <= 0;
                                flag_5to6 <= 1;
                                countSA <= countSA+1;
                            end
                            else if (map[pathy][pathx-1]==6)
                            begin : D2
                                pathx     <= pathx-1 ;
                                pathy     <= pathy ;
                                Last_step <= 2;
                                out <=  2; //walk left
                                flagSTALL <= 1;//flagggggggggggggggg
                                map[pathy][pathx-1]<=2;
                            end
                            else if (map[pathy][pathx-1]==4)
                            begin : D3
                                pathx     <= pathx-1 ;
                                pathy     <= pathy ;
                                Last_step <= 2;
                                out <=  2; //walk left
                                map[pathy][pathx-1]<=1;
                            end
                            else if (map[pathy+1][pathx]==6)
                            begin : D4
                                pathx     <= pathx ;
                                pathy     <= pathy+1 ;
                                Last_step <= 1;
                                out <=  1; //walk down
                                flagSTALL <= 1;//flagggggggggggggggg
                                map[pathy+1][pathx]<=2;
                            end
                            else if (map[pathy+1][pathx]==4)
                            begin : D5
                                pathx     <= pathx ;
                                pathy     <= pathy+1 ;
                                Last_step <= 1;
                                out <=  1; //walk down
                                map[pathy+1][pathx]<=1;
                            end
                            else if (map[pathy][pathx+1]==6)
                            begin : D6
                                pathx     <= pathx+1 ;
                                pathy     <= pathy ;
                                Last_step <= 0;
                                out <=  0; //walk right
                                flagSTALL <= 1 ;//flagggggggggggggggg
                                map[pathy][pathx+1]<=2;
                            end
                            else if (map[pathy][pathx+1]==4)
                            begin : D7
                                pathx     <= pathx+1 ;
                                pathy     <= pathy ;
                                Last_step <= 0;
                                out <=  0; //walk right
                                map[pathy][pathx+1]<=1;
                            end
                            //--------up is road to hostage-----------
                            else if (map[pathy][pathx-1]==2)
                            begin : D8
                                pathx     <= pathx-1 ;
                                pathy     <= pathy ;
                                Last_step <= 2;
                                out <=  2; //walk left
                                flagSTALL <= 1;//flagggggggggggggggg
                            end
                            else if (map[pathy][pathx-1]==1)
                            begin : D9
                                pathx     <= pathx-1 ;
                                pathy     <= pathy ;
                                Last_step <= 2;
                                out <=  2; //walk left
                            end
                            else if (map[pathy+1][pathx]==2)
                            begin : D10
                                pathx     <= pathx ;
                                pathy     <= pathy+1 ;
                                Last_step <= 1;
                                out <=  1; //walk down
                                flagSTALL <= 1;//flagggggggggggggggg
                            end
                            else if (map[pathy+1][pathx]==1)
                            begin : D11
                                pathx     <= pathx ;
                                pathy     <= pathy+1 ;
                                Last_step <= 1;
                                out <=  1; //walk down
                            end
                            else if (map[pathy][pathx+1]==2)
                            begin : D12
                                pathx     <= pathx+1 ;
                                pathy     <= pathy ;
                                Last_step <= 0;
                                out <=  0; //walk right
                                flagSTALL <= 1 ;//flagggggggggggggggg
                            end
                            else if (map[pathy][pathx+1]==1)
                            begin : D13
                                pathx     <= pathx+1 ;
                                pathy     <= pathy ;
                                Last_step <= 0;
                                out <=  0; //walk right
                            end
                            else if (map[pathy-1][pathx]==2)
                            begin : D14
                                pathx     <= pathx ;
                                pathy     <= pathy-1 ;
                                Last_step <= 3;
                                out <=  3; //walk up
                                flagSTALL <= 1 ; //flagggggggggggggggg
                            end
                            else //no road ,i only can turn around
                            begin : D15
                                pathx     <= pathx ;
                                pathy     <= pathy-1 ;
                                Last_step <= 3;
                                out <=  3; //walk up
                            end
                        end
                    /*-------------------------------------------------------------------
                                       last step is Left,so can't go Right
                    ---------------------------------------------------------------------*/
                    2:
                        if (flagSTALL == 1)
                        begin
                            flagSTALL <= 0;
                            out <= 4;
                        end
                        else
                        begin
                            flag_6to5 <= 0;
                            if (map[pathy-1][pathx]==3)
                            begin
                                pathx     <= pathx ;
                                pathy     <= pathy-1 ;
                                Last_step <= 3;
                                out <=  3; //walk up
                                flag_5to6 <= 1;
                                map[pathy-1][pathx]<=0;
                                countSA <= countSA+1;
                            end
                            else if (map[pathy][pathx-1]==3)
                            begin
                                pathx     <= pathx-1 ;
                                pathy     <= pathy ;
                                Last_step <= 2;
                                out <=  2; //walk left
                                flag_5to6 <= 1;
                                map[pathy][pathx-1]<=0;
                                countSA <= countSA+1;
                            end
                            else if (map[pathy+1][pathx]==3)
                            begin
                                pathx     <= pathx ;
                                pathy     <= pathy+1 ;
                                Last_step <= 1;
                                out <=  1; //walk down
                                flag_5to6 <= 1;
                                map[pathy+1][pathx]<=0;
                                countSA <= countSA+1;
                            end
                            else if (map[pathy-1][pathx]==6)
                            begin : L2
                                pathx     <= pathx ;
                                pathy     <= pathy-1 ;
                                Last_step <= 3;
                                out <=  3; //walk up
                                flagSTALL <= 1;
                                map[pathy-1][pathx]<=2;
                            end
                            else if (map[pathy-1][pathx]==4)
                            begin : L3
                                pathx     <= pathx ;
                                pathy     <= pathy-1 ;
                                Last_step <= 3;
                                out <=  3; //walk up
                                map[pathy-1][pathx]<=1;
                            end
                            else if (map[pathy][pathx-1]==6)
                            begin : L4
                                pathx     <= pathx-1 ;
                                pathy     <= pathy ;
                                Last_step <= 2;
                                out <=  2; //walk left
                                flagSTALL <= 1;
                                map[pathy][pathx-1]<=2;
                            end
                            else if (map[pathy][pathx-1]==4)
                            begin : L5
                                pathx     <= pathx-1 ;
                                pathy     <= pathy ;
                                Last_step <= 2;
                                out <=  2; //walk left
                                map[pathy][pathx-1]<=1;
                            end
                            else if (map[pathy+1][pathx]==6)
                            begin : L6
                                pathx     <= pathx ;
                                pathy     <= pathy+1 ;
                                Last_step <= 1;
                                out <=  1; //walk down
                                flagSTALL <= 1;
                                map[pathy+1][pathx]<=2;
                            end
                            else if (map[pathy+1][pathx]==4)
                            begin : L7
                                pathx     <= pathx ;
                                pathy     <= pathy+1 ;
                                Last_step <= 1;
                                out <=  1; //walk down
                                map[pathy+1][pathx]<=1;
                            end
                            //-----up is road to hostage----------
                            else if (map[pathy-1][pathx]==2)
                            begin : L8
                                pathx     <= pathx ;
                                pathy     <= pathy-1 ;
                                Last_step <= 3;
                                out <=  3; //walk up
                                flagSTALL <= 1;
                            end
                            else if (map[pathy-1][pathx]==1)
                            begin : L9
                                pathx     <= pathx ;
                                pathy     <= pathy-1 ;
                                Last_step <= 3;
                                out <=  3; //walk up
                            end
                            else if (map[pathy][pathx-1]==2)
                            begin : L10
                                pathx     <= pathx-1 ;
                                pathy     <= pathy ;
                                Last_step <= 2;
                                out <=  2; //walk left
                                flagSTALL <= 1;
                            end
                            else if (map[pathy][pathx-1]==1)
                            begin : L11
                                pathx     <= pathx-1 ;
                                pathy     <= pathy ;
                                Last_step <= 2;
                                out <=  2; //walk left
                            end
                            else if (map[pathy+1][pathx]==2)
                            begin : L12
                                pathx     <= pathx ;
                                pathy     <= pathy+1 ;
                                Last_step <= 1;
                                out <=  1; //walk down
                                flagSTALL <= 1;
                            end
                            else if (map[pathy+1][pathx]==1)
                            begin : L13
                                pathx     <= pathx ;
                                pathy     <= pathy+1 ;
                                Last_step <= 1;
                                out <=  1; //walk down
                            end
                            else if (map[pathy][pathx+1]==2)
                            begin : L14
                                pathx     <= pathx+1 ;
                                pathy     <= pathy ;
                                Last_step <= 0;
                                out <=  0; //walk right
                                flagSTALL <= 1;
                            end
                            else //no road ,i only can turn around
                            begin : L15
                                pathx     <= pathx+1 ;
                                pathy     <= pathy ;
                                Last_step <= 0;
                                out <=  0; //walk right
                            end
                        end
                    /*-------------------------------------------------------------------
                                     last step is Up,so can't go Down
                    ---------------------------------------------------------------------*/
                    3:
                        if (flagSTALL == 1)
                        begin
                            flagSTALL <= 0;
                            out <= 4;
                        end
                        else
                        begin
                            flag_6to5 <= 0;
                            if (map[pathy][pathx+1]==3)
                            begin
                                pathx     <= pathx+1 ;
                                pathy     <= pathy ;
                                Last_step <= 0;
                                out <=  0; //walk right
                                flag_5to6 <= 1;
                                map[pathy][pathx+1]<=0;
                                countSA <= countSA+1;
                            end
                            else if (map[pathy-1][pathx]==3)
                            begin
                                pathx     <= pathx ;
                                pathy     <= pathy-1 ;
                                Last_step <= 3;
                                out <=  3; //walk up
                                flag_5to6 <= 1;
                                map[pathy-1][pathx]<=0;
                                countSA <= countSA+1;
                            end
                            else if (map[pathy][pathx-1]==3)
                            begin
                                pathx     <= pathx-1 ;
                                pathy     <= pathy ;
                                Last_step <= 2;
                                out <=  2; //walk left
                                flag_5to6 <= 1;
                                map[pathy][pathx-1]<=0;
                                countSA <= countSA+1;
                            end
                            else if (map[pathy][pathx+1]==6)
                            begin : U2
                                pathx     <= pathx+1 ;
                                pathy     <= pathy ;
                                Last_step <= 0;
                                out <=  0; //walk right
                                flagSTALL <= 1;//flagggggggggggggggg
                                map[pathy][pathx+1]<=2;
                            end
                            else if (map[pathy][pathx+1]==4)
                            begin : U3
                                pathx     <= pathx+1 ;
                                pathy     <= pathy ;
                                Last_step <= 0;
                                out <=  0; //walk right
                                map[pathy][pathx+1]<=1;
                            end
                            else if (map[pathy-1][pathx]==6)
                            begin : U4
                                pathx     <= pathx ;
                                pathy     <= pathy-1 ;
                                Last_step <= 3;
                                out <=  3; //walk up
                                flagSTALL <= 1;//flagggggggggggggggg
                                map[pathy-1][pathx]<=2;
                            end
                            else if (map[pathy-1][pathx]==4)
                            begin : U5
                                pathx     <= pathx ;
                                pathy     <= pathy-1 ;
                                Last_step <= 3;
                                out <=  3; //walk up
                                map[pathy-1][pathx]<=1;
                            end
                            else if (map[pathy][pathx-1]==6)
                            begin : U6
                                pathx     <= pathx-1 ;
                                pathy     <= pathy ;
                                Last_step <= 2;
                                out <=  2; //walk left
                                flagSTALL <= 1;//flagggggggggggggggg
                                map[pathy][pathx-1]<=2;
                            end
                            else if (map[pathy][pathx-1]==4)
                            begin : U7
                                pathx     <= pathx-1 ;
                                pathy     <= pathy ;
                                Last_step <= 2;
                                out <=  2; //walk left
                                map[pathy][pathx-1]<=1;
                            end
                            //-----------up is road to hostage-------------------
                            else if (map[pathy][pathx+1]==2)
                            begin : U8
                                pathx     <= pathx+1 ;
                                pathy     <= pathy ;
                                Last_step <= 0;
                                out <=  0; //walk right
                                flagSTALL <= 1;//flagggggggggggggggg
                            end
                            else if (map[pathy][pathx+1]==1)
                            begin : U9
                                pathx     <= pathx+1 ;
                                pathy     <= pathy ;
                                Last_step <= 0;
                                out <=  0; //walk right
                            end
                            else if (map[pathy-1][pathx]==2)
                            begin : U10
                                pathx     <= pathx ;
                                pathy     <= pathy-1 ;
                                Last_step <= 3;
                                out <=  3; //walk up
                                flagSTALL <= 1;//flagggggggggggggggg
                            end
                            else if (map[pathy-1][pathx]==1)
                            begin : U11
                                pathx     <= pathx ;
                                pathy     <= pathy-1 ;
                                Last_step <= 3;
                                out <=  3; //walk up
                            end
                            else if (map[pathy][pathx-1]==2)
                            begin : U12
                                pathx     <= pathx-1 ;
                                pathy     <= pathy ;
                                Last_step <= 2;
                                out <=  2; //walk left
                                flagSTALL <= 1;//flagggggggggggggggg
                            end
                            else if (map[pathy][pathx-1]==1)
                            begin : U13
                                pathx     <= pathx-1 ;
                                pathy     <= pathy ;
                                Last_step <= 2;
                                out <=  2; //walk left
                            end
                            else if (map[pathy+1][pathx]==2)
                            begin : U14
                                pathx     <= pathx ;
                                pathy     <= pathy+1 ;
                                Last_step <= 1;
                                out <=  1; //walk down
                                flagSTALL <= 1;//flagggggggggggggggg
                            end
                            else //no road ,i only can turn around
                            begin : U15
                                pathx     <= pathx ;
                                pathy     <= pathy+1 ;
                                Last_step <= 1;
                                out <=  1; //walk down
                            end
                        end
                endcase
            end
        end
        /*----------------------------------------------------------------------------------------------------------
            PPPPPPPP      AAA      SSSSSSSS   SSSSSSSS   
            PP     PP    AA AA    S          S                     
            PP     PP   AA   AA    SSSSSSSS   SSSSSSSS           
            PPPPPPPP   AAAAAAAAA           S          S           
            PP        AA       AA  SSSSSSSS   SSSSSSSS         
        *///-----------------------------------------------------------------------------------------------------*--  
        else if (current_state == STATE6_CALC)
        begin
            if (in_valid2==1)
            begin
                flag_5to6 <= 0;
                if (countHostage!=0)
                begin
                    data4 <= data3;
                    data3 <= data2;
                    data2 <= data1;
                    data1 <= in_data;
                end
                flag_6to5 <= 1;
            end
            else if (flag_6to5)
            begin
                out_valid2<= 1;
            end
        end
        /*----------------------------------------------------------------------------------------------------------
                        OOOOO    UU      UU TTTTTTTTTT        
                      OO     OO  UU      UU     TT            
                     OO       OO UU      UU     TT            
                      OO     OO   UU    UU      TT            
                        OOOOO      UUUUUU       TT            
        *///-----------------------------------------------------------------------------------------------------*--  
        else if (current_state == STATE7_OUTPUT)
        begin
            out_valid1 <= 1;
            //              1 hostage
            if (countHostage==1 && flagFinish == 0)
            begin
                out_data <= data1;
                flagEND <= 1;
            end
            //          4 hostages
            else if (countHostage==4)
            begin
                if (cnt < 1)
                begin
                    out_data <= Res1 ;
                end
                else if (cnt < 2)
                begin
                    out_data <= Res2 ;
                end
                else if (cnt < 3)
                begin
                    out_data <= Res3 ;
                end
                else if (cnt < 4)
                begin
                    out_data <= Res4 ;
                    flagEND <= 1;
                end
            end

            //           3 hostages
            else if (countHostage==3)
            begin
                if (cnt < 1)
                begin
                    out_data <= Res1 ;
                end
                else if (cnt < 2)
                begin
                    out_data <= Res2 ;
                end
                else if (cnt < 3)
                begin
                    out_data <= Res3 ;
                    flagEND <= 1;
                end
            end
            //          2 hostages
            else if (countHostage==2)
            begin
                if (cnt < 1)
                begin
                    out_data <= H3_h_1 ;
                end
                else if (cnt < 2)
                begin
                    out_data <= H3_h_2 ;
                    flagEND <= 1;
                end
            end
            //           0 hostage
            else if (countHostage==0)
            begin
                out_data <= 9'd0;
                flagFinish <= 1;
                flagEND <= 1;
            end

            // else if (flagFinish==1)
            // begin
            //   out_valid1 <= 0;
            // end

        end

    end
end


/*=====================================================================================================
                        SAVE ALL PEOPLE THEN FLAG = 1
  *///===================================================================================================
always @(posedge clk or negedge rst_n)
begin : SAVE_ALL
    if(~rst_n)
    begin
        flag_save_all <= 0;
    end
    else
    begin
        if (current_state==IDLE)
        begin
            flag_save_all <= 0;
        end
        else
            if (current_state==STATE5_WALK)
            begin
                if (countHostage == countSA)
                begin
                    flag_save_all <= 1;
                end
            end
    end
end
/*=====================================================================================================
                      breakpoint
*///===================================================================================================
always @(posedge clk or negedge rst_n)
begin : breakpoint
    if(~rst_n)
    begin
        flag_finishD <= 0;
        count1_2     <= 0;
    end
    else
    begin
        count1_2 <= count1_1;
        if ( count1_2 > 1 && count1_2 == count1_1 )
        begin
            flag_finishD  <= 1;
        end
        else if ( count1_2 != count1_1 )
        begin
            flag_finishD <= 0;
        end
    end
end
/*-----------------------------------------------------------------------------------
        MM       MM      AAAA      PPPPPPPP      11                                        0 1 0 0 0                  
        MMM     MMM     AA  AA     PP     PP   1 11                                        0 0 0 0 0                  
        MM MM MM MM    AA    AA    PP     PP     11                                        0 0 0 1 0                 
        MM  MMM  MM   AAAAAAAAAA   PPPPPPPP      11                                        0 0 0 0 0                  
        MM       MM  AA        AA  PP         11111111        store the trap               1 0 0 0 0                                   
*///---------------------------------------------------------------------------------       
always @(posedge clk or negedge rst_n)
begin : del_the_deadend
    if (~rst_n)
    begin
        flag_2to3<=0;
        for (i=0;i<=16;i=i+1)
            for (j=0;j<=16;j=j+1)
            begin
                begin
                    map1[i][j]<=0;
                end
            end
    end
    else
    begin
        if (current_state==IDLE)
        begin
            flag_2to3<=0;
            for (i=0;i<=16;i=i+1)
                for (j=0;j<=16;j=j+1)
                begin
                    begin
                        map1[i][j]<=0;
                    end
                end
        end
        else  if (current_state==STATE2_TRAP)
        begin
            for (i=1;i<=17;i=i+1)
                for (j=1;j<=17;j=j+1)
                begin
                    begin
                        if (map[i][j]==2)
                        begin
                            map1[i-1][j-1]<= 1;
                        end
                    end
                end
            flag_2to3<=1;
            // else if (current_state==STATE3_D_H_)
            // begin

            // end
        end
    end
end
/*-----------------------------------------------------------------------------------    0 1 0 0 0 0 0
        MM       MM      AAAA      PPPPPPPP    222222                                    1 1 0 0 0 0 0         
        MMM     MMM     AA  AA     PP     PP  2      22                                  0 1 0 0 0 0 0      
        MM MM MM MM    AA    AA    PP     PP       222                                   0 1 0 0 0 0 0  
        MM  MMM  MM   AAAAAAAAAA   PPPPPPPP      222                                     0 1 0 0 0 0 0  
        MM       MM  AA        AA  PP         222222222        the one road to goal      0 1 1 1 1 1 1    
*///---------------------------------------------------------------------------------    0 0 0 0 0 1 0
always @(posedge clk or negedge rst_n)
begin : map2_del_the_deadend
    if (~rst_n)
    begin
        count2_1  <= 0;
        for (i=0;i<=18;i=i+1)
            for (j=0;j<=18;j=j+1)
            begin
                begin
                    map2[i][j]<=0;
                end
            end
    end
    else
    begin
        if (current_state == IDLE)
        begin
            count2_1  <= 0;
            for (i=0;i<=18;i=i+1)
                for (j=0;j<=18;j=j+1)
                begin
                    begin
                        map2[i][j]<=0;
                    end
                end
        end
        else  if (current_state==STATE2_TRAP)
        begin
            map2[0][1]<=1;
            map2[1][0]<=1;
            map2[18][17]<=1;
            map2[17][18]<=1;
            for (i=1;i<=17;i=i+1)
                for (j=1;j<=17;j=j+1)
                begin
                    begin
                        if (map[i][j]==1 || map[i][j]==2)
                        begin
                            map2[i][j]<= 1;
                        end
                    end
                end
        end
        /*----------------------------------------------------------------------------------------------
        DDDDDDD     EEEEEEEEEE  LLL            DDDDDDD     EEEEEEEEEE      AAAA      DDDDDDD                                                                     
        DD     DD   EE          LLL            DD     DD   EE             AA  AA     DD     DD                                                                
        DD      DD  EEEEEEEEE   LLL            DD      DD  EEEEEEEEE     AA    AA    DD      DD                                                              
        DD      DD  EE          LLL            DD      DD  EE           AAAAAAAAAA   DD      DD                                                                
        DDDDDDDD    EEEEEEEEEE  LLLLLLLLL      DDDDDDDD    EEEEEEEEEE  AA        AA  DDDDDDDD     MAP2                                                               
        *///-------------------------------------------------------------------------------------------
        else if (current_state==STATE3_D_H_)
        begin
            for ( i=1 ; i<=17 ; i=i+1 )
            begin
                for ( j=1 ;j<=17 ;j=j+1 )
                begin
                    if (map2[i][j]==1) //del the deadend
                    begin
                        if (map2[i+1][j]+map2[i-1][j]+map2[i][j+1]+map2[i][j-1] == 1)
                        begin
                            map2[i][j]<=0;
                            count2_1  <= count2_1 + 1 ;
                        end
                    end
                end
            end
        end
    end
end
/*=====================================================================================================
                     breakpoint2
*///===================================================================================================
always @(posedge clk or negedge rst_n)
begin : breakpoint2
    if(~rst_n)
    begin
        flag_3to4 <= 0;
        count2_2     <= 0;
    end
    else
    begin
        count2_2 <= count2_1;
        if ( count2_2 > 1 && count2_2 == count2_1 )
        begin
            flag_3to4  <= 1;
        end
        else if ( count2_2 != count2_1 )
        begin
            flag_3to4 <= 0;
        end
    end
end

/*----------------------------------------------------------------------------------------------------------
      CCCCCC        AAA      LL         CCCCCC  UU      UU  LL            AAA    TTTTTTTTTT EEEEEEEEEE       
    CC             AA AA     LL       CC        UU      UU  LL           AA AA       TT     EE               
   CC             AA   AA    LL      CC         UU      UU  LL          AA   AA      TT     EEEEEEEEE        
    CC       C   AAAAAAAAA   LL       CC         UU    UU   LL         AAAAAAAAA     TT     EE               
     CCCCCCCC   AA       AA  LLLLLLLLL CCCCCCCC   UUUUUU    LLLLLLLLL AA       AA    TT     EEEEEEEEEE       
*///-------------------------------------------------------------------------------------------------------  
always @(*)
begin

    if (countHostage==4)
    begin
        H2_e_1_sign = 0 ;
        H2_e_1_1    = 0 ;
        H2_e_1_2    = 0 ;
        //   H2_value_1  = 0 ;
        H2_e_2_sign = 0 ;
        H2_e_2_1    = 0 ;
        H2_e_2_2    = 0 ;
        //   H2_value_2  = 0 ;
        H3_s_1 = 0 ;
        H3_s_2 = 0 ;
        H3_s_3 = 0 ;


        H4_com1_1 = (data1<=data2) ? data2 : data1 ; //big
        H4_com1_2 = (data1<=data2) ? data1 : data2 ; //small
        H4_com1_3 = (data3<=data4) ? data4 : data3 ; //big
        H4_com1_4 = (data3<=data4) ? data3 : data4 ; //small

        H4_com2_1 = (H4_com1_1 <= H4_com1_3 ) ? H4_com1_3 : H4_com1_1 ;// 1st
        H4_com2_2 = (H4_com1_1 <= H4_com1_3 ) ? H4_com1_1 : H4_com1_3 ;// not yet
        H4_com2_3 = (H4_com1_2 <= H4_com1_4 ) ? H4_com1_4 : H4_com1_2 ;// not yet
        H4_com2_4 = (H4_com1_2 <= H4_com1_4 ) ? H4_com1_2 : H4_com1_4 ;// 4th

        H4_com3_1 = (H4_com2_2 <= H4_com2_3 ) ? H4_com2_3 : H4_com2_2 ;// 2nd
        H4_com3_2 = (H4_com2_2 <= H4_com2_3 ) ? H4_com2_2 : H4_com2_3 ;// 3th

        //H4_com2_1 > H4_com3_1 > H4_com3_2 > H4_com2_4
        // use the regs which we used in hostage==2
        H4_e_1_sign = H4_com2_1[8] ;
        H4_e_1_1    = H4_com2_1[7:4] - 2'b11 ;
        H4_e_1_2    = H4_com2_1[3:0] - 2'b11 ;
        // H4_value_1  = H4_e_1_1*10 +H4_e_1_2 ;

        H4_e_2_sign = H4_com3_1[8] ;
        H4_e_2_1    = H4_com3_1[7:4] - 2'b11 ;
        H4_e_2_2    = H4_com3_1[3:0] - 2'b11 ;
        // H4_value_2  = H4_e_2_1*10 +H4_e_2_2 ;

        H4_e_3_sign = H4_com3_2[8] ;
        H4_e_3_1    = H4_com3_2[7:4] - 2'b11 ;
        H4_e_3_2    = H4_com3_2[3:0] - 2'b11 ;
        // H4_value_3  = H4_e_3_1*10 +H4_e_3_2 ;

        H4_e_4_sign = H4_com2_4[8] ;
        H4_e_4_1    = H4_com2_4[7:4] - 2'b11 ;
        H4_e_4_2    = H4_com2_4[3:0] - 2'b11 ;
        // H4_value_4  = H4_e_4_1*10 +H4_e_4_2 ;

    end
    else if (countHostage==3)
    begin
        H2_e_1_sign = 0 ;
        H2_e_1_1    = 0 ;
        H2_e_1_2    = 0 ;
        //   H2_value_1  = 0 ;
        H2_e_2_sign = 0 ;
        H2_e_2_1    = 0 ;
        H2_e_2_2    = 0 ;
        //   H2_value_2  = 0 ;
        H4_e_1_sign = 0 ;
        H4_e_1_1    = 0 ;
        H4_e_1_2    = 0 ;
        //  H4_value_1  = 0 ;
        H4_e_2_sign = 0 ;
        H4_e_2_1    = 0 ;
        H4_e_2_2    = 0 ;
        //  H4_value_2  = 0 ;
        H4_e_3_sign = 0 ;
        H4_e_3_1    = 0 ;
        H4_e_3_2    = 0 ;
        //   H4_value_3  = 0 ;
        H4_e_4_sign = 0 ;
        H4_e_4_1    = 0 ;
        H4_e_4_2    = 0 ;
        //   H4_value_4  = 0 ;
        if (data1<=data2)
        begin
            if (data1 <= data3)
            begin
                H3_s_3 = data1;
                if (data2<=data3) //3,2,1
                begin
                    H3_s_2 = data2;
                    H3_s_1 = data3;
                end
                else
                begin             // 2,3,1
                    H3_s_1 = data2;
                    H3_s_2 = data3;
                end
            end
            else
            begin
                H3_s_1 = data2;     // 2,1,3
                H3_s_2 = data1;
                H3_s_3 = data3;
            end
        end
        else
        begin
            if (data3>=data1)
            begin
                H3_s_1 = data3;     // 3,1,2
                H3_s_2 = data1;
                H3_s_3 = data2;
            end
            else if (data3<=data2)
            begin
                H3_s_1 = data1;     // 1,2,3
                H3_s_2 = data2;
                H3_s_3 = data3;
            end
            else
            begin
                H3_s_1 = data1;     // 1,3,2
                H3_s_2 = data3;
                H3_s_3 = data2;
            end
        end
    end
    else if (countHostage==2)
    begin
        H2_s_1 = data1 ;
        H2_s_2 = data2 ;
        if (data1<=data2)
        begin
            H2_s_1 = data2;
            H2_s_2 = data1;
        end
        else
        begin
            H2_s_1 = data1;
            H2_s_2 = data2;
        end
        H2_e_1_sign = H2_s_1[8] ;
        H2_e_1_1    = H2_s_1[7:4] - 2'b11 ;
        H2_e_1_2    = H2_s_1[3:0] - 2'b11 ;
        // H2_value_1 = H2_e_1_1*10 +H2_e_1_2 ;

        H2_e_2_sign = H2_s_2[8] ;
        H2_e_2_1    = H2_s_2[7:4] - 2'b11 ;
        H2_e_2_2    = H2_s_2[3:0] - 2'b11 ;
        // H2_value_2  = H2_e_2_1*10 +H2_e_2_2 ;
        H4_e_1_sign = 0 ;
        H4_e_1_1    = 0 ;
        H4_e_1_2    = 0 ;
        //   H4_value_1  = 0 ;
        H4_e_2_sign = 0 ;
        H4_e_2_1    = 0 ;
        H4_e_2_2    = 0 ;
        //   H4_value_2  = 0 ;
        H4_e_3_sign = 0 ;
        H4_e_3_1    = 0 ;
        H4_e_3_2    = 0 ;
        //   H4_value_3  = 0 ;
        H4_e_4_sign = 0 ;
        H4_e_4_1    = 0 ;
        H4_e_4_2    = 0 ;
        //   H4_value_4  = 0 ;
        H3_s_1 = 0 ;
        H3_s_2 = 0 ;
        H3_s_3 = 0 ;

    end
    else
    begin
        H3_s_1 = 0 ;
        H3_s_2 = 0 ;
        H3_s_3 = 0 ;
        H2_e_1_sign = 0 ;
        H2_e_1_1    = 0 ;
        H2_e_1_2    = 0 ;
        //   H2_value_1  = 0 ;
        H2_e_2_sign = 0 ;
        H2_e_2_1    = 0 ;
        H2_e_2_2    = 0 ;
        //   H2_value_2  = 0 ;
        H4_e_1_sign = 0 ;
        H4_e_1_1    = 0 ;
        H4_e_1_2    = 0 ;
        //   H4_value_1  = 0 ;
        H4_e_2_sign = 0 ;
        H4_e_2_1    = 0 ;
        H4_e_2_2    = 0 ;
        //   H4_value_2  = 0 ;
        H4_e_3_sign = 0 ;
        H4_e_3_1    = 0 ;
        H4_e_3_2    = 0 ;
        //   H4_value_3  = 0 ;
        H4_e_4_sign = 0 ;
        H4_e_4_1    = 0 ;
        H4_e_4_2    = 0 ;
        //   H4_value_4  = 0 ;
    end
end
always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        H2_value_1 <= 0 ;
        H2_value_2 <= 0 ;

        H4_value_1 <= 0 ;
        H4_value_2 <= 0 ;
        H4_value_3 <= 0 ;
        H4_value_4 <= 0 ;

    end
    else
    begin
        H2_value_1 <= H2_e_1_1*10 +H2_e_1_2 ;
        H2_value_2 <= H2_e_2_1*10 +H2_e_2_2 ;

        H4_value_1 <= H4_e_1_1*10 +H4_e_1_2 ;
        H4_value_2 <= H4_e_2_1*10 +H4_e_2_2 ;
        H4_value_3 <= H4_e_3_1*10 +H4_e_3_2 ;
        H4_value_4 <= H4_e_4_1*10 +H4_e_4_2 ;

    end
end



always @(*)
begin
    if (countHostage==2)
    begin
        H2_1 = (H2_e_1_sign) ? ~H2_value_1+1 : H2_value_1 ;
        H2_2 = (H2_e_2_sign) ? ~H2_value_2+1 : H2_value_2 ;
        H4_1 = 0;
        H4_2 = 0;
        H4_3 = 0;
        H4_4 = 0;
        H4_h_b1 = 0;
        H4_h_s1 = 0;
        H4_h_b2 = 0;
        H4_h_s2 = 0;
        H4_Big  = 0;
        H4_Sma  = 0;
        half4   = 0;
    end
    else if (countHostage==4)
    begin

        H4_1 = (H4_e_1_sign) ? ~H4_value_1+1 : H4_value_1 ;
        H4_2 = (H4_e_2_sign) ? ~H4_value_2+1 : H4_value_2 ;
        H4_3 = (H4_e_3_sign) ? ~H4_value_3+1 : H4_value_3 ;
        H4_4 = (H4_e_4_sign) ? ~H4_value_4+1 : H4_value_4 ;

        H2_1 = 0;
        H2_2 = 0;
        // H4_h_1 = H4_1 - half4;
        // H4_h_2 = H4_2 - half4;
        // H4_h_3 = H4_3 - half4;
        // H4_h_4 = H4_4 - half4;

        H4_h_b1 = (H4_1 <= H4_2) ? H4_2 : H4_1 ; //big
        H4_h_s1 = (H4_1 <= H4_2) ? H4_1 : H4_2 ; //small
        H4_h_b2 = (H4_3 <= H4_4) ? H4_4 : H4_3 ; //big
        H4_h_s2 = (H4_3 <= H4_4) ? H4_3 : H4_4 ; //small

        H4_Big  = (H4_h_b1 <= H4_h_b2 ) ? H4_h_b2 : H4_h_b1 ;// biggest
        H4_Sma  = (H4_h_s1 <= H4_h_s2 ) ? H4_h_s1 : H4_h_s2 ;// smallest
        half4   = (H4_Big+H4_Sma)/2 ;
    end
    else
    begin
        H4_h_b1 = 0;
        H4_h_s1 = 0;
        H4_h_b2 = 0;
        H4_h_s2 = 0;
        H4_Big  = 0;
        H4_Sma  = 0;
        half4   = 0;
        H2_1    = 0;
        H2_2    = 0;
        H4_1    = 0;
        H4_2    = 0;
        H4_3    = 0;
        H4_4    = 0;
    end
end

always @(*)
begin
    if (countHostage==4)
    begin
        H3_h_1 = H4_1 - half4;
        H3_h_2 = H4_2 - half4;
        H3_h_3 = H4_3 - half4;
        H3_h_4 = H4_4 - half4;
    end
    else if (countHostage==3)
    begin
        half3 =(H3_s_1 + H3_s_3) / 2 ;
        H3_h_1 = H3_s_1 - half3 ;
        H3_h_2 = H3_s_2 - half3 ;
        H3_h_3 = H3_s_3 - half3 ;
        H3_h_4 = 0 ;
    end
    else if (countHostage==2)
    begin
        half2 = (H2_1 + H2_2) / 2;
        H3_h_1 = H2_1 - half2 ;
        H3_h_2 = H2_2 - half2 ;
        H3_h_3 = 0 ;
        H3_h_4 = 0 ;
    end
    else
    begin
        H3_h_1 = 0 ;
        H3_h_2 = 0 ;
        H3_h_3 = 0 ;
        H3_h_4 = 0 ;
    end

    Res1 = H3_h_1;
    Res2 = (Res1*2+H3_h_2)/3;
    Res3 = (Res2*2+H3_h_3)/3;
    Res4 = (Res3*2+H3_h_4)/3;

end





endmodule
