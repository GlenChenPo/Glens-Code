//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : WD.v
//   Module Name : WD
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module WD(
    // Input signals
    clk,
    rst_n,
    in_valid,
    keyboard,
    answer,
    weight,
    match_target,
    // Output signals
    out_valid,
    result,
    out_value
  );
  // ===============================================================
  // Input & Output Declaration
  // ===============================================================
  input clk, rst_n, in_valid;
  input [4:0] keyboard, answer;
  input [3:0] weight;
  input [2:0] match_target;
  output reg out_valid;
  output reg [4:0]  result;
  output reg [10:0] out_value;
  // ===============================================================
  // ===============================================================
  // ===============================================================
  // Genvar & Parameters & Integer Declaration
  // ===============================================================
  // state
  parameter IDLE    = 2'd0;
  parameter STATE_1 = 2'd1; //get the input
  parameter STATE_2 = 2'd2; //process
  parameter STATE_3 = 2'd3; //output
  //genvar

  // ===============================================================
  // Wire & Reg Declaration
  // ===============================================================

  reg [1:0] current_state,next_state;//current & next state
  reg  a0,a1,a2,a3,a4;
  reg  b0,b1,b2,b3,b4;
  reg [2:0] A,B;
  reg [12:0] cnt;//counter

  //new

  reg [4:0] W_tmp [0:2]; //Right
  reg [4:0] R_tmp [0:4]; //Wrong
  reg [1:0] flag,flag1;//flag=finish sort R & W

  // temporary
  reg [4:0] key_tmp [0:7];
  reg [4:0] ans_tmp [0:4];
  reg [3:0] wei_tmp [0:4];
  reg [2:0] tar_tmp [0:1];

  //reg [4:0] sp_wei [0:4];

  reg [10:0] val_tmp;
  reg [4:0] cmp [0:4];
  reg [4:0] cmp1 [0:4];
  reg [4:0] cmp2 [0:4];
  reg [4:0] cmp3 [0:4];
  reg [4:0] cmp4 [0:4];

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
  */
  // -----------------Set Counter-----------------------------------
  always @(posedge clk or negedge rst_n) //cnt
  begin
    //*************************************************************
    //Reset--------------------------------------------------------
    if(~rst_n)
    begin
      cnt <= 0;
    end
    else if(in_valid && cnt==7)  //get the input,use 8 cycles
    begin
      cnt <= 0;
      flag<= 0;
    end
    else if (current_state == STATE_2 && cnt==7 && flag==0)//get the Wrong & Right
    begin
      flag <= 1;
      cnt <= 0;
    end
    else if (current_state == STATE_2 && flag1==1)
    begin
      cnt <= 0;
    end
    else if (current_state==IDLE && cnt==5)//cnt = output cycle
    begin
      cnt  <= 0;
    end
    //*************************************************************
    //count--------------------------------------------------------
    else if(in_valid)
    begin
      cnt <= cnt+1;
    end
    else if (current_state == STATE_2)
    begin
      cnt <= cnt+1;
    end
    else if (current_state == STATE_3)
    begin
      cnt <= cnt+1;
    end
    else if (out_valid)
    begin
      cnt <= cnt+1;
    end
  end


  // ----------------------Current State----------------------------
  //----------------------------------------------------------------
  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n) // rst_n=0(idle)  rst_n=1(next state)
      current_state <= IDLE;
    else
      current_state <= next_state;
  end
  //---------------------- Next State-------------------------------
  //----------------------------------------------------------------
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
      STATE_1: //GET THE INPUT
      begin
        if (~in_valid)
          next_state = STATE_2;
        else
          next_state = STATE_1;
      end

      STATE_2: //PROCESS
        if (flag1==1)
          next_state = STATE_3;
        else
          next_state = STATE_2;

      STATE_3: //GET THE OUPUT
        if(cnt==4)
          next_state = IDLE;
        else
          next_state = STATE_3;

      default:
        next_state = IDLE;
    endcase
  end
  //----------------------- Output Logic----------------------------
  //----------------------------------------------------------------
  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
      out_valid <= 0;
    else if (current_state == STATE_3)
      out_valid <= 1;
    else if (current_state==STATE_1)
      out_valid <= 0;
    else if (current_state==STATE_2)
      out_valid <= 0;
    else if (current_state==IDLE)
      out_valid <= 0;

  end
  // ===============================================================
  /*    SSSSSS     TTTTTTTTTT      AA           11
      SS               TT         A  A         111                                              
      SS               TT        AA  AA       1111                                                  
        SSSSSS         TT       AAAAAAAA        11                          
              SS       TT       AA    AA        11                                                 
              SS       TT      AA      AA       11                          
       SSSSSSS         TT      AA      AA    1111111                            
  */
  // ===============================================================
  // proc_1 Store the keyboard
  //-------------------------------------------------
  always @(posedge clk or negedge rst_n)
  begin : proc_1
    if(~rst_n)
    begin
      key_tmp[0] <= 0;
      key_tmp[1] <= 0;
      key_tmp[2] <= 0;
      key_tmp[3] <= 0;
      key_tmp[4] <= 0;
      key_tmp[5] <= 0;
      key_tmp[6] <= 0;
    end
    else if(in_valid && cnt<8)
    begin
      key_tmp[0] <= key_tmp[1];
      key_tmp[1] <= key_tmp[2];
      key_tmp[2] <= key_tmp[3];
      key_tmp[3] <= key_tmp[4];
      key_tmp[4] <= key_tmp[5];
      key_tmp[5] <= key_tmp[6];
      key_tmp[6] <= key_tmp[7];
      key_tmp[7] <= keyboard;
    end
  end
  //-------------------------------------------------
  // proc_2 Store the anwser & weight
  //-------------------------------------------------
  always @(posedge clk or negedge rst_n)
  begin : proc_2
    if(~rst_n)
    begin
      ans_tmp[0] <= 0;
      ans_tmp[1] <= 0;
      ans_tmp[2] <= 0;
      ans_tmp[3] <= 0;
      ans_tmp[4] <= 0;
    end
    else if(in_valid && cnt<5)
    begin
      ans_tmp[0] <= ans_tmp[1];
      ans_tmp[1] <= ans_tmp[2];
      ans_tmp[2] <= ans_tmp[3];
      ans_tmp[3] <= ans_tmp[4];
      ans_tmp[4] <= answer;
    end
  end
  //-------------------------------------------------
  // proc_3 Store the weight
  //-------------------------------------------------
  always @(posedge clk or negedge rst_n)
  begin : proc_3
    if(~rst_n)
    begin
      wei_tmp[0] <= 0;
      wei_tmp[1] <= 0;
      wei_tmp[2] <= 0;
      wei_tmp[3] <= 0;
      wei_tmp[4] <= 0;
    end
    else if(in_valid && cnt<5)
    begin
      wei_tmp[0] <= wei_tmp[1];
      wei_tmp[1] <= wei_tmp[2];
      wei_tmp[2] <= wei_tmp[3];
      wei_tmp[3] <= wei_tmp[4];
      wei_tmp[4] <= weight;
    end
  end
  //-------------------------------------------------
  // proc_4 Store the match_target (_A,_B)
  //-------------------------------------------------
  always @(posedge clk or negedge rst_n)
  begin : proc_4
    if(~rst_n)
    begin
      tar_tmp[0] <= 0;
      tar_tmp[1] <= 0;
    end
    else if(in_valid && cnt<2)
    begin
      tar_tmp[0] <= tar_tmp[1];
      tar_tmp[1] <= match_target;
    end
  end
  // ===============================================================
  // proc_5 sort right & wrong
  // ---------------------------------------------------------------
  always @(posedge clk or negedge rst_n)
  begin : proc_5
    if (~rst_n)
    begin
      W_tmp[0] <=0;
      W_tmp[1] <=0;
      W_tmp[2] <=0;
      R_tmp[0] <=0;
      R_tmp[1] <=0;
      R_tmp[2] <=0;
      R_tmp[3] <=0;
      R_tmp[4] <=0;
    end
    else
    begin
      if(current_state == STATE_2)
      begin
        if (cnt<8 && flag==0)
        begin
          if (key_tmp[cnt]!=ans_tmp[0] && key_tmp[cnt]!=ans_tmp[1] && key_tmp[cnt]!=ans_tmp[2]
              && key_tmp[cnt]!=ans_tmp[3] && key_tmp[cnt]!=ans_tmp[4])
          begin
            W_tmp[0] <= W_tmp[1];
            W_tmp[1] <= W_tmp[2];
            W_tmp[2] <= key_tmp[cnt];
          end
          else
          begin
            R_tmp[0] <= R_tmp[1];
            R_tmp[1] <= R_tmp[2];
            R_tmp[2] <= R_tmp[3];
            R_tmp[3] <= R_tmp[4];
            R_tmp[4] <= key_tmp[cnt];
          end
        end
      end
      else
      begin
        W_tmp[0] <=0;
        W_tmp[1] <=0;
        W_tmp[2] <=0;
        R_tmp[0] <=0;
        R_tmp[1] <=0;
        R_tmp[2] <=0;
        R_tmp[3] <=0;
        R_tmp[4] <=0;
      end
    end
  end
  // ===============================================================
  /*    SSSSSS     TTTTTTTTTT      AA          222222222
      SS               TT         A  A        22       22                                           
      SS               TT        AA  AA                22                                            
        SSSSSS         TT       AAAAAAAA              22                      
              SS       TT       AA    AA           222                                                 
              SS       TT      AA      AA        222                            
       SSSSSSS         TT      AA      AA     222222222222                              
  */
  // ===============================================================
  // determine how many A&B cmp[0 1 2 3 4] have.
  // ---------------------------------------------------------------
  always @(posedge clk or negedge rst_n)
  begin
    if(~rst_n)
    begin
      a0<= 0;
      b0<= 0;
    end
    else
    begin
      if (cmp[0]==ans_tmp[0])
      begin
        a0<=1;
        b0<=0;
      end
      else if (cmp[0]==ans_tmp[1]||cmp[0]==ans_tmp[2]||cmp[0]==ans_tmp[3]||cmp[0]==ans_tmp[4])
      begin
        b0<=1;
        a0<=0;
      end
      else
      begin
        a0<=0;
        b0<=0;
      end
    end
  end
  //---------------------------------------------------------
  always @(posedge clk or negedge rst_n)
  begin
    if(~rst_n)
    begin
      a1 <= 0;
      b1 <= 0;
    end
    else
    begin
      if (cmp[1]==ans_tmp[1])
      begin
        a1<=1;
        b1<=0;
      end
      else if (cmp[1]==ans_tmp[0]||cmp[1]==ans_tmp[2]||cmp[1]==ans_tmp[3]||cmp[1]==ans_tmp[4])
      begin
        b1<=1;
        a1<=0;
      end
      else
      begin
        a1<=0;
        b1<=0;
      end
    end
  end//--------------------------------------------------------
  always @(posedge clk or negedge rst_n)
  begin
    if(~rst_n)
    begin
      a2 <= 0;
      b2 <= 0;
    end
    else
    begin
      if (cmp[2]==ans_tmp[2])
      begin
        a2<=1;
        b2<=0;
      end
      else if (cmp[2]==ans_tmp[0]||cmp[2]==ans_tmp[1]||cmp[2]==ans_tmp[3]||cmp[2]==ans_tmp[4])
      begin
        b2<=1;
        a2<=0;
      end
      else
      begin
        a2<=0;
        b2<=0;
      end
    end
  end//-------------------------------------------------------
  always @(posedge clk or negedge rst_n)
  begin
    if(~rst_n)
    begin
      a3 <= 0;
      b3 <= 0;
    end
    else
    begin
      if (cmp[3]==ans_tmp[3])
      begin
        a3<=1;
        b3<=0;
      end
      else if (cmp[3]==ans_tmp[0]||cmp[3]==ans_tmp[1]||cmp[3]==ans_tmp[2]||cmp[3]==ans_tmp[4])
      begin
        b3<=1;
        a3<=0;
      end
      else
      begin
        a3<=0;
        b3<=0;
      end
    end
  end//--------------------------------------------------------
  always @(posedge clk or negedge rst_n)
  begin
    if(~rst_n)
    begin
      a4 <= 0;
      b4 <= 0;
    end
    else
    begin
      if (cmp[4]==ans_tmp[4])
      begin
        a4<=1;
        b4<=0;
      end
      else if (cmp[4]==ans_tmp[0]||cmp[4]==ans_tmp[1]||cmp[4]==ans_tmp[2]||cmp[4]==ans_tmp[3])
      begin
        b4<=1;
        a4<=0;
      end
      else
      begin
        a4<=0;
        b4<=0;
      end
    end
  end
  // ===============================================================
  // compare the AB==AB
  // ---------------------------------------------------------------
  always @(posedge clk or negedge rst_n)
    if(~rst_n)
    begin
      cmp2[0]<=0;
      cmp2[1]<=0;
      cmp2[2]<=0;
      cmp2[3]<=0;
      cmp2[4]<=0;
      A<=0;
      B<=0;
    end
    else
    begin
      if (current_state==STATE_1)
      begin
        cmp2[0]<=0;
        cmp2[1]<=0;
        cmp2[2]<=0;
        cmp2[3]<=0;
        cmp2[4]<=0;
        A<=0;
        B<=0;
      end
      else
        if (current_state==STATE_2)
        begin
          A<=a0+a1+a2+a3+a4;
          B<=b0+b1+b2+b3+b4;
          cmp2[0]<=cmp1[0];
          cmp2[1]<=cmp1[1];
          cmp2[2]<=cmp1[2];
          cmp2[3]<=cmp1[3];
          cmp2[4]<=cmp1[4];
        end
    end

  always @(posedge clk or negedge rst_n)
  begin
    if (~rst_n)
    begin
      cmp3[0]<=0;
      cmp3[1]<=0;
      cmp3[2]<=0;
      cmp3[3]<=0;
      cmp3[4]<=0;
    end
    else
    begin
      if (current_state==STATE_1)
      begin
        cmp3[0]<=0;
        cmp3[1]<=0;
        cmp3[2]<=0;
        cmp3[3]<=0;
        cmp3[4]<=0;
      end
      else if((A==tar_tmp[0]) && (B==tar_tmp[1]))
      begin
        cmp3[0]<=cmp2[0];
        cmp3[1]<=cmp2[1];
        cmp3[2]<=cmp2[2];
        cmp3[3]<=cmp2[3];
        cmp3[4]<=cmp2[4];
      end
      else
      begin
        cmp3[0]<=cmp3[0];
        cmp3[1]<=cmp3[1];
        cmp3[2]<=cmp3[2];
        cmp3[3]<=cmp3[3];
        cmp3[4]<=cmp3[4];
      end
    end
  end



  /* =========================================================================================
         if it is bigger one that we store it to cmp4.           *****************************
                                                        ************************************** 
                                                  ********************************************
   ------------------------------------------*************************************************
  */
  always @(posedge clk or negedge rst_n)
  begin
    if (~rst_n)
    begin
      cmp4[0]<=0;
      cmp4[1]<=0;
      cmp4[2]<=0;
      cmp4[3]<=0;
      cmp4[4]<=0;
      val_tmp<=0;
    end
    else
    begin
      if (current_state==STATE_1)
      begin
        cmp4[0]<=0;
        cmp4[1]<=0;
        cmp4[2]<=0;
        cmp4[3]<=0;
        cmp4[4]<=0;
        val_tmp<=0;
      end
      else if (current_state==STATE_2)
      begin

        if (cmp3[0]*wei_tmp[0]+cmp3[1]*wei_tmp[1]+cmp3[2]*wei_tmp[2]+cmp3[3]*wei_tmp[3]+cmp3[4]*wei_tmp[4]
            >val_tmp)
        begin
          val_tmp<=cmp3[0]*wei_tmp[0]+cmp3[1]*wei_tmp[1]+cmp3[2]*wei_tmp[2]+cmp3[3]*wei_tmp[3]+cmp3[4]*wei_tmp[4];
          cmp4[0]<=cmp3[0];
          cmp4[1]<=cmp3[1];
          cmp4[2]<=cmp3[2];
          cmp4[3]<=cmp3[3];
          cmp4[4]<=cmp3[4];
        end
        else if (cmp3[0]*wei_tmp[0]+cmp3[1]*wei_tmp[1]+cmp3[2]*wei_tmp[2]+cmp3[3]*wei_tmp[3]+cmp3[4]*wei_tmp[4]
                 ==val_tmp)
        begin
          if (cmp3[0]*16+cmp3[1]*8+cmp3[2]*4+cmp3[3]*2+cmp3[4]>
              cmp4[0]*16+cmp4[1]*8+cmp4[2]*4+cmp4[3]*2+cmp4[4])
          begin
            val_tmp<=cmp3[0]*wei_tmp[0]+cmp3[1]*wei_tmp[1]+cmp3[2]*wei_tmp[2]+cmp3[3]*wei_tmp[3]+cmp3[4]*wei_tmp[4];
            cmp4[0]<=cmp3[0];
            cmp4[1]<=cmp3[1];
            cmp4[2]<=cmp3[2];
            cmp4[3]<=cmp3[3];
            cmp4[4]<=cmp3[4];
          end
          else if (cmp3[0]*16+cmp3[1]*8+cmp3[2]*4+cmp3[3]*2+cmp3[4]==
                   cmp4[0]*16+cmp4[1]*8+cmp4[2]*4+cmp4[3]*2+cmp4[4])
          begin
            if (cmp3[0]<cmp4[0])
            begin
              val_tmp<=cmp3[0]*wei_tmp[0]+cmp3[1]*wei_tmp[1]+cmp3[2]*wei_tmp[2]+cmp3[3]*wei_tmp[3]+cmp3[4]*wei_tmp[4];
              cmp4[0]<=cmp3[0];
              cmp4[1]<=cmp3[1];
              cmp4[2]<=cmp3[2];
              cmp4[3]<=cmp3[3];
              cmp4[4]<=cmp3[4];
            end
            else if (cmp3[0]==cmp4[0])
            begin
              if (cmp3[1]<cmp4[1])
              begin
                val_tmp<=cmp3[0]*wei_tmp[0]+cmp3[1]*wei_tmp[1]+cmp3[2]*wei_tmp[2]+cmp3[3]*wei_tmp[3]+cmp3[4]*wei_tmp[4];
                cmp4[0]<=cmp3[0];
                cmp4[1]<=cmp3[1];
                cmp4[2]<=cmp3[2];
                cmp4[3]<=cmp3[3];
                cmp4[4]<=cmp3[4];
              end
              else if (cmp3[1]==cmp4[1])
              begin
                if (cmp3[2]<cmp4[2])
                begin
                  val_tmp<=cmp3[0]*wei_tmp[0]+cmp3[1]*wei_tmp[1]+cmp3[2]*wei_tmp[2]+cmp3[3]*wei_tmp[3]+cmp3[4]*wei_tmp[4];
                  cmp4[0]<=cmp3[0];
                  cmp4[1]<=cmp3[1];
                  cmp4[2]<=cmp3[2];
                  cmp4[3]<=cmp3[3];
                  cmp4[4]<=cmp3[4];
                end
                else if (cmp3[2]==cmp4[2])
                begin
                  if (cmp3[3]<cmp4[3])
                  begin
                    val_tmp<=cmp3[0]*wei_tmp[0]+cmp3[1]*wei_tmp[1]+cmp3[2]*wei_tmp[2]+cmp3[3]*wei_tmp[3]+cmp3[4]*wei_tmp[4];
                    cmp4[0]<=cmp3[0];
                    cmp4[1]<=cmp3[1];
                    cmp4[2]<=cmp3[2];
                    cmp4[3]<=cmp3[3];
                    cmp4[4]<=cmp3[4];
                  end
                  else if (cmp3[3]==cmp4[3])
                  begin
                    if (cmp3[4]<cmp4[4])
                    begin
                      val_tmp<=cmp3[0]*wei_tmp[0]+cmp3[1]*wei_tmp[1]+cmp3[2]*wei_tmp[2]+cmp3[3]*wei_tmp[3]+cmp3[4]*wei_tmp[4];
                      cmp4[0]<=cmp3[0];
                      cmp4[1]<=cmp3[1];
                      cmp4[2]<=cmp3[2];
                      cmp4[3]<=cmp3[3];
                      cmp4[4]<=cmp3[4];
                    end

                    else
                    begin
                      cmp4[0]<=cmp4[0];
                      cmp4[1]<=cmp4[1];
                      cmp4[2]<=cmp4[2];
                      cmp4[3]<=cmp4[3];
                      cmp4[4]<=cmp4[4];
                      val_tmp<=val_tmp;
                    end
                  end
                  else
                  begin
                    cmp4[0]<=cmp4[0];
                    cmp4[1]<=cmp4[1];
                    cmp4[2]<=cmp4[2];
                    cmp4[3]<=cmp4[3];
                    cmp4[4]<=cmp4[4];
                    val_tmp<=val_tmp;
                  end
                end
                else
                begin
                  cmp4[0]<=cmp4[0];
                  cmp4[1]<=cmp4[1];
                  cmp4[2]<=cmp4[2];
                  cmp4[3]<=cmp4[3];
                  cmp4[4]<=cmp4[4];
                  val_tmp<=val_tmp;
                end
              end
              else
              begin
                cmp4[0]<=cmp4[0];
                cmp4[1]<=cmp4[1];
                cmp4[2]<=cmp4[2];
                cmp4[3]<=cmp4[3];
                cmp4[4]<=cmp4[4];
                val_tmp<=val_tmp;
              end
            end
            else
            begin
              cmp4[0]<=cmp4[0];
              cmp4[1]<=cmp4[1];
              cmp4[2]<=cmp4[2];
              cmp4[3]<=cmp4[3];
              cmp4[4]<=cmp4[4];
              val_tmp<=val_tmp;
            end
          end
          else
          begin
            cmp4[0]<=cmp4[0];
            cmp4[1]<=cmp4[1];
            cmp4[2]<=cmp4[2];
            cmp4[3]<=cmp4[3];
            cmp4[4]<=cmp4[4];
            val_tmp<=val_tmp;
          end
        end
        else
        begin
          cmp4[0]<=cmp4[0];
          cmp4[1]<=cmp4[1];
          cmp4[2]<=cmp4[2];
          cmp4[3]<=cmp4[3];
          cmp4[4]<=cmp4[4];
          val_tmp<=val_tmp;
        end
      end
    end

  end
  // =======================================================
  /*    SSSSSS     TTTTTTTTTT      AA        33333333
      SS               TT         A  A      33      333                                       
      SS               TT        AA  AA              33                                        
        SSSSSS         TT       AAAAAAAA      3333333                 
              SS       TT       AA    AA            33                                         
              SS       TT      AA      AA   33      333                 
       SSSSSSS         TT      AA      AA    333333333                   
  */
  // =======================================================
  // Store score
  //-------------------------------------------------
  always @(posedge clk or negedge rst_n)
  begin
    if(~rst_n)
    begin
      out_value<=0;
      result <=0;
    end
    else
    begin
      if (current_state == IDLE)
      begin
        out_value<=0;
        result <=0;
      end
      else if (current_state==STATE_1)
      begin
        out_value<=0;
        result <=0;
      end
      else if (current_state==STATE_3 && cnt<5)
      begin
        out_value <= val_tmp;
        result <= cmp4[cnt];
      end
    end
  end


  /*=================================================================================
          ccccc  cc cc  cc   pppppp                  ccccc  cc cc  cc   pppppp                                                   
        ccc      ccc  cc  c  pp   pp               ccc      ccc  cc  c  pp   pp                                            
        ccc      cc   c   c  pppppp                ccc      cc   c   c  pppppp                                             
         cccccc  cc   c   c  pp                     cccccc  cc   c   c  pp                                                  
  */
  always @(posedge clk or negedge rst_n)
  begin
    if (~rst_n)
    begin
      cmp1[0]<=0;
      cmp1[1]<=0;
      cmp1[2]<=0;
      cmp1[3]<=0;
      cmp1[4]<=0;
    end
    else
    begin
      if (current_state==STATE_1)
      begin
        cmp1[0]<=0;
        cmp1[1]<=0;
        cmp1[2]<=0;
        cmp1[3]<=0;
        cmp1[4]<=0;
      end
      else if (current_state==STATE_2)
      begin
        cmp1[0]<=cmp[0];
        cmp1[1]<=cmp[1];
        cmp1[2]<=cmp[2];
        cmp1[3]<=cmp[3];
        cmp1[4]<=cmp[4];
      end
    end
  end

  always @(posedge clk or negedge rst_n)
  begin
    if(~rst_n)
    begin
      cmp[0] <= 0;
      cmp[1] <= 0;
      cmp[2] <= 0;
      cmp[3] <= 0;
      cmp[4] <= 0;
    end
    else
      if (current_state==STATE_1)
      begin
        cmp[0] <= 0;
        cmp[1] <= 0;
        cmp[2] <= 0;
        cmp[3] <= 0;
        cmp[4] <= 0;
        flag1<= 0;
      end
      else if (current_state==STATE_2)
      begin
        if (tar_tmp[0]+tar_tmp[1]==5)
        begin
          case(cnt)
            0:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            1:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            2:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            3:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            4:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            5:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            6:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            7:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            8:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            9:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            10:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            11:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            12:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            13:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            14:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            15:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            16:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            17:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            18:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            19:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            20:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            21:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            22:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            23:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            24:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            25:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            26:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            27:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            28:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            29:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            30:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            31:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            32:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            33:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            34:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            35:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            36:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            37:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            38:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            39:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            40:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            41:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            42:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            43:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            44:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            45:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            46:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            47:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            48:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            49:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            50:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            51:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            52:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            53:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            54:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            55:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            56:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            57:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            58:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            59:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            60:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            61:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            62:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            63:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            64:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            65:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            66:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            67:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            68:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            69:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            70:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            71:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            72:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            73:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            74:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            75:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            76:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            77:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            78:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            79:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            80:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            81:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            82:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            83:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            84:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            85:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            86:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            87:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            88:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            89:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            90:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            91:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            92:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            93:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            94:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            95:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            96:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            97:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            98:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            99:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            100:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            101:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            102:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            103:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            104:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            105:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            106:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            107:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            108:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            109:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            110:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            111:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            112:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            113:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            114:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            115:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            116:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            117:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            118:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            119:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            124:
            begin
              flag1  <= 1;
              cmp[0] <= 0;
              cmp[1] <= 0;
              cmp[2] <= 0;
              cmp[3] <= 0;
              cmp[4] <= 0;
            end
          endcase
        end
        else if (tar_tmp[0]+tar_tmp[1]==4)
        begin
          case(cnt)
            0:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=R_tmp[1];
              cmp[2]<=R_tmp[2];
              cmp[3]<=R_tmp[3];
              cmp[4]<=W_tmp[2];
            end
            1:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=R_tmp[1];
              cmp[2]<=R_tmp[2];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[3];
            end
            2:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=R_tmp[1];
              cmp[2]<=R_tmp[3];
              cmp[3]<=R_tmp[2];
              cmp[4]<=W_tmp[2];
            end
            3:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=R_tmp[1];
              cmp[2]<=R_tmp[3];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[2];
            end
            4:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=R_tmp[1];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[2];
              cmp[4]<=R_tmp[3];
            end
            5:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=R_tmp[1];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[3];
              cmp[4]<=R_tmp[2];
            end
            6:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=R_tmp[2];
              cmp[2]<=R_tmp[1];
              cmp[3]<=R_tmp[3];
              cmp[4]<=W_tmp[2];
            end
            7:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=R_tmp[2];
              cmp[2]<=R_tmp[1];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[3];
            end
            8:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=R_tmp[2];
              cmp[2]<=R_tmp[3];
              cmp[3]<=R_tmp[1];
              cmp[4]<=W_tmp[2];
            end
            9:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=R_tmp[2];
              cmp[2]<=R_tmp[3];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[1];
            end
            10:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=R_tmp[2];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[1];
              cmp[4]<=R_tmp[3];
            end
            11:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=R_tmp[2];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[3];
              cmp[4]<=R_tmp[1];
            end
            12:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=R_tmp[3];
              cmp[2]<=R_tmp[1];
              cmp[3]<=R_tmp[2];
              cmp[4]<=W_tmp[2];
            end
            13:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=R_tmp[3];
              cmp[2]<=R_tmp[1];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[2];
            end
            14:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=R_tmp[3];
              cmp[2]<=R_tmp[2];
              cmp[3]<=R_tmp[1];
              cmp[4]<=W_tmp[2];
            end
            15:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=R_tmp[3];
              cmp[2]<=R_tmp[2];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[1];
            end
            16:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=R_tmp[3];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[1];
              cmp[4]<=R_tmp[2];
            end
            17:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=R_tmp[3];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[2];
              cmp[4]<=R_tmp[1];
            end
            18:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[1];
              cmp[3]<=R_tmp[2];
              cmp[4]<=R_tmp[3];
            end
            19:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[1];
              cmp[3]<=R_tmp[3];
              cmp[4]<=R_tmp[2];
            end
            20:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[2];
              cmp[3]<=R_tmp[1];
              cmp[4]<=R_tmp[3];
            end
            21:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[2];
              cmp[3]<=R_tmp[3];
              cmp[4]<=R_tmp[1];
            end
            22:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[3];
              cmp[3]<=R_tmp[1];
              cmp[4]<=R_tmp[2];
            end
            23:
            begin
              cmp[0]<=R_tmp[0];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[3];
              cmp[3]<=R_tmp[2];
              cmp[4]<=R_tmp[1];
            end
            24:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=R_tmp[0];
              cmp[2]<=R_tmp[2];
              cmp[3]<=R_tmp[3];
              cmp[4]<=W_tmp[2];
            end
            25:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=R_tmp[0];
              cmp[2]<=R_tmp[2];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[3];
            end
            26:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=R_tmp[0];
              cmp[2]<=R_tmp[3];
              cmp[3]<=R_tmp[2];
              cmp[4]<=W_tmp[2];
            end
            27:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=R_tmp[0];
              cmp[2]<=R_tmp[3];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[2];
            end
            28:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=R_tmp[0];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[2];
              cmp[4]<=R_tmp[3];
            end
            29:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=R_tmp[0];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[3];
              cmp[4]<=R_tmp[2];
            end
            30:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=R_tmp[2];
              cmp[2]<=R_tmp[0];
              cmp[3]<=R_tmp[3];
              cmp[4]<=W_tmp[2];
            end
            31:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=R_tmp[2];
              cmp[2]<=R_tmp[0];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[3];
            end
            32:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=R_tmp[2];
              cmp[2]<=R_tmp[3];
              cmp[3]<=R_tmp[0];
              cmp[4]<=W_tmp[2];
            end
            33:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=R_tmp[2];
              cmp[2]<=R_tmp[3];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[0];
            end
            34:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=R_tmp[2];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[0];
              cmp[4]<=R_tmp[3];
            end
            35:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=R_tmp[2];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[3];
              cmp[4]<=R_tmp[0];
            end
            36:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=R_tmp[3];
              cmp[2]<=R_tmp[0];
              cmp[3]<=R_tmp[2];
              cmp[4]<=W_tmp[2];
            end
            37:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=R_tmp[3];
              cmp[2]<=R_tmp[0];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[2];
            end
            38:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=R_tmp[3];
              cmp[2]<=R_tmp[2];
              cmp[3]<=R_tmp[0];
              cmp[4]<=W_tmp[2];
            end
            39:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=R_tmp[3];
              cmp[2]<=R_tmp[2];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[0];
            end
            40:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=R_tmp[3];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[0];
              cmp[4]<=R_tmp[2];
            end
            41:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=R_tmp[3];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[2];
              cmp[4]<=R_tmp[0];
            end
            42:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[0];
              cmp[3]<=R_tmp[2];
              cmp[4]<=R_tmp[3];
            end
            43:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[0];
              cmp[3]<=R_tmp[3];
              cmp[4]<=R_tmp[2];
            end
            44:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[2];
              cmp[3]<=R_tmp[0];
              cmp[4]<=R_tmp[3];
            end
            45:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[2];
              cmp[3]<=R_tmp[3];
              cmp[4]<=R_tmp[0];
            end
            46:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[3];
              cmp[3]<=R_tmp[0];
              cmp[4]<=R_tmp[2];
            end
            47:
            begin
              cmp[0]<=R_tmp[1];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[3];
              cmp[3]<=R_tmp[2];
              cmp[4]<=R_tmp[0];
            end
            48:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=R_tmp[0];
              cmp[2]<=R_tmp[1];
              cmp[3]<=R_tmp[3];
              cmp[4]<=W_tmp[2];
            end
            49:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=R_tmp[0];
              cmp[2]<=R_tmp[1];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[3];
            end
            50:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=R_tmp[0];
              cmp[2]<=R_tmp[3];
              cmp[3]<=R_tmp[1];
              cmp[4]<=W_tmp[2];
            end
            51:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=R_tmp[0];
              cmp[2]<=R_tmp[3];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[1];
            end
            52:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=R_tmp[0];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[1];
              cmp[4]<=R_tmp[3];
            end
            53:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=R_tmp[0];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[3];
              cmp[4]<=R_tmp[1];
            end
            54:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=R_tmp[1];
              cmp[2]<=R_tmp[0];
              cmp[3]<=R_tmp[3];
              cmp[4]<=W_tmp[2];
            end
            55:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=R_tmp[1];
              cmp[2]<=R_tmp[0];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[3];
            end
            56:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=R_tmp[1];
              cmp[2]<=R_tmp[3];
              cmp[3]<=R_tmp[0];
              cmp[4]<=W_tmp[2];
            end
            57:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=R_tmp[1];
              cmp[2]<=R_tmp[3];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[0];
            end
            58:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=R_tmp[1];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[0];
              cmp[4]<=R_tmp[3];
            end
            59:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=R_tmp[1];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[3];
              cmp[4]<=R_tmp[0];
            end
            60:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=R_tmp[3];
              cmp[2]<=R_tmp[0];
              cmp[3]<=R_tmp[1];
              cmp[4]<=W_tmp[2];
            end
            61:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=R_tmp[3];
              cmp[2]<=R_tmp[0];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[1];
            end
            62:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=R_tmp[3];
              cmp[2]<=R_tmp[1];
              cmp[3]<=R_tmp[0];
              cmp[4]<=W_tmp[2];
            end
            63:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=R_tmp[3];
              cmp[2]<=R_tmp[1];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[0];
            end
            64:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=R_tmp[3];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[0];
              cmp[4]<=R_tmp[1];
            end
            65:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=R_tmp[3];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[1];
              cmp[4]<=R_tmp[0];
            end
            66:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[0];
              cmp[3]<=R_tmp[1];
              cmp[4]<=R_tmp[3];
            end
            67:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[0];
              cmp[3]<=R_tmp[3];
              cmp[4]<=R_tmp[1];
            end
            68:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[1];
              cmp[3]<=R_tmp[0];
              cmp[4]<=R_tmp[3];
            end
            69:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[1];
              cmp[3]<=R_tmp[3];
              cmp[4]<=R_tmp[0];
            end
            70:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[3];
              cmp[3]<=R_tmp[0];
              cmp[4]<=R_tmp[1];
            end
            71:
            begin
              cmp[0]<=R_tmp[2];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[3];
              cmp[3]<=R_tmp[1];
              cmp[4]<=R_tmp[0];
            end
            72:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=R_tmp[0];
              cmp[2]<=R_tmp[1];
              cmp[3]<=R_tmp[2];
              cmp[4]<=W_tmp[2];
            end
            73:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=R_tmp[0];
              cmp[2]<=R_tmp[1];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[2];
            end
            74:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=R_tmp[0];
              cmp[2]<=R_tmp[2];
              cmp[3]<=R_tmp[1];
              cmp[4]<=W_tmp[2];
            end
            75:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=R_tmp[0];
              cmp[2]<=R_tmp[2];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[1];
            end
            76:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=R_tmp[0];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[1];
              cmp[4]<=R_tmp[2];
            end
            77:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=R_tmp[0];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[2];
              cmp[4]<=R_tmp[1];
            end
            78:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=R_tmp[1];
              cmp[2]<=R_tmp[0];
              cmp[3]<=R_tmp[2];
              cmp[4]<=W_tmp[2];
            end
            79:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=R_tmp[1];
              cmp[2]<=R_tmp[0];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[2];
            end
            80:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=R_tmp[1];
              cmp[2]<=R_tmp[2];
              cmp[3]<=R_tmp[0];
              cmp[4]<=W_tmp[2];
            end
            81:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=R_tmp[1];
              cmp[2]<=R_tmp[2];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[0];
            end
            82:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=R_tmp[1];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[0];
              cmp[4]<=R_tmp[2];
            end
            83:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=R_tmp[1];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[2];
              cmp[4]<=R_tmp[0];
            end
            84:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=R_tmp[2];
              cmp[2]<=R_tmp[0];
              cmp[3]<=R_tmp[1];
              cmp[4]<=W_tmp[2];
            end
            85:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=R_tmp[2];
              cmp[2]<=R_tmp[0];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[1];
            end
            86:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=R_tmp[2];
              cmp[2]<=R_tmp[1];
              cmp[3]<=R_tmp[0];
              cmp[4]<=W_tmp[2];
            end
            87:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=R_tmp[2];
              cmp[2]<=R_tmp[1];
              cmp[3]<=W_tmp[2];
              cmp[4]<=R_tmp[0];
            end
            88:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=R_tmp[2];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[0];
              cmp[4]<=R_tmp[1];
            end
            89:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=R_tmp[2];
              cmp[2]<=W_tmp[2];
              cmp[3]<=R_tmp[1];
              cmp[4]<=R_tmp[0];
            end
            90:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[0];
              cmp[3]<=R_tmp[1];
              cmp[4]<=R_tmp[2];
            end
            91:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[0];
              cmp[3]<=R_tmp[2];
              cmp[4]<=R_tmp[1];
            end
            92:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[1];
              cmp[3]<=R_tmp[0];
              cmp[4]<=R_tmp[2];
            end
            93:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[1];
              cmp[3]<=R_tmp[2];
              cmp[4]<=R_tmp[0];
            end
            94:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[2];
              cmp[3]<=R_tmp[0];
              cmp[4]<=R_tmp[1];
            end
            95:
            begin
              cmp[0]<=R_tmp[3];
              cmp[1]<=W_tmp[2];
              cmp[2]<=R_tmp[2];
              cmp[3]<=R_tmp[1];
              cmp[4]<=R_tmp[0];
            end
            96:
            begin
              cmp[0]<=W_tmp[2];
              cmp[1]<=R_tmp[0];
              cmp[2]<=R_tmp[1];
              cmp[3]<=R_tmp[2];
              cmp[4]<=R_tmp[3];
            end
            97:
            begin
              cmp[0]<=W_tmp[2];
              cmp[1]<=R_tmp[0];
              cmp[2]<=R_tmp[1];
              cmp[3]<=R_tmp[3];
              cmp[4]<=R_tmp[2];
            end
            98:
            begin
              cmp[0]<=W_tmp[2];
              cmp[1]<=R_tmp[0];
              cmp[2]<=R_tmp[2];
              cmp[3]<=R_tmp[1];
              cmp[4]<=R_tmp[3];
            end
            99:
            begin
              cmp[0]<=W_tmp[2];
              cmp[1]<=R_tmp[0];
              cmp[2]<=R_tmp[2];
              cmp[3]<=R_tmp[3];
              cmp[4]<=R_tmp[1];
            end
            100:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            101:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            102:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            103:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            104:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            105:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            106:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            107:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            108:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            109:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            110:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            111:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            112:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            113:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            114:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            115:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            116:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            117:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            118:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            119:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            120:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            121:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            122:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            123:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            124:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            125:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            126:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            127:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            128:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            129:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            130:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            131:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            132:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            133:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            134:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            135:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            136:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            137:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            138:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            139:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            140:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            141:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            142:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            143:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            144:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            145:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            146:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            147:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            148:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            149:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            150:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            151:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            152:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            153:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            154:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            155:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            156:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            157:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            158:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            159:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            160:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            161:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            162:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            163:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            164:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            165:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            166:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            167:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            168:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            169:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            170:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            171:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            172:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            173:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            174:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            175:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            176:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            177:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            178:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            179:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            180:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            181:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            182:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            183:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            184:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            185:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            186:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            187:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            188:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            189:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            190:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            191:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            192:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            193:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            194:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            195:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            196:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            197:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            198:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            199:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            200:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            201:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            202:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            203:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            204:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            205:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            206:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            207:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            208:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            209:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            210:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            211:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            212:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            213:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            214:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            215:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            216:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            217:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            218:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            219:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            220:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            221:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            222:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            223:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            224:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            225:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            226:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            227:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            228:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            229:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            230:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            231:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            232:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            233:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            234:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            235:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            236:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            237:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            238:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            239:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            240:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            241:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            242:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            243:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            244:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            245:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            246:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            247:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            248:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            249:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            250:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            251:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            252:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            253:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            254:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            255:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            256:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            257:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            258:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            259:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            260:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            261:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            262:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            263:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            264:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            265:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            266:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            267:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            268:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            269:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            270:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            271:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            272:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            273:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            274:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            275:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            276:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            277:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            278:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            279:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            280:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            281:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            282:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            283:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            284:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            285:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            286:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            287:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            288:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            289:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            290:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            291:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            292:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            293:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            294:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            295:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            296:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            297:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            298:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            299:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            300:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            301:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            302:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            303:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            304:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            305:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            306:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            307:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            308:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            309:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            310:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            311:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            312:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            313:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            314:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            315:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            316:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            317:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            318:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            319:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            320:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            321:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            322:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            323:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            324:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            325:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            326:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            327:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            328:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            329:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            330:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            331:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            332:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            333:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            334:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            335:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            336:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            337:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            338:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            339:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            340:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            341:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            342:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            343:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            344:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            345:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            346:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            347:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            348:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            349:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            350:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            351:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            352:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            353:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            354:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            355:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            356:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            357:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            358:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            359:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            360:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            361:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            362:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            363:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            364:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            365:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            366:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            367:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            368:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            369:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            370:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            371:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            372:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            373:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            374:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            375:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            376:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            377:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            378:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            379:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            380:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            381:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            382:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            383:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            384:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            385:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            386:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            387:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            388:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            389:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            390:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            391:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            392:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            393:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            394:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            395:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            396:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            397:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            398:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            399:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            400:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            401:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            402:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            403:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            404:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            405:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            406:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            407:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            408:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            409:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            410:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            411:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            412:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            413:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            414:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            415:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            416:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            417:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            418:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            419:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            420:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            421:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            422:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            423:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            424:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            425:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            426:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            427:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            428:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            429:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            430:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            431:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            432:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            433:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            434:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            435:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            436:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            437:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            438:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            439:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            440:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            441:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            442:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            443:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            444:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            445:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            446:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            447:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            448:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            449:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            450:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            451:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            452:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            453:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            454:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            455:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            456:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            457:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            458:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            459:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            460:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            461:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            462:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            463:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            464:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            465:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            466:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            467:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            468:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            469:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            470:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            471:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            472:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            473:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            474:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            475:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            476:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            477:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            478:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            479:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            480:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            481:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            482:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            483:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            484:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            485:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            486:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            487:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            488:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            489:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            490:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            491:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            492:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            493:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            494:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            495:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            496:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            497:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            498:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            499:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            500:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            501:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            502:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            503:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            504:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            505:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            506:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            507:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            508:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            509:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            510:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            511:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            512:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            513:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            514:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            515:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            516:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            517:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            518:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            519:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            520:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            521:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            522:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            523:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            524:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            525:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            526:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            527:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            528:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            529:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            530:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            531:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            532:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            533:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            534:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            535:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            536:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            537:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            538:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            539:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            540:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            541:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            542:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            543:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            544:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            545:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            546:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            547:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            548:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            549:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            550:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            551:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            552:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            553:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            554:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            555:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            556:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            557:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            558:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            559:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            560:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            561:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            562:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            563:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            564:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            565:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            566:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            567:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            568:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            569:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            570:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            571:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            572:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            573:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            574:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            575:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            576:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            577:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            578:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            579:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            580:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            581:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            582:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            583:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            584:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            585:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            586:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            587:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            588:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            589:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            590:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            591:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            592:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            593:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            594:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            595:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            596:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            597:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            598:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            599:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            603:
            begin
              cmp[0] <= 0;
              cmp[1] <= 0;
              cmp[2] <= 0;
              cmp[3] <= 0;
              cmp[4] <= 0;
              flag1  <= 1;
            end


          endcase
        end
        else if (tar_tmp[0]+tar_tmp[1]==3)
        begin
          case(cnt)
            0:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            2:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            3:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            4:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            5:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            6:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            7:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            8:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            9:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            10:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            11:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            12:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            13:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            14:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            15:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            16:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            17:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            18:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            19:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            20:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            21:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            22:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            23:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            24:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            25:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            26:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            27:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            28:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            29:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            30:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            31:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            32:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            33:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            34:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            35:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            36:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            37:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            38:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            39:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            40:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            41:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            42:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            43:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            44:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            45:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            46:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            47:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            48:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            49:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            50:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            51:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            52:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            53:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            54:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            55:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            56:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            57:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            58:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            59:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            60:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            61:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            62:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            63:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            64:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            65:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            66:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            67:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            68:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            69:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            70:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            71:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            72:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            73:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            74:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            75:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            76:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            77:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            78:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            79:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            80:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            81:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            82:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            83:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            84:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            85:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            86:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            87:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            88:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            89:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            90:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            91:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            92:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            93:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            94:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            95:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            96:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            97:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            98:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            99:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            100:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            101:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            102:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            103:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            104:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            105:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            106:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            107:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            108:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            109:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            110:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            111:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            112:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            113:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            114:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            115:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            116:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            117:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            118:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            119:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            120:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            121:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            122:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            123:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            124:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            125:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            126:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            127:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            128:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            129:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            130:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            131:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            132:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            133:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            134:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            135:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            136:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            137:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            138:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            139:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            140:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            141:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            142:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            143:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            144:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            145:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            146:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            147:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            148:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            149:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            150:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            151:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            152:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            153:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            154:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            155:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            156:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            157:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            158:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            159:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            160:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            161:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            162:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            163:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            164:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            165:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            166:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            167:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            168:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            169:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            170:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            171:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            172:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            173:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            174:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            175:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            176:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            177:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            178:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            179:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            180:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            181:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            182:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            183:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            184:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            185:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            186:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            187:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            188:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            189:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            190:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            191:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            192:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            193:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            194:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            195:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            196:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            197:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            198:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            199:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            200:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            201:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            202:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            203:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            204:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            205:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            206:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            207:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            208:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            209:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            210:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            211:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            212:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            213:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            214:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            215:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            216:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            217:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            218:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            219:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            220:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            221:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            222:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            223:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            224:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            225:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            226:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            227:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            228:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            229:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            230:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            231:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            232:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            233:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            234:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            235:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            236:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            237:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            238:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            239:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            240:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            241:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            242:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            243:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            244:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            245:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            246:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            247:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            248:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            249:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            250:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            251:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            252:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            253:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            254:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            255:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            256:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            257:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            258:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            259:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            260:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            261:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            262:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            263:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            264:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            265:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            266:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            267:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            268:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            269:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            270:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            271:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            272:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            273:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            274:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            275:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            276:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            277:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            278:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            279:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            280:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            281:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            282:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            283:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            284:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            285:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            286:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            287:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            288:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            289:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            290:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            291:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            292:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            293:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            294:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            295:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            296:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            297:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            298:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            299:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            300:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            301:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            302:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            303:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            304:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            305:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            306:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            307:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            308:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            309:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            310:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            311:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            312:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            313:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            314:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            315:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            316:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            317:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            318:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            319:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            320:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            321:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            322:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            323:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            324:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            325:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            326:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            327:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            328:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            329:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            330:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            331:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            332:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            333:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            334:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            335:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            336:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            337:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            338:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            339:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            340:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            341:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            342:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            343:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            344:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            345:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            346:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            347:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            348:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            349:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            350:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            351:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            352:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            353:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            354:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            355:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            356:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            357:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            358:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            359:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            360:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            361:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            362:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            363:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            364:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            365:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            366:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            367:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            368:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            369:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            370:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            371:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            372:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            373:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            374:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            375:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            376:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            377:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            378:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            379:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            380:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            381:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            382:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            383:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            384:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            385:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            386:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            387:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            388:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            389:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            390:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            391:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            392:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            393:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            394:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            395:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            396:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            397:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            398:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            399:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            400:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            401:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            402:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            403:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            404:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            405:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            406:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            407:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            408:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            409:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            410:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            411:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            412:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            413:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            414:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            415:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            416:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            417:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            418:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            419:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            420:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            421:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            422:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            423:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            424:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            425:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            426:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            427:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            428:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            429:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            430:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            431:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            432:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            433:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            434:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            435:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            436:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            437:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            438:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            439:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            440:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            441:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            442:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            443:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            444:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            445:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            446:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            447:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            448:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            449:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            450:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            451:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            452:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            453:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            454:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            455:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            456:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            457:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            458:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            459:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            460:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            461:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            462:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            463:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            464:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            465:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            466:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            467:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            468:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            469:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            470:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            471:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            472:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            473:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            474:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            475:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            476:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            477:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            478:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            479:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            480:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            481:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            482:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            483:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            484:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            485:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            486:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            487:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            488:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            489:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            490:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            491:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            492:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            493:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            494:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            495:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            496:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            497:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            498:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            499:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            500:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            501:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            502:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            503:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            504:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            505:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            506:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            507:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            508:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            509:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            510:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            511:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            512:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            513:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            514:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            515:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            516:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            517:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            518:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            519:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            520:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            521:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            522:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            523:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            524:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            525:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            526:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            527:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            528:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            529:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            530:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            531:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            532:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            533:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            534:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            535:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            536:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            537:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            538:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            539:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            540:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            541:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            542:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            543:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            544:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            545:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            546:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            547:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            548:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            549:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            550:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            551:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            552:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            553:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            554:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            555:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            556:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            557:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            558:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            559:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            560:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            561:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            562:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            563:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            564:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            565:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            566:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            567:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            568:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            569:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            570:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            571:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            572:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            573:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            574:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            575:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            576:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            577:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            578:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            579:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            580:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            581:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            582:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            583:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            584:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            585:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            586:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            587:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            588:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            589:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            590:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            591:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            592:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            593:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            594:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            595:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            596:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            597:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            598:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            599:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            600:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            601:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            602:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            603:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            604:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            605:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            606:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            607:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            608:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            609:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            610:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            611:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            612:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            613:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            614:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            615:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            616:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            617:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            618:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            619:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            620:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            621:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            622:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            623:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            624:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            625:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            626:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            627:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            628:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            629:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            630:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            631:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            632:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            633:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            634:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            635:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            636:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            637:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            638:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            639:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            640:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            641:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            642:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            643:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            644:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            645:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            646:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            647:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            648:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            649:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            650:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            651:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            652:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            653:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            654:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            655:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            656:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            657:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            658:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            659:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            660:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            661:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            662:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            663:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            664:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            665:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            666:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            667:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            668:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            669:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            670:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            671:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            672:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            673:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            674:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            675:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            676:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            677:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            678:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            679:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            680:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            681:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            682:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            683:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            684:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            685:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            686:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            687:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            688:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            689:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            690:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            691:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            692:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            693:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            694:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            695:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            696:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            697:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            698:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            699:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            700:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            701:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            702:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            703:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            704:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            705:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            706:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            707:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            708:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            709:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            710:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            711:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            712:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            713:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            714:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            715:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            716:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            717:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            718:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            719:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            720:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            721:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            722:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            723:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            724:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            725:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            726:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            727:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            728:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            729:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            730:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            731:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            732:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            733:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            734:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            735:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            736:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            737:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            738:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            739:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            740:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            741:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            742:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            743:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            744:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            745:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            746:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            747:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            748:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            749:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            750:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            751:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            752:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            753:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            754:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            755:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            756:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            757:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            758:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            759:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            760:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            761:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            762:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            763:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            764:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            765:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            766:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            767:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            768:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            769:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            770:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            771:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            772:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            773:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            774:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            775:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            776:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            777:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            778:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            779:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            780:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            781:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            782:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            783:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            784:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            785:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            786:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            787:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            788:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            789:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            790:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            791:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            792:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            793:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            794:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            795:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            796:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            797:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            798:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            799:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            800:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            801:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            802:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            803:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            804:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            805:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            806:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            807:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            808:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            809:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            810:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            811:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            812:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            813:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            814:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            815:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            816:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            817:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            818:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            819:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            820:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            821:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            822:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            823:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            824:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            825:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            826:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            827:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            828:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            829:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            830:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            831:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            832:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            833:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            834:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            835:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            836:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            837:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            838:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            839:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            840:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            841:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            842:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            843:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            844:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            845:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            846:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            847:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            848:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            849:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            850:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            851:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            852:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            853:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            854:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            855:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            856:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            857:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            858:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            859:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            860:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            861:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            862:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            863:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            864:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            865:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            866:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            867:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            868:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            869:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            870:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            871:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            872:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            873:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            874:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            875:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            876:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            877:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            878:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            879:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            880:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            881:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            882:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            883:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            884:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            885:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            886:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            887:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            888:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            889:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            890:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            891:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            892:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            893:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            894:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            895:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            896:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            897:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            898:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            899:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            900:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            901:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            902:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            903:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            904:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            905:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            906:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            907:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            908:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            909:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            910:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            911:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            912:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            913:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            914:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            915:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            916:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            917:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            918:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            919:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            920:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            921:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            922:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            923:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            924:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            925:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            926:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            927:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            928:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            929:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            930:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            931:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            932:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            933:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            934:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            935:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            936:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            937:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            938:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            939:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            940:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            941:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            942:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            943:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            944:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            945:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            946:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            947:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            948:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            949:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            950:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            951:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            952:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            953:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            954:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            955:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            956:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            957:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            958:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            959:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            960:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            961:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            962:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            963:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            964:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            965:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            966:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            967:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            968:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            969:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            970:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            971:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            972:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            973:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            974:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            975:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            976:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            977:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            978:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            979:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            980:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            981:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            982:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            983:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            984:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            985:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            986:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            987:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            988:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            989:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            990:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            991:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            992:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            993:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            994:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            995:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            996:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            997:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            998:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            999:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            1000:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1001:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            1002:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1003:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1004:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            1005:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            1006:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1007:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            1008:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1009:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1010:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            1011:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1012:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            1013:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1014:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1015:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1016:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1017:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            1018:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            1019:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            1020:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            1021:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1022:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1023:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            1024:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1025:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            1026:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            1027:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1028:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            1029:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            1030:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1031:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            1032:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            1033:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1034:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            1035:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1036:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            1037:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            1038:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            1039:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1040:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1041:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            1042:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1043:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            1044:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            1045:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1046:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1047:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            1048:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1049:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            1050:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            1051:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            1052:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1053:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            1054:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1055:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            1056:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1057:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1058:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            1059:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1060:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            1061:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            1062:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1063:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1064:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            1065:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            1066:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1067:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            1068:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            1069:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1070:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            1071:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            1072:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1073:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            1074:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            1075:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            1076:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1077:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            1078:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1079:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            1080:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1081:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1082:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            1083:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1084:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1085:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1086:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1087:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1088:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            1089:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1090:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            1091:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1092:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            1093:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1094:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            1095:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1096:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            1097:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            1098:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1099:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1100:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            1101:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1102:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            1103:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            1104:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1105:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1106:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            1107:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1108:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1109:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1110:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1111:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1112:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            1113:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            1114:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1115:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            1116:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            1117:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1118:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            1119:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            1120:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1121:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            1122:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1123:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1124:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1125:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            1126:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1127:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            1128:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1129:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1130:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            1131:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1132:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            1133:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1134:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1135:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1136:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            1137:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            1138:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1139:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            1140:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            1141:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1142:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            1143:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            1144:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1145:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            1146:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            1147:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1148:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1149:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            1150:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1151:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            1152:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            1153:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1154:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            1155:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1156:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            1157:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            1158:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            1159:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1160:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            1161:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            1162:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1163:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            1164:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            1165:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1166:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            1167:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            1168:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1169:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            1170:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            1171:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            1172:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1173:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            1174:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1175:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            1176:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1177:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1178:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            1179:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1180:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            1181:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            1182:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1183:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1184:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1185:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            1186:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1187:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            1188:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            1189:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1190:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1191:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            1192:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1193:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            1194:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            1195:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            1196:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1197:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            1198:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1199:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            1223:
            begin
              flag1  <= 1;
              cmp[0] <= 0;
              cmp[1] <= 0;
              cmp[2] <= 0;
              cmp[3] <= 0;
              cmp[4] <= 0;
            end
          endcase
        end
        else if (tar_tmp[0]+tar_tmp[1]==2)
        begin
          case(cnt)
            0:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            2:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            3:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            4:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            5:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            6:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            7:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            8:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            9:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            10:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            11:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            12:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            13:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            14:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            15:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            16:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            17:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            18:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            19:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            20:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            21:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            22:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            23:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            24:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            25:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            26:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            27:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            28:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            29:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            30:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            31:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            32:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            33:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            34:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            35:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            36:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            37:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            38:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            39:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            40:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            41:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            42:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            43:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            44:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            45:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            46:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            47:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            48:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            49:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            50:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            51:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            52:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            53:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            54:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            55:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            56:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            57:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            58:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            59:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            60:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            61:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            62:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            63:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            64:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            65:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            66:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            67:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            68:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            69:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            70:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            71:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            72:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            73:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            74:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            75:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            76:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            77:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            78:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            79:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            80:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            81:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            82:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            83:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            84:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            85:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            86:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            87:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            88:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            89:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            90:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            91:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            92:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            93:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            94:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            95:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            96:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            97:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            98:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            99:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            100:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            101:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            102:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            103:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            104:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            105:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            106:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            107:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            108:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            109:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            110:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            111:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            112:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            113:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            114:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            115:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            116:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            117:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            118:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            119:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            120:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            121:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            122:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            123:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            124:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            125:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            126:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            127:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            128:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            129:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            130:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            131:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            132:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            133:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            134:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            135:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            136:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            137:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            138:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            139:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            140:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            141:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            142:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            143:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            144:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            145:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            146:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            147:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            148:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            149:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            150:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            151:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            152:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            153:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            154:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            155:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            156:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            157:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            158:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            159:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            160:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            161:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            162:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            163:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            164:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            165:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            166:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            167:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            168:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            169:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            170:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            171:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            172:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            173:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            174:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            175:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            176:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            177:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            178:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            179:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            180:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            181:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            182:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            183:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            184:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            185:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            186:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            187:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            188:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            189:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            190:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            191:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            192:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            193:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            194:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            195:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            196:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            197:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            198:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            199:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            200:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            201:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            202:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            203:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            204:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            205:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            206:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            207:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            208:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            209:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            210:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            211:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            212:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            213:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            214:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            215:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            216:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            217:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            218:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            219:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            220:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            221:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            222:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            223:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            224:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            225:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            226:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            227:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            228:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            229:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            230:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            231:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            232:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            233:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            234:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            235:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            236:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            237:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            238:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            239:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            240:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            241:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            242:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            243:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            244:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            245:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            246:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            247:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            248:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            249:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            250:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            251:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            252:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            253:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            254:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            255:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            256:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            257:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            258:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            259:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            260:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            261:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            262:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            263:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            264:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            265:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            266:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            267:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            268:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            269:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            270:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            271:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            272:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            273:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            274:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            275:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            276:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            277:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            278:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            279:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            280:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            281:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            282:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            283:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            284:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            285:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            286:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            287:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            288:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            289:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            290:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            291:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            292:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            293:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            294:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            295:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            296:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            297:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            298:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            299:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            300:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            301:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            302:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            303:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            304:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            305:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            306:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            307:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            308:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            309:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            310:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            311:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            312:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            313:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            314:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            315:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            316:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            317:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            318:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            319:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            320:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            321:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            322:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            323:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            324:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            325:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            326:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            327:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            328:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            329:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            330:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            331:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            332:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            333:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            334:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            335:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            336:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            337:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            338:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            339:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            340:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            341:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            342:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            343:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            344:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            345:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            346:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            347:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            348:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            349:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            350:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            351:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            352:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            353:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            354:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            355:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            356:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            357:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            358:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            359:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[0];
            end
            360:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            361:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            362:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            363:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            364:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            365:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            366:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            367:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            368:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            369:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            370:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            371:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            372:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            373:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            374:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            375:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            376:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            377:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            378:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            379:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            380:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            381:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            382:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            383:
            begin
              cmp[0] <= R_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            384:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            385:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            386:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            387:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            388:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            389:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            390:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            391:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            392:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            393:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            394:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            395:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            396:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            397:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            398:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            399:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            400:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            401:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            402:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            403:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            404:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            405:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            406:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            407:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            408:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            409:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            410:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            411:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            412:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            413:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            414:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            415:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            416:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            417:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            418:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            419:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            420:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            421:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            422:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            423:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            424:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            425:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            426:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            427:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            428:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            429:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            430:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            431:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            432:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            433:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            434:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            435:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            436:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            437:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            438:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            439:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            440:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            441:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            442:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            443:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            444:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            445:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            446:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            447:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[0];
            end
            448:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            449:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            450:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            451:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            452:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            453:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            454:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            455:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            456:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            457:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            458:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            459:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            460:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            461:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            462:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            463:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            464:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            465:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            466:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            467:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            468:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            469:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            470:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            471:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[0];
            end
            472:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            473:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            474:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            475:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[0];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            476:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[0];
              cmp[4] <= W_tmp[0];
            end
            477:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[0];
            end
            478:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            479:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[0];
            end
            480:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            481:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            482:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            483:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            484:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            485:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            486:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            487:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            488:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            489:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            490:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            491:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            492:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            493:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            494:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            495:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            496:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            497:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            498:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            499:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            500:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            501:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            502:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            503:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            504:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            505:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            506:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            507:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            508:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            509:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            510:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            511:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            512:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            513:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            514:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            515:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            516:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            517:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            518:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            519:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            520:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            521:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            522:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            523:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            524:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            525:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            526:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            527:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            528:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            529:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            530:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            531:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            532:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            533:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            534:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            535:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            536:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            537:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            538:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            539:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            540:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            541:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            542:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            543:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            544:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            545:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            546:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            547:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            548:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            549:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            550:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            551:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            552:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            553:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            554:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            555:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            556:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            557:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            558:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            559:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            560:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            561:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            562:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            563:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            564:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            565:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            566:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            567:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            568:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            569:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            570:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            571:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            572:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            573:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            574:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            575:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            576:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            577:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            578:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            579:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            580:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            581:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            582:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            583:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            584:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            585:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            586:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            587:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            588:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            589:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            590:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            591:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            592:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            593:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            594:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            595:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            596:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            597:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            598:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            599:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            600:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            601:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            602:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            603:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            604:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            605:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            606:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            607:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            608:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            609:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            610:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            611:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            612:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            613:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            614:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            615:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            616:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            617:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            618:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            619:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            620:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            621:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            622:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            623:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            624:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            625:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            626:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            627:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            628:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            629:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            630:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            631:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            632:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            633:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            634:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            635:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            636:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            637:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            638:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            639:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            640:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            641:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            642:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            643:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            644:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            645:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            646:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            647:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            648:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            649:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            650:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            651:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            652:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            653:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            654:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            655:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            656:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            657:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            658:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            659:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            660:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            661:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            662:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            663:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            664:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            665:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            666:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            667:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            668:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            669:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            670:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            671:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            672:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            673:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            674:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            675:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            676:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            677:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            678:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            679:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            680:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            681:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            682:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            683:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            684:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            685:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            686:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            687:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            688:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            689:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            690:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            691:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            692:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            693:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            694:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            695:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            696:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            697:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            698:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            699:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            700:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            701:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            702:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            703:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            704:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            705:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            706:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            707:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            708:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            709:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            710:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            711:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            712:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            713:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            714:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            715:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            716:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            717:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            718:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            719:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[1];
            end
            720:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            721:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            722:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            723:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            724:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            725:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            726:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            727:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            728:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            729:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            730:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            731:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            732:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            733:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            734:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            735:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            736:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            737:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            738:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            739:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            740:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            741:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            742:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            743:
            begin
              cmp[0] <= R_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            744:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            745:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            746:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            747:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            748:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            749:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            750:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            751:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            752:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            753:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            754:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            755:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            756:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            757:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            758:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            759:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            760:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            761:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            762:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            763:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            764:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            765:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            766:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            767:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            768:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            769:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            770:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            771:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            772:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            773:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            774:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            775:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            776:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            777:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            778:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            779:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            780:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            781:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            782:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            783:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            784:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            785:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            786:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            787:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            788:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            789:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            790:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            791:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            792:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            793:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            794:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            795:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            796:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            797:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            798:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            799:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            800:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            801:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            802:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            803:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            804:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            805:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            806:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            807:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[1];
            end
            808:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            809:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            810:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            811:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            812:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            813:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            814:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            815:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            816:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            817:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            818:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            819:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            820:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            821:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[1];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            822:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            823:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            824:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            825:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            826:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            827:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            828:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            829:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            830:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[1];
            end
            831:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[1];
            end
            832:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            833:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            834:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            835:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            836:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            837:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[1];
            end
            838:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            839:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[1];
            end
            840:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            841:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            842:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            843:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            844:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            845:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            846:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            847:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            848:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            849:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            850:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            851:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            852:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            853:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            854:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            855:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            856:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            857:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            858:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            859:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            860:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            861:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            862:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            863:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            864:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            865:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            866:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            867:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            868:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            869:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            870:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            871:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            872:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            873:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            874:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            875:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            876:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            877:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            878:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            879:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            880:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            881:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            882:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            883:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            884:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            885:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            886:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            887:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            888:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            889:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            890:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            891:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            892:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            893:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            894:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            895:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            896:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            897:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            898:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            899:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            900:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            901:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            902:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            903:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            904:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            905:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            906:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            907:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            908:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            909:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            910:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            911:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            912:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            913:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            914:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            915:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            916:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            917:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            918:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            919:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            920:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            921:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            922:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            923:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            924:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            925:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            926:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            927:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            928:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            929:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            930:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            931:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            932:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            933:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            934:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            935:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            936:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            937:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            938:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            939:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            940:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            941:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            942:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            943:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            944:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            945:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            946:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            947:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            948:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            949:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            950:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            951:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            952:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            953:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            954:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            955:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            956:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            957:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            958:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            959:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[2];
            end
            960:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            961:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            962:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            963:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            964:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            965:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            966:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            967:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            968:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            969:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            970:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            971:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            972:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            973:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            974:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            975:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            976:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            977:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            978:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            979:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            980:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            981:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            982:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            983:
            begin
              cmp[0] <= R_tmp[2];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            984:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            985:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            986:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            987:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            988:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            989:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            990:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            991:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            992:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            993:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            994:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            995:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            996:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            997:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            998:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            999:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            1000:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            1001:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            1002:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            1003:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            1004:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1005:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            1006:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            1007:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            1008:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1009:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1010:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            1011:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1012:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1013:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1014:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1015:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1016:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            1017:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            1018:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1019:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            1020:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            1021:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1022:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            1023:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            1024:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1025:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            1026:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1027:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1028:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1029:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            1030:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1031:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            1032:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            1033:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            1034:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            1035:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1036:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            1037:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            1038:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            1039:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            1040:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            1041:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            1042:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            1043:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            1044:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            1045:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1046:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[2];
            end
            1047:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[2];
            end
            1048:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1049:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            1050:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            1051:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            1052:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            1053:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            1054:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1055:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            1056:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            1057:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            1058:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1059:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1060:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            1061:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            1062:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            1063:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            1064:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1065:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            1066:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            1067:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            1068:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1069:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1070:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1071:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[2];
            end
            1072:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1073:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            1074:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            1075:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            1076:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            1077:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[2];
            end
            1078:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1079:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[2];
            end
            1080:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1081:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1082:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            1083:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            1084:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            1085:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            1086:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1087:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1088:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            1089:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1090:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1091:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1092:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            1093:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            1094:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            1095:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1096:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            1097:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            1098:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            1099:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            1100:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1101:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1102:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            1103:
            begin
              cmp[0] <= R_tmp[3];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            1104:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1105:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1106:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            1107:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            1108:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            1109:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            1110:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1111:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1112:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            1113:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1114:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            1115:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1116:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            1117:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            1118:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            1119:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1120:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            1121:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            1122:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            1123:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            1124:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            1125:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1126:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            1127:
            begin
              cmp[0] <= R_tmp[4];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            1128:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1129:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1130:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            1131:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1132:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1133:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1134:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[2];
            end
            1135:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[1];
            end
            1136:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            1137:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1138:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            1139:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1140:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            1141:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1142:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            1143:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1144:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            1145:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            1146:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1147:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1148:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            1149:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1150:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            1151:
            begin
              cmp[0] <= W_tmp[0];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            1152:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            1153:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            1154:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            1155:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1156:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            1157:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            1158:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[2];
            end
            1159:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= W_tmp[0];
            end
            1160:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            1161:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1162:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            1163:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[2];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            1164:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[2];
            end
            1165:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[4];
            end
            1166:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[2];
            end
            1167:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[2];
              cmp[4] <= R_tmp[3];
            end
            1168:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            1169:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[2];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            1170:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            1171:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            1172:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            1173:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            1174:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            1175:
            begin
              cmp[0] <= W_tmp[1];
              cmp[1] <= W_tmp[2];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            1176:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            1177:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            1178:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1179:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1180:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            1181:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[3];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            1182:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= W_tmp[1];
            end
            1183:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= W_tmp[0];
            end
            1184:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            1185:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[0];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1186:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            1187:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= R_tmp[4];
              cmp[2] <= W_tmp[1];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            1188:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[1];
            end
            1189:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[4];
            end
            1190:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[1];
            end
            1191:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[1];
              cmp[4] <= R_tmp[3];
            end
            1192:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            1193:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[0];
              cmp[2] <= W_tmp[1];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            1194:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= R_tmp[4];
              cmp[4] <= W_tmp[0];
            end
            1195:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[3];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[4];
            end
            1196:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= R_tmp[3];
              cmp[4] <= W_tmp[0];
            end
            1197:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= R_tmp[4];
              cmp[3] <= W_tmp[0];
              cmp[4] <= R_tmp[3];
            end
            1198:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[3];
              cmp[4] <= R_tmp[4];
            end
            1199:
            begin
              cmp[0] <= W_tmp[2];
              cmp[1] <= W_tmp[1];
              cmp[2] <= W_tmp[0];
              cmp[3] <= R_tmp[4];
              cmp[4] <= R_tmp[3];
            end
            1223:
            begin
              flag1  <= 1;
              cmp[0] <= 0;
              cmp[1] <= 0;
              cmp[2] <= 0;
              cmp[3] <= 0;
              cmp[4] <= 0;
            end
          endcase
        end
      end
  end
endmodule
