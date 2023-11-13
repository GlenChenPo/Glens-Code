module pokemon(input clk, INF.pokemon_inf inf);
import usertype::*;

//================================================================
//  FSM parameter
//================================================================
parameter S_IDLE       = 5'd0 ;
parameter S_loading    = 5'd1 ;
parameter S_MENU       = 5'd2 ;
parameter S_saving     = 5'd3 ;
parameter S_OPTION_1   = 5'd4 ;
parameter S_Deposit    = 5'd5 ;
parameter S_output     = 5'd6 ;
parameter S_Check      = 5'd7 ;
parameter S_Buy        = 5'd8 ;
parameter S_Sell       = 5'd9 ;
parameter S_UseItem    = 5'd10 ;

parameter S_OPTION_2   = 5'd11 ;
parameter S_loading2   = 5'd12 ;
parameter S_Attack     = 5'd13 ;
parameter S_sav_p2     = 5'd14 ;
parameter S_Continue   = 5'd15 ;
parameter S_Waiting    = 5'd16 ;


logic [6:0]  c_s , n_s;


// iloveiclab


//================================================================
// logic 
//================================================================
logic [3:0] action;
logic [7:0] ID_1 , ID_2 , ID_3;
logic [63:0] temp_info_1 , temp_info_2 , info_for_out;
logic [3:0]  temp_arror;
logic [15:0] temp_D;

logic flag_usedBracer;
logic [4:0] Big_cnt;
logic flag_action;
logic flag_Cinvalid;
logic flag_fin_attack ,  flag_finAction;
logic flag_item_pokemon;
//================================================================
//  FSM parameter
//================================================================
always_ff @(posedge clk or negedge inf.rst_n) 
begin
    if (!inf.rst_n) 
         c_s = S_IDLE;   
    else 
         c_s = n_s;
end

always_comb
  begin
    case (c_s)
        S_IDLE:
           if(inf.id_valid)
            n_s = S_loading;
           else
            n_s = S_IDLE; 
        
        S_MENU:
           begin
            if (inf.id_valid) 
              n_s = S_saving;
            else if (inf.act_valid) 
              n_s = S_Continue; 
            else 
              n_s = S_MENU;      
           end
        S_Continue:
          begin
            if (action==4'b0001) 
              begin
              if (inf.item_valid||inf.type_valid) 
                begin
                  n_s = S_Buy;
                end
              else 
                begin
                  n_s = S_Continue;
                end  
              end
            else if (action==4'b0010) 
              begin
              if (inf.item_valid||inf.type_valid) 
                begin
                  n_s = S_Sell;
                end
              else
                begin
                  n_s = S_Continue;
                end  
              end
            else if (action==4'b0100) 
              begin
              if (inf.amnt_valid) 
                begin
                  n_s = S_Deposit;
                end
              else 
                begin
                  n_s = S_Continue;
                end  
              end
            else if (action==4'b1000) 
              begin
                n_s = S_Check;
              end 
            else if (action==4'b0110) 
              begin
              if (inf.item_valid) 
                begin
                  n_s = S_UseItem;
                end
              else 
                begin
                  n_s = S_Continue;
                end  
              end     
            else if (action==4'b1010) 
              begin
              if (inf.id_valid) 
                begin
                  n_s = S_loading2;
                end
              else
                begin
                  n_s = S_Continue;  
                end  
              end
            else
              begin 
              n_s = S_Continue;  
              end
          end    
        S_loading:
          begin
            if (inf.C_out_valid) 
              begin
                if (flag_action) 
                  begin
                    case (action)
                      4'b0001:n_s = S_Buy;
                      4'b0010:n_s = S_Sell;
                      4'b0110:n_s = S_UseItem;
                      4'b1010:n_s = S_OPTION_2;
                      4'b0100:n_s = S_Deposit;
                      4'b1000:n_s = S_Check;
                      default:n_s = S_loading;
                    endcase        
                  end
                else
                  begin
                    n_s = S_Waiting;
                  end 
              end
            else
              begin 
                n_s = S_loading;
              end
          end  
        S_Waiting:
          begin
            case (action)
              4'b0001: 
                begin
                  if (flag_action) 
                    n_s = S_Buy;
                  else
                    n_s = S_Waiting;
                end
              4'b0010:
                begin
                  if (flag_action) 
                    n_s = S_Sell;
                  else
                    n_s = S_Waiting;
                end
              4'b0110:
                begin
                  if (flag_action) 
                    n_s = S_UseItem;
                  else
                    n_s = S_Waiting;
                end
              4'b1010:
                begin
                  if (flag_action) 
                    n_s = S_OPTION_2;
                  else
                    n_s = S_Waiting;
                end
              4'b0100:
                begin
                  if (flag_action) 
                    n_s = S_Deposit;
                  else
                    n_s = S_Waiting;
                end

              4'b1000:n_s = S_Check;
              default:n_s = S_Waiting;
            endcase
          end
                      
//--------- 4 states for attack ---------------             
        S_OPTION_2:
             n_s = S_loading2;
        S_loading2:
          if (inf.C_out_valid) 
            n_s = S_Attack;
          else 
            n_s = S_loading2;
        S_Attack:
          if (flag_fin_attack||flag_finAction) 
            n_s = S_sav_p2;
          else
            n_s = S_Attack;     
        S_sav_p2:
          if(inf.C_out_valid) 
            n_s = S_output;
          else
            n_s = S_sav_p2;
//----------------------------------------------
        S_saving:
           if(inf.C_out_valid)
             n_s = S_OPTION_1;
           else
             n_s = S_saving;
        S_OPTION_1:
             n_s = S_loading;   
        S_output:
           if (inf.out_valid) 
             n_s = S_MENU;  
           else
             n_s = S_output;    

// 6 actions
        S_Check:
          if (Big_cnt==1) 
            n_s = S_output;
          else 
            n_s = S_Check;    
        S_UseItem:
          if (Big_cnt==2)
            n_s = S_output;
          else 
            n_s = S_UseItem;
        S_Buy:
          if (Big_cnt==2) 
            n_s = S_output;
          else
            n_s = S_Buy; 
        S_Sell:
          if (Big_cnt==2) 
            n_s = S_output;
          else
            n_s = S_Sell;
        S_Deposit:
          if(Big_cnt==2)
            n_s = S_output;
          else 
            n_s = S_Deposit;  
      default:
        n_s= S_IDLE;
    endcase
  end


//================================================================
//  INPUT
//================================================================
//  temp action
//------------------------------------------
always_ff @(posedge clk or negedge inf.rst_n) 
begin
    if (!inf.rst_n) 
        action <= 0;    
    else if (inf.act_valid) 
        action <= inf.D[3:0];
    else if (c_s==S_MENU)
        action <= 0;
    else if(c_s==S_IDLE)
        action <= 0;
end
//------------------------------------------
//  temp id
//------------------------------------------
always_ff @(posedge clk or negedge inf.rst_n)
begin
    if (!inf.rst_n) 
        ID_1 <= 0;
    else if (action==4'b1010) 
        ID_1 <=  ID_1;
    else if (inf.id_valid) 
        ID_1 <= inf.D[7:0];   
    else if(c_s==S_IDLE)
        ID_1 <= 0;  
end

always_ff @(posedge clk or negedge inf.rst_n)
begin
    if (!inf.rst_n) 
        ID_2 <= 0;    
    else if(inf.id_valid) 
        ID_2 <= ID_1;
    else if(c_s==S_loading2)
        ID_2 <= ID_3;       
    else if(c_s==S_IDLE)
        ID_2 <= 0;  
end

always_ff @(posedge clk or negedge inf.rst_n)
begin
    if (!inf.rst_n) 
        ID_3 <= 0;    
    else if (inf.id_valid) 
        ID_3 <= inf.D[7:0];   
    else if(c_s==S_IDLE)
        ID_3 <= 0;  
end
//------------------------------------------
//  temp D
//------------------------------------------
always_ff @(posedge clk or negedge inf.rst_n)
begin
    if (!inf.rst_n) 
      begin 
        temp_D <= 0;
        flag_item_pokemon <= 0;
      end    
    else if (inf.item_valid)
      begin 
        temp_D <= inf.D;
        flag_item_pokemon <= 0;
      end
    else if (inf.type_valid)
      begin 
        temp_D <= inf.D;
        flag_item_pokemon <= 1; 
      end
    else if (inf.amnt_valid) 
        temp_D <= inf.D;  

    else if (c_s==S_output) 
      begin
        temp_D <= 0;
        flag_item_pokemon <= 0;
      end            
    else if(c_s==S_IDLE)
      begin
        temp_D <= 0;
        flag_item_pokemon <= 0;
      end     
end
//------------------------------------------
//   flag_action
//------------------------------------------
always_ff @(posedge clk or negedge inf.rst_n)
begin
    if (!inf.rst_n) 
        flag_action <= 0; 
    else if (inf.item_valid)
        flag_action <= 1;
    else if (inf.type_valid)
        flag_action <= 1;
    else if (inf.amnt_valid) 
        flag_action <= 1;
    else if (c_s==S_saving || c_s==S_loading || c_s==S_OPTION_1) 
      begin
        if (inf.id_valid) 
          begin
            flag_action <= 1;
          end
      end    
    else if (c_s==S_output) 
        flag_action <= 0;     
    else if(c_s==S_IDLE)
        flag_action <= 0; 
end
//------------------------------------------
//  temp information
//------------------------------------------
always_ff @(posedge clk or negedge inf.rst_n) 
begin
    if (!inf.rst_n)begin
        temp_info_1 <= 0;
        temp_arror <= 0;
        flag_usedBracer <= 0;
        flag_finAction  <= 0;
    end
    else if (c_s==S_loading)
    begin 
        temp_info_1[63:56] <= inf.C_data_r[7:0]; 
        temp_info_1[55:48] <= inf.C_data_r[15:8]; 
        temp_info_1[47:40] <= inf.C_data_r[23:16]; 
        temp_info_1[39:32] <= inf.C_data_r[31:24]; 
        temp_info_1[31:24] <= inf.C_data_r[39:32]; 
        temp_info_1[23:16] <= inf.C_data_r[47:40]; 
        temp_info_1[15:8]  <= inf.C_data_r[55:48]; 
        temp_info_1[7:0]   <= inf.C_data_r[63:56];
    end
    else if (c_s==S_Buy && flag_finAction==0) 
      begin
        if (flag_item_pokemon==0) // buy item
          begin
            if (temp_D[3:0]==4'b0001)//berry (16 dollars)
              begin
                if (temp_info_1[45:32]<=14'd16) //don't have money
                  begin
                    temp_arror <= 4'b0010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    if (temp_info_1[63:60]==4'hF) //bag is full
                      begin
                       temp_arror <= 4'b0100;
                       flag_finAction <= 1; 
                      end
                    else 
                      begin
                        temp_info_1[63:60]<=temp_info_1[63:60]+4'b0001;
                        temp_info_1[45:32]<=temp_info_1[45:32]-14'd16;
                        flag_finAction <= 1;
                      end  
                  end  
              end
            else if (temp_D[3:0]==4'b0010)//medcine (128)
              begin
                if (temp_info_1[45:32]<=14'd128) //don't have money
                  begin
                    temp_arror <= 4'b0010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    if (temp_info_1[59:56]==4'hF) //bag is full
                      begin
                       temp_arror <= 4'b0100;
                       flag_finAction <= 1; 
                      end
                    else 
                      begin
                        temp_info_1[59:56]<=temp_info_1[59:56]+4'b0001;
                        temp_info_1[45:32]<=temp_info_1[45:32]-14'd128;
                        flag_finAction <= 1;
                      end  
                  end  
              end 
            else if (temp_D[3:0]==4'b0100)//candy (300)
              begin
                if (temp_info_1[45:32]<=14'd300) //don't have money
                  begin
                    temp_arror <= 4'b0010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    if (temp_info_1[55:52]==4'hF) //bag is full
                      begin
                       temp_arror <= 4'b0100;
                       flag_finAction <= 1; 
                      end
                    else 
                      begin
                        temp_info_1[55:52]<=temp_info_1[55:52]+4'b0001;
                        temp_info_1[45:32]<=temp_info_1[45:32]-14'd300;
                        flag_finAction <= 1;
                      end  
                  end  
              end
            else if (temp_D[3:0]==4'b1000)//bracer (64)
              begin
                if (temp_info_1[45:32]<=14'd64) //don't have money
                  begin
                    temp_arror <= 4'b0010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    if (temp_info_1[51:48]==4'hF) //bag is full
                      begin
                       temp_arror <= 4'b0100;
                       flag_finAction <= 1; 
                      end
                    else 
                      begin
                        temp_info_1[51:48]<=temp_info_1[51:48]+4'b0001;
                        temp_info_1[45:32]<=temp_info_1[45:32]-14'd64;
                        flag_finAction <= 1;
                      end  
                  end  
              end
            else if (temp_D[3:0]==4'b1001)//water stone (800)
              begin
                 if (temp_info_1[45:32]<=14'd800) //don't have money
                  begin
                    temp_arror <= 4'b0010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    if (temp_info_1[47:46]!=2'b00) //bag is full
                      begin
                       temp_arror <= 4'b0100;
                       flag_finAction <= 1; 
                      end
                    else 
                      begin
                        temp_info_1[47:46]<=2'b01;
                        temp_info_1[45:32]<=temp_info_1[45:32]-14'd800;
                        flag_finAction <= 1;
                      end  
                  end 
              end
            else if (temp_D[3:0]==4'b1010)//fire stone  (800)
              begin
                 if (temp_info_1[45:32]<=14'd800) //don't have money
                  begin
                    temp_arror <= 4'b0010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    if (temp_info_1[47:46]!=2'b00) //bag is full
                      begin
                       temp_arror <= 4'b0100;
                       flag_finAction <= 1; 
                      end
                    else 
                      begin
                        temp_info_1[47:46]<=2'b10;
                        temp_info_1[45:32]<=temp_info_1[45:32]-14'd800;
                        flag_finAction <= 1;
                      end  
                  end 
              end
            else if (temp_D[3:0]==4'b1100)//thunder stone (800)
              begin
                 if (temp_info_1[45:32]<=14'd800) //don't have money
                  begin
                    temp_arror <= 4'b0010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    if (temp_info_1[47:46]!=2'b00) //bag is full
                      begin
                       temp_arror <= 4'b0100;
                       flag_finAction <= 1; 
                      end
                    else 
                      begin
                        temp_info_1[47:46]<=2'b11;
                        temp_info_1[45:32]<=temp_info_1[45:32]-14'd800;
                        flag_finAction <= 1;
                      end  
                  end 
              end            
          end
        else if (flag_item_pokemon) // buy pokemon
          begin
            if (temp_D[3:0]==4'b0001)     //grass (100 dollars)
              begin
                if (temp_info_1[45:32]<=14'd100) //don't have money
                  begin
                    temp_arror <= 4'b0010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    if (temp_info_1[31:28]!=4'b0) //already have pokemon
                      begin
                       temp_arror <= 4'b0001;
                       flag_finAction <= 1; 
                      end
                    else 
                      begin
                        temp_info_1[45:32]<=temp_info_1[45:32]-14'd100;//money
                        temp_info_1[31:28]<=4'b0001;//stage
                        temp_info_1[27:24]<=4'b0001;//type
                        temp_info_1[23:16]<=8'd128;//HP
                        temp_info_1[15:8] <=8'd63;//Attack
                        temp_info_1[7:0]  <=8'b0;//Exp
                        flag_finAction <= 1;
                      end  
                  end      
              end
            else if (temp_D[3:0]==4'b0010)//fire (90)
              begin
                if (temp_info_1[45:32]<=14'd90) //don't have money
                  begin
                    temp_arror <= 4'b0010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    if (temp_info_1[31:28]!=4'b0) //already have pokemon
                      begin
                       temp_arror <= 4'b0001;
                       flag_finAction <= 1; 
                      end
                    else 
                      begin
                        temp_info_1[45:32]<=temp_info_1[45:32]-14'd90;//money
                        temp_info_1[31:28]<=4'b0001;//stage
                        temp_info_1[27:24]<=4'b0010;//type
                        temp_info_1[23:16]<=8'd119;//HP
                        temp_info_1[15:8] <=8'd64;//Attack
                        temp_info_1[7:0]  <=8'b0;//Exp
                        flag_finAction <= 1;
                      end  
                  end      
              end
            else if (temp_D[3:0]==4'b0100)//water (110)
              begin
                if (temp_info_1[45:32]<=14'd110) //don't have money
                  begin
                    temp_arror <= 4'b0010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    if (temp_info_1[31:28]!=4'b0) //already have pokemon
                      begin
                       temp_arror <= 4'b0001;
                       flag_finAction <= 1; 
                      end
                    else 
                      begin
                        temp_info_1[45:32]<=temp_info_1[45:32]-14'd110;//money
                        temp_info_1[31:28]<=4'b0001;//stage
                        temp_info_1[27:24]<=4'b0100;//type
                        temp_info_1[23:16]<=8'd125;//HP
                        temp_info_1[15:8] <=8'd60;//Attack
                        temp_info_1[7:0]  <=8'b0;//Exp
                        flag_finAction <= 1;
                      end  
                  end      
              end
            else if (temp_D[3:0]==4'b1000)//electric (120)
              begin
                if (temp_info_1[45:32]<=14'd120) //don't have money
                  begin
                    temp_arror <= 4'b0010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    if (temp_info_1[31:28]!=4'b0) //already have pokemon
                      begin
                       temp_arror <= 4'b0001;
                       flag_finAction <= 1; 
                      end
                    else 
                      begin
                        temp_info_1[45:32]<=temp_info_1[45:32]-14'd120;//money
                        temp_info_1[31:28]<=4'b0001;//stage
                        temp_info_1[27:24]<=4'b1000;//type
                        temp_info_1[23:16]<=8'd122;//HP
                        temp_info_1[15:8] <=8'd65;//Attack
                        temp_info_1[7:0]  <=8'b0;//Exp
                        flag_finAction <= 1;
                      end  
                  end      
              end
            else if (temp_D[3:0]==4'b0101)//normal (130)
              begin
                if (temp_info_1[45:32]<=14'd130) //don't have money
                  begin
                    temp_arror <= 4'b0010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    if (temp_info_1[31:28]!=4'b0) //already have pokemon
                      begin
                       temp_arror <= 4'b0001;
                       flag_finAction <= 1; 
                      end
                    else 
                      begin
                        temp_info_1[45:32]<=temp_info_1[45:32]-14'd130;//money
                        temp_info_1[31:28]<=4'b0001;//stage
                        temp_info_1[27:24]<=4'b0101;//type
                        temp_info_1[23:16]<=8'd124;//HP
                        temp_info_1[15:8] <=8'd62;//Attack
                        temp_info_1[7:0]  <=8'b0;//Exp
                        flag_finAction <= 1;
                      end  
                  end      
              end                
          end  
      end
    else if (c_s==S_Sell && flag_finAction==0) 
      begin
        if (flag_item_pokemon==0) //SELL ITEM
          begin
            if (temp_D[3:0]==4'b0001) //berry (12dollars)
              begin
                if (temp_info_1[63:60]==0) // don't have item
                  begin
                    temp_arror <= 4'b1010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    temp_info_1[63:60] <= temp_info_1[63:60] - 8'b1;
                    temp_info_1[45:32] <= temp_info_1[45:32] + 14'd12;
                    flag_finAction <= 1;  
                  end  
              end
            else if (temp_D[3:0]==4'b0010) //medcine (96)
              begin
                if (temp_info_1[59:56]==0) // don't have item
                  begin
                    temp_arror <= 4'b1010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    temp_info_1[59:56] <= temp_info_1[59:56] - 8'b1;
                    temp_info_1[45:32] <= temp_info_1[45:32] + 14'd96;
                    flag_finAction <= 1;  
                  end  
              end
            else if (temp_D[3:0]==4'b0100) //candy (225)
              begin
                if (temp_info_1[55:52]==0) // don't have item
                  begin
                    temp_arror <= 4'b1010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    temp_info_1[55:52] <= temp_info_1[55:52] - 8'b1;
                    temp_info_1[45:32] <= temp_info_1[45:32] + 14'd225;
                    flag_finAction <= 1;  
                  end  
              end
            else if (temp_D[3:0]==4'b1000) //bracer (48)
              begin
                if (temp_info_1[51:48]==0) // don't have item
                  begin
                    temp_arror <= 4'b1010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    temp_info_1[51:48] <= temp_info_1[51:48] - 'b1;
                    temp_info_1[45:32] <= temp_info_1[45:32] + 14'd48;
                    flag_finAction <= 1;  
                  end  
              end
            else if (temp_D[3:0]==4'b1001) //water stone (600)
              begin
                if (temp_info_1[47:46]!=2'b01) // don't have item
                  begin
                    temp_arror <= 4'b1010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    temp_info_1[47:46] <= 2'b0;
                    temp_info_1[45:32] <= temp_info_1[45:32] + 14'd600;
                    flag_finAction <= 1;  
                  end  
              end
            else if (temp_D[3:0]==4'b1010) //fire stone (600)
              begin
                if (temp_info_1[47:46]!=2'b10) // don't have item
                  begin
                    temp_arror <= 4'b1010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    temp_info_1[47:46] <= 2'b0;
                    temp_info_1[45:32] <= temp_info_1[45:32] + 14'd600;
                    flag_finAction <= 1;  
                  end  
              end
            else if (temp_D[3:0]==4'b1100) //thunder stone (600)
              begin
                if (temp_info_1[47:46]!=2'b11) // don't have item
                  begin
                    temp_arror <= 4'b1010;
                    flag_finAction <= 1;
                  end
                else 
                  begin
                    temp_info_1[47:46] <= 2'b0;
                    temp_info_1[45:32] <= temp_info_1[45:32] + 14'd600;
                    flag_finAction <= 1;  
                  end  
              end                               
          end
        else if (flag_item_pokemon) //SELL POKEMON
          begin
            if (temp_info_1[31:28]==4'b0) 
              begin
                temp_arror <= 4'b0110;
                flag_finAction <= 1;  
              end
            else 
              begin
                if (temp_info_1[27:24]==4'b0001) //grass 
                  begin
                    if(temp_info_1[31:28]==4'b0001)//pokemon is lowest 
                      begin
                        temp_arror <= 4'b1000; 
                        flag_finAction <= 1;
                      end
                    else if(temp_info_1[31:28]==4'b0010)//pokemon is middle
                      begin
                        temp_info_1[45:32] <= temp_info_1[45:32] + 14'd510;
                        temp_info_1[31:0] <= 32'b0;
                        flag_finAction <= 1;
                        flag_usedBracer <= 0;  
                      end
                    else if(temp_info_1[31:28]==4'b0100)//pokemon is highest 
                      begin
                        temp_info_1[45:32] <= temp_info_1[45:32] + 14'd1100;
                        temp_info_1[31:0] <= 32'b0;
                        flag_finAction <= 1;
                        flag_usedBracer <= 0;    
                      end        
                  end
                else if (temp_info_1[27:24]==4'b0010) //fire 
                  begin
                    if(temp_info_1[31:28]==4'b0001)//pokemon is lowest 
                      begin
                        temp_arror <= 4'b1000; 
                        flag_finAction <= 1; 
                      end
                    else if(temp_info_1[31:28]==4'b0010)//pokemon is middle
                      begin
                        temp_info_1[45:32] <= temp_info_1[45:32] + 14'd450;
                        temp_info_1[31:0] <= 32'b0;
                        flag_finAction <= 1;
                        flag_usedBracer <= 0;  
                      end
                    else if(temp_info_1[31:28]==4'b0100)//pokemon is highest 
                      begin
                        temp_info_1[45:32] <= temp_info_1[45:32] + 14'd1000;
                        temp_info_1[31:0] <= 32'b0;
                        flag_finAction <= 1;
                        flag_usedBracer <= 0;    
                      end        
                  end
                else if (temp_info_1[27:24]==4'b0100) //water 
                  begin
                    if(temp_info_1[31:28]==4'b0001)//pokemon is lowest 
                      begin
                        temp_arror <= 4'b1000; 
                        flag_finAction <= 1; 
                      end
                    else if(temp_info_1[31:28]==4'b0010)//pokemon is middle
                      begin
                        temp_info_1[45:32] <= temp_info_1[45:32] + 14'd500;
                        temp_info_1[31:0] <= 32'b0;
                        flag_finAction <= 1;
                        flag_usedBracer <= 0;  
                      end
                    else if(temp_info_1[31:28]==4'b0100)//pokemon is highest 
                      begin
                        temp_info_1[45:32] <= temp_info_1[45:32] + 14'd1200;
                        temp_info_1[31:0] <= 32'b0;
                        flag_finAction <= 1;
                        flag_usedBracer <= 0;    
                      end        
                  end
                else if (temp_info_1[27:24]==4'b1000) //electric 
                  begin
                    if(temp_info_1[31:28]==4'b0001)//pokemon is lowest 
                      begin
                        temp_arror <= 4'b1000; 
                        flag_finAction <= 1; 
                      end
                    else if(temp_info_1[31:28]==4'b0010)//pokemon is middle
                      begin
                        temp_info_1[45:32] <= temp_info_1[45:32] + 14'd550;
                        temp_info_1[31:0] <= 32'b0;
                        flag_finAction <= 1;
                        flag_usedBracer <= 0;  
                      end
                    else if(temp_info_1[31:28]==4'b0100)//pokemon is highest 
                      begin
                        temp_info_1[45:32] <= temp_info_1[45:32] + 14'd1300;
                        temp_info_1[31:0] <= 32'b0;
                        flag_finAction <= 1;
                        flag_usedBracer <= 0;    
                      end        
                  end
                else if (temp_info_1[27:24]==4'b0101) //normal
                  begin 
                    temp_arror <= 4'b1000; 
                    flag_finAction <= 1;         
                  end   
              end      
          end  
      end
    else if (c_s==S_Deposit && flag_finAction==0) 
      begin
        temp_info_1[45:32] <= temp_info_1[45:32] + temp_D[13:0];
        flag_finAction <= 1;
      end    
    else if (c_s==S_UseItem) 
      begin
        if (temp_info_1[31:0]==32'b0) // u don't have any pokemon 
          begin
            temp_arror <= 4'b0110;
            temp_info_1 <= temp_info_1;
            flag_finAction <= 1;
          end
        else if(flag_finAction==0)
        begin            
          if (temp_D[3:0]==4'b0001)//-------- Berry  HP+'d32 ---------------------------
            begin
              if (temp_info_1[63:60]==4'b0) 
                begin
                  temp_arror <= 4'b1010;
                  temp_info_1 <= temp_info_1;
                end
              else 
                begin
                  if (temp_info_1[27:24]==4'b0001) //grass
                    begin
                      if (temp_info_1[31:28]==4'b0100 && temp_info_1[23:16]>=8'd222) 
                        begin// highest  will full HP
                          temp_arror <= 0;
                          temp_info_1[23:16] <= 8'd254;
                          temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else if (temp_info_1[31:28]==4'b0010 && temp_info_1[23:16]>=8'd160) 
                        begin// middle  will full HP
                          temp_arror <= 0;
                          temp_info_1[23:16] <= 8'd192;
                          temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else if (temp_info_1[31:28]==4'b0001 && temp_info_1[23:16]>=8'd96) 
                        begin// lowest  will full HP
                          temp_arror <= 0;
                          temp_info_1[23:16] <= 8'd128;
                          temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else 
                        begin
                          temp_arror <= 4'b0;
                          temp_info_1[23:16] <= temp_info_1[23:16] + 8'd32;
                          temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                          flag_finAction <= 1;
                        end      
                    end
                  else if (temp_info_1[27:24]==4'b0010) //fire 
                    begin
                      if (temp_info_1[31:28]==4'b0100 && temp_info_1[23:16]>=8'd193) 
                        begin// highest  will full HP
                          temp_arror <= 0;
                          temp_info_1[23:16] <= 8'd225;
                          temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else if (temp_info_1[31:28]==4'b0010 && temp_info_1[23:16]>=8'd145) 
                        begin// middle  will full HP
                          temp_arror <= 0;
                          temp_info_1[23:16] <= 8'd177;
                          temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else if (temp_info_1[31:28]==4'b0001 && temp_info_1[23:16]>=8'd87) 
                        begin// lowest  will full HP
                          temp_arror <= 0;
                          temp_info_1[23:16] <= 8'd119;
                          temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else 
                        begin
                          temp_arror <= 4'b0;
                          temp_info_1[23:16] <= temp_info_1[23:16] + 8'd32;
                          temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                          flag_finAction <= 1;
                        end    
                    end
                  else if (temp_info_1[27:24]==4'b0100) //water 
                    begin
                      if (temp_info_1[31:28]==4'b0100 && temp_info_1[23:16]>=8'd213) 
                        begin// highest  will full HP
                          temp_arror <= 0;
                          temp_info_1[23:16] <= 8'd245;
                          temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else if (temp_info_1[31:28]==4'b0010 && temp_info_1[23:16]>=8'd155) 
                        begin// middle  will full HP
                          temp_arror <= 0;
                          temp_info_1[23:16] <= 8'd187;
                          temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else if (temp_info_1[31:28]==4'b0001 && temp_info_1[23:16]>=8'd93) 
                        begin// lowest  will full HP
                          temp_arror <= 0;
                          temp_info_1[23:16] <= 8'd125;
                          temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else 
                        begin
                          temp_arror <= 4'b0;
                          temp_info_1[23:16] <= temp_info_1[23:16] + 8'd32;
                          temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                          flag_finAction <= 1;
                        end    
                    end
                  else if (temp_info_1[27:24]==4'b1000) //electric 
                    begin
                      if (temp_info_1[31:28]==4'b0100 && temp_info_1[23:16]>=8'd203) 
                        begin// highest  will full HP
                          temp_arror <= 0;
                          temp_info_1[23:16] <= 8'd235;
                          temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else if (temp_info_1[31:28]==4'b0010 && temp_info_1[23:16]>=8'd150) 
                        begin// middle  will full HP
                          temp_arror <= 0;
                          temp_info_1[23:16] <= 8'd182;
                          temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else if (temp_info_1[31:28]==4'b0001 && temp_info_1[23:16]>=8'd90) 
                        begin// lowest  will full HP
                          temp_arror <= 0;
                          temp_info_1[23:16] <= 8'd122;
                          temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else 
                        begin
                          temp_arror <= 4'b0;
                          temp_info_1[23:16] <= temp_info_1[23:16] + 8'd32;
                          temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                          flag_finAction <= 1;
                        end    
                    end
                 else if (temp_info_1[27:24]==4'b0101) //normal 
                    begin
                      if (temp_info_1[23:16]>=8'd92) 
                        begin// lowest  will full HP
                          temp_arror <= 0;
                          temp_info_1[23:16] <= 8'd124;
                          temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else 
                        begin
                          temp_arror <= 4'b0;
                          temp_info_1[23:16] <= temp_info_1[23:16] + 8'd32;
                          temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                          flag_finAction <= 1;
                        end      
                    end           
                  else 
                    begin
                      temp_arror <= 4'b0;
                      temp_info_1[23:16] <= temp_info_1[23:16] + 8'd32;
                      temp_info_1[63:60] <= temp_info_1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end
                end
            end               
          else if (temp_D[3:0]==4'b0010)//---Medicine recover full HP------------------- 
            begin
              if (temp_info_1[59:56]==4'b0) 
                begin
                  temp_arror <= 4'b1010;
                  temp_info_1 <= temp_info_1;    
                end
              else 
                begin
                  if (temp_info_1[27:24]==4'b0001) //grass
                    begin
                      if (temp_info_1[31:28]==4'b0100) 
                        begin// highest
                          temp_arror <= 0;
                          temp_info_1[23:16] <= 8'd254;
                          temp_info_1[59:56] <= temp_info_1[59:56] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else if (temp_info_1[31:28]==4'b0010) 
                        begin// middle
                          temp_arror <= 0;
                          temp_info_1[23:16] <= 8'd192;
                          temp_info_1[59:56] <= temp_info_1[59:56] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else if (temp_info_1[31:28]==4'b0001) 
                        begin// lowest
                          temp_arror <= 0;
                          temp_info_1[23:16] <= 8'd128;
                          temp_info_1[59:56] <= temp_info_1[59:56] - 4'b0001;
                          flag_finAction <= 1;
                        end    
                    end
                  else if (temp_info_1[27:24]==4'b0010) //fire 
                    begin
                          if (temp_info_1[31:28]==4'b0100) 
                            begin// highest  will full HP
                              temp_arror <= 0;
                              temp_info_1[23:16] <= 8'd225;
                              temp_info_1[59:56] <= temp_info_1[59:56] - 4'b0001;
                              flag_finAction <= 1;
                            end
                          else if (temp_info_1[31:28]==4'b0010) 
                            begin// middle  will full HP
                              temp_arror <= 0;
                              temp_info_1[23:16] <= 8'd177;
                              temp_info_1[59:56] <= temp_info_1[59:56] - 4'b0001;
                              flag_finAction <= 1;
                            end
                          else if (temp_info_1[31:28]==4'b0001) 
                            begin// lowest  will full HP
                              temp_arror <= 0;
                              temp_info_1[23:16] <= 8'd119;
                              temp_info_1[59:56] <= temp_info_1[59:56] - 4'b0001;
                              flag_finAction <= 1;
                            end 
                    end
                  else if (temp_info_1[27:24]==4'b0100) //water 
                    begin
                          if (temp_info_1[31:28]==4'b0100) 
                            begin// highest  will full HP
                              temp_arror <= 0;
                              temp_info_1[23:16] <= 8'd245;
                              temp_info_1[59:56] <= temp_info_1[59:56] - 4'b0001;
                              flag_finAction <= 1;
                            end
                          else if (temp_info_1[31:28]==4'b0010) 
                            begin// middle  will full HP
                              temp_arror <= 0;
                              temp_info_1[23:16] <= 8'd187;
                              temp_info_1[59:56] <= temp_info_1[59:56] - 4'b0001;
                              flag_finAction <= 1;
                            end
                          else if (temp_info_1[31:28]==4'b0001) 
                            begin// lowest  will full HP
                              temp_arror <= 0;
                              temp_info_1[23:16] <= 8'd125;
                              temp_info_1[59:56] <= temp_info_1[59:56] - 4'b0001;
                              flag_finAction <= 1;
                            end 
                    end
                  else if (temp_info_1[27:24]==4'b1000) //electric 
                    begin
                          if (temp_info_1[31:28]==4'b0100) 
                            begin// highest  will full HP
                              temp_arror <= 0;
                              temp_info_1[23:16] <= 8'd235;
                              temp_info_1[59:56] <= temp_info_1[59:56] - 4'b0001;
                              flag_finAction <= 1;
                            end
                          else if (temp_info_1[31:28]==4'b0010) 
                            begin// middle  will full HP
                              temp_arror <= 0;
                              temp_info_1[23:16] <= 8'd182;
                              temp_info_1[59:56] <= temp_info_1[59:56] - 4'b0001;
                              flag_finAction <= 1;
                            end
                          else if (temp_info_1[31:28]==4'b0001) 
                            begin// lowest  will full HP
                              temp_arror <= 0;
                              temp_info_1[23:16] <= 8'd122;
                              temp_info_1[59:56] <= temp_info_1[59:56] - 4'b0001;
                              flag_finAction <= 1;
                            end 
                    end
                  else if (temp_info_1[27:24]==4'b0101) //normal 
                    begin
                          temp_arror <= 0;
                          temp_info_1[23:16] <= 8'd124;
                          temp_info_1[59:56] <= temp_info_1[59:56] - 4'b0001;
                          flag_finAction <= 1;   
                    end           
                end
            end
          else if (temp_D[3:0]==4'b0100)//---Candy EXP+'d15 ---------------------------- 
            begin
              if (temp_info_1[55:52]==4'b0) 
                begin
                 temp_arror <= 4'b1010;
                 temp_info_1 <= temp_info_1;    
                end
              else 
                begin
                  if (temp_info_1[27:24]==4'b0001) // Grass
                    begin
                      if (temp_info_1[31:28]==4'b0001) // Lowest
                        begin
                          if (temp_info_1[7:0]>=8'h11) // pokemon evolve
                          begin
                            temp_arror <= 4'b0;
                            temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                            temp_info_1[31:28] <= 4'b0010;// stage up to Middle
                            temp_info_1[23:16] <= 8'd192; // HP reset 
                            temp_info_1[15:8]  <= 8'd94; //ATK reset
                            temp_info_1[7:0]   <= 8'b0;  //exp reset
                            flag_usedBracer <= 0;
                            flag_finAction <= 1;
                          end 
                          else 
                          begin
                            temp_arror <= 4'b0;
                            temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                            temp_info_1[7:0]   <= temp_info_1[7:0] + 8'h0F; //exp + 15
                            flag_usedBracer <= flag_usedBracer; 
                            flag_finAction <= 1;   
                          end
                        end
                      else if (temp_info_1[31:28]==4'b0010) // Middle
                        begin
                          if (temp_info_1[7:0]>=8'h30) // pokemon evolve
                            begin
                              temp_arror <= 4'b0;
                              temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                              temp_info_1[31:28] <= 4'b0100;// stage up to Highest
                              temp_info_1[23:16] <= 8'd254; // HP reset 
                              temp_info_1[15:8]  <= 8'd123; //ATK reset 
                              temp_info_1[7:0]   <= 8'b0;  //exp reset
                              flag_usedBracer <= 0;
                              flag_finAction <= 1;
                            end
                          else 
                            begin
                              temp_arror <= 4'b0;
                              temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                              temp_info_1[7:0]   <= temp_info_1[7:0] + 8'h0F; //exp + 15
                              flag_usedBracer <= flag_usedBracer;
                              flag_finAction <= 1;                             
                            end   
                        end
                      else if (temp_info_1[31:28]==4'b0100) // Highest
                        begin // only cost Candy but nothing change
                          temp_arror <= 4'b0;
                          temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                          flag_finAction <= 1; 
                        end
                    end
                  else if (temp_info_1[27:24]==4'b0010) // Fire
                    begin
                      if (temp_info_1[31:28]==4'b0001) // Lowest
                        begin
                          if (temp_info_1[7:0]>=8'd15) // pokemon evolve
                            begin //39exp lv up
                              temp_arror <= 4'b0;
                              temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                              temp_info_1[31:28] <= 4'b0010;// stage up to Middle
                              temp_info_1[23:16] <= 8'd177; // HP reset 
                              temp_info_1[15:8]  <= 8'd96;  //ATK reset 
                              temp_info_1[7:0]   <= 8'b0;   //exp reset
                              flag_usedBracer <= 0;
                              flag_finAction <= 1;
                            end 
                          else 
                            begin
                              temp_arror <= 4'b0;
                              temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                              temp_info_1[7:0]   <= temp_info_1[7:0] + 8'h0F; //exp + 15
                              flag_usedBracer <= flag_usedBracer;
                              flag_finAction <= 1;    
                            end
                        end
                      else if (temp_info_1[31:28]==4'b0010) // Middle
                        begin
                         if (temp_info_1[7:0]>=8'd44) // pokemon evolve
                          begin // 59exp lv up
                            temp_arror <= 4'b0;
                            temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                            temp_info_1[31:28] <= 4'b0100;// stage up to Highest
                            temp_info_1[23:16] <= 8'd225;// HP reset 
                            temp_info_1[15:8]  <= 8'd127;//ATK reset
                            temp_info_1[7:0]   <= 8'b0;  //exp reset
                            flag_usedBracer <= 0;
                            flag_finAction <= 1;
                          end
                         else 
                          begin
                            temp_arror <= 4'b0;
                            temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                            temp_info_1[7:0]   <= temp_info_1[7:0] + 8'h0F; //exp + 15
                            flag_usedBracer <= flag_usedBracer;
                            flag_finAction <= 1;                             
                          end   
                        end
                      else if (temp_info_1[31:28]==4'b0100) // Highest
                        begin // only cost Candy but nothing change
                          temp_arror <= 4'b0;
                          temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                          flag_finAction <= 1; 
                        end
                    end
                  else if (temp_info_1[27:24]==4'b0100) // Water
                    begin
                      if (temp_info_1[31:28]==4'b0001) // Lowest
                        begin
                          if (temp_info_1[7:0]>=8'd13) // pokemon evolve
                            begin // exp28 lv up
                              temp_arror <= 4'b0;
                              temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                              temp_info_1[31:28] <= 4'b0010;// stage up to Middle
                              temp_info_1[23:16] <= 8'd187; // HP reset 
                              temp_info_1[15:8]  <= 8'd89; //ATK reset  
                              temp_info_1[7:0]   <= 8'b0;  //exp reset
                              flag_usedBracer <= 0;
                              flag_finAction <= 1;
                            end 
                          else 
                            begin
                              temp_arror <= 4'b0;
                              temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                              temp_info_1[7:0]   <= temp_info_1[7:0] + 8'h0F; //exp + 15
                              flag_usedBracer <= flag_usedBracer;
                              flag_finAction <= 1;    
                            end
                        end
                      else if (temp_info_1[31:28]==4'b0010) // Middle
                        begin
                         if (temp_info_1[7:0]>=8'd40) // pokemon evolve
                          begin //exp55 lv up
                            temp_arror <= 4'b0;
                            temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                            temp_info_1[31:28] <= 4'b0100;// stage up to Highest
                            temp_info_1[23:16] <= 8'd245; // HP reset
                            temp_info_1[15:8]  <= 8'd113; //ATK reset
                            temp_info_1[7:0]   <= 8'b0;  //exp reset
                            flag_usedBracer <= 0;
                            flag_finAction <= 1;
                          end
                         else 
                          begin
                            temp_arror <= 4'b0;
                            temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                            temp_info_1[7:0]   <= temp_info_1[7:0] + 8'h0F; //exp + 15
                            flag_usedBracer <= flag_usedBracer;
                            flag_finAction <= 1;                             
                          end   
                        end
                      else if (temp_info_1[31:28]==4'b0100) // Highest
                        begin // only cost Candy but nothing change
                          temp_arror <= 4'b0;
                          temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                          flag_finAction <= 1; 
                        end
                    end
                  else if (temp_info_1[27:24]==4'b1000) // Electric
                    begin
                      if (temp_info_1[31:28]==4'b0001) // Lowest
                        begin
                          if (temp_info_1[7:0]>=8'd11) // pokemon evolve
                          begin //exp26 lv up
                            temp_arror <= 4'b0;
                            temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                            temp_info_1[31:28] <= 4'b0010;// stage up to Middle
                            temp_info_1[23:16] <= 8'd182; // HP reset 
                            temp_info_1[15:8]  <= 8'd97; //ATK reset '
                            temp_info_1[7:0]   <= 8'b0;  //exp reset
                            flag_usedBracer <= 0;
                            flag_finAction <= 1;
                          end 
                          else 
                          begin
                            temp_arror <= 4'b0;
                            temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                            temp_info_1[7:0]   <= temp_info_1[7:0] + 8'd15; //exp + 15
                            flag_usedBracer <= flag_usedBracer;
                            flag_finAction <= 1;    
                          end
                        end
                      else if (temp_info_1[31:28]==4'b0010) // Middle
                        begin
                         if (temp_info_1[7:0]>=8'd36) // pokemon evolve
                          begin // exp51 lv up
                            temp_arror <= 4'b0;
                            temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                            temp_info_1[31:28] <= 4'b0100;// stage up to Highest
                            temp_info_1[23:16] <= 8'd235; // HP reset
                            temp_info_1[15:8]  <= 8'd124; //ATK reset
                            temp_info_1[7:0]   <= 8'b0;  //exp reset
                            flag_usedBracer <= 0;
                            flag_finAction <= 1;
                          end
                         else 
                          begin
                            temp_arror <= 4'b0;
                            temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                            temp_info_1[7:0]   <= temp_info_1[7:0] + 8'h0F; //exp + 15
                            flag_usedBracer <= flag_usedBracer;
                            flag_finAction <= 1;                             
                          end   
                        end
                      else if (temp_info_1[31:28]==4'b0100) // Highest
                        begin // only cost Candy but nothing change
                          temp_arror <= 4'b0;
                          temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                          flag_finAction <= 1; 
                        end
                    end
                  else if (temp_info_1[27:24]==4'b0101) // Normal
                      begin
                        if (temp_info_1[7:0]>=8'd14) // exp will fixed in high exp
                        begin //fix in 29
                          temp_info_1[7:0] <= 8'd29;
                          temp_arror <= 4'b0;
                          temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                          flag_finAction <= 1; 
                        end
                        else 
                        begin
                          temp_info_1[7:0] <=  temp_info_1[7:0] + 8'h0F;
                          temp_arror <= 4'b0;
                          temp_info_1[55:52] <= temp_info_1[55:52] - 4'b0001;
                          flag_finAction <= 1;  
                        end
                      end    
                end
            end  
          else if (temp_D[3:0]==4'b1000)//---Bracer--------------------------------  
            begin
              if (temp_info_1[51:48]==4'b0) 
                begin
                  temp_arror <= 4'b1010;
                  temp_info_1 <= temp_info_1;
                  flag_finAction <= 1;    
                end
               else 
                begin
                  if (flag_usedBracer) // the effect can't stack 
                    begin
                      temp_arror <= 4'b0;
                      temp_info_1[51:48] <= temp_info_1[51:48] - 4'b0001;
                      flag_finAction <= 1; 
                    end
                  else
                    begin
                      temp_arror <= 4'b0;
                      temp_info_1[51:48] <= temp_info_1[51:48] - 4'b0001;
                      temp_info_1[15:8]  <= temp_info_1[15:8]  + 8'd32;
                      flag_usedBracer <= 1;
                      flag_finAction <= 1; 
                    end
                end
            end
          else if (temp_D[3:0]==4'b1001) //---Water Stone-------------------------------
            begin
              if (temp_info_1[47:46]!=2'b01) // you don't have water stone
                begin
                  temp_arror <= 4'b1010;
                  temp_info_1 <= temp_info_1;
                  flag_finAction <= 1;    
                end
              else 
                begin
                  if (temp_info_1[27:24]==4'b0101) // you have Eevee
                    begin
                      if (temp_info_1[7:0]==8'd29)  // enough EXP
                        begin
                          temp_info_1[47:46] <= 2'b0;    // stone bec. empty
                          temp_info_1[31:28] <= 4'b0100; // stage up to Highest
                          temp_info_1[27:24] <= 4'b0100; // become water Eevee
                          temp_info_1[23:16] <= 8'd245;   // HP reset
                          temp_info_1[15:8]  <= 8'd113;   //ATK reset
                          temp_info_1[7:0]   <= 8'b0;    //exp reset
                          flag_usedBracer <= 0;
                          temp_arror <= 4'b0;
                          flag_finAction <= 1;                        
                        end
                      else // u don't have enough EXP but still cost stone
                        begin
                          temp_info_1[47:46] <= 2'b0;
                          temp_arror <= 4'b0;
                          flag_finAction <= 1;  
                        end
                    end
                  else // yout don't have Eevee
                    begin
                      temp_info_1[47:46] <= 2'b00;
                      temp_arror <= 4'b0;
                      flag_finAction <= 1;   
                    end   
                end 
            end
          else if (temp_D[3:0]==4'b1010)//---Fire Stone-------------------------------
            begin
                if (temp_info_1[47:46]!=2'b10) // you don't have fire stone
                  begin
                    temp_arror <= 4'b1010;
                    temp_info_1 <= temp_info_1;
                    flag_finAction <= 1;    
                  end
                else 
                  begin
                    if (temp_info_1[27:24]==4'b0101) // you have Eevee
                      begin
                        if (temp_info_1[7:0]==8'h1D) // enough EXP
                          begin
                            temp_info_1[47:46] <= 2'b0; // stone bec. empty
                            temp_info_1[31:28] <= 4'b0100; // stage up to Highest
                            temp_info_1[27:24] <= 4'b0010; // become Fire Eevee
                            temp_info_1[23:16] <= 8'd225;  // HP reset 
                            temp_info_1[15:8]  <= 8'd127;  //ATK reset 
                            temp_info_1[7:0]   <= 8'b0;    //exp reset
                            flag_usedBracer <= 0;
                            temp_arror <= 4'b0;
                            flag_finAction <= 1;                        
                          end
                        else // u don't have enough EXP but still cost stone
                          begin
                            temp_info_1[47:46] <= 2'b0;
                            temp_arror <= 4'b0;
                            flag_finAction <= 1;  
                          end
                      end
                    else // yout don't have Eevee
                      begin
                         temp_info_1[47:46] <= 2'b0;
                         temp_arror <= 4'b0;
                         flag_finAction <= 1;   
                      end   
                  end 
            end
          else if (temp_D[3:0]==4'b1100) //---Thunder Stone--------------------------
            begin
              if (temp_info_1[47:46]!=2'b11) // you don't have thunder stone
                begin
                  temp_arror <= 4'b1010;
                  temp_info_1 <= temp_info_1;
                  flag_finAction <= 1;    
                end
              else 
                begin
                  if (temp_info_1[27:24]==4'b0101) // you have Eevee
                    begin
                      if (temp_info_1[7:0]==8'd29) // enough EXP
                        begin
                          temp_info_1[47:46] <= 2'b00; // stone bec. empty
                          temp_info_1[31:28] <= 4'b0100; // stage up to Highest
                          temp_info_1[27:24] <= 4'b1000; // become Thunder Eevee   
                          temp_info_1[23:16] <= 8'd235;   // HP reset
                          temp_info_1[15:8]  <= 8'd124;   //ATK reset
                          temp_info_1[7:0]   <= 8'b0;    //exp reset
                          flag_usedBracer <= 0;
                          temp_arror <= 4'b0;
                          flag_finAction <= 1;                        
                        end
                      else // u don't have enough EXP but still cost stone
                        begin
                          temp_info_1[47:46] <= 2'b00;
                          temp_arror <= 4'b0;
                          flag_finAction <= 1;  
                        end
                    end
                  else // yout don't have Eevee
                    begin
                       temp_info_1[47:46] <= 2'b00;
                       temp_arror <= 4'b0;
                       flag_finAction <= 1;   
                    end   
                end 
            end
        end
      end
    else if (c_s==S_Attack && flag_finAction==0) 
      begin
        if (temp_info_1[31:0]== 0 || temp_info_2[31:0]== 0) // someone doesn't have pokemon
          begin
            temp_arror <= 4'b0110;
            flag_finAction <= 1; 
          end
        else if (temp_info_1[23:16]==8'b0 || temp_info_2[23:16]==8'b0) // pokemon HP is 0
          begin 
            temp_arror <= 4'b1101;
            flag_finAction <= 1;  
          end   
        else // start attack
          begin
            if (temp_info_1[31:28]==4'b0100) // attacker is highest so don't change anything
              begin
                if (flag_usedBracer) 
                  begin
                    temp_info_1[15:8] <= temp_info_1[15:8] - 'd32;
                    flag_usedBracer <= 0;
                    flag_finAction <= 1; 
                  end
                else
                  begin 
                    temp_info_1 <= temp_info_1;
                    flag_finAction <= 1; 
                  end
              end
            else if (temp_info_1[31:28]==4'b0010)// attacker is middle
              begin
                if (temp_info_2[31:28]==4'b0001) // opponent is lowest Att. will gain 16exp
                 begin
                  if (temp_info_1[27:24]==4'b0001 && temp_info_1[7:0]>=8'd47) 
                    begin// Att. is grass &'d63 can evolve 
                       temp_arror <= 4'b0;
                       temp_info_1[31:28] <= 4'b0100; // stage up to Highest
                       temp_info_1[23:16] <= 8'd254; // HP reset
                       temp_info_1[15:8]  <= 8'd123; //ATK reset
                       temp_info_1[7:0]   <= 8'b0;  //exp reset
                       flag_usedBracer <= 0;
                       flag_finAction <= 1;       
                    end 
                  else if (temp_info_1[27:24]==4'b0010 && temp_info_1[7:0]>=8'd43) 
                    begin // Att. is fire 'd59 can evolve
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_1[23:16] <= 8'd225; // HP reset 
                      temp_info_1[15:8]  <= 8'd127; //ATK reset 
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;                 
                    end
                  else if (temp_info_1[27:24]==4'b0100 && temp_info_1[7:0]>=8'd39)
                    begin // Att. is watter 'd55 can evolve
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_1[23:16] <= 8'd245; // HP reset
                      temp_info_1[15:8]  <= 8'd113; //ATK reset
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;           
                    end
                  else if (temp_info_1[27:24]==4'b1000 && temp_info_1[7:0]>=8'd35) 
                    begin // Att. is electric 'd51 can evolve
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_1[23:16] <= 8'd235; // HP reset 
                      temp_info_1[15:8]  <= 8'd124; //ATK reset 
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;              
                    end              
                  else
                    begin // can't evolve
                      if (flag_usedBracer) 
                        begin
                          temp_arror <= 4'b0;
                          temp_info_1[15:8]  <= temp_info_1[15:8] - 8'd32; //ATK - 32
                          temp_info_1[7:0]   <= temp_info_1[7:0]  + 8'd16;  //exp + 16
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                      else 
                        begin
                          temp_arror <= 4'b0;
                          temp_info_1[7:0]   <= temp_info_1[7:0]  + 8'd16;  //exp + 16
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                    end
                 end  
                else if (temp_info_2[31:28]==4'b0010) // opponent is middle Att. will gain 24exp
                 begin
                   if (temp_info_1[27:24]==4'b0001 && temp_info_1[7:0]>=8'd39) 
                    begin// Att. is grass &'d63 can evolve 
                       temp_arror <= 4'b0;
                       temp_info_1[31:28] <= 4'b0100; // stage up to Highest
                       temp_info_1[23:16] <= 8'd254; // HP reset
                       temp_info_1[15:8]  <= 8'd123; //ATK reset
                       temp_info_1[7:0]   <= 8'b0;  //exp reset
                       flag_usedBracer <= 0;
                       flag_finAction <= 1;       
                    end 
                  else if (temp_info_1[27:24]==4'b0010 && temp_info_1[7:0]>=8'd35) 
                    begin // Att. is fire 'd59 can evolve
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_1[23:16] <= 8'd225; // HP reset 
                      temp_info_1[15:8]  <= 8'd127; //ATK reset 
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;                 
                    end
                  else if (temp_info_1[27:24]==4'b0100 && temp_info_1[7:0]>=8'd31)
                    begin // Att. is watter 'd55 can evolve
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_1[23:16] <= 8'd245; // HP reset  
                      temp_info_1[15:8]  <= 8'd113; //ATK reset 
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;           
                    end
                  else if (temp_info_1[27:24]==4'b1000 && temp_info_1[7:0]>=8'd27) 
                    begin // Att. is electric 'd51 can evolve
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_1[23:16] <= 8'd235; // HP reset 
                      temp_info_1[15:8]  <= 8'd124; //ATK reset 
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;              
                    end              
                  else
                    begin // can't evolve
                      if (flag_usedBracer) 
                        begin
                          temp_arror <= 4'b0;
                          temp_info_1[15:8]  <= temp_info_1[15:8] - 8'd32; //ATK - 32
                          temp_info_1[7:0]   <= temp_info_1[7:0]  + 8'd24;  //exp + 24
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                      else 
                        begin
                          temp_arror <= 4'b0;
                          temp_info_1[7:0]   <= temp_info_1[7:0]  + 8'd24;  //exp + 24
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                    end
                 end
                else if (temp_info_2[31:28]==4'b0100) // opponent is highest Att. will gain 32exp
                 begin
                  if (temp_info_1[27:24]==4'b0001 && temp_info_1[7:0]>=8'd31) 
                    begin// Att. is grass &'d63 can evolve 
                       temp_arror <= 4'b0;
                       temp_info_1[31:28] <= 4'b0100; // stage up to Highest
                       temp_info_1[23:16] <= 8'd254; // HP reset 
                       temp_info_1[15:8]  <= 8'd123; //ATK reset 
                       temp_info_1[7:0]   <= 8'b0;  //exp reset
                       flag_usedBracer <= 0;
                       flag_finAction <= 1;       
                    end 
                  else if (temp_info_1[27:24]==4'b0010 && temp_info_1[7:0]>=8'd27) 
                    begin // Att. is fire 'd59 can evolve
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_1[23:16] <= 8'd225; // HP reset 
                      temp_info_1[15:8]  <= 8'd127; //ATK reset 
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;                 
                    end
                  else if (temp_info_1[27:24]==4'b0100 && temp_info_1[7:0]>=8'd23)
                    begin // Att. is watter 'd55 can evolve
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_1[23:16] <= 8'd245; // HP reset  
                      temp_info_1[15:8]  <= 8'd113; //ATK reset 
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;           
                    end
                  else if (temp_info_1[27:24]==4'b1000 && temp_info_1[7:0]>=8'd19) 
                    begin // Att. is electric 'd51 can evolve
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_1[23:16] <= 8'd235; // HP reset
                      temp_info_1[15:8]  <= 8'd124; //ATK reset
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;              
                    end              
                  else
                    begin // can't evolve
                      if (flag_usedBracer) 
                        begin
                          temp_arror <= 4'b0;
                          temp_info_1[15:8]  <= temp_info_1[15:8] - 8'd32; //ATK - 32
                          temp_info_1[7:0]   <= temp_info_1[7:0]  + 8'd32;  //exp + 32
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                      else 
                        begin
                          temp_arror <= 4'b0;
                          temp_info_1[7:0]   <= temp_info_1[7:0]  + 8'd32;  //exp + 32
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                    end
                 end
              end 
            else if (temp_info_1[31:28]==4'b0001) // attaker is lowest
              begin
                if (temp_info_2[31:28]==4'b0001) // opponent is lowest Att. will gain 16exp
                 begin
                  if (temp_info_1[27:24]==4'b0001 && temp_info_1[7:0]>=8'd16) 
                    begin// Att. is grass &'d32 can evolve 
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_1[23:16] <= 8'd192; // HP reset
                      temp_info_1[15:8]  <= 8'd94; //ATK reset 
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;      
                    end 
                  else if (temp_info_1[27:24]==4'b0010 && temp_info_1[7:0]>=8'd14) 
                    begin // Att. is fire 'd30 can evolve
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_1[23:16] <= 8'd177; // HP reset 
                      temp_info_1[15:8]  <= 8'd96; //ATK reset 
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;                
                    end
                  else if (temp_info_1[27:24]==4'b0100 && temp_info_1[7:0]>=8'd12)
                    begin // Att. is watter 'd28 can evolve
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_1[23:16] <= 8'd187; // HP reset 
                      temp_info_1[15:8]  <= 8'd89; //ATK reset  
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;         
                    end
                  else if (temp_info_1[27:24]==4'b1000 && temp_info_1[7:0]>=8'd10) 
                    begin // Att. is electric 'd26 can evolve
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_1[23:16] <= 8'd182; // HP reset 
                      temp_info_1[15:8]  <= 8'd97; //ATK reset 
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;           
                    end
                  else if (temp_info_1[27:24]==4'b0101 && temp_info_1[7:0]>=8'd13) 
                    begin // Att. is Normal will fix at 'd29
                    if (flag_usedBracer) 
                      begin
                        temp_info_1[15:8]  <= temp_info_1[15:8] - 8'd32; //ATK - 32
                        temp_info_1[7:0] <= 8'h1D;
                        temp_arror <= 4'b0;
                        flag_finAction <= 1;
                        flag_usedBracer <= 0;
                      end
                    else 
                      begin
                        temp_info_1[7:0] <= 8'h1D;
                        temp_arror <= 4'b0;
                        flag_finAction <= 1; 
                      end   
                    end                    
                  else
                    begin // can't evolve
                      if (flag_usedBracer) 
                        begin
                          temp_arror <= 4'b0;
                          temp_info_1[15:8]  <= temp_info_1[15:8] - 8'd32; //ATK - 32
                          temp_info_1[7:0]   <= temp_info_1[7:0]  + 8'd16;  //exp + 16
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                      else 
                        begin
                          temp_arror <= 4'b0;
                          temp_info_1[7:0]   <= temp_info_1[7:0]  + 8'd16;  //exp + 16
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                    end
                 end 
                else if (temp_info_2[31:28]==4'b0010) // opponent is middle Att. will gain 24exp
                 begin
                   if (temp_info_1[27:24]==4'b0001 && temp_info_1[7:0]>=8'd8) 
                    begin// Att. is grass &'d32 can evolve 
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_1[23:16] <= 8'd192; // HP reset
                      temp_info_1[15:8]  <= 8'd94;  //ATK reset 
                      temp_info_1[7:0]   <= 8'b0;   //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;      
                    end 
                  else if (temp_info_1[27:24]==4'b0010 && temp_info_1[7:0]>=8'd6) 
                    begin // Att. is fire 'd30 can evolve
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_1[23:16] <= 8'd177; // HP reset  
                      temp_info_1[15:8]  <= 8'd96 ; //ATK reset 
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;                
                    end
                  else if (temp_info_1[27:24]==4'b0100 && temp_info_1[7:0]>=8'd4)
                    begin // Att. is watter 'd28 can evolve
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_1[23:16] <= 8'd187; // HP reset 
                      temp_info_1[15:8]  <= 8'd89; //ATK reset  
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;         
                    end
                  else if (temp_info_1[27:24]==4'b1000 && temp_info_1[7:0]>=8'd2) 
                    begin // Att. is electric 'd26 can evolve
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_1[23:16] <= 8'd182; // HP reset 
                      temp_info_1[15:8]  <= 8'd97 ; //ATK reset
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;           
                    end
                  else if (temp_info_1[27:24]==4'b0101 && temp_info_1[7:0]>=8'd5) 
                    begin // Att. is Normal will fix at 'd29
                      if (flag_usedBracer) 
                        begin
                          temp_info_1[15:8]  <= temp_info_1[15:8] - 8'd32; //ATK - 32
                          temp_info_1[7:0] <= 8'h1D;
                          temp_arror <= 4'b0;
                          flag_finAction <= 1;
                          flag_usedBracer <= 0;
                        end
                      else 
                        begin
                          temp_info_1[7:0] <= 8'h1D;
                          temp_arror <= 4'b0;
                          flag_finAction <= 1; 
                        end   
                    end                    
                  else
                    begin // can't evolve
                      if (flag_usedBracer) 
                        begin
                          temp_arror <= 4'b0;
                          temp_info_1[15:8]  <= temp_info_1[15:8] - 8'd32; //ATK - 32
                          temp_info_1[7:0]   <= temp_info_1[7:0]  + 8'd24;  //exp + 24
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                      else 
                        begin
                          temp_arror <= 4'b0;
                          temp_info_1[7:0]   <= temp_info_1[7:0]  + 8'd24;  //exp + 24
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                    end
                 end
                else if (temp_info_2[31:28]==4'b0100) // opponent is highest Att. will gain 32exp
                 begin
                   if (temp_info_1[27:24]==4'b0001) 
                    begin// Att. is grass &'d32 can evolve 
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_1[23:16] <= 8'd192; // HP reset
                      temp_info_1[15:8]  <= 8'd94; //ATK reset 
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;      
                    end 
                  else if (temp_info_1[27:24]==4'b0010) 
                    begin // Att. is fire 'd30 can evolve
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_1[23:16] <= 8'd177; // HP reset
                      temp_info_1[15:8]  <= 8'd96; //ATK reset 
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;                
                    end
                  else if (temp_info_1[27:24]==4'b0100)
                    begin // Att. is watter 'd28 can evolve
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_1[23:16] <= 8'd187; // HP reset
                      temp_info_1[15:8]  <= 8'd89; //ATK reset 
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;         
                    end
                  else if (temp_info_1[27:24]==4'b1000) 
                    begin // Att. is electric 'd26 can evolve
                      temp_arror <= 4'b0;
                      temp_info_1[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_1[23:16] <= 8'd182; // HP reset 
                      temp_info_1[15:8]  <= 8'd97; //ATK reset  
                      temp_info_1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;           
                    end
                  else if (temp_info_1[27:24]==4'b0101) 
                    begin // Att. is Normal will fix at 'd29
                      if (flag_usedBracer) 
                        begin
                          temp_info_1[15:8]  <= temp_info_1[15:8] - 8'd32; //ATK - 32
                          temp_info_1[7:0] <= 8'h1D;
                          temp_arror <= 4'b0;
                          flag_finAction <= 1;
                          flag_usedBracer <= 0;
                        end
                      else 
                        begin
                          temp_info_1[7:0] <= 8'h1D;
                          temp_arror <= 4'b0;
                          flag_finAction <= 1; 
                        end   
                    end                    
                 end 
              end
          end
      end
    else if (c_s==S_sav_p2)
      begin
        flag_finAction <= 0;
      end
    else if (c_s==S_saving) 
      begin
        flag_usedBracer <= 0;
      end
    else if (c_s==S_output)
      begin
        flag_finAction <= 0;
      end  
    else if (c_s==S_MENU)
      begin
        temp_arror <= 0;
      end
    else if(c_s==S_IDLE)
      begin
        temp_info_1 <= 0;
        temp_arror <= 0;
      end  
end

//==========================================================================================================================================================================================================
//==========================================================================================================================================================================================================
//==========================================================================================================================================================================================================
//==========================================================================================================================================================================================================
//==========================================================================================================================================================================================================
//==========================================================================================================================================================================================================

always_ff @(posedge clk or negedge inf.rst_n) 
begin
  if (!inf.rst_n)
    begin 
      temp_info_2 <= 0;
      flag_fin_attack <= 0;
    end 
  else if (c_s==S_loading2)
    begin 
      temp_info_2[63:56] <= inf.C_data_r[7:0]; 
      temp_info_2[55:48] <= inf.C_data_r[15:8]; 
      temp_info_2[47:40] <= inf.C_data_r[23:16]; 
      temp_info_2[39:32] <= inf.C_data_r[31:24]; 
      temp_info_2[31:24] <= inf.C_data_r[39:32]; 
      temp_info_2[23:16] <= inf.C_data_r[47:40]; 
      temp_info_2[15:8]  <= inf.C_data_r[55:48]; 
      temp_info_2[7:0]   <= inf.C_data_r[63:56];
    end
  else if (inf.id_valid) 
      temp_info_2 <= temp_info_1; 
  else if(c_s==S_IDLE)
      temp_info_2 <= 0;
  else if (c_s==S_Attack && flag_fin_attack==0) 
    begin
      if (temp_info_1[23:16]==0||temp_info_2[23:16]==0) 
        begin
          flag_fin_attack <= 1;
        end
      else if (temp_info_2[31:28]==4'b0001) // def. is lowest
        begin
          if (temp_info_2[27:24]==4'b0001) //def. is grass
            begin
              if (temp_info_1[31:28]==4'b0001)      //att. is lowest  exp +8
                begin
                  if (temp_info_2[7:0]>=8'd24) //def. Lv. up
                    begin
                      temp_info_2[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_2[23:16] <= 8'd192;  // HP reset
                      temp_info_2[15:8]  <= 8'd94;  //ATK reset 
                      temp_info_2[7:0]   <= 8'b0;   //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0100||temp_info_1[27:24]==4'b1000) 
                    begin //att. is grass or water or electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (temp_info_1[27:24]==4'b0010) 
                    begin // att. is fire
                      if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (temp_info_1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end     
                end
              else if (temp_info_1[31:28]==4'b0010) //att. is middle  exp +12
                begin
                  if (temp_info_2[7:0]>=8'd20) //def. Lv. up
                    begin
                      temp_info_2[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_2[23:16] <= 8'hC0;  // HP reset 'd192 = 'hC0 
                      temp_info_2[15:8]  <= 8'h5E;  //ATK reset 'd94  = 'h5E
                      temp_info_2[7:0]   <= 8'b0;   //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0100||temp_info_1[27:24]==4'b1000) 
                    begin //att. is grass or water or electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (temp_info_1[27:24]==4'b0010) 
                    begin // att. is fire
                      if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (temp_info_1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end       
                end
              else if (temp_info_1[31:28]==4'b0100) //att. is highest  exp +16
                begin
                  if (temp_info_2[7:0]>=8'd16) //def. Lv. up
                    begin
                      temp_info_2[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_2[23:16] <= 8'hC0;  // HP reset 'd192 = 'hC0 
                      temp_info_2[15:8]  <= 8'h5E;  //ATK reset 'd94  = 'h5E
                      temp_info_2[7:0]   <= 8'b0;   //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0100||temp_info_1[27:24]==4'b1000) 
                    begin //att. is grass or water or electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (temp_info_1[27:24]==4'b0010) 
                    begin // att. is fire
                      if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (temp_info_1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end       
                end    
            end
          else if (temp_info_2[27:24]==4'b0010) //def. is fire
            begin
              if (temp_info_1[31:28]==4'b0001)      //att. is lowest  exp +8
                begin
                  if (temp_info_2[7:0]>=8'd22) //def. Lv. up (30-8=22)
                    begin
                      temp_info_2[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_2[23:16] <= 8'hB1; // HP reset 'd177 = 'hB1 
                      temp_info_2[15:8]  <= 8'h60; //ATK reset 'd96  = 'h60
                      temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0010) 
                    begin //att. is grass or fire
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (temp_info_1[27:24]==4'b0100) 
                    begin // att. is water
                      if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (temp_info_1[27:24]==4'b0101||temp_info_1[27:24]==4'b1000) 
                    begin // att. is normal or electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end   
                end
              else if (temp_info_1[31:28]==4'b0010) //att. is middle  exp +12  
                begin
                  if (temp_info_2[7:0]>=8'd18) //def. Lv. up (30-12=18)
                    begin
                      temp_info_2[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_2[23:16] <= 8'hB1; // HP reset 'd177 = 'hB1 
                      temp_info_2[15:8]  <= 8'h60; //ATK reset 'd96  = 'h60
                      temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0010) 
                    begin //att. is grass or fire
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (temp_info_1[27:24]==4'b0100) 
                    begin // att. is water
                      if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (temp_info_1[27:24]==4'b0101||temp_info_1[27:24]==4'b1000) 
                    begin // att. is normal or electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end   
                end
              else if (temp_info_1[31:28]==4'b0100) //att. is highest  exp +16   
                begin
                  if (temp_info_2[7:0]>=8'd14) //def. Lv. up (30-16=14)
                    begin
                      temp_info_2[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_2[23:16] <= 8'hB1; // HP reset 'd177 = 'hB1 
                      temp_info_2[15:8]  <= 8'h60; //ATK reset 'd96  = 'h60
                      temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0010) 
                    begin //att. is grass or fire
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (temp_info_1[27:24]==4'b0100) 
                    begin // att. is water
                      if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (temp_info_1[27:24]==4'b0101||temp_info_1[27:24]==4'b1000) 
                    begin // att. is normal or electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end   
                end
            end  
          else if (temp_info_2[27:24]==4'b0100) //def. is water
            begin
              if (temp_info_1[31:28]==4'b0001)      //att. is lowest  exp +8
                begin
                  if (temp_info_2[7:0]>=8'd20) //def. Lv. up (28-8=20)
                    begin
                      temp_info_2[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_2[23:16] <= 8'hBB; // HP reset 'd187 = 'hBB 
                      temp_info_2[15:8]  <= 8'h59; //ATK reset 'd89  = 'h59
                      temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b0010||temp_info_1[27:24]==4'b0100) 
                    begin //att. is fire or water
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b1000) 
                    begin // att. is grass or electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (temp_info_1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end    
                end
              else if (temp_info_1[31:28]==4'b0010) //att. is middle  exp +12 
                begin
                  if (temp_info_2[7:0]>=8'd16) //def. Lv. up (28-12=16)
                    begin
                      temp_info_2[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_2[23:16] <= 8'hBB; // HP reset 'd187 = 'hBB 
                      temp_info_2[15:8]  <= 8'h59; //ATK reset 'd89  = 'h59
                      temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b0010||temp_info_1[27:24]==4'b0100) 
                    begin //att. is fire or water
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b1000) 
                    begin // att. is grass or electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (temp_info_1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end    
                end
              else if (temp_info_1[31:28]==4'b0100) //att. is highest  exp +16      
                begin
                  if (temp_info_2[7:0]>=8'd12) //def. Lv. up (28-16=12)
                    begin
                      temp_info_2[31:28] <= 4'b0010;// stage up to Middle
                      temp_info_2[23:16] <= 8'hBB; // HP reset 'd187 = 'hBB 
                      temp_info_2[15:8]  <= 8'h59; //ATK reset 'd89  = 'h59
                      temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b0010||temp_info_1[27:24]==4'b0100) 
                    begin //att. is fire or water
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b1000) 
                    begin // att. is grass or electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (temp_info_1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end    
                end
            end
          else if (temp_info_2[27:24]==4'b1000) //def. is electric
            begin
              if (temp_info_1[31:28]==4'b0001)      //att. is lowest  exp +8
                begin
                  if (temp_info_2[7:0]>=8'd18) //def. Lv. up (26-8=18)
                    begin
                     temp_info_2[31:28] <= 4'b0010;// stage up to Middle
                     temp_info_2[23:16] <= 8'hB6; // HP reset 'd182 = 'hB6 
                     temp_info_2[15:8]  <= 8'h61; //ATK reset 'd97  = 'h61
                     temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b1000) 
                    begin //att. is electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end   
                  else if (temp_info_1[27:24]==4'b0101||temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0010||temp_info_1[27:24]==4'b0100) 
                    begin // att. is normal , grass , fire , water
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end     
                end
              else if (temp_info_1[31:28]==4'b0010) //att. is middle  exp +12 
                begin
                  if (temp_info_2[7:0]>=8'd14) //def. Lv. up (26-12=14)
                    begin
                     temp_info_2[31:28] <= 4'b0010;// stage up to Middle
                     temp_info_2[23:16] <= 8'hB6; // HP reset 'd182 = 'hB6 
                     temp_info_2[15:8]  <= 8'h61; //ATK reset 'd97  = 'h61
                     temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b1000) 
                    begin //att. is electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end   
                  else if (temp_info_1[27:24]==4'b0101||temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0010||temp_info_1[27:24]==4'b0100) 
                    begin // att. is normal , grass , fire , water
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end     
                end  
              else if (temp_info_1[31:28]==4'b0100) //att. is highest  exp +16      
                begin
                  if (temp_info_2[7:0]>=8'd10) //def. Lv. up (26-16=10)
                    begin
                     temp_info_2[31:28] <= 4'b0010;// stage up to Middle
                     temp_info_2[23:16] <= 8'hB6; // HP reset 'd182 = 'hB6 
                     temp_info_2[15:8]  <= 8'h61; //ATK reset 'd97  = 'h61
                     temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b1000) 
                    begin //att. is electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end   
                  else if (temp_info_1[27:24]==4'b0101||temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0010||temp_info_1[27:24]==4'b0100) 
                    begin // att. is normal , grass , fire , water
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end     
                end 
            end
          else if (temp_info_2[27:24]==4'b0101) //def. is normal
            begin
              if (temp_info_1[31:28]==4'b0001)    //att. is lowest  exp +8
                begin
                  if (temp_info_2[7:0]>=8'd21) //def. the limit 29
                    begin
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= 8'd29; 
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= 8'd29; 
                          flag_fin_attack <= 1;
                        end   
                    end 
                  else  
                    begin 
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end 
                end
              else if (temp_info_1[31:28]==4'b0010) //att. is middle  exp +12
                begin
                  if (temp_info_2[7:0]>=8'd17) //def. the limit 29
                    begin
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= 8'd29; 
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= 8'd29; 
                          flag_fin_attack <= 1;
                        end   
                    end 
                  else  
                    begin 
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end 
                end
              else if (temp_info_1[31:28]==4'b0100) //att. is highest  exp +16
                begin
                  if (temp_info_2[7:0]>=8'd13) //def. the limit 29
                    begin
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= 8'd29; 
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= 8'd29; 
                          flag_fin_attack <= 1;
                        end   
                    end 
                  else  
                    begin 
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end 
                end
            end
        end
      else if (temp_info_2[31:28]==4'b0010) // def. is middle
        begin
          if (temp_info_2[27:24]==4'b0001)      //def. is grass
            begin
              if (temp_info_1[31:28]==4'b0001)      //att. is lowest  exp +8
                begin
                  if (temp_info_2[7:0]>=8'd55) //def. Lv. up (lv63 midd->high)
                    begin
                      temp_info_2[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_2[23:16] <= 8'hFE; // HP reset 'd254 = 'hFE 
                      temp_info_2[15:8]  <= 8'h7B; //ATK reset 'd123 = 'h7B
                      temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0100||temp_info_1[27:24]==4'b1000) 
                    begin //att. is grass or water or electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (temp_info_1[27:24]==4'b0010) 
                    begin // att. is fire
                      if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (temp_info_1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
              else if (temp_info_1[31:28]==4'b0010) //att. is middle  exp +12
                begin
                  if (temp_info_2[7:0]>=8'd51) //def. Lv. up (lv63 midd->high)
                    begin
                      temp_info_2[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_2[23:16] <= 8'hFE; // HP reset 'd254 = 'hFE 
                      temp_info_2[15:8]  <= 8'h7B; //ATK reset 'd123 = 'h7B
                      temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0100||temp_info_1[27:24]==4'b1000) 
                    begin //att. is grass or water or electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (temp_info_1[27:24]==4'b0010) 
                    begin // att. is fire
                      if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (temp_info_1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
              else if (temp_info_1[31:28]==4'b0100) //att. is highest  exp +16
                begin
                  if (temp_info_2[7:0]>=8'd47) //def. Lv. up (lv63 midd->high)
                    begin
                      temp_info_2[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_2[23:16] <= 8'hFE; // HP reset 'd254 = 'hFE 
                      temp_info_2[15:8]  <= 8'h7B; //ATK reset 'd123 = 'h7B
                      temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0100||temp_info_1[27:24]==4'b1000) 
                    begin //att. is grass or water or electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (temp_info_1[27:24]==4'b0010) 
                    begin // att. is fire
                      if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (temp_info_1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end        
                end     
            end
          else if (temp_info_2[27:24]==4'b0010) //def. is fire
            begin
              if (temp_info_1[31:28]==4'b0001)      //att. is lowest  exp +8
                begin
                  if (temp_info_2[7:0]>=8'd51) //def. Lv. up (59-8=51)
                    begin
                      temp_info_2[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_2[23:16] <= 8'hE1; // HP reset 'd225 = 'hE1 
                      temp_info_2[15:8]  <= 8'h7F; //ATK reset 'd127 = 'h7F
                      temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0010) 
                    begin //att. is grass or fire
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (temp_info_1[27:24]==4'b0100) 
                    begin // att. is water
                      if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (temp_info_1[27:24]==4'b0101||temp_info_1[27:24]==4'b1000) 
                    begin // att. is normal or electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
              else if (temp_info_1[31:28]==4'b0010) //att. is middle  exp +12
                begin
                  if (temp_info_2[7:0]>=8'd47) //def. Lv. up (59-12=47)
                    begin
                      temp_info_2[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_2[23:16] <= 8'hE1; // HP reset 'd225 = 'hE1 
                      temp_info_2[15:8]  <= 8'h7F; //ATK reset 'd127 = 'h7F
                      temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0010) 
                    begin //att. is grass or fire
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (temp_info_1[27:24]==4'b0100) 
                    begin // att. is water
                      if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (temp_info_1[27:24]==4'b0101||temp_info_1[27:24]==4'b1000) 
                    begin // att. is normal or electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
              else if (temp_info_1[31:28]==4'b0100) //att. is highest  exp +16  
                begin
                  if (temp_info_2[7:0]>=8'd43) //def. Lv. up (59-16=43)
                    begin
                      temp_info_2[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_2[23:16] <= 8'hE1; // HP reset 'd225 = 'hE1 
                      temp_info_2[15:8]  <= 8'h7F; //ATK reset 'd127 = 'h7F
                      temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0010) 
                    begin //att. is grass or fire
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (temp_info_1[27:24]==4'b0100) 
                    begin // att. is water
                      if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (temp_info_1[27:24]==4'b0101||temp_info_1[27:24]==4'b1000) 
                    begin // att. is normal or electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
            end  
          else if (temp_info_2[27:24]==4'b0100) //def. is water
            begin
              if (temp_info_1[31:28]==4'b0001)      //att. is lowest  exp +8
                begin
                  if (temp_info_2[7:0]>=8'd47) //def. Lv. up (55-8=47)
                    begin
                      temp_info_2[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_2[23:16] <= 8'hF5; // HP reset 'd245 = 'hF5 
                      temp_info_2[15:8]  <= 8'h71; //ATK reset 'd113 = 'h71
                      temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b0010||temp_info_1[27:24]==4'b0100) 
                    begin //att. is fire or water
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b1000) 
                    begin // att. is grass or electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (temp_info_1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end      
                end
              else if (temp_info_1[31:28]==4'b0010) //att. is middle  exp +12
                begin
                  if (temp_info_2[7:0]>=8'd43) //def. Lv. up (55-12=43)
                    begin
                      temp_info_2[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_2[23:16] <= 8'hF5; // HP reset 'd245 = 'hF5 
                      temp_info_2[15:8]  <= 8'h71; //ATK reset 'd113 = 'h71
                      temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b0010||temp_info_1[27:24]==4'b0100) 
                    begin //att. is fire or water
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b1000) 
                    begin // att. is grass or electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (temp_info_1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
              else if (temp_info_1[31:28]==4'b0100) //att. is highest  exp +16
                begin
                  if (temp_info_2[7:0]>=8'd39) //def. Lv. up (55-16=39)
                    begin
                      temp_info_2[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_2[23:16] <= 8'hF5; // HP reset 'd245 = 'hF5 
                      temp_info_2[15:8]  <= 8'h71; //ATK reset 'd113 = 'h71
                      temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b0010||temp_info_1[27:24]==4'b0100) 
                    begin //att. is fire or water
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b1000) 
                    begin // att. is grass or electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (temp_info_1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
            end
          else if (temp_info_2[27:24]==4'b1000) //def. is electric
            begin
              if (temp_info_1[31:28]==4'b0001)      //att. is lowest  exp +8
                begin
                  if (temp_info_2[7:0]>=8'd43) //def. Lv. up (51-8=43)
                    begin
                      temp_info_2[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_2[23:16] <= 8'hEB; // HP reset 'd235 = 'hEB
                      temp_info_2[15:8]  <= 8'h7C; //ATK reset 'd124 = 'h7C
                      temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b1000) 
                    begin //att. is electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end   
                  else if (temp_info_1[27:24]==4'b0101||temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0010||temp_info_1[27:24]==4'b0100) 
                    begin // att. is normal , grass , fire , water
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
              else if (temp_info_1[31:28]==4'b0010) //att. is middle  exp +12
                begin
                  if (temp_info_2[7:0]>=8'd39) //def. Lv. up (51-12=39)
                    begin
                      temp_info_2[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_2[23:16] <= 8'hEB; // HP reset 'd235 = 'hEB
                      temp_info_2[15:8]  <= 8'h7C; //ATK reset 'd124 = 'h7C
                      temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b1000) 
                    begin //att. is electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end   
                  else if (temp_info_1[27:24]==4'b0101||temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0010||temp_info_1[27:24]==4'b0100) 
                    begin // att. is normal , grass , fire , water
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
              else if (temp_info_1[31:28]==4'b0100) //att. is highest  exp +16
                begin
                  if (temp_info_2[7:0]>=8'd35) //def. Lv. up (51-16=35)
                    begin
                      temp_info_2[31:28] <= 4'b0100;// stage up to Highest
                      temp_info_2[23:16] <= 8'hEB; // HP reset 'd235 = 'hEB
                      temp_info_2[15:8]  <= 8'h7C; //ATK reset 'd124 = 'h7C
                      temp_info_2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (temp_info_1[27:24]==4'b1000) 
                    begin //att. is electric
                      if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end   
                  else if (temp_info_1[27:24]==4'b0101||temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0010||temp_info_1[27:24]==4'b0100) 
                    begin // att. is normal , grass , fire , water
                      if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                        begin
                          temp_info_2[23:16] <= 8'b0;
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                          temp_info_2[7:0]   <= temp_info_2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
            end
        end
      else if (temp_info_2[31:28]==4'b0100) // def. is highest EXP fix at 0
        begin
           if (temp_info_2[27:24]==4'b0001)      //def. is grass
            begin
              if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0100||temp_info_1[27:24]==4'b1000) 
                begin //att. is grass or water or electric
                  if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                    begin
                      temp_info_2[23:16] <= 8'b0;
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end
              else if (temp_info_1[27:24]==4'b0010) 
                begin // att. is fire
                  if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                    begin
                      temp_info_2[23:16] <= 8'b0;
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end     
              else if (temp_info_1[27:24]==4'b0101) 
                begin // att. is normal
                  if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                    begin
                      temp_info_2[23:16] <= 8'b0;
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end      
            end
          else if (temp_info_2[27:24]==4'b0010) //def. is fire
            begin
              if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0010) 
                begin //att. is grass or fire
                  if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                    begin
                      temp_info_2[23:16] <= 8'b0;
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end
              else if (temp_info_1[27:24]==4'b0100) 
                begin // att. is water
                  if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                    begin
                      temp_info_2[23:16] <= 8'b0;
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end     
              else if (temp_info_1[27:24]==4'b0101||temp_info_1[27:24]==4'b1000) 
                begin // att. is normal or electric
                  if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                    begin
                      temp_info_2[23:16] <= 8'b0;
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end      
            end  
          else if (temp_info_2[27:24]==4'b0100) //def. is water
            begin
              if (temp_info_1[27:24]==4'b0010||temp_info_1[27:24]==4'b0100) 
                begin //att. is fire or water
                  if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                    begin
                      temp_info_2[23:16] <= 8'b0;
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end
              else if (temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b1000) 
                begin // att. is grass or electric
                  if (temp_info_2[23:16]<=temp_info_1[15:8]*2) // hp will 0 after attck
                    begin
                      temp_info_2[23:16] <= 8'b0;
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]*2;
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end     
              else if (temp_info_1[27:24]==4'b0101) 
                begin // att. is normal
                  if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                    begin
                      temp_info_2[23:16] <= 8'b0;
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end      
            end
          else if (temp_info_2[27:24]==4'b1000) //def. is electric
            begin
              if (temp_info_1[27:24]==4'b1000) 
                begin //att. is electric
                  if (temp_info_2[23:16]<=temp_info_1[15:8]/2) // hp will 0 after attck
                    begin
                      temp_info_2[23:16] <= 8'b0;
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8]/2;
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end   
              else if (temp_info_1[27:24]==4'b0101||temp_info_1[27:24]==4'b0001||temp_info_1[27:24]==4'b0010||temp_info_1[27:24]==4'b0100) 
                begin // att. is normal , grass , fire , water
                  if (temp_info_2[23:16]<=temp_info_1[15:8]) // hp will 0 after attck
                    begin
                      temp_info_2[23:16] <= 8'b0;
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      temp_info_2[23:16] <= temp_info_2[23:16]-temp_info_1[15:8];
                      temp_info_2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end        
            end
        end  
    end
  else if (c_s==S_sav_p2) 
    begin
      flag_fin_attack <= 0;
    end  
  else if (c_s==S_output) 
    begin
      flag_fin_attack <= 0;
      temp_info_2 <= 0;
    end    
  else 
      temp_info_2 <= temp_info_2;
end



//================================================================
//                     CCCCCC  
//                   CC        
//                  CC         
//                   CC          
//                    CCCCCCCC   
//================================================================
// ADDRESS
always_ff @(posedge clk or negedge inf.rst_n) 
begin 
   if (!inf.rst_n) 
   begin
       inf.C_addr <= 0;
   end 
   else 
   begin
    case (c_s)
        S_saving:
           inf.C_addr <= ID_2;
        S_loading: 
           inf.C_addr <= ID_1;
        S_loading2:
           inf.C_addr <= ID_3;
        S_IDLE:
           inf.C_addr <= 0; 
    endcase
   end
end

// C_r_wb
always_ff @(posedge clk or negedge inf.rst_n) 
begin : C_r_wb
   if (~inf.rst_n) 
     begin
       inf.C_r_wb <= 0;
     end    
   else 
     begin
      if(c_s==S_saving) 
          inf.C_r_wb <= 1'b0;
      else if(c_s==S_sav_p2) 
          inf.C_r_wb <= 1'b0;
      else 
          inf.C_r_wb <= 1'b1;  
     end
end

// C_in_valid
always_ff @(posedge clk or negedge inf.rst_n) 
begin : C_in_valid
   if (!inf.rst_n)
     begin
         inf.C_in_valid <= 0;
         flag_Cinvalid <= 0;
     end
   else if(c_s==S_loading)
     begin
       if (flag_Cinvalid) 
         begin
           inf.C_in_valid <= 0;
         end
       else if (flag_Cinvalid==0) 
         begin
           inf.C_in_valid <= 1;
           flag_Cinvalid <= 1;
         end
     end
   else if(c_s==S_loading2)
     begin
       if (flag_Cinvalid) 
         begin
           inf.C_in_valid <= 0;
         end
       else if (flag_Cinvalid==0) 
         begin
           inf.C_in_valid <= 1;
           flag_Cinvalid <= 1;
         end
     end 
    else if(c_s==S_saving)
      begin
        if (flag_Cinvalid) 
          begin
            inf.C_in_valid <= 0;
          end
        else if (flag_Cinvalid==0) 
          begin
            inf.C_in_valid <= 1;
            flag_Cinvalid <= 1;
          end
      end
    else if(c_s==S_sav_p2)
      begin
        if (flag_Cinvalid) 
          begin
            inf.C_in_valid <= 0;
          end
        else if (flag_Cinvalid==0) 
          begin
            inf.C_in_valid <= 1;
            flag_Cinvalid <= 1;
          end
      end 
    else if (c_s==S_OPTION_1) 
      begin
        flag_Cinvalid <= 0;
      end
    else if (c_s==S_OPTION_2) 
      begin
        flag_Cinvalid <= 0;
      end 
    else
      begin
         inf.C_in_valid <= 0;
         flag_Cinvalid <= 0;   
      end
end

// WRITE
// C_data
always_ff @(posedge clk or negedge inf.rst_n) 
begin : C_data_w
    if (!inf.rst_n) 
      begin
        inf.C_data_w <= 0;  
      end
    else 
      begin
        if (c_s==S_saving) 
          begin
            if (flag_usedBracer) 
              begin
                inf.C_data_w[63:56] <= temp_info_2[7:0];
                inf.C_data_w[55:48] <= temp_info_2[15:8] - 8'd32; // change user bracer disappear 
                inf.C_data_w[47:40] <= temp_info_2[23:16]; 
                inf.C_data_w[39:32] <= temp_info_2[31:24]; 
                inf.C_data_w[31:24] <= temp_info_2[39:32]; 
                inf.C_data_w[23:16] <= temp_info_2[47:40]; 
                inf.C_data_w[15:8]  <= temp_info_2[55:48]; 
                inf.C_data_w[7:0]   <= temp_info_2[63:56]; 
              end
            else if (flag_usedBracer==0) 
              begin
                inf.C_data_w[63:56] <= temp_info_2[7:0];
                inf.C_data_w[55:48] <= temp_info_2[15:8];
                inf.C_data_w[47:40] <= temp_info_2[23:16]; 
                inf.C_data_w[39:32] <= temp_info_2[31:24]; 
                inf.C_data_w[31:24] <= temp_info_2[39:32]; 
                inf.C_data_w[23:16] <= temp_info_2[47:40]; 
                inf.C_data_w[15:8]  <= temp_info_2[55:48]; 
                inf.C_data_w[7:0]   <= temp_info_2[63:56]; 
              end  
          end
        else if (c_s==S_sav_p2) 
          begin
             inf.C_data_w[63:56] <= temp_info_2[7:0];
             inf.C_data_w[55:48] <= temp_info_2[15:8];
             inf.C_data_w[47:40] <= temp_info_2[23:16]; 
             inf.C_data_w[39:32] <= temp_info_2[31:24]; 
             inf.C_data_w[31:24] <= temp_info_2[39:32]; 
             inf.C_data_w[23:16] <= temp_info_2[47:40]; 
             inf.C_data_w[15:8]  <= temp_info_2[55:48]; 
             inf.C_data_w[7:0]   <= temp_info_2[63:56];  
          end
        else 
          begin
              inf.C_data_w <= 0;  
          end
      end
end
//================================================================
//   Counter
//================================================================
always_ff @(posedge clk or negedge inf.rst_n) 
begin
    if (!inf.rst_n) 
    begin
       Big_cnt <= 0; 
    end
    else 
    begin
      case (c_s)
        S_MENU: begin 
        if (Big_cnt==12) begin
        Big_cnt <= 0;  
        end
        else begin
        Big_cnt <= Big_cnt+1;
        end        
        end
        S_Check   : Big_cnt <= Big_cnt+1;
        S_UseItem : Big_cnt <= Big_cnt+1;
        S_Attack  : Big_cnt <= Big_cnt+1;
        S_Buy     : Big_cnt <= Big_cnt+1;
        S_Sell    : Big_cnt <= Big_cnt+1;
        S_Deposit : Big_cnt <= Big_cnt+1;
      default:
      Big_cnt <= 0; 
      endcase

    end
    
end


//================================================================
// always_ff @(posedge clk or negedge inf.rst_n) 
// begin
//   if (!inf.rst_n) 
//     begin
//       info_for_out <= 0;    
//     end 
//   else 
//     begin
//       case (c_s)
//           S_UseItem: info_for_out <= temp_info_1;
//           S_Buy:     info_for_out <= temp_info_1;
//           S_Sell:    info_for_out <= temp_info_1;
//           S_Check:   info_for_out <= temp_info_1;
//           S_Deposit: info_for_out <= temp_info_1;
//           S_sav_p2: 
//             begin 
//               info_for_out[63:32] <= temp_info_1[31:0];
//               info_for_out[31:0]  <= temp_info_2[31:0];
//             end 
//           S_IDLE: info_for_out <= 0;  
//       endcase  
//     end 
// end
always_comb 
  begin
    case (c_s)
      S_UseItem: info_for_out = temp_info_1;
      S_Buy:     info_for_out = temp_info_1;
      S_Sell:    info_for_out = temp_info_1;
      S_Check:   info_for_out = temp_info_1;
      S_Deposit: info_for_out = temp_info_1;
      S_sav_p2: 
        begin 
          info_for_out[63:32] = temp_info_1[31:0];
          info_for_out[31:0]  = temp_info_2[31:0];
        end   
      default: info_for_out = 0;
    endcase
  end


//================================================================
//   Output
//================================================================
always_ff @(posedge clk or negedge inf.rst_n) 
begin
   if (~inf.rst_n) 
   begin
       inf.out_valid <= 0;
   end
   else 
   begin
    case (n_s)
        S_output: inf.out_valid <= 1;
        S_MENU  : inf.out_valid <= 0; 
    default: inf.out_valid <= 0; 
    endcase
   end 
end

always_ff @(posedge clk or negedge inf.rst_n) 
begin
   if (~inf.rst_n) 
   begin
       inf.out_info <= 0;
   end
   else 
   begin
    case (n_s)
        S_output: 
        begin
          if (temp_arror!=0) 
          begin
            inf.out_info <= 0; 
          end
          else 
            begin
              inf.out_info <= info_for_out;
            end  
        end
        S_MENU  : inf.out_info <= 0; 
    default: inf.out_info <= 0; 
    endcase
   end 
end

always_ff @(posedge clk or negedge inf.rst_n) 
begin 
   if (~inf.rst_n) 
       inf.complete <= 0;
   else if(temp_arror==0)
       inf.complete <= 1;
   else 
       inf.complete <= 0;
end


always_ff @(posedge clk or negedge inf.rst_n) 
begin
   if (~inf.rst_n) 
   begin
       inf.err_msg <= 0;
   end
   else 
   begin
    case (c_s)
      S_UseItem: inf.err_msg <= temp_arror;
      S_Sell :   inf.err_msg <= temp_arror;
      S_Buy :    inf.err_msg <= temp_arror;
      S_Attack:  inf.err_msg <= temp_arror;
      S_sav_p2:  inf.err_msg <= temp_arror;
      S_Deposit: inf.err_msg <= 0; 
      S_Check:   inf.err_msg <= 0; 
      default:   inf.err_msg <= 0; 
    endcase
   end 
end


endmodule