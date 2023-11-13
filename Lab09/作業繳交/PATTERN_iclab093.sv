`include "../00_TESTBED/pseudo_DRAM.sv"
`include "Usertype_PKG.sv"

program automatic PATTERN(input clk, INF.PATTERN inf);
import usertype::*;


//================================================================
// parameters & integer
//================================================================
//      DRAM
//================================================================
parameter DRAM_p_r          = "../00_TESTBED/DRAM/dram.dat";
parameter user_numbers      = 256;
parameter DRAM_addr_begin   = 'h10000;
logic [7:0] golden_DRAM[ (DRAM_addr_begin+0) : ((DRAM_addr_begin+user_numbers*8)-1) ];
integer SEED = 127;

logic [7:0] player;
logic [5:0] buy_num;
logic [3:0] item_temp;
//*********** Golden ***********************************
logic[16:0]   golden_id_1 , golden_id_2;
logic         golden_complete;
Error_Msg     golden_err_msg;
logic[63:0]   golden_info;

//================================================================
//      Price
//================================================================
//----Buy---------------------------------------------------------
// item
parameter buyprice_berry    = 16 ;
parameter buyprice_medicine = 128;
parameter buyprice_candy    = 300;
parameter buyprice_bracer   = 64 ;
parameter buyprice_stone    = 800;
// pokemon
parameter buyprice_G = 100;
parameter buyprice_F = 90;
parameter buyprice_W = 110;
parameter buyprice_E = 120;
parameter buyprice_N = 130;

//----Sell--------------------------------------------------------
// item
parameter sellprice_berry    = 12;
parameter sellprice_medicine = 96;
parameter sellprice_candy    = 225;
parameter sellprice_bracer   = 48;
parameter sellprice_stone    = 600;
// pokemon (normal can't sell)
parameter sellprice_G_Middle = 510;
parameter sellprice_F_Middle = 450;
parameter sellprice_W_Middle = 500;
parameter sellprice_E_Middle = 550;
parameter sellprice_G_High = 1100;
parameter sellprice_F_High = 1000;
parameter sellprice_W_High = 1200;
parameter sellprice_E_High = 1300;

//================================================================
//      Pokemon parameter
//================================================================
//-------Lowest---------------------------------------------------
// grass
parameter G_Low_HP  = 128;
parameter G_Low_ATK = 63;
parameter G_Low_EXP = 32;
// fire
parameter F_Low_HP  = 119;
parameter F_Low_ATK = 64;
parameter F_Low_EXP = 30;
// water
parameter W_Low_HP  = 125;
parameter W_Low_ATK = 60;
parameter W_Low_EXP = 30;
// electric
parameter E_Low_HP  = 122;
parameter E_Low_ATK = 65;
parameter E_Low_EXP = 26;
// normal
parameter N_Low_HP  = 124;
parameter N_Low_ATK = 62;
parameter N_Low_EXP = 29;
//-------Middle---------------------------------------------------
// grass
parameter G_Mid_HP  = 192;
parameter G_Mid_ATK = 94;
parameter G_Mid_EXP = 63;
// fire
parameter F_Mid_HP  = 177;
parameter F_Mid_ATK = 96;
parameter F_Mid_EXP = 59;
// water
parameter W_Mid_HP  = 187;
parameter W_Mid_ATK = 89;
parameter W_Mid_EXP = 55;
// electric
parameter E_Mid_HP  = 182;
parameter E_Mid_ATK = 97;
parameter E_Mid_EXP = 51;
//-------Highest--------------------------------------------------
// grass
parameter G_Hig_HP  = 254;
parameter G_Hig_ATK = 123;
parameter G_Hig_EXP = 0;
// fire
parameter F_Hig_HP  = 225;
parameter F_Hig_ATK = 127;
parameter F_Hig_EXP = 0;
// water
parameter W_Hig_HP  = 245;
parameter W_Hig_ATK = 113;
parameter W_Hig_EXP = 0;
// electric
parameter E_Hig_HP  = 235;
parameter E_Hig_ATK = 124;
parameter E_Hig_EXP = 0;

//-------Flag------------------------------------------------------
logic sell_item_pokemon; //0:item 1:pokemon
logic buy_item_pokemon; //0:item 1:pokemon
//
integer p1_getEXP;
integer p2_getEXP;
integer buy_I_or_P;
integer sell_I_or_P;

integer   user_cnt, act_cnt;
integer  i,j,k,l;
integer  q,z;

logic flag_usedBracer;
logic flag_finAction;
logic flag_fin_attack;

//-------parameter--------------------------------------------------
parameter user_num=128;



//================================================================
//  logic
//================================================================
Player_Info info_player1;
Player_Info info_player2;

Money temp_amnt;


//================================================================
// class random
//================================================================
//----ID---------------------------------------
class random_id;
        rand Player_id ran_id;
        constraint range{
            ran_id inside{[0:255]};
        }
endclass

//----Action------------------------------------
class random_action;
        rand Action ran_Act;
        constraint range{
            ran_Act inside{Buy,Sell,Deposit,Use_item,Check,Attack};
        }
endclass

class random_item;
        rand Item ran_Item;
        constraint range{
            ran_Item inside{Berry,Medicine,Candy,Bracer,Water_stone,Fire_stone,Thunder_stone};
        }
endclass

class random_type;
        rand PKM_Type ran_Type;
        constraint range{
            ran_Type inside{Grass,Fire,Water,Electric,Normal};
        }
endclass

class random_amount;
        rand logic [13:0] ran_Amnt;
        constraint range{
            ran_Amnt inside{[1:12]};
        }
endclass


//================================================================
// initial
//================================================================
initial $readmemh(DRAM_p_r, golden_DRAM);
random_id            r_id = new();
random_action       r_act = new();
random_item        r_item = new();
random_type        r_type = new();
random_amount	     r_amnt = new();


task input_task; 
  begin
    player = 8'b0; 
    BtoB_10;
    BtoS_10;
    CtoS_10;
    StoS_10;
    AtoS_10;
    golden_err_msg=0;
    give_id;
    get_info_1;
    player = player+1;
    AtoA_10;
    BtoA_10;

    give_id;
    get_info_1;
    player = player+1;
    CtoA_10;

    give_id;
    get_info_1;
    player = player+1;
    CtoC_10;
    BtoC_10;
  
    UtoU_10;
    AtoU_10;
    BtoU_10;

    CtoU_10;
    CtoD_10;
    DtoA_10;
    attack_fake;
    golden_err_msg = 0;
    
    DtoD_10;
    DtoS_10;
    UtoS_10;
    usestone_task;
    save_p1;
    UtoD_10;
    player = 0;
    BtoD_10_1;
    player = 0;
    BtoD_10_2;
    // check_task;
    buy_item_FAKE;
    buy_item_FAKE;
    buy_item_FAKE;
    player = 0;
    usebracer_task;
    player = 2; 
    attack_task;
    DtoD_10noID;

  end
endtask

// repeat input
initial 
  begin
  	reset_signal_task;
      // for( user_cnt = 0; user_cnt < user_num; user_cnt = user_cnt +1)
      //   begin
      // end	
    input_task; 
    
    repeat(3) @(negedge clk);   
  	pass_task;

  end





initial begin
	forever@(posedge clk)begin
		if(inf.rst_n==0)
          begin
		    @(negedge clk);
			if((inf.complete !== 0) || (inf.err_msg !== 0) || (inf.out_info !== 0) || (inf.out_valid != 0))
            begin
        
  $display("\033[33m	                                             .:                                                                                         ");      
    $display("                                                   .:                                                                                                 ");
    $display("                                                  --`                                                                                                 ");
    $display("                                                `--`                                                                                                  ");
    $display("                 `-.                            -..        .-//-                                                                                      ");
    $display("                  `.:.`                        -.-     `:+yhddddo.                                                                                    ");
    $display("                    `-:-`             `       .-.`   -ohdddddddddh:                                                                                   ");
    $display("                      `---`       `.://:-.    :`- `:ydddddhhsshdddh-                                                                                  ");
    $display("                        `--.     ./////:-::` `-.--yddddhs+//::/hdddy`                                                                                 ");
    $display("                          .-..   ////:-..-// :.:oddddho:----:::+dddd+                                                                                 ");
    $display("                           `-.-` ///::::/::/:/`odddho:-------:::sdddh`                                                                                ");
    $display("             `:/+++//:--.``  .--..+----::://o:`osss/-.--------::/dddd/             ..`                                                                ");
    $display("             oddddddddddhhhyo///.-/:-::--//+o-`:``````...------::dddds          `.-.`                                                                 ");
    $display("            .ddddhhhhhddddddddddo.//::--:///+/`.````````..``...-:ddddh       `.-.`                                                                    ");
    $display("            /dddd//::///+syhhdy+:-`-/--/////+o```````.-.......``./yddd`   `.--.`                                                                      ");
    $display("            /dddd:/------:://-.`````-/+////+o:`````..``     `.-.``./ym.`..--`                                                                         ");
    $display("            :dddd//--------.`````````.:/+++/.`````.` `.-      `-:.``.o:---`                                                                           ");
    $display("            .ddddo/-----..`........`````..```````..  .-o`       `:.`.--/-      ```````````                                                            ");
    $display("             ydddh/:---..--.````.`.-.````````````-   `yd:        `:.`...:` `................`                                                         ");
    $display("             :dddds:--..:.\033[31m FFFFFF    AA     IIIIIIII  LL      \033[33m ...```````````````..`                                                  ");
    $display("              sdddds:.`/` \033[31m FF       A  A       II     LL      \033[33m`..-.-:-.````..`-                                                       ");
    $display("              `ydddd-`.:  \033[31m FFFFFF  AAAAAA      II     LL      \033[33m..---..``.+::-.-``--:                                                   ");
    $display("               .yddh``-.  \033[31m FF     AA    AA     II     LL      \033[33m  --.`      /:::-:..--`                                                 ");
    $display("                .sdo``:`  \033[31m FF    A A    A A IIIIIIII  LLLLLLLL\033[33m  -::::-`.`                                                             ");
    $display(" ````.........```.++``-:`        :y:.-``````````````....``.......-.```..::::----.```  ``                                                              ");
    $display("`...````..`....----:.``...````  ``::.``````.-:/+oosssyyy:`.yyh-..`````.:` ````...-----..`                                                             ");
    $display("                 `.+.``````........````.:+syhdddddddddddhoyddh.``````--              `..--.`                                                          ");
    $display("            ``.....--```````.```````.../ddddddhhyyyyyyyhhhddds````.--`             ````   ``                                                          ");
    $display("         `.-..``````-.`````.-.`.../ss/.oddhhyssssooooooossyyd:``.-:.         `-//::/++/:::.`                                                          ");
    $display("       `..```````...-::`````.-....+hddhhhyssoo+++//////++osss.-:-.           /++++o++//s+++/                                                          ");
    $display("     `-.```````-:-....-/-``````````:hddhsso++/////////////+oo+:`             +++::/o:::s+::o \033[31m     `-/++++:-`                              \033[33m");
    $display("    `:````````./`  `.----:..````````.oysso+///////////////++:::.             :++//+++/+++/+- \033[31m   :ymMMMMMMMMms-                            \033[33m");
    $display("    :.`-`..```./.`----.`  .----..`````-oo+////////////////o:-.`-.            `+++++++++++/.  \033[31m `yMMMNho++odMMMNo                           \033[33m");
    $display("    ..`:..-.`.-:-::.`        `..-:::::--/+++////////////++:-.```-`            +++++++++o:    \033[31m hMMMm-      /MMMMo  .ssss`/yh+.syyyyyyyyss. \033[33m");
    $display("     `.-::-:..-:-.`                 ```.+::/++//++++++++:..``````:`          -++++++++oo     \033[31m:MMMM:        yMMMN  -MMMMdMNNs-mNNNNNMMMMd` \033[33m");
    $display("        `   `--`                        /``...-::///::-.`````````.: `......` ++++++++oy-     \033[31m+MMMM`        +MMMN` -MMMMh:--. ````:mMMNs`  \033[33m");
    $display("           --`                          /`````````````````````````/-.``````.::-::::::/+      \033[31m:MMMM:        yMMMm  -MMMM`       `oNMMd:    \033[33m");
    $display("          .`                            :```````````````````````--.`````````..````.``/-      \033[31m dMMMm:`    `+MMMN/  -MMMN       :dMMNs`     \033[33m");
    $display("                                        :``````````````````````-.``.....````.```-::-.+       \033[31m `yNMMMdsooymMMMm/   -MMMN     `sMMMMy/////` \033[33m");
    $display("                                        :.````````````````````````-:::-::.`````-:::::+::-.`  \033[31m   -smNMMMMMNNd+`    -NNNN     hNNNNNNNNNNN- \033[33m");
    $display("                                `......../```````````````````````-:/:   `--.```.://.o++++++/.\033[31m      .:///:-`       `----     ------------` \033[33m");
    $display("                              `:.``````````````````````````````.-:-`      `/````..`+sssso++++:                                                        ");
    $display("                              :`````.---...`````````````````.--:-`         :-````./ysoooss++++.                                                       ");
    $display("                              -.````-:/.`.--:--....````...--:/-`            /-..-+oo+++++o++++.                                                       ");
    $display("             `:++/:.`          -.```.::      `.--:::::://:::::.              -:/o++++++++s++++                                                        ");
    $display("           `-+++++++++////:::/-.:.```.:-.`              :::::-.-`               -+++++++o++++.                                                        ");
    $display("           /++osoooo+++++++++:`````````.-::.             .::::.`-.`              `/oooo+++++.                                                         ");
    $display("           ++oysssosyssssooo/.........---:::               -:::.``.....`     `.:/+++++++++:                                                           ");
    $display("           -+syoooyssssssyo/::/+++++/+::::-`                 -::.``````....../++++++++++:`                                                            ");
    $display("             .:///-....---.-..-.----..`                        `.--.``````````++++++/:.                                                               ");
    $display("                                                                   `........-:+/:-.`                                                    \033[37m      ");
		$display ("--------------------------------------------------------------------------------------------");
		$display ("            FAIL! Output signal should be 0 after the reset signal is asserted              ");
		$display ("--------------------------------------------------------------------------------------------");
			  repeat(3) @(negedge clk);
              $finish;
			end
		  end
	end
end

initial begin
	forever@(posedge clk)begin
		if(inf.out_valid)begin
		    @(negedge clk);
			if((inf.complete  !==  golden_complete)||(inf.err_msg !== golden_err_msg)||(inf.out_info !== golden_info))
            begin
        
  $display("\033[33m	                                             .:                                                                                         ");      
    $display("                                                   .:                                                                                                 ");
    $display("                                                  --`                                                                                                 ");
    $display("                                                `--`                                                                                                  ");
    $display("                 `-.                            -..        .-//-                                                                                      ");
    $display("                  `.:.`                        -.-     `:+yhddddo.                                                                                    ");
    $display("                    `-:-`             `       .-.`   -ohdddddddddh:                                                                                   ");
    $display("                      `---`       `.://:-.    :`- `:ydddddhhsshdddh-                                                                                  ");
    $display("                        `--.     ./////:-::` `-.--yddddhs+//::/hdddy`                                                                                 ");
    $display("                          .-..   ////:-..-// :.:oddddho:----:::+dddd+                                                                                 ");
    $display("                           `-.-` ///::::/::/:/`odddho:-------:::sdddh`                                                                                ");
    $display("             `:/+++//:--.``  .--..+----::://o:`osss/-.--------::/dddd/             ..`                                                                ");
    $display("             oddddddddddhhhyo///.-/:-::--//+o-`:``````...------::dddds          `.-.`                                                                 ");
    $display("            .ddddhhhhhddddddddddo.//::--:///+/`.````````..``...-:ddddh       `.-.`                                                                    ");
    $display("            /dddd//::///+syhhdy+:-`-/--/////+o```````.-.......``./yddd`   `.--.`                                                                      ");
    $display("            /dddd:/------:://-.`````-/+////+o:`````..``     `.-.``./ym.`..--`                                                                         ");
    $display("            :dddd//--------.`````````.:/+++/.`````.` `.-      `-:.``.o:---`                                                                           ");
    $display("            .ddddo/-----..`........`````..```````..  .-o`       `:.`.--/-      ```````````                                                            ");
    $display("             ydddh/:---..--.````.`.-.````````````-   `yd:        `:.`...:` `................`                                                         ");
    $display("             :dddds:--..:.\033[31m FFFFFF    AA     IIIIIIII  LL      \033[33m ...```````````````..`                                                  ");
    $display("              sdddds:.`/` \033[31m FF       A  A       II     LL      \033[33m`..-.-:-.````..`-                                                       ");
    $display("              `ydddd-`.:  \033[31m FFFFFF  AAAAAA      II     LL      \033[33m..---..``.+::-.-``--:                                                   ");
    $display("               .yddh``-.  \033[31m FF     AA    AA     II     LL      \033[33m  --.`      /:::-:..--`                                                 ");
    $display("                .sdo``:`  \033[31m FF    A A    A A IIIIIIII  LLLLLLLL\033[33m  -::::-`.`                                                             ");
    $display(" ````.........```.++``-:`        :y:.-``````````````....``.......-.```..::::----.```  ``                                                              ");
    $display("`...````..`....----:.``...````  ``::.``````.-:/+oosssyyy:`.yyh-..`````.:` ````...-----..`                                                             ");
    $display("                 `.+.``````........````.:+syhdddddddddddhoyddh.``````--              `..--.`                                                          ");
    $display("            ``.....--```````.```````.../ddddddhhyyyyyyyhhhddds````.--`             ````   ``                                                          ");
    $display("         `.-..``````-.`````.-.`.../ss/.oddhhyssssooooooossyyd:``.-:.         `-//::/++/:::.`                                                          ");
    $display("       `..```````...-::`````.-....+hddhhhyssoo+++//////++osss.-:-.           /++++o++//s+++/                                                          ");
    $display("     `-.```````-:-....-/-``````````:hddhsso++/////////////+oo+:`             +++::/o:::s+::o \033[31m     `-/++++:-`                              \033[33m");
    $display("    `:````````./`  `.----:..````````.oysso+///////////////++:::.             :++//+++/+++/+- \033[31m   :ymMMMMMMMMms-                            \033[33m");
    $display("    :.`-`..```./.`----.`  .----..`````-oo+////////////////o:-.`-.            `+++++++++++/.  \033[31m `yMMMNho++odMMMNo                           \033[33m");
    $display("    ..`:..-.`.-:-::.`        `..-:::::--/+++////////////++:-.```-`            +++++++++o:    \033[31m hMMMm-      /MMMMo  .ssss`/yh+.syyyyyyyyss. \033[33m");
    $display("     `.-::-:..-:-.`                 ```.+::/++//++++++++:..``````:`          -++++++++oo     \033[31m:MMMM:        yMMMN  -MMMMdMNNs-mNNNNNMMMMd` \033[33m");
    $display("        `   `--`                        /``...-::///::-.`````````.: `......` ++++++++oy-     \033[31m+MMMM`        +MMMN` -MMMMh:--. ````:mMMNs`  \033[33m");
    $display("           --`                          /`````````````````````````/-.``````.::-::::::/+      \033[31m:MMMM:        yMMMm  -MMMM`       `oNMMd:    \033[33m");
    $display("          .`                            :```````````````````````--.`````````..````.``/-      \033[31m dMMMm:`    `+MMMN/  -MMMN       :dMMNs`     \033[33m");
    $display("                                        :``````````````````````-.``.....````.```-::-.+       \033[31m `yNMMMdsooymMMMm/   -MMMN     `sMMMMy/////` \033[33m");
    $display("                                        :.````````````````````````-:::-::.`````-:::::+::-.`  \033[31m   -smNMMMMMNNd+`    -NNNN     hNNNNNNNNNNN- \033[33m");
    $display("                                `......../```````````````````````-:/:   `--.```.://.o++++++/.\033[31m      .:///:-`       `----     ------------` \033[33m");
    $display("                              `:.``````````````````````````````.-:-`      `/````..`+sssso++++:                                                        ");
    $display("                              :`````.---...`````````````````.--:-`         :-````./ysoooss++++.                                                       ");
    $display("                              -.````-:/.`.--:--....````...--:/-`            /-..-+oo+++++o++++.                                                       ");
    $display("             `:++/:.`          -.```.::      `.--:::::://:::::.              -:/o++++++++s++++                                                        ");
    $display("           `-+++++++++////:::/-.:.```.:-.`              :::::-.-`               -+++++++o++++.                                                        ");
    $display("           /++osoooo+++++++++:`````````.-::.             .::::.`-.`              `/oooo+++++.                                                         ");
    $display("           ++oysssosyssssooo/.........---:::               -:::.``.....`     `.:/+++++++++:                                                           ");
    $display("           -+syoooyssssssyo/::/+++++/+::::-`                 -::.``````....../++++++++++:`                                                            ");
    $display("             .:///-....---.-..-.----..`                        `.--.``````````++++++/:.                                                               ");
    $display("                                                                   `........-:+/:-.`                                                            \033[37m      ");
		$display ("--------------------------------------------------------------------------------------------");
		$display ("                               FAIL! Incorrect Anwser                                       ");
		$display ("--------------------------------------------------------------------------------------------");
			  repeat(4) @(negedge clk);
              $finish;
			end
		end
	end
end


//===========================================================================================================================================================================================================
//===========================================================================================================================================================================================================
//     TTTTTTTTTT    AA        SSSSSS    KK    KKK 
//         TT       A  A     SS          KK   KKK  
//         TT      A    A     SSSSSSS    KKKKKK    
//         TT     AAAAAAAA           SS  KK   KKK  
//         TT    AA      AA   SSSSSSS    KK     KKK
//===========================================================================================================================================================================================================
//===========================================================================================================================================================================================================
task reset_signal_task; 
  begin 
    #(0.5);  inf.rst_n <= 0;
     $readmemh(DRAM_p_r, golden_DRAM);

	// ( D, id_valid , act_valid , item_valid , type_valid , amnt_valid )
	inf.D 	            = 0;
	inf.id_valid 	      = 0;
	inf.act_valid    	  = 0;
	inf.item_valid	    = 0;
	inf.type_valid      = 0;
	inf.amnt_valid      = 0;
	#(5);
	
    #(10);  inf.rst_n <=1;
  end 
endtask



//-----------------------------------------------------------------------------------------
//  6 Action
//-----------------------------------------------------------------------------------------
// task do_action;
// for (i = 0; i < 4; i=i+1) 
//         begin
// 	  	  r_act.randomize();
// 	  	  case(r_act.ran_Act)
// 	  	    Buy:          buy_task; 
// 	  	    Sell:        sell_task; 
//           Check:      check_task;
//           Attack:    attack_task;
//           Deposit:  deposit_task;
// 	  	    Use_item: useitem_task; 
//         endcase
// 	    end
// endtask

// task useitem_task;
//   begin
//     give_act_useitem;
//     give_type;  
//     cal_useitem;
//     useitem_err;
//     outcheck;
//    end
// endtask

task usebracer_task;
  begin
    give_act_useitem;
    give_bracer;  
    cal_useitem;
    repeat(1) @(negedge clk);
    useitem_err;
    outcheck;
   end
endtask

task usestone_task;
  begin
    give_id;
    get_info_1;
    give_act_useitem;
    give_stone;  
    cal_useitem;
    repeat(1) @(negedge clk);
    useitem_err;
    outcheck;
   end
endtask

task usestone_task_noid;
  begin
    give_act_useitem;
    give_stone;  
    cal_useitem;
    repeat(1) @(negedge clk);
    useitem_err;
    save_p1;
    outcheck;
   end
endtask

task check_task;
  begin
    give_id;
    give_act_check;  
    get_info_1;
    cal_check;
    outcheck;
  end
endtask

task check_task_noid;
  begin
    give_act_check;  
    cal_check;
    outcheck;
  end
endtask

task deposit_task;
  begin
    // get_info_1;
    give_act_deposit;  
    give_amnt;  
    golden_err_msg =No_Err;
    golden_complete = 1;
    info_player1.bag_info.money = info_player1.bag_info.money + 1;
    golden_info  = info_player1;
    outcheck;
  end
endtask

task deposit_alot;
  begin
    // get_info_1;
    give_act_deposit;  
    give_amnt_alot;  
    golden_err_msg =No_Err;
    golden_complete = 1;
    info_player1.bag_info.money = info_player1.bag_info.money + 900;
    golden_info  = info_player1;
    outcheck;
  end
endtask

task sell_task;
   begin
    give_act_sell;  
     sell_I_or_P = {$random(SEED)} % 2;
    //  get_info_1;
    case(sell_I_or_P)  
      0:
        begin
          give_item_ran;
          cal_sellitem;
          #(1);
          sell_err;
          outcheck;
        end  
      1:
        begin
          give_type_noD;
          cal_sellpokemon;
          #(1);
          sell_err;
          outcheck;
        end 
    endcase
  end
endtask

task sell_item_task;
    give_id;
    get_info_1;
    give_act_sell;
    give_med;
    cal_sellitem;
    #(1);
    sell_err;
    outcheck;
endtask

task sell_item_task_noid;
    repeat(1) @(negedge clk);
    give_act_sell;
    give_med;
    cal_sellitem;
    #(1);
    sell_err;
    outcheck;
endtask

task sell_poke_task;
    give_id;
    get_info_1;
    give_act_sell; 
    give_type_noD;
    cal_sellpokemon;
    #(1);
    sell_err;
    outcheck;
endtask

task sell_poke_tasknoID;
    repeat(2) @(negedge clk);
    give_act_sell; 
    give_type_noD;
    cal_sellpokemon;
    #(1);
    sell_err;
    outcheck;
endtask

task sell_stone;
    give_id;
    get_info_1;
    give_act_sell; 
    give_stone;
    cal_sellitem;
    #(1);
    sell_err;
    outcheck;
endtask


task buy_task;
  begin
    give_act_buy;  
    buy_I_or_P = {$random(SEED)} % 2;
    get_info_1;
    case(buy_I_or_P)  
      0:
        begin
          give_item_ran;
          cal_buyitem;
          #(1);
          buy_err;
          outcheck;
        end  
      1:
        begin
          give_type;
          cal_buypokemon;
          #(1);
          buy_err;
          outcheck;
        end 
    endcase
  end
endtask

task buy_poke_task;
  begin
    give_id;
    get_info_1;
    give_act_buy;  
    give_type;
    cal_buypokemon;
    #(1);
    buy_err;
    outcheck;     
  end
endtask

task buy_poke_tasknoID;
  begin
    give_act_buy;  
    give_type;
    cal_buypokemon;
    #(1);
    buy_err;
    outcheck;     
  end
endtask

task buy_item_task;
  begin
    give_act_buy;  
    give_item_ran;
    cal_buyitem;
    #(1);
    buy_err;
    outcheck;     
  end
endtask


task buy_item_FAKE;
  begin
    give_act_buy;  
    give_item_B;
    cal_buyitem;
    #(1);
    buy_err;
    outcheck;     
  end
endtask

task buy_item_stone;
  begin
    give_id;
    get_info_1;
    give_act_buy;  
    give_stone;
    cal_buyitem;
    #(1);
    buy_err;
    outcheck;     
  end
endtask


    // get_info_1;
task attack_task;
  begin
    give_act_attack;  
    give_id_2; 
    get_info_2;
    cal_attack_player1;
    cal_attack_player2;
    #(1);
    save_p2;
    attack_err;
    outcheck;
  end
endtask

task attack_fake;
  begin
    give_act_attack;  
    give_id_2; 
    get_info_2;
    cal_attack_player1;
    cal_attack_player2;
    #(1);
    save_p2;
    attack_err;
    outcheck;
  end
endtask

//-----------------------------------------------------------------------------------------
//  Sub_task
//-----------------------------------------------------------------------------------------
task get_info_1;
  info_player1[63:56] = golden_DRAM[golden_id_1][7:0];
  info_player1[55:48] = golden_DRAM[golden_id_1+1][7:0];
  info_player1[47:40] = golden_DRAM[golden_id_1+2][7:0];
  info_player1[39:32] = golden_DRAM[golden_id_1+3][7:0];
  info_player1[31:24] = golden_DRAM[golden_id_1+4][7:0];
  info_player1[23:16] = golden_DRAM[golden_id_1+5][7:0];
  info_player1[15:8]  = golden_DRAM[golden_id_1+6][7:0];
  info_player1[7:0]   = golden_DRAM[golden_id_1+7][7:0];  
endtask
task get_info_2;
   info_player2[63:56] = golden_DRAM[golden_id_2][7:0];
   info_player2[55:48] = golden_DRAM[golden_id_2+1][7:0];
   info_player2[47:40] = golden_DRAM[golden_id_2+2][7:0];
   info_player2[39:32] = golden_DRAM[golden_id_2+3][7:0];
   info_player2[31:24] = golden_DRAM[golden_id_2+4][7:0];
   info_player2[23:16] = golden_DRAM[golden_id_2+5][7:0];
   info_player2[15:8]  = golden_DRAM[golden_id_2+6][7:0];
   info_player2[7:0]   = golden_DRAM[golden_id_2+7][7:0];
endtask

task save_p1;
  if(flag_usedBracer)
    begin
      golden_DRAM[golden_id_1][7:0]   = info_player1[63:56];
      golden_DRAM[golden_id_1+1][7:0] = info_player1[55:48];
      golden_DRAM[golden_id_1+2][7:0] = info_player1[47:40];
      golden_DRAM[golden_id_1+3][7:0] = info_player1[39:32];
      golden_DRAM[golden_id_1+4][7:0] = info_player1[31:24];
      golden_DRAM[golden_id_1+5][7:0] = info_player1[23:16];
      golden_DRAM[golden_id_1+6][7:0] = info_player1[15:8] - 8'd32;
      golden_DRAM[golden_id_1+7][7:0] = info_player1[7:0]  ;
      flag_usedBracer = 0;
    end
  else 
    begin
      golden_DRAM[golden_id_1][7:0]   = info_player1[63:56];
      golden_DRAM[golden_id_1+1][7:0] = info_player1[55:48];
      golden_DRAM[golden_id_1+2][7:0] = info_player1[47:40];
      golden_DRAM[golden_id_1+3][7:0] = info_player1[39:32];
      golden_DRAM[golden_id_1+4][7:0] = info_player1[31:24];
      golden_DRAM[golden_id_1+5][7:0] = info_player1[23:16];
      golden_DRAM[golden_id_1+6][7:0] = info_player1[15:8] ;
      golden_DRAM[golden_id_1+7][7:0] = info_player1[7:0]  ;
    end    
endtask

task save_p2;
  golden_DRAM[golden_id_2][7:0]   = info_player2[63:56];
  golden_DRAM[golden_id_2+1][7:0] = info_player2[55:48];
  golden_DRAM[golden_id_2+2][7:0] = info_player2[47:40];
  golden_DRAM[golden_id_2+3][7:0] = info_player2[39:32];
  golden_DRAM[golden_id_2+4][7:0] = info_player2[31:24];
  golden_DRAM[golden_id_2+5][7:0] = info_player2[23:16];
  golden_DRAM[golden_id_2+6][7:0] = info_player2[15:8] ;
  golden_DRAM[golden_id_2+7][7:0] = info_player2[7:0]  ;
endtask



task give_act_buy;
    repeat(2) @(negedge clk); //can't touch (2)
    inf.act_valid  = 'b1; 
    inf.D          = {12'b0 , 4'b0001};
    repeat(1) @(negedge clk);
    inf.act_valid  = 'b0;
    inf.D          = 'bx;  
endtask

task give_act_sell;
    repeat(1) @(negedge clk);
    inf.act_valid  = 'b1; 
    inf.D          = {12'b0 , 4'b0010};
    repeat(1) @(negedge clk);
    inf.act_valid  = 'b0;
    inf.D          = 'bx;  
endtask

task give_act_useitem;
    repeat(3) @(negedge clk);
    inf.act_valid  = 'b1; 
    inf.D          = {12'b0 , 4'b0110};
    repeat(1) @(negedge clk);
    inf.act_valid  = 'b0;
    inf.D          = 'bx;  
endtask

task give_act_attack;
    repeat(2) @(negedge clk);
    inf.act_valid  = 'b1; 
    inf.D          = {12'b0 , 4'b1010};
    repeat(1) @(negedge clk);
    inf.act_valid  = 'b0;
    inf.D          = 'bx;  
endtask

task give_act_deposit;
    repeat(3) @(negedge clk);
    inf.act_valid  = 'b1; 
    inf.D          = {12'b0 , 4'b0100};
    repeat(1) @(negedge clk);
    inf.act_valid  = 'b0;
    inf.D          = 'bx;  
endtask

task give_act_check;
    repeat(2) @(negedge clk); //can't touch
    inf.act_valid  = 'b1; 
    inf.D          = {12'b0 , 4'b1000};
    repeat(1) @(negedge clk);
    inf.act_valid  = 'b0;
    inf.D          = 'bx;  
endtask

//-------give things for action-----------------------------------------

task give_id;
  begin  
    repeat(2) @(negedge clk);
    // r_id.randomize();   
    inf.id_valid  = 'b1; 
    inf.D         = {8'b0 , player};
    golden_id_1   = DRAM_addr_begin + player*8;
    repeat(1) @(negedge clk);
    inf.id_valid  = 'b0;
    inf.D         = 'bx;
  end
endtask


task give_id_2;
  begin  
    repeat(1) @(negedge clk);
    // r_id.randomize();   
    inf.id_valid  = 'b1; 
    inf.D         = {8'b0 , player};
    golden_id_2   = DRAM_addr_begin + player*8;
    repeat(1) @(negedge clk);
    inf.id_valid  = 'b0;
    inf.D         = 'bx;
  end
endtask

task give_Player0;
  begin
    repeat(1) @(negedge clk); 
    inf.id_valid  = 'b1; 
    inf.D         = 0;
    golden_id_1   = DRAM_addr_begin;
    player = 1;
    repeat(1) @(negedge clk);
    inf.id_valid  = 'b0;
    inf.D         = 'bx;
  end
endtask

task give_Player1;
  begin
    repeat(1) @(negedge clk); 
    inf.id_valid  = 'b1; 
    inf.D         = 0;
    golden_id_1   = DRAM_addr_begin + 8;
    player = 2;
    repeat(1) @(negedge clk);
    inf.id_valid  = 'b0;
    inf.D         = 'bx;
  end
endtask

task give_random;
  begin
    repeat(1) @(negedge clk);
    r_id.randomize();   
    inf.id_valid  = 'b1; 
    inf.D         = {8'b0 , r_id.ran_id};
    golden_id_2   = DRAM_addr_begin + r_id.ran_id*8;
    repeat(1) @(negedge clk);
    inf.id_valid  = 'b0;
    inf.D         = 'bx;
  end
endtask

task give_amnt;
  begin
    repeat(1) @(negedge clk);
    // r_amnt.randomize();   
    inf.amnt_valid  = 'b1; 
    inf.D           = {15'b0 , 1'b1};
    repeat(1) @(negedge clk);
    inf.amnt_valid  = 'b0;
    inf.D           = 'bx;  
  end
endtask    

task give_amnt_alot;
  begin
    repeat(1) @(negedge clk);
    // r_amnt.randomize();   
    inf.amnt_valid  = 'b1; 
    inf.D           = {2'b0 , 14'd900};
    repeat(1) @(negedge clk);
    inf.amnt_valid  = 'b0;
    inf.D           = 'bx;  
  end
endtask

task give_type;
  begin
    repeat(1) @(negedge clk);
    r_type.randomize();   
    inf.type_valid  = 'b1; 
    inf.D           = {8'b0 , r_type.ran_Type};
    repeat(1) @(negedge clk);
    inf.type_valid  = 'b0;
    inf.D           = 'bx;  
  end
endtask

task give_stone;
  begin
    repeat(1) @(negedge clk);  
    inf.item_valid  = 'b1; 
    inf.D           = {8'b0 , 4'b1001};
    item_temp = 4'b1001;
    repeat(1) @(negedge clk);
    inf.item_valid  = 'b0;
    inf.D           = 'bx;  
  end
endtask 

task give_type_noD;
  begin
    repeat(1) @(negedge clk);
    r_type.randomize();   
    inf.type_valid  = 'b1; 
    inf.D           = 'b0;
    repeat(1) @(negedge clk);
    inf.type_valid  = 'b0;
    inf.D           = 'bx;  
  end
endtask 

task give_bracer;
  begin
      repeat(1) @(negedge clk);  
    inf.item_valid  = 'b1; 
    inf.D           = {12'b0 , 4'b1000};
    flag_usedBracer = 0;
    item_temp = 4'b1000;
    repeat(1) @(negedge clk);
    inf.item_valid  = 'b0;
    inf.D           = 'bx;    
  end
endtask 


task give_item_ran;
  begin
    repeat(1) @(negedge clk);
    r_item.randomize();   
    inf.item_valid  = 'b1; 
    inf.D           = {12'b0 , r_item.ran_Item};
    repeat(1) @(negedge clk);
    inf.item_valid  = 'b0;
    inf.D           = 'bx;  
  end
endtask

task give_item_B;
  begin
    repeat(1) @(negedge clk);
    inf.item_valid  = 'b1; 
    inf.D           = {12'b0 , 4'b0001};
    item_temp = 4'b0001;
    repeat(1) @(negedge clk);
    inf.item_valid  = 'b0;
    inf.D           = 'bx;  
  end
endtask 

task give_med;
  begin
    repeat(1) @(negedge clk);
    inf.item_valid  = 'b1; 
    inf.D           = {12'b0 ,4'b0010};
    item_temp = 4'b0010;
    repeat(1) @(negedge clk);
    inf.item_valid  = 'b0;
    inf.D           = 'bx;  
  end
endtask  

//--buy-------------------------
task cal_buyitem;
  begin
    // case(r_item.ran_Item)
    case(item_temp)
      Berry: 
        begin
          if(info_player1.bag_info.money<=14'd16)
            begin
              golden_err_msg = Out_of_money;
              golden_complete = 0;
            end
          else if(info_player1.bag_info.berry_num == 8'd15)
            begin
              golden_err_msg =Bag_is_full ;
              golden_complete = 0;
            end    
          else 
            begin
              golden_err_msg =No_Err;
              golden_complete = 1;
              info_player1.bag_info.berry_num = info_player1.bag_info.berry_num + 1;
            end     
        end
      Medicine:
        begin
          if(info_player1.bag_info.money<=14'd128)
            begin
              golden_err_msg = Out_of_money;
              golden_complete = 0;
            end
          else if(info_player1.bag_info.medicine_num == 8'd15)
            begin
              golden_err_msg =Bag_is_full ;
              golden_complete = 0;
            end     
          else 
            begin
              golden_err_msg =No_Err;
              golden_complete = 1;
              info_player1.bag_info.medicine_num = info_player1.bag_info.medicine_num + 1;
            end     
        end  
      Candy:
        begin
          if(info_player1.bag_info.money<=14'd225)
            begin
              golden_err_msg = Out_of_money;
              golden_complete = 0;
            end
          else if(info_player1.bag_info.candy_num == 8'd15)
            begin
              golden_err_msg =Bag_is_full ;
              golden_complete = 0;
            end     
          else 
            begin
              golden_err_msg =No_Err;
              golden_complete = 1;
              info_player1.bag_info.candy_num = info_player1.bag_info.candy_num + 1;
            end     
        end  
      Bracer:
        begin
          if(info_player1.bag_info.money<=14'd48)
            begin
              golden_err_msg = Out_of_money;
              golden_complete = 0;
            end
          else if(info_player1.bag_info.bracer_num == 8'd15)
            begin
              golden_err_msg =Bag_is_full ;
              golden_complete = 0;
            end     
          else 
            begin
              golden_err_msg =No_Err;
              golden_complete = 1;
              info_player1.bag_info.bracer_num = info_player1.bag_info.bracer_num + 1;
            end     
        end       
      Water_stone:
        begin
          if(info_player1.bag_info.money <= 14'd800)
            begin
              golden_err_msg = Out_of_money;
              golden_complete = 0;
            end
          else if(info_player1.bag_info.stone != 2'b0)
            begin
              golden_err_msg =Bag_is_full ;
              golden_complete = 0;
            end     
          else 
            begin
              golden_err_msg =No_Err;
              golden_complete = 1;
              info_player1.bag_info.stone = W_stone;
              info_player1.bag_info.money = info_player1.bag_info.money - 14'd800;
            end     
        end   
      Fire_stone:
        begin
          if(info_player1.bag_info.money<=14'd800)
            begin
              golden_err_msg = Out_of_money;
              golden_complete = 0;
            end
          else if(info_player1.bag_info.stone != 2'b0)
            begin
              golden_err_msg =Bag_is_full ;
              golden_complete = 0;
            end    
          else 
            begin
              golden_err_msg =No_Err;
              golden_complete = 1;
              info_player1.bag_info.stone = F_stone;
              info_player1.bag_info.money = info_player1.bag_info.money-14'd800;
            end     
        end    
      Thunder_stone:
        begin
          if(info_player1.bag_info.money<=14'd800)
            begin
              golden_err_msg = Out_of_money;
              golden_complete = 0;
            end
          else if(info_player1.bag_info.stone != 2'b0)
            begin
              golden_err_msg =Bag_is_full ;
              golden_complete = 0;
            end    
          else 
            begin
              golden_err_msg =No_Err;
              golden_complete = 1;
              info_player1.bag_info.stone = T_stone;
            info_player1.bag_info.money = info_player1.bag_info.money-14'd800;
            end     
        end    
    endcase
  end
endtask    

task cal_buypokemon;
  begin
        case(r_type.ran_Type)
          Grass:
            begin
              if (info_player1[45:32]<14'd100)
                begin
                  golden_err_msg = Out_of_money;
                  golden_complete = 0;
                end   
              else if(info_player1[31:0]!=0)
                begin
                  golden_err_msg = Already_Have_PKM;
                  golden_complete = 0;
                end
              else 
                begin
                  golden_err_msg = No_Err;
                  golden_complete = 1;
                  info_player1.pkm_info.stage    = Lowest;
                  info_player1.pkm_info.pkm_type = Grass;
                  info_player1.pkm_info.hp       = G_Low_HP;
                  info_player1.pkm_info.atk      = G_Low_ATK;
                  info_player1.pkm_info.exp      = 0;
                end    
            end
          Fire:
            begin
               if (info_player1[45:32]<14'd90)
                begin
                  golden_err_msg = Out_of_money;
                  golden_complete = 0;
                end   
              else if(info_player1[31:0]!=0)
                begin
                  golden_err_msg = Already_Have_PKM;
                  golden_complete = 0;
                end
              else 
                begin
                  golden_err_msg = No_Err;
                  golden_complete <= 1;
                  info_player1.pkm_info.stage    = Lowest;
                  info_player1.pkm_info.pkm_type = Fire;
                  info_player1.pkm_info.hp       = F_Low_HP;
                  info_player1.pkm_info.atk      = F_Low_ATK;
                  info_player1.pkm_info.exp      = 0;
                end
            end
          Water:
            begin
               if (info_player1[45:32]<14'd110)
                begin
                  golden_err_msg = Out_of_money;
                  golden_complete = 0;
                end   
              else if(info_player1[31:0]!=0)
                begin
                  golden_err_msg = Already_Have_PKM;
                  golden_complete = 0;
                end
              else 
                begin
                  golden_err_msg = No_Err;
                  golden_complete <= 1;
                  info_player1.pkm_info.stage    = Lowest;
                  info_player1.pkm_info.pkm_type = Water;
                  info_player1.pkm_info.hp       = W_Low_HP;
                  info_player1.pkm_info.atk      = W_Low_ATK;
                  info_player1.pkm_info.exp      = 0;
                end
            end
          Electric:
            begin
               if (info_player1[45:32]<14'd120)
                begin
                  golden_err_msg = Out_of_money;
                  golden_complete = 0;
                end   
              else if(info_player1[31:0]!=0)
                begin
                  golden_err_msg = Already_Have_PKM;
                  golden_complete = 0;
                end
              else 
                begin
                  golden_err_msg = No_Err;
                  golden_complete <= 1;
                  info_player1.pkm_info.stage    = Lowest;
                  info_player1.pkm_info.pkm_type = Electric;
                  info_player1.pkm_info.hp       = E_Low_HP;
                  info_player1.pkm_info.atk      = E_Low_ATK;
                  info_player1.pkm_info.exp      = 0;
                end
            end                  
          Normal:
            begin
               if (info_player1[45:32]<14'd130)
                begin
                  golden_err_msg = Out_of_money;
                  golden_complete = 0;
                end   
              else if(info_player1[31:0]!=0)
                begin
                  golden_err_msg = Already_Have_PKM;
                  golden_complete = 0;
                end
              else 
                begin
                  golden_err_msg = No_Err;
                  golden_complete <= 1;
                  info_player1.pkm_info.stage    = Lowest;
                  info_player1.pkm_info.pkm_type = Normal;
                  info_player1.pkm_info.hp       = N_Low_HP;
                  info_player1.pkm_info.atk      = N_Low_ATK;
                  info_player1.pkm_info.exp      = 0;
                end
            end  
        endcase 
  end
endtask  

task buy_err;
  if(golden_err_msg!=0)
    begin
      golden_info = 0;
    end  
  else
    begin
      golden_info = info_player1;
    end
endtask

//--sell-------------------------
task cal_sellitem;
  begin
   case(item_temp)
      Berry: 
        begin
          if(info_player1.bag_info.berry_num==4'b0)
            begin
              golden_err_msg = Not_Having_Item;
              golden_complete = 0;
            end
          else 
            begin
              golden_err_msg =No_Err;
              golden_complete = 1;
              info_player1.bag_info.money = info_player1.bag_info.money + 14'd12;
              info_player1.bag_info.berry_num = info_player1.bag_info.berry_num - 1;
            end     
        end
      Medicine:
        begin
          if(info_player1.bag_info.medicine_num==4'b0)
            begin
              golden_err_msg = Not_Having_Item;
              golden_complete = 0;
            end
          else 
            begin
              golden_err_msg =No_Err;
              golden_complete = 1;
              info_player1.bag_info.money = info_player1.bag_info.money + 14'd96;
              info_player1.bag_info.medicine_num = info_player1.bag_info.medicine_num - 1;
            end     
        end
      Candy:
       begin
          if(info_player1.bag_info.candy_num==4'b0)
            begin
              golden_err_msg = Not_Having_Item;
              golden_complete = 0;
            end
          else 
            begin
              golden_err_msg =No_Err;
              golden_complete = 1;
              info_player1.bag_info.money = info_player1.bag_info.money + 14'd225;
              info_player1.bag_info.candy_num = info_player1.bag_info.candy_num - 1;
            end     
        end 
      Bracer:
        begin
          if(info_player1.bag_info.bracer_num==4'b0)
            begin
              golden_err_msg = Not_Having_Item;
              golden_complete = 0;
            end
          else 
            begin
              golden_err_msg =No_Err;
              golden_complete = 1;
              info_player1.bag_info.money = info_player1.bag_info.money + 14'd48;
              info_player1.bag_info.bracer_num = info_player1.bag_info.bracer_num - 1;
            end     
        end       
      Water_stone:
        begin
          if(info_player1.bag_info.stone!=2'b01)
            begin
              golden_err_msg = Not_Having_Item;
              golden_complete = 0;
            end
          else 
            begin
              golden_err_msg =No_Err;
              golden_complete = 1;
              info_player1.bag_info.money = info_player1.bag_info.money + 14'd600;
              info_player1.bag_info.stone = No_stone;
            end     
        end   
      Fire_stone:
        begin
          if(info_player1.bag_info.stone!=2'b10)
            begin
              golden_err_msg = Not_Having_Item;
              golden_complete = 0;
            end
          else 
            begin
              golden_err_msg =No_Err;
              golden_complete = 1;
              info_player1.bag_info.money = info_player1.bag_info.money + 14'd600;
              info_player1.bag_info.stone = No_stone;
            end     
        end       
      Thunder_stone:
        begin
          if(info_player1.bag_info.stone!=2'b11)
            begin
              golden_err_msg = Not_Having_Item;
              golden_complete = 0;
            end
          else 
            begin
              golden_err_msg =No_Err;
              golden_complete = 1;
              info_player1.bag_info.money = info_player1.bag_info.money + 14'd600;
              info_player1.bag_info.stone = No_stone;
            end     
        end       
    endcase
  end
endtask    

task cal_sellpokemon;
  begin
    if(info_player1[31:0]==0)
      begin
        golden_err_msg  = Not_Having_PKM;
        golden_complete = 0;
      end
    else
      begin
        case(info_player1.pkm_info.pkm_type)
          Grass:
            begin
              if(info_player1.pkm_info.stage==Lowest)
                begin
                  golden_err_msg = Has_Not_Grown;
                  golden_complete = 0; 
                end
              else if (info_player1.pkm_info.stage==Middle)
                begin
                  golden_err_msg = No_Err;
                  golden_complete = 1;
                  info_player1.pkm_info = 0;
                  info_player1.bag_info.money = info_player1.bag_info.money + sellprice_G_Middle;
                end
              else if (info_player1.pkm_info.stage==Highest)
                begin
                  golden_err_msg = No_Err;
                  golden_complete = 1;
                  info_player1.pkm_info = 0;
                  info_player1.bag_info.money = info_player1.bag_info.money + sellprice_G_High;  
                end           
            end
          Fire:
            begin
              if(info_player1.pkm_info.stage==Lowest)
                begin
                  golden_err_msg = Has_Not_Grown;
                  golden_complete = 0; 
                end
              else if (info_player1.pkm_info.stage==Middle)
                begin
                  golden_err_msg = No_Err;
                  golden_complete = 1;
                  info_player1.pkm_info = 0;
                  info_player1.bag_info.money = info_player1.bag_info.money + sellprice_F_Middle;
                end
              else if (info_player1.pkm_info.stage==Highest)
                begin
                  golden_err_msg = No_Err;
                  golden_complete = 1;
                  info_player1.pkm_info = 0;
                  info_player1.bag_info.money = info_player1.bag_info.money + sellprice_F_High;  
                end           
            end
          Water:
            begin
              if(info_player1.pkm_info.stage==Lowest)
                begin
                  golden_err_msg = Has_Not_Grown;
                  golden_complete = 0; 
                end
              else if (info_player1.pkm_info.stage==Middle)
                begin
                  golden_err_msg = No_Err;
                  golden_complete = 1;
                  info_player1.pkm_info = 0;
                  info_player1.bag_info.money = info_player1.bag_info.money + sellprice_W_Middle;
                end
              else if (info_player1.pkm_info.stage==Highest)
                begin
                  golden_err_msg = No_Err;
                  golden_complete = 1;
                  info_player1.pkm_info = 0;
                  info_player1.bag_info.money = info_player1.bag_info.money + sellprice_W_High;  
                end           
            end
          Electric:
            begin
              if(info_player1.pkm_info.stage==Lowest)
                begin
                  golden_err_msg = Has_Not_Grown;
                  golden_complete = 0; 
                end
              else if (info_player1.pkm_info.stage==Middle)
                begin
                  golden_err_msg = No_Err;
                  golden_complete = 1;
                  info_player1.pkm_info = 0;
                  info_player1.bag_info.money = info_player1.bag_info.money + sellprice_E_Middle;
                end
              else if (info_player1.pkm_info.stage==Highest)
                begin
                  golden_err_msg = No_Err;
                  golden_complete = 1;
                  info_player1.pkm_info = 0;
                  info_player1.bag_info.money = info_player1.bag_info.money + sellprice_E_High;  
                end           
            end                  
          Normal:
            begin
              golden_err_msg = Has_Not_Grown;
              golden_complete = 0; 
            end  
        endcase
      end 

  end
endtask  

task sell_err;
  if(golden_err_msg!=0)
    begin
      golden_info = 0;
    end  
  else
    begin
      golden_info = info_player1;
    end
endtask  


//-----output----------------------
task outcheck;
  begin
    for (i = 0; i < 1000 ; i=i+1) 
      begin
	      if(inf.out_valid==0)
            repeat(1) @(negedge clk);          
	  end     
  end
endtask    

//---check-------------------------
task cal_check;
  golden_err_msg = No_Err;
  golden_complete= 1;
  golden_info    = info_player1;
endtask

//---use item----------------------
task cal_useitem;
begin
  if (info_player1[31:0]==32'b0) // u don't have any pokemon 
    begin
      golden_err_msg = Not_Having_PKM;
      info_player1 <= info_player1;
      flag_finAction <= 1;
    end
  else 
    begin            
      if (item_temp == Berry)//-------- Berry  HP+'d32 ---------------------------
        begin
          if (info_player1[63:60]==4'b0) 
            begin
              golden_err_msg = Not_Having_Item;
              info_player1 <= info_player1;
            end
          else 
            begin
              if (info_player1[27:24]==4'b0001) //grass
                begin
                  if (info_player1[31:28]==4'b0100 && info_player1[23:16]>=8'd222) 
                    begin// highest  will full HP
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= 8'd254;
                      info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end
                  else if (info_player1[31:28]==4'b0010 && info_player1[23:16]>=8'd160) 
                    begin// middle  will full HP
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= 8'd192;
                      info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end
                  else if (info_player1[31:28]==4'b0001 && info_player1[23:16]>=8'd96) 
                    begin// lowest  will full HP
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= 8'd128;
                      info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end
                  else 
                    begin
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= info_player1[23:16] + 8'd32;
                      info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end      
                end
              else if (info_player1[27:24]==4'b0010) //fire 
                begin
                  if (info_player1[31:28]==4'b0100 && info_player1[23:16]>=8'd193) 
                    begin// highest  will full HP
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= 8'd225;
                      info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end
                  else if (info_player1[31:28]==4'b0010 && info_player1[23:16]>=8'd145) 
                    begin// middle  will full HP
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= 8'd177;
                      info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end
                  else if (info_player1[31:28]==4'b0001 && info_player1[23:16]>=8'd87) 
                    begin// lowest  will full HP
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= 8'd119;
                      info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end
                  else 
                    begin
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= info_player1[23:16] + 8'd32;
                      info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end    
                end
              else if (info_player1[27:24]==4'b0100) //water 
                begin
                  if (info_player1[31:28]==4'b0100 && info_player1[23:16]>=8'd213) 
                    begin// highest  will full HP
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= 8'd245;
                      info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end
                  else if (info_player1[31:28]==4'b0010 && info_player1[23:16]>=8'd155) 
                    begin// middle  will full HP
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= 8'd187;
                      info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end
                  else if (info_player1[31:28]==4'b0001 && info_player1[23:16]>=8'd93) 
                    begin// lowest  will full HP
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= 8'd125;
                      info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end
                  else 
                    begin
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= info_player1[23:16] + 8'd32;
                      info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end    
                end
              else if (info_player1[27:24]==4'b1000) //electric 
                begin
                  if (info_player1[31:28]==4'b0100 && info_player1[23:16]>=8'd203) 
                    begin// highest  will full HP
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= 8'd235;
                      info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end
                  else if (info_player1[31:28]==4'b0010 && info_player1[23:16]>=8'd150) 
                    begin// middle  will full HP
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= 8'd182;
                      info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end
                  else if (info_player1[31:28]==4'b0001 && info_player1[23:16]>=8'd90) 
                    begin// lowest  will full HP
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= 8'd122;
                      info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end
                  else 
                    begin
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= info_player1[23:16] + 8'd32;
                      info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end    
                end
             else if (info_player1[27:24]==4'b0101) //normal 
                begin
                  if (info_player1[23:16]>=8'd92) 
                    begin// lowest  will full HP
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= 8'd124;
                      info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end
                  else 
                    begin
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= info_player1[23:16] + 8'd32;
                      info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                      flag_finAction <= 1;
                    end      
                end           
              else 
                begin
                  golden_err_msg = No_Err;
                  info_player1[23:16] <= info_player1[23:16] + 8'd32;
                  info_player1[63:60] <= info_player1[63:60] - 4'b0001;
                  flag_finAction <= 1;
                end
            end
        end               
      else if (item_temp == Medicine)//---Medicine recover full HP------------------- 
        begin
          if (info_player1[59:56]==4'b0) 
            begin
              golden_err_msg = Not_Having_Item;
              info_player1 <= info_player1;    
            end
          else 
            begin
              if (info_player1[27:24]==4'b0001) //grass
                begin
                  if (info_player1[31:28]==4'b0100) 
                    begin// highest
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= 8'd254;
                      info_player1[59:56] <= info_player1[59:56] - 4'b0001;
                      flag_finAction <= 1;
                    end
                  else if (info_player1[31:28]==4'b0010) 
                    begin// middle
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= 8'd192;
                      info_player1[59:56] <= info_player1[59:56] - 4'b0001;
                      flag_finAction <= 1;
                    end
                  else if (info_player1[31:28]==4'b0001) 
                    begin// lowest
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= 8'd128;
                      info_player1[59:56] <= info_player1[59:56] - 4'b0001;
                      flag_finAction <= 1;
                    end    
                end
              else if (info_player1[27:24]==4'b0010) //fire 
                begin
                      if (info_player1[31:28]==4'b0100) 
                        begin// highest  will full HP
                          golden_err_msg = No_Err;
                          info_player1[23:16] <= 8'd225;
                          info_player1[59:56] <= info_player1[59:56] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else if (info_player1[31:28]==4'b0010) 
                        begin// middle  will full HP
                          golden_err_msg = No_Err;
                          info_player1[23:16] <= 8'd177;
                          info_player1[59:56] <= info_player1[59:56] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else if (info_player1[31:28]==4'b0001) 
                        begin// lowest  will full HP
                          golden_err_msg = No_Err;
                          info_player1[23:16] <= 8'd119;
                          info_player1[59:56] <= info_player1[59:56] - 4'b0001;
                          flag_finAction <= 1;
                        end 
                end
              else if (info_player1[27:24]==4'b0100) //water 
                begin
                      if (info_player1[31:28]==4'b0100) 
                        begin// highest  will full HP
                          golden_err_msg = No_Err;
                          info_player1[23:16] <= 8'd245;
                          info_player1[59:56] <= info_player1[59:56] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else if (info_player1[31:28]==4'b0010) 
                        begin// middle  will full HP
                          golden_err_msg = No_Err;
                          info_player1[23:16] <= 8'd187;
                          info_player1[59:56] <= info_player1[59:56] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else if (info_player1[31:28]==4'b0001) 
                        begin// lowest  will full HP
                          golden_err_msg = No_Err;
                          info_player1[23:16] <= 8'd125;
                          info_player1[59:56] <= info_player1[59:56] - 4'b0001;
                          flag_finAction <= 1;
                        end 
                end
              else if (info_player1[27:24]==4'b1000) //electric 
                begin
                      if (info_player1[31:28]==4'b0100) 
                        begin// highest  will full HP
                          golden_err_msg = No_Err;
                          info_player1[23:16] <= 8'd235;
                          info_player1[59:56] <= info_player1[59:56] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else if (info_player1[31:28]==4'b0010) 
                        begin// middle  will full HP
                          golden_err_msg = No_Err;
                          info_player1[23:16] <= 8'd182;
                          info_player1[59:56] <= info_player1[59:56] - 4'b0001;
                          flag_finAction <= 1;
                        end
                      else if (info_player1[31:28]==4'b0001) 
                        begin// lowest  will full HP
                          golden_err_msg = No_Err;
                          info_player1[23:16] <= 8'd122;
                          info_player1[59:56] <= info_player1[59:56] - 4'b0001;
                          flag_finAction <= 1;
                        end 
                end
              else if (info_player1[27:24]==4'b0101) //normal 
                begin
                      golden_err_msg = No_Err;
                      info_player1[23:16] <= 8'd124;
                      info_player1[59:56] <= info_player1[59:56] - 4'b0001;
                      flag_finAction <= 1;   
                end           
            end
        end
      else if (item_temp == Candy)//---Candy EXP+'d15 ---------------------------- 
        begin
          if (info_player1[55:52]==4'b0) 
            begin
             golden_err_msg = Not_Having_Item;
             info_player1 <= info_player1;    
            end
          else 
            begin
              if (info_player1[27:24]==4'b0001) // Grass
                begin
                  if (info_player1[31:28]==4'b0001) // Lowest
                    begin
                      if (info_player1[7:0]>=8'h11) // pokemon evolve
                      begin
                        golden_err_msg = No_Err;
                        info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                        info_player1[31:28] <= 4'b0010;// stage up to Middle
                        info_player1[23:16] <= 8'd192; // HP reset 
                        info_player1[15:8]  <= 8'd94; //ATK reset
                        info_player1[7:0]   <= 8'b0;  //exp reset
                        flag_usedBracer <= 0;
                        flag_finAction <= 1;
                      end 
                      else 
                      begin
                        golden_err_msg = No_Err;
                        info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                        info_player1[7:0]   <= info_player1[7:0] + 8'h0F; //exp + 15
                        flag_usedBracer <= flag_usedBracer; 
                        flag_finAction <= 1;   
                      end
                    end
                  else if (info_player1[31:28]==4'b0010) // Middle
                    begin
                      if (info_player1[7:0]>=8'h30) // pokemon evolve
                        begin
                          golden_err_msg = No_Err;
                          info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                          info_player1[31:28] <= 4'b0100;// stage up to Highest
                          info_player1[23:16] <= 8'd254; // HP reset 
                          info_player1[15:8]  <= 8'd123; //ATK reset 
                          info_player1[7:0]   <= 8'b0;  //exp reset
                          flag_usedBracer <= 0;
                          flag_finAction <= 1;
                        end
                      else 
                        begin
                          golden_err_msg = No_Err;
                          info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                          info_player1[7:0]   <= info_player1[7:0] + 8'h0F; //exp + 15
                          flag_usedBracer <= flag_usedBracer;
                          flag_finAction <= 1;                             
                        end   
                    end
                  else if (info_player1[31:28]==4'b0100) // Highest
                    begin // only cost Candy but nothing change
                      golden_err_msg = No_Err;
                      info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                      flag_finAction <= 1; 
                    end
                end
              else if (info_player1[27:24]==4'b0010) // Fire
                begin
                  if (info_player1[31:28]==4'b0001) // Lowest
                    begin
                      if (info_player1[7:0]>=8'd15) // pokemon evolve
                        begin //39exp lv up
                          golden_err_msg = No_Err;
                          info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                          info_player1[31:28] <= 4'b0010;// stage up to Middle
                          info_player1[23:16] <= 8'd177; // HP reset 
                          info_player1[15:8]  <= 8'd96;  //ATK reset 
                          info_player1[7:0]   <= 8'b0;   //exp reset
                          flag_usedBracer <= 0;
                          flag_finAction <= 1;
                        end 
                      else 
                        begin
                          golden_err_msg = No_Err;
                          info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                          info_player1[7:0]   <= info_player1[7:0] + 8'h0F; //exp + 15
                          flag_usedBracer <= flag_usedBracer;
                          flag_finAction <= 1;    
                        end
                    end
                  else if (info_player1[31:28]==4'b0010) // Middle
                    begin
                     if (info_player1[7:0]>=8'd44) // pokemon evolve
                      begin // 59exp lv up
                        golden_err_msg = No_Err;
                        info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                        info_player1[31:28] <= 4'b0100;// stage up to Highest
                        info_player1[23:16] <= 8'd225;// HP reset 
                        info_player1[15:8]  <= 8'd127;//ATK reset
                        info_player1[7:0]   <= 8'b0;  //exp reset
                        flag_usedBracer <= 0;
                        flag_finAction <= 1;
                      end
                     else 
                      begin
                        golden_err_msg = No_Err;
                        info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                        info_player1[7:0]   <= info_player1[7:0] + 8'h0F; //exp + 15
                        flag_usedBracer <= flag_usedBracer;
                        flag_finAction <= 1;                             
                      end   
                    end
                  else if (info_player1[31:28]==4'b0100) // Highest
                    begin // only cost Candy but nothing change
                      golden_err_msg = No_Err;
                      info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                      flag_finAction <= 1; 
                    end
                end
              else if (info_player1[27:24]==4'b0100) // Water
                begin
                  if (info_player1[31:28]==4'b0001) // Lowest
                    begin
                      if (info_player1[7:0]>=8'd13) // pokemon evolve
                        begin // exp28 lv up
                          golden_err_msg = No_Err;
                          info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                          info_player1[31:28] <= 4'b0010;// stage up to Middle
                          info_player1[23:16] <= 8'd187; // HP reset 
                          info_player1[15:8]  <= 8'd89; //ATK reset  
                          info_player1[7:0]   <= 8'b0;  //exp reset
                          flag_usedBracer <= 0;
                          flag_finAction <= 1;
                        end 
                      else 
                        begin
                          golden_err_msg = No_Err;
                          info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                          info_player1[7:0]   <= info_player1[7:0] + 8'h0F; //exp + 15
                          flag_usedBracer <= flag_usedBracer;
                          flag_finAction <= 1;    
                        end
                    end
                  else if (info_player1[31:28]==4'b0010) // Middle
                    begin
                     if (info_player1[7:0]>=8'd40) // pokemon evolve
                      begin //exp55 lv up
                        golden_err_msg = No_Err;
                        info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                        info_player1[31:28] <= 4'b0100;// stage up to Highest
                        info_player1[23:16] <= 8'd245; // HP reset
                        info_player1[15:8]  <= 8'd113; //ATK reset
                        info_player1[7:0]   <= 8'b0;  //exp reset
                        flag_usedBracer <= 0;
                        flag_finAction <= 1;
                      end
                     else 
                      begin
                        golden_err_msg = No_Err;
                        info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                        info_player1[7:0]   <= info_player1[7:0] + 8'h0F; //exp + 15
                        flag_usedBracer <= flag_usedBracer;
                        flag_finAction <= 1;                             
                      end   
                    end
                  else if (info_player1[31:28]==4'b0100) // Highest
                    begin // only cost Candy but nothing change
                      golden_err_msg = No_Err;
                      info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                      flag_finAction <= 1; 
                    end
                end
              else if (info_player1[27:24]==4'b1000) // Electric
                begin
                  if (info_player1[31:28]==4'b0001) // Lowest
                    begin
                      if (info_player1[7:0]>=8'd11) // pokemon evolve
                      begin //exp26 lv up
                        golden_err_msg = No_Err;
                        info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                        info_player1[31:28] <= 4'b0010;// stage up to Middle
                        info_player1[23:16] <= 8'd182; // HP reset 
                        info_player1[15:8]  <= 8'd97; //ATK reset '
                        info_player1[7:0]   <= 8'b0;  //exp reset
                        flag_usedBracer <= 0;
                        flag_finAction <= 1;
                      end 
                      else 
                      begin
                        golden_err_msg = No_Err;
                        info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                        info_player1[7:0]   <= info_player1[7:0] + 8'd15; //exp + 15
                        flag_usedBracer <= flag_usedBracer;
                        flag_finAction <= 1;    
                      end
                    end
                  else if (info_player1[31:28]==4'b0010) // Middle
                    begin
                     if (info_player1[7:0]>=8'd36) // pokemon evolve
                      begin // exp51 lv up
                        golden_err_msg = No_Err;
                        info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                        info_player1[31:28] <= 4'b0100;// stage up to Highest
                        info_player1[23:16] <= 8'd235; // HP reset
                        info_player1[15:8]  <= 8'd124; //ATK reset
                        info_player1[7:0]   <= 8'b0;  //exp reset
                        flag_usedBracer <= 0;
                        flag_finAction <= 1;
                      end
                     else 
                      begin
                        golden_err_msg = No_Err;
                        info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                        info_player1[7:0]   <= info_player1[7:0] + 8'h0F; //exp + 15
                        flag_usedBracer <= flag_usedBracer;
                        flag_finAction <= 1;                             
                      end   
                    end
                  else if (info_player1[31:28]==4'b0100) // Highest
                    begin // only cost Candy but nothing change
                      golden_err_msg = No_Err;
                      info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                      flag_finAction <= 1; 
                    end
                end
              else if (info_player1[27:24]==4'b0101) // Normal
                  begin
                    if (info_player1[7:0]>=8'd14) // exp will fixed in high exp
                    begin //fix in 29
                      info_player1[7:0] <= 8'd29;
                      golden_err_msg = No_Err;
                      info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                      flag_finAction <= 1; 
                    end
                    else 
                    begin
                      info_player1[7:0] <=  info_player1[7:0] + 8'h0F;
                      golden_err_msg = No_Err;
                      info_player1[55:52] <= info_player1[55:52] - 4'b0001;
                      flag_finAction <= 1;  
                    end
                  end    
            end
        end  
      else if (item_temp== Bracer)//---Bracer--------------------------------  
        begin
          if (info_player1[51:48]==4'b0) 
            begin
              golden_err_msg = Not_Having_Item;
              info_player1 <= info_player1;
              flag_finAction <= 1;    
            end
           else 
            begin
              if (flag_usedBracer) // the effect can't stack 
                begin
                  golden_err_msg = No_Err;
                  info_player1[51:48] <= info_player1[51:48] - 4'b0001;
                  flag_finAction <= 1; 
                end
              else
                begin
                  golden_err_msg = No_Err;
                  info_player1[51:48] <= info_player1[51:48] - 4'b0001;
                  info_player1[15:8]  <= info_player1[15:8]  + 8'd32;
                  flag_usedBracer <= 1;
                  flag_finAction <= 1; 
                end
            end
        end
      else if (item_temp == Water_stone) //---Water Stone-------------------------------
        begin
          if (info_player1[47:46]!=2'b01) // you don't have water stone
            begin
              golden_err_msg = Not_Having_Item;
              info_player1 <= info_player1;
              flag_finAction <= 1;    
            end
          else 
            begin
              if (info_player1[27:24]==4'b0101) // you have Eevee
                begin
                  if (info_player1[7:0]==8'd29)  // enough EXP
                    begin
                      info_player1[47:46] <= 2'b0;    // stone bec. empty
                      info_player1[31:28] <= 4'b0100; // stage up to Highest
                      info_player1[27:24] <= 4'b0100; // become water Eevee
                      info_player1[23:16] <= 8'd245;   // HP reset
                      info_player1[15:8]  <= 8'd113;   //ATK reset
                      info_player1[7:0]   <= 8'b0;    //exp reset
                      flag_usedBracer <= 0;
                      golden_err_msg = No_Err;
                      flag_finAction <= 1;                        
                    end
                  else // u don't have enough EXP but still cost stone
                    begin
                      info_player1[47:46] <= 2'b0;
                      golden_err_msg = No_Err;
                      flag_finAction <= 1;  
                    end
                end
              else // yout don't have Eevee
                begin
                  info_player1[47:46] <= 2'b00;
                  golden_err_msg = No_Err;
                  flag_finAction <= 1;   
                end   
            end 
        end
      else if (item_temp == Fire_stone)//---Fire Stone-------------------------------
        begin
            if (info_player1[47:46]!=2'b10) // you don't have fire stone
              begin
                golden_err_msg = Not_Having_Item;
                info_player1 <= info_player1;
                flag_finAction <= 1;    
              end
            else 
              begin
                if (info_player1[27:24]==4'b0101) // you have Eevee
                  begin
                    if (info_player1[7:0]==8'h1D) // enough EXP
                      begin
                        info_player1[47:46] <= 2'b0; // stone bec. empty
                        info_player1[31:28] <= 4'b0100; // stage up to Highest
                        info_player1[27:24] <= 4'b0010; // become Fire Eevee
                        info_player1[23:16] <= 8'd225;  // HP reset 
                        info_player1[15:8]  <= 8'd127;  //ATK reset 
                        info_player1[7:0]   <= 8'b0;    //exp reset
                        flag_usedBracer <= 0;
                        golden_err_msg = No_Err;
                        flag_finAction <= 1;                        
                      end
                    else // u don't have enough EXP but still cost stone
                      begin
                        info_player1[47:46] <= 2'b0;
                        golden_err_msg = No_Err;
                        flag_finAction <= 1;  
                      end
                  end
                else // yout don't have Eevee
                  begin
                     info_player1[47:46] <= 2'b0;
                     golden_err_msg = No_Err;
                     flag_finAction <= 1;   
                  end   
              end 
        end
      else if (item_temp == Thunder_stone) //---Thunder Stone--------------------------
        begin
          if (info_player1[47:46]!=2'b11) // you don't have thunder stone
            begin
              golden_err_msg = Not_Having_Item;
              info_player1 <= info_player1;
              flag_finAction <= 1;    
            end
          else 
            begin
              if (info_player1[27:24]==4'b0101) // you have Eevee
                begin
                  if (info_player1[7:0]==8'd29) // enough EXP
                    begin
                      info_player1[47:46] <= 2'b00; // stone bec. empty
                      info_player1[31:28] <= 4'b0100; // stage up to Highest
                      info_player1[27:24] <= 4'b1000; // become Thunder Eevee   
                      info_player1[23:16] <= 8'd235;   // HP reset
                      info_player1[15:8]  <= 8'd124;   //ATK reset
                      info_player1[7:0]   <= 8'b0;    //exp reset
                      flag_usedBracer <= 0;
                      golden_err_msg = No_Err;
                      flag_finAction <= 1;                        
                    end
                  else // u don't have enough EXP but still cost stone
                    begin
                      info_player1[47:46] <= 2'b00;
                      golden_err_msg = No_Err;
                      flag_finAction <= 1;  
                    end
                end
              else // yout don't have Eevee
                begin
                   info_player1[47:46] <= 2'b00;
                   golden_err_msg = No_Err;
                   flag_finAction <= 1;   
                end   
            end 
        end
    end
  end
endtask

task useitem_err;
  begin
    if(golden_err_msg!=0)
      begin
        flag_finAction = 0;
        golden_info = 0;
        golden_complete = 0;
      end
    else if(golden_err_msg==0)
      begin
        golden_info = info_player1;
        golden_complete = 1;
        flag_finAction = 0;
      end
  end  
endtask

//---attack------------------------
task attack_err;
  begin
    if(golden_err_msg!=0)
      begin
        flag_fin_attack = 0;
        flag_finAction = 0;
        golden_info = 0;
        golden_complete = 0;
      end
    else if(golden_err_msg==0)
      begin
        golden_info[63:32] = info_player1[31:0];
        golden_info[31:0]  = info_player2[31:0];
        golden_complete = 1;
        flag_fin_attack = 0;
        flag_usedBracer = 0;
        flag_finAction = 0;
      end
  end  
endtask

task cal_attack_player1;
  begin          
        if (info_player1[31:0]== 0 || info_player2[31:0]== 0) // someone doesn't have pokemon
          begin
            golden_err_msg = Not_Having_PKM;
            flag_finAction <= 1; 
          end
        else if (info_player1[23:16]==8'b0 || info_player2[23:16]==8'b0) // pokemon HP is 0
          begin 
            golden_err_msg = HP_is_Zero;
            flag_finAction <= 1;  
          end   
        else // start attack
          begin
            if (info_player1[31:28]==4'b0100) // attacker is highest so don't change anything
              begin
                if (flag_usedBracer) 
                  begin
                    info_player1[15:8] <= info_player1[15:8] - 'd32;
                    flag_usedBracer <= 0;
                    flag_finAction <= 1; 
                  end
                else
                  begin 
                    info_player1 <= info_player1;
                    flag_finAction <= 1; 
                  end
              end
            else if (info_player1[31:28]==4'b0010)// attacker is middle
              begin
                if (info_player2[31:28]==4'b0001) // opponent is lowest Att. will gain 16exp
                 begin
                  if (info_player1[27:24]==4'b0001 && info_player1[7:0]>=8'd47) 
                    begin// Att. is grass &'d63 can evolve 
                       golden_err_msg = No_Err;
                       info_player1[31:28] <= 4'b0100; // stage up to Highest
                       info_player1[23:16] <= 8'd254; // HP reset
                       info_player1[15:8]  <= 8'd123; //ATK reset
                       info_player1[7:0]   <= 8'b0;  //exp reset
                       flag_usedBracer <= 0;
                       flag_finAction <= 1;       
                    end 
                  else if (info_player1[27:24]==4'b0010 && info_player1[7:0]>=8'd43) 
                    begin // Att. is fire 'd59 can evolve
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0100;// stage up to Highest
                      info_player1[23:16] <= 8'd225; // HP reset 
                      info_player1[15:8]  <= 8'd127; //ATK reset 
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;                 
                    end
                  else if (info_player1[27:24]==4'b0100 && info_player1[7:0]>=8'd39)
                    begin // Att. is watter 'd55 can evolve
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0100;// stage up to Highest
                      info_player1[23:16] <= 8'd245; // HP reset
                      info_player1[15:8]  <= 8'd113; //ATK reset
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;           
                    end
                  else if (info_player1[27:24]==4'b1000 && info_player1[7:0]>=8'd35) 
                    begin // Att. is electric 'd51 can evolve
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0100;// stage up to Highest
                      info_player1[23:16] <= 8'd235; // HP reset 
                      info_player1[15:8]  <= 8'd124; //ATK reset 
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;              
                    end              
                  else
                    begin // can't evolve
                      if (flag_usedBracer) 
                        begin
                          golden_err_msg = No_Err;
                          info_player1[15:8]  <= info_player1[15:8] - 8'd32; //ATK - 32
                          info_player1[7:0]   <= info_player1[7:0]  + 8'd16;  //exp + 16
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                      else 
                        begin
                          golden_err_msg = No_Err;
                          info_player1[7:0]   <= info_player1[7:0]  + 8'd16;  //exp + 16
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                    end
                 end  
                else if (info_player2[31:28]==4'b0010) // opponent is middle Att. will gain 24exp
                 begin
                   if (info_player1[27:24]==4'b0001 && info_player1[7:0]>=8'd39) 
                    begin// Att. is grass &'d63 can evolve 
                       golden_err_msg = No_Err;
                       info_player1[31:28] <= 4'b0100; // stage up to Highest
                       info_player1[23:16] <= 8'd254; // HP reset
                       info_player1[15:8]  <= 8'd123; //ATK reset
                       info_player1[7:0]   <= 8'b0;  //exp reset
                       flag_usedBracer <= 0;
                       flag_finAction <= 1;       
                    end 
                  else if (info_player1[27:24]==4'b0010 && info_player1[7:0]>=8'd35) 
                    begin // Att. is fire 'd59 can evolve
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0100;// stage up to Highest
                      info_player1[23:16] <= 8'd225; // HP reset 
                      info_player1[15:8]  <= 8'd127; //ATK reset 
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;                 
                    end
                  else if (info_player1[27:24]==4'b0100 && info_player1[7:0]>=8'd31)
                    begin // Att. is watter 'd55 can evolve
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0100;// stage up to Highest
                      info_player1[23:16] <= 8'd245; // HP reset  
                      info_player1[15:8]  <= 8'd113; //ATK reset 
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;           
                    end
                  else if (info_player1[27:24]==4'b1000 && info_player1[7:0]>=8'd27) 
                    begin // Att. is electric 'd51 can evolve
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0100;// stage up to Highest
                      info_player1[23:16] <= 8'd235; // HP reset 
                      info_player1[15:8]  <= 8'd124; //ATK reset 
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;              
                    end              
                  else
                    begin // can't evolve
                      if (flag_usedBracer) 
                        begin
                          golden_err_msg = No_Err;
                          info_player1[15:8]  <= info_player1[15:8] - 8'd32; //ATK - 32
                          info_player1[7:0]   <= info_player1[7:0]  + 8'd24;  //exp + 24
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                      else 
                        begin
                          golden_err_msg = No_Err;
                          info_player1[7:0]   <= info_player1[7:0]  + 8'd24;  //exp + 24
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                    end
                 end
                else if (info_player2[31:28]==4'b0100) // opponent is highest Att. will gain 32exp
                 begin
                  if (info_player1[27:24]==4'b0001 && info_player1[7:0]>=8'd31) 
                    begin// Att. is grass &'d63 can evolve 
                       golden_err_msg = No_Err;
                       info_player1[31:28] <= 4'b0100; // stage up to Highest
                       info_player1[23:16] <= 8'd254; // HP reset 
                       info_player1[15:8]  <= 8'd123; //ATK reset 
                       info_player1[7:0]   <= 8'b0;  //exp reset
                       flag_usedBracer <= 0;
                       flag_finAction <= 1;       
                    end 
                  else if (info_player1[27:24]==4'b0010 && info_player1[7:0]>=8'd27) 
                    begin // Att. is fire 'd59 can evolve
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0100;// stage up to Highest
                      info_player1[23:16] <= 8'd225; // HP reset 
                      info_player1[15:8]  <= 8'd127; //ATK reset 
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;                 
                    end
                  else if (info_player1[27:24]==4'b0100 && info_player1[7:0]>=8'd23)
                    begin // Att. is watter 'd55 can evolve
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0100;// stage up to Highest
                      info_player1[23:16] <= 8'd245; // HP reset  
                      info_player1[15:8]  <= 8'd113; //ATK reset 
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;           
                    end
                  else if (info_player1[27:24]==4'b1000 && info_player1[7:0]>=8'd19) 
                    begin // Att. is electric 'd51 can evolve
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0100;// stage up to Highest
                      info_player1[23:16] <= 8'd235; // HP reset
                      info_player1[15:8]  <= 8'd124; //ATK reset
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;              
                    end              
                  else
                    begin // can't evolve
                      if (flag_usedBracer) 
                        begin
                          golden_err_msg = No_Err;
                          info_player1[15:8]  <= info_player1[15:8] - 8'd32; //ATK - 32
                          info_player1[7:0]   <= info_player1[7:0]  + 8'd32;  //exp + 32
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                      else 
                        begin
                          golden_err_msg = No_Err;
                          info_player1[7:0]   <= info_player1[7:0]  + 8'd32;  //exp + 32
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                    end
                 end
              end 
            else if (info_player1[31:28]==4'b0001) // attaker is lowest
              begin
                if (info_player2[31:28]==4'b0001) // opponent is lowest Att. will gain 16exp
                 begin
                  if (info_player1[27:24]==4'b0001 && info_player1[7:0]>=8'd16) 
                    begin// Att. is grass &'d32 can evolve 
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0010;// stage up to Middle
                      info_player1[23:16] <= 8'd192; // HP reset
                      info_player1[15:8]  <= 8'd94; //ATK reset 
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;      
                    end 
                  else if (info_player1[27:24]==4'b0010 && info_player1[7:0]>=8'd14) 
                    begin // Att. is fire 'd30 can evolve
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0010;// stage up to Middle
                      info_player1[23:16] <= 8'd177; // HP reset 
                      info_player1[15:8]  <= 8'd96; //ATK reset 
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;                
                    end
                  else if (info_player1[27:24]==4'b0100 && info_player1[7:0]>=8'd12)
                    begin // Att. is watter 'd28 can evolve
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0010;// stage up to Middle
                      info_player1[23:16] <= 8'd187; // HP reset 
                      info_player1[15:8]  <= 8'd89; //ATK reset  
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;         
                    end
                  else if (info_player1[27:24]==4'b1000 && info_player1[7:0]>=8'd10) 
                    begin // Att. is electric 'd26 can evolve
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0010;// stage up to Middle
                      info_player1[23:16] <= 8'd182; // HP reset 
                      info_player1[15:8]  <= 8'd97; //ATK reset 
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;           
                    end
                  else if (info_player1[27:24]==4'b0101 && info_player1[7:0]>=8'd13) 
                    begin // Att. is Normal will fix at 'd29
                    if (flag_usedBracer) 
                      begin
                        info_player1[15:8]  <= info_player1[15:8] - 8'd32; //ATK - 32
                        info_player1[7:0] <= 8'h1D;
                        golden_err_msg = No_Err;
                        flag_finAction <= 1;
                        flag_usedBracer <= 0;
                      end
                    else 
                      begin
                        info_player1[7:0] <= 8'h1D;
                        golden_err_msg = No_Err;
                        flag_finAction <= 1; 
                      end   
                    end                    
                  else
                    begin // can't evolve
                      if (flag_usedBracer) 
                        begin
                          golden_err_msg = No_Err;
                          info_player1[15:8]  <= info_player1[15:8] - 8'd32; //ATK - 32
                          info_player1[7:0]   <= info_player1[7:0]  + 8'd16;  //exp + 16
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                      else 
                        begin
                          golden_err_msg = No_Err;
                          info_player1[7:0]   <= info_player1[7:0]  + 8'd16;  //exp + 16
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                    end
                 end 
                else if (info_player2[31:28]==4'b0010) // opponent is middle Att. will gain 24exp
                 begin
                   if (info_player1[27:24]==4'b0001 && info_player1[7:0]>=8'd8) 
                    begin// Att. is grass &'d32 can evolve 
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0010;// stage up to Middle
                      info_player1[23:16] <= 8'd192; // HP reset
                      info_player1[15:8]  <= 8'd94;  //ATK reset 
                      info_player1[7:0]   <= 8'b0;   //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;      
                    end 
                  else if (info_player1[27:24]==4'b0010 && info_player1[7:0]>=8'd6) 
                    begin // Att. is fire 'd30 can evolve
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0010;// stage up to Middle
                      info_player1[23:16] <= 8'd177; // HP reset  
                      info_player1[15:8]  <= 8'd96 ; //ATK reset 
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;                
                    end
                  else if (info_player1[27:24]==4'b0100 && info_player1[7:0]>=8'd4)
                    begin // Att. is watter 'd28 can evolve
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0010;// stage up to Middle
                      info_player1[23:16] <= 8'd187; // HP reset 
                      info_player1[15:8]  <= 8'd89; //ATK reset  
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;         
                    end
                  else if (info_player1[27:24]==4'b1000 && info_player1[7:0]>=8'd2) 
                    begin // Att. is electric 'd26 can evolve
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0010;// stage up to Middle
                      info_player1[23:16] <= 8'd182; // HP reset 
                      info_player1[15:8]  <= 8'd97 ; //ATK reset
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;           
                    end
                  else if (info_player1[27:24]==4'b0101 && info_player1[7:0]>=8'd5) 
                    begin // Att. is Normal will fix at 'd29
                      if (flag_usedBracer) 
                        begin
                          info_player1[15:8]  <= info_player1[15:8] - 8'd32; //ATK - 32
                          info_player1[7:0] <= 8'h1D;
                          golden_err_msg = No_Err;
                          flag_finAction <= 1;
                          flag_usedBracer <= 0;
                        end
                      else 
                        begin
                          info_player1[7:0] <= 8'h1D;
                          golden_err_msg = No_Err;
                          flag_finAction <= 1; 
                        end   
                    end                    
                  else
                    begin // can't evolve
                      if (flag_usedBracer) 
                        begin
                          golden_err_msg = No_Err;
                          info_player1[15:8]  <= info_player1[15:8] - 8'd32; //ATK - 32
                          info_player1[7:0]   <= info_player1[7:0]  + 8'd24;  //exp + 24
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                      else 
                        begin
                          golden_err_msg = No_Err;
                          info_player1[7:0]   <= info_player1[7:0]  + 8'd24;  //exp + 24
                          flag_usedBracer <= 0;
                          flag_finAction <= 1; 
                        end
                    end
                 end
                else if (info_player2[31:28]==4'b0100) // opponent is highest Att. will gain 32exp
                 begin
                   if (info_player1[27:24]==4'b0001) 
                    begin// Att. is grass &'d32 can evolve 
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0010;// stage up to Middle
                      info_player1[23:16] <= 8'd192; // HP reset
                      info_player1[15:8]  <= 8'd94; //ATK reset 
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;      
                    end 
                  else if (info_player1[27:24]==4'b0010) 
                    begin // Att. is fire 'd30 can evolve
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0010;// stage up to Middle
                      info_player1[23:16] <= 8'd177; // HP reset
                      info_player1[15:8]  <= 8'd96; //ATK reset 
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;                
                    end
                  else if (info_player1[27:24]==4'b0100)
                    begin // Att. is watter 'd28 can evolve
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0010;// stage up to Middle
                      info_player1[23:16] <= 8'd187; // HP reset
                      info_player1[15:8]  <= 8'd89; //ATK reset 
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;         
                    end
                  else if (info_player1[27:24]==4'b1000) 
                    begin // Att. is electric 'd26 can evolve
                      golden_err_msg = No_Err;
                      info_player1[31:28] <= 4'b0010;// stage up to Middle
                      info_player1[23:16] <= 8'd182; // HP reset 
                      info_player1[15:8]  <= 8'd97; //ATK reset  
                      info_player1[7:0]   <= 8'b0;  //exp reset
                      flag_usedBracer <= 0;
                      flag_finAction <= 1;           
                    end
                  else if (info_player1[27:24]==4'b0101) 
                    begin // Att. is Normal will fix at 'd29
                      if (flag_usedBracer) 
                        begin
                          info_player1[15:8]  <= info_player1[15:8] - 8'd32; //ATK - 32
                          info_player1[7:0] <= 8'h1D;
                          golden_err_msg = No_Err;
                          flag_finAction <= 1;
                          flag_usedBracer <= 0;
                        end
                      else 
                        begin
                          info_player1[7:0] <= 8'h1D;
                          golden_err_msg = No_Err;
                          flag_finAction <= 1; 
                        end   
                    end                    
                 end 
              end
          end
  end
endtask

task  cal_attack_player2;
  begin
  if (info_player1[23:16]==0||info_player2[23:16]==0) 
        begin
          flag_fin_attack <= 1;
        end
      else if (info_player2[31:28]==4'b0001) // def. is lowest
        begin
          if (info_player2[27:24]==4'b0001) //def. is grass
            begin
              if (info_player1[31:28]==4'b0001)      //att. is lowest  exp +8
                begin
                  if (info_player2[7:0]>=8'd24) //def. Lv. up
                    begin
                      info_player2[31:28] <= 4'b0010;// stage up to Middle
                      info_player2[23:16] <= 8'd192;  // HP reset
                      info_player2[15:8]  <= 8'd94;  //ATK reset 
                      info_player2[7:0]   <= 8'b0;   //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0100||info_player1[27:24]==4'b1000) 
                    begin //att. is grass or water or electric
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (info_player1[27:24]==4'b0010) 
                    begin // att. is fire
                      if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (info_player1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end     
                end
              else if (info_player1[31:28]==4'b0010) //att. is middle  exp +12
                begin
                  if (info_player2[7:0]>=8'd20) //def. Lv. up
                    begin
                      info_player2[31:28] <= 4'b0010;// stage up to Middle
                      info_player2[23:16] <= 8'hC0;  // HP reset 'd192 = 'hC0 
                      info_player2[15:8]  <= 8'h5E;  //ATK reset 'd94  = 'h5E
                      info_player2[7:0]   <= 8'b0;   //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0100||info_player1[27:24]==4'b1000) 
                    begin //att. is grass or water or electric
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (info_player1[27:24]==4'b0010) 
                    begin // att. is fire
                      if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (info_player1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end       
                end
              else if (info_player1[31:28]==4'b0100) //att. is highest  exp +16
                begin
                  if (info_player2[7:0]>=8'd16) //def. Lv. up
                    begin
                      info_player2[31:28] <= 4'b0010;// stage up to Middle
                      info_player2[23:16] <= 8'hC0;  // HP reset 'd192 = 'hC0 
                      info_player2[15:8]  <= 8'h5E;  //ATK reset 'd94  = 'h5E
                      info_player2[7:0]   <= 8'b0;   //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0100||info_player1[27:24]==4'b1000) 
                    begin //att. is grass or water or electric
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (info_player1[27:24]==4'b0010) 
                    begin // att. is fire
                      if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (info_player1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end       
                end    
            end
          else if (info_player2[27:24]==4'b0010) //def. is fire
            begin
              if (info_player1[31:28]==4'b0001)      //att. is lowest  exp +8
                begin
                  if (info_player2[7:0]>=8'd22) //def. Lv. up (30-8=22)
                    begin
                      info_player2[31:28] <= 4'b0010;// stage up to Middle
                      info_player2[23:16] <= 8'hB1; // HP reset 'd177 = 'hB1 
                      info_player2[15:8]  <= 8'h60; //ATK reset 'd96  = 'h60
                      info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0010) 
                    begin //att. is grass or fire
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (info_player1[27:24]==4'b0100) 
                    begin // att. is water
                      if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (info_player1[27:24]==4'b0101||info_player1[27:24]==4'b1000) 
                    begin // att. is normal or electric
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end   
                end
              else if (info_player1[31:28]==4'b0010) //att. is middle  exp +12  
                begin
                  if (info_player2[7:0]>=8'd18) //def. Lv. up (30-12=18)
                    begin
                      info_player2[31:28] <= 4'b0010;// stage up to Middle
                      info_player2[23:16] <= 8'hB1; // HP reset 'd177 = 'hB1 
                      info_player2[15:8]  <= 8'h60; //ATK reset 'd96  = 'h60
                      info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0010) 
                    begin //att. is grass or fire
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (info_player1[27:24]==4'b0100) 
                    begin // att. is water
                      if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (info_player1[27:24]==4'b0101||info_player1[27:24]==4'b1000) 
                    begin // att. is normal or electric
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end   
                end
              else if (info_player1[31:28]==4'b0100) //att. is highest  exp +16   
                begin
                  if (info_player2[7:0]>=8'd14) //def. Lv. up (30-16=14)
                    begin
                      info_player2[31:28] <= 4'b0010;// stage up to Middle
                      info_player2[23:16] <= 8'hB1; // HP reset 'd177 = 'hB1 
                      info_player2[15:8]  <= 8'h60; //ATK reset 'd96  = 'h60
                      info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0010) 
                    begin //att. is grass or fire
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (info_player1[27:24]==4'b0100) 
                    begin // att. is water
                      if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (info_player1[27:24]==4'b0101||info_player1[27:24]==4'b1000) 
                    begin // att. is normal or electric
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end   
                end
            end  
          else if (info_player2[27:24]==4'b0100) //def. is water
            begin
              if (info_player1[31:28]==4'b0001)      //att. is lowest  exp +8
                begin
                  if (info_player2[7:0]>=8'd20) //def. Lv. up (28-8=20)
                    begin
                      info_player2[31:28] <= 4'b0010;// stage up to Middle
                      info_player2[23:16] <= 8'hBB; // HP reset 'd187 = 'hBB 
                      info_player2[15:8]  <= 8'h59; //ATK reset 'd89  = 'h59
                      info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b0010||info_player1[27:24]==4'b0100) 
                    begin //att. is fire or water
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b1000) 
                    begin // att. is grass or electric
                      if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (info_player1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end    
                end
              else if (info_player1[31:28]==4'b0010) //att. is middle  exp +12 
                begin
                  if (info_player2[7:0]>=8'd16) //def. Lv. up (28-12=16)
                    begin
                      info_player2[31:28] <= 4'b0010;// stage up to Middle
                      info_player2[23:16] <= 8'hBB; // HP reset 'd187 = 'hBB 
                      info_player2[15:8]  <= 8'h59; //ATK reset 'd89  = 'h59
                      info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b0010||info_player1[27:24]==4'b0100) 
                    begin //att. is fire or water
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b1000) 
                    begin // att. is grass or electric
                      if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (info_player1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end    
                end
              else if (info_player1[31:28]==4'b0100) //att. is highest  exp +16      
                begin
                  if (info_player2[7:0]>=8'd12) //def. Lv. up (28-16=12)
                    begin
                      info_player2[31:28] <= 4'b0010;// stage up to Middle
                      info_player2[23:16] <= 8'hBB; // HP reset 'd187 = 'hBB 
                      info_player2[15:8]  <= 8'h59; //ATK reset 'd89  = 'h59
                      info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b0010||info_player1[27:24]==4'b0100) 
                    begin //att. is fire or water
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b1000) 
                    begin // att. is grass or electric
                      if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (info_player1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end    
                end
            end
          else if (info_player2[27:24]==4'b1000) //def. is electric
            begin
              if (info_player1[31:28]==4'b0001)      //att. is lowest  exp +8
                begin
                  if (info_player2[7:0]>=8'd18) //def. Lv. up (26-8=18)
                    begin
                     info_player2[31:28] <= 4'b0010;// stage up to Middle
                     info_player2[23:16] <= 8'hB6; // HP reset 'd182 = 'hB6 
                     info_player2[15:8]  <= 8'h61; //ATK reset 'd97  = 'h61
                     info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b1000) 
                    begin //att. is electric
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end   
                  else if (info_player1[27:24]==4'b0101||info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0010||info_player1[27:24]==4'b0100) 
                    begin // att. is normal , grass , fire , water
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end     
                end
              else if (info_player1[31:28]==4'b0010) //att. is middle  exp +12 
                begin
                  if (info_player2[7:0]>=8'd14) //def. Lv. up (26-12=14)
                    begin
                     info_player2[31:28] <= 4'b0010;// stage up to Middle
                     info_player2[23:16] <= 8'hB6; // HP reset 'd182 = 'hB6 
                     info_player2[15:8]  <= 8'h61; //ATK reset 'd97  = 'h61
                     info_player2[7:0]   <= 8'b0;  //exp reset
                     flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b1000) 
                    begin //att. is electric
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end   
                  else if (info_player1[27:24]==4'b0101||info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0010||info_player1[27:24]==4'b0100) 
                    begin // att. is normal , grass , fire , water
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end     
                end  
              else if (info_player1[31:28]==4'b0100) //att. is highest  exp +16      
                begin
                  if (info_player2[7:0]>=8'd10) //def. Lv. up (26-16=10)
                    begin
                     info_player2[31:28] <= 4'b0010;// stage up to Middle
                     info_player2[23:16] <= 8'hB6; // HP reset 'd182 = 'hB6 
                     info_player2[15:8]  <= 8'h61; //ATK reset 'd97  = 'h61
                     info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b1000) 
                    begin //att. is electric
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end   
                  else if (info_player1[27:24]==4'b0101||info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0010||info_player1[27:24]==4'b0100) 
                    begin // att. is normal , grass , fire , water
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end     
                end 
            end
          else if (info_player2[27:24]==4'b0101) //def. is normal
            begin
              if (info_player1[31:28]==4'b0001)    //att. is lowest  exp +8
                begin
                  if (info_player2[7:0]>=8'd21) //def. the limit 29
                    begin
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= 8'd29; 
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= 8'd29; 
                          flag_fin_attack <= 1;
                        end   
                    end 
                  else  
                    begin 
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end 
                end
              else if (info_player1[31:28]==4'b0010) //att. is middle  exp +12
                begin
                  if (info_player2[7:0]>=8'd17) //def. the limit 29
                    begin
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= 8'd29; 
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= 8'd29; 
                          flag_fin_attack <= 1;
                        end   
                    end 
                  else  
                    begin 
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end 
                end
              else if (info_player1[31:28]==4'b0100) //att. is highest  exp +16
                begin
                  if (info_player2[7:0]>=8'd13) //def. the limit 29
                    begin
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= 8'd29; 
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= 8'd29; 
                          flag_fin_attack <= 1;
                        end   
                    end 
                  else  
                    begin 
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end 
                end
            end
        end
      else if (info_player2[31:28]==4'b0010) // def. is middle
        begin
          if (info_player2[27:24]==4'b0001)      //def. is grass
            begin
              if (info_player1[31:28]==4'b0001)      //att. is lowest  exp +8
                begin
                  if (info_player2[7:0]>=8'd55) //def. Lv. up (lv63 midd->high)
                    begin
                      info_player2[31:28] <= 4'b0100;// stage up to Highest
                      info_player2[23:16] <= 8'hFE; // HP reset 'd254 = 'hFE 
                      info_player2[15:8]  <= 8'h7B; //ATK reset 'd123 = 'h7B
                      info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0100||info_player1[27:24]==4'b1000) 
                    begin //att. is grass or water or electric
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (info_player1[27:24]==4'b0010) 
                    begin // att. is fire
                      if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (info_player1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
              else if (info_player1[31:28]==4'b0010) //att. is middle  exp +12
                begin
                  if (info_player2[7:0]>=8'd51) //def. Lv. up (lv63 midd->high)
                    begin
                      info_player2[31:28] <= 4'b0100;// stage up to Highest
                      info_player2[23:16] <= 8'hFE; // HP reset 'd254 = 'hFE 
                      info_player2[15:8]  <= 8'h7B; //ATK reset 'd123 = 'h7B
                      info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0100||info_player1[27:24]==4'b1000) 
                    begin //att. is grass or water or electric
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (info_player1[27:24]==4'b0010) 
                    begin // att. is fire
                      if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (info_player1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
              else if (info_player1[31:28]==4'b0100) //att. is highest  exp +16
                begin
                  if (info_player2[7:0]>=8'd47) //def. Lv. up (lv63 midd->high)
                    begin
                      info_player2[31:28] <= 4'b0100;// stage up to Highest
                      info_player2[23:16] <= 8'hFE; // HP reset 'd254 = 'hFE 
                      info_player2[15:8]  <= 8'h7B; //ATK reset 'd123 = 'h7B
                      info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0100||info_player1[27:24]==4'b1000) 
                    begin //att. is grass or water or electric
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (info_player1[27:24]==4'b0010) 
                    begin // att. is fire
                      if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (info_player1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end        
                end     
            end
          else if (info_player2[27:24]==4'b0010) //def. is fire
            begin
              if (info_player1[31:28]==4'b0001)      //att. is lowest  exp +8
                begin
                  if (info_player2[7:0]>=8'd51) //def. Lv. up (59-8=51)
                    begin
                      info_player2[31:28] <= 4'b0100;// stage up to Highest
                      info_player2[23:16] <= 8'hE1; // HP reset 'd225 = 'hE1 
                      info_player2[15:8]  <= 8'h7F; //ATK reset 'd127 = 'h7F
                      info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0010) 
                    begin //att. is grass or fire
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (info_player1[27:24]==4'b0100) 
                    begin // att. is water
                      if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (info_player1[27:24]==4'b0101||info_player1[27:24]==4'b1000) 
                    begin // att. is normal or electric
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
              else if (info_player1[31:28]==4'b0010) //att. is middle  exp +12
                begin
                  if (info_player2[7:0]>=8'd47) //def. Lv. up (59-12=47)
                    begin
                      info_player2[31:28] <= 4'b0100;// stage up to Highest
                      info_player2[23:16] <= 8'hE1; // HP reset 'd225 = 'hE1 
                      info_player2[15:8]  <= 8'h7F; //ATK reset 'd127 = 'h7F
                      info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0010) 
                    begin //att. is grass or fire
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (info_player1[27:24]==4'b0100) 
                    begin // att. is water
                      if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (info_player1[27:24]==4'b0101||info_player1[27:24]==4'b1000) 
                    begin // att. is normal or electric
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
              else if (info_player1[31:28]==4'b0100) //att. is highest  exp +16  
                begin
                  if (info_player2[7:0]>=8'd43) //def. Lv. up (59-16=43)
                    begin
                      info_player2[31:28] <= 4'b0100;// stage up to Highest
                      info_player2[23:16] <= 8'hE1; // HP reset 'd225 = 'hE1 
                      info_player2[15:8]  <= 8'h7F; //ATK reset 'd127 = 'h7F
                      info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0010) 
                    begin //att. is grass or fire
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (info_player1[27:24]==4'b0100) 
                    begin // att. is water
                      if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (info_player1[27:24]==4'b0101||info_player1[27:24]==4'b1000) 
                    begin // att. is normal or electric
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
            end  
          else if (info_player2[27:24]==4'b0100) //def. is water
            begin
              if (info_player1[31:28]==4'b0001)      //att. is lowest  exp +8
                begin
                  if (info_player2[7:0]>=8'd47) //def. Lv. up (55-8=47)
                    begin
                      info_player2[31:28] <= 4'b0100;// stage up to Highest
                      info_player2[23:16] <= 8'hF5; // HP reset 'd245 = 'hF5 
                      info_player2[15:8]  <= 8'h71; //ATK reset 'd113 = 'h71
                      info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b0010||info_player1[27:24]==4'b0100) 
                    begin //att. is fire or water
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b1000) 
                    begin // att. is grass or electric
                      if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (info_player1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end      
                end
              else if (info_player1[31:28]==4'b0010) //att. is middle  exp +12
                begin
                  if (info_player2[7:0]>=8'd43) //def. Lv. up (55-12=43)
                    begin
                      info_player2[31:28] <= 4'b0100;// stage up to Highest
                      info_player2[23:16] <= 8'hF5; // HP reset 'd245 = 'hF5 
                      info_player2[15:8]  <= 8'h71; //ATK reset 'd113 = 'h71
                      info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b0010||info_player1[27:24]==4'b0100) 
                    begin //att. is fire or water
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b1000) 
                    begin // att. is grass or electric
                      if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (info_player1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
              else if (info_player1[31:28]==4'b0100) //att. is highest  exp +16
                begin
                  if (info_player2[7:0]>=8'd39) //def. Lv. up (55-16=39)
                    begin
                      info_player2[31:28] <= 4'b0100;// stage up to Highest
                      info_player2[23:16] <= 8'hF5; // HP reset 'd245 = 'hF5 
                      info_player2[15:8]  <= 8'h71; //ATK reset 'd113 = 'h71
                      info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b0010||info_player1[27:24]==4'b0100) 
                    begin //att. is fire or water
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end
                  else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b1000) 
                    begin // att. is grass or electric
                      if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end     
                  else if (info_player1[27:24]==4'b0101) 
                    begin // att. is normal
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
            end
          else if (info_player2[27:24]==4'b1000) //def. is electric
            begin
              if (info_player1[31:28]==4'b0001)      //att. is lowest  exp +8
                begin
                  if (info_player2[7:0]>=8'd43) //def. Lv. up (51-8=43)
                    begin
                      info_player2[31:28] <= 4'b0100;// stage up to Highest
                      info_player2[23:16] <= 8'hEB; // HP reset 'd235 = 'hEB
                      info_player2[15:8]  <= 8'h7C; //ATK reset 'd124 = 'h7C
                      info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b1000) 
                    begin //att. is electric
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end   
                  else if (info_player1[27:24]==4'b0101||info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0010||info_player1[27:24]==4'b0100) 
                    begin // att. is normal , grass , fire , water
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd8; // EXP+8
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
              else if (info_player1[31:28]==4'b0010) //att. is middle  exp +12
                begin
                  if (info_player2[7:0]>=8'd39) //def. Lv. up (51-12=39)
                    begin
                      info_player2[31:28] <= 4'b0100;// stage up to Highest
                      info_player2[23:16] <= 8'hEB; // HP reset 'd235 = 'hEB
                      info_player2[15:8]  <= 8'h7C; //ATK reset 'd124 = 'h7C
                      info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b1000) 
                    begin //att. is electric
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end   
                  else if (info_player1[27:24]==4'b0101||info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0010||info_player1[27:24]==4'b0100) 
                    begin // att. is normal , grass , fire , water
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd12; // EXP+12
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
              else if (info_player1[31:28]==4'b0100) //att. is highest  exp +16
                begin
                  if (info_player2[7:0]>=8'd35) //def. Lv. up (51-16=35)
                    begin
                      info_player2[31:28] <= 4'b0100;// stage up to Highest
                      info_player2[23:16] <= 8'hEB; // HP reset 'd235 = 'hEB
                      info_player2[15:8]  <= 8'h7C; //ATK reset 'd124 = 'h7C
                      info_player2[7:0]   <= 8'b0;  //exp reset
                      flag_fin_attack <= 1;
                    end
                  else if (info_player1[27:24]==4'b1000) 
                    begin //att. is electric
                      if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end   
                  else if (info_player1[27:24]==4'b0101||info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0010||info_player1[27:24]==4'b0100) 
                    begin // att. is normal , grass , fire , water
                      if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                        begin
                          info_player2[23:16] <= 8'b0;
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end
                      else // still have hp
                        begin
                          info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                          info_player2[7:0]   <= info_player2[7:0] + 8'd16; // EXP+16
                          flag_fin_attack <= 1;
                        end   
                    end        
                end
            end
        end
      else if (info_player2[31:28]==4'b0100) // def. is highest EXP fix at 0
        begin
           if (info_player2[27:24]==4'b0001)      //def. is grass
            begin
              if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0100||info_player1[27:24]==4'b1000) 
                begin //att. is grass or water or electric
                  if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                    begin
                      info_player2[23:16] <= 8'b0;
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end
              else if (info_player1[27:24]==4'b0010) 
                begin // att. is fire
                  if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                    begin
                      info_player2[23:16] <= 8'b0;
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end     
              else if (info_player1[27:24]==4'b0101) 
                begin // att. is normal
                  if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                    begin
                      info_player2[23:16] <= 8'b0;
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end      
            end
          else if (info_player2[27:24]==4'b0010) //def. is fire
            begin
              if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0010) 
                begin //att. is grass or fire
                  if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                    begin
                      info_player2[23:16] <= 8'b0;
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end
              else if (info_player1[27:24]==4'b0100) 
                begin // att. is water
                  if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                    begin
                      info_player2[23:16] <= 8'b0;
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end     
              else if (info_player1[27:24]==4'b0101||info_player1[27:24]==4'b1000) 
                begin // att. is normal or electric
                  if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                    begin
                      info_player2[23:16] <= 8'b0;
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end      
            end  
          else if (info_player2[27:24]==4'b0100) //def. is water
            begin
              if (info_player1[27:24]==4'b0010||info_player1[27:24]==4'b0100) 
                begin //att. is fire or water
                  if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                    begin
                      info_player2[23:16] <= 8'b0;
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end
              else if (info_player1[27:24]==4'b0001||info_player1[27:24]==4'b1000) 
                begin // att. is grass or electric
                  if (info_player2[23:16]<=info_player1[15:8]*2) // hp will 0 after attck
                    begin
                      info_player2[23:16] <= 8'b0;
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]*2;
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end     
              else if (info_player1[27:24]==4'b0101) 
                begin // att. is normal
                  if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                    begin
                      info_player2[23:16] <= 8'b0;
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end      
            end
          else if (info_player2[27:24]==4'b1000) //def. is electric
            begin
              if (info_player1[27:24]==4'b1000) 
                begin //att. is electric
                  if (info_player2[23:16]<=info_player1[15:8]/2) // hp will 0 after attck
                    begin
                      info_player2[23:16] <= 8'b0;
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      info_player2[23:16] <= info_player2[23:16]-info_player1[15:8]/2;
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end   
              else if (info_player1[27:24]==4'b0101||info_player1[27:24]==4'b0001||info_player1[27:24]==4'b0010||info_player1[27:24]==4'b0100) 
                begin // att. is normal , grass , fire , water
                  if (info_player2[23:16]<=info_player1[15:8]) // hp will 0 after attck
                    begin
                      info_player2[23:16] <= 8'b0;
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end
                  else // still have hp
                    begin
                      info_player2[23:16] <= info_player2[23:16]-info_player1[15:8];
                      info_player2[7:0]   <= 8'b0;
                      flag_fin_attack <= 1;
                    end   
                end        
            end
        end  
    end
endtask 
 





//=======================================================================================
//                   action to action
//=======================================================================================
// X to X
task AtoA_10;
  for(k=0 ;k<=10; k=k+1)
   begin
     if(k<=10)
       begin
          attack_fake;
          player = player+1; 
       end  
   end  
endtask

task BtoB_10;
  for(k=0 ;k<=10; k=k+1)
   begin
     if(k<=10)
       begin
          buy_poke_task;
          save_p1;
          player = player+1; 
       end  
   end  
endtask

task CtoC_10;
  for(k=0 ;k<=10; k=k+1)
   begin
     if(k<=10)
       begin
          check_task_noid; 
       end  
   end  
endtask

task DtoD_10;
  for(k=0 ;k<=9; k=k+1)
   begin
     if(k<=9)
       begin
          give_id;
          get_info_1;
          deposit_task;
          save_p1;
          player = player+1;
       end  
   end  
endtask

task DtoD_10noID;
  for(k=0 ;k<=10; k=k+1)
   begin
     if(k<=10)
       begin
          deposit_task;
          save_p1;
       end  
   end  
endtask



task StoS_10;
  for(k=0 ;k<=10; k=k+1)
   begin
     if(k<=10)
       begin
          sell_item_task;
          player = player+1; 
       end  
   end  
endtask

task UtoU_10;
  for(k=0 ;k<=9; k=k+1)
   begin
     if(k<=9)
       begin
          usestone_task;
          save_p1;
          player = player+1; 
       end  
   end  
endtask


// X to Y
task BtoS_10;
  for(l=0 ;l<=10; l=l+1)
   begin
     if(l<=10)
       begin
          buy_poke_task;
          save_p1;
          player = player+1;
          sell_poke_task;
          save_p1;
          player = player+1; 
       end  
   end  
endtask

task BtoC_10;
  for(l=0 ;l<=10; l=l+1)
   begin
     if(l<=10)
       begin
          buy_poke_task;
          save_p1;
          player = player+1;
          check_task;
          player = player+1; 
       end  
   end  
endtask

task BtoU_10;
  for(l=0 ;l<=9; l=l+1)
   begin
     if(l<=9)
       begin
          buy_item_stone;
          save_p1;
          player=player+1;
          golden_err_msg = 0;
          usestone_task;
          save_p1;
          player=player+1;
          golden_err_msg = 0;
       end  
   end  
endtask

task CtoU_10;
  for(l=0 ;l<=8; l=l+1)
   begin
     if(l<=8)
       begin
          check_task;
          player = player+1;
          usestone_task;
          save_p1;
          golden_err_msg = 0; 
       end  
   end  
endtask

task CtoD_10;
  for(l=0 ;l<=10; l=l+1)
   begin
     if(l<=10)
       begin
          check_task;
          player = player+1;
          give_id;
          get_info_1;
          deposit_task;
          save_p1;
       end  
   end  
endtask

task CtoS_10;
  for(l=0 ;l<=10; l=l+1)
   begin
     if(l<=10)
       begin
          check_task;
          player = player+1;
          sell_poke_task;
          save_p1;
          player = player+1; 
       end  
   end  
endtask




// contact with attack 
task AtoS_10;
  for(l=0 ;l<=10; l=l+1)
   begin
     if(l<=10)
       begin
          attack_fake;
          player = player+1;
          sell_item_task_noid; 
       end  
   end  
endtask


task BtoA_10;
  for(l=0 ;l<=10; l=l+1)
   begin
     if(l<=10)
       begin
          buy_item_FAKE;
          golden_err_msg = 0;
          attack_fake;
          player = player+1; 
       end  
   end  
endtask

task CtoA_10;
  for(l=0 ;l<=19; l=l+1)
   begin
     if(l<=10)
       begin
          check_task_noid;
          attack_fake;
          player = player+1; 
       end  
   end  
endtask

task AtoU_10;
  for(l=0 ;l<=9; l=l+1)
   begin
     if(l<=9)
       begin
          attack_fake;
          golden_err_msg = 0;
          usestone_task_noid;
          golden_err_msg = 0;
          player = player+1; 
       end  
   end  
endtask

task DtoA_10;
  for(l=0 ;l<=10; l=l+1)
   begin
     if(l<=10)
       begin
          attack_fake;
          golden_err_msg = 0;
          deposit_task;
          save_p1; 
          player = player+1;
       end  
   end  
endtask

task DtoS_10;
  for(k=0 ;k<=10; k=k+1)
   begin
     if(k<=10)
       begin
          deposit_task;
          save_p1; 
          player = player+1;
          sell_item_task;
       end  
   end  
endtask

task UtoS_10;
  for(k=0 ;k<=9; k=k+1)
   begin
     if(k<=9)
       begin
         player = player+1;
         usestone_task;
         save_p1;
         player = player+1;
         sell_stone;
         save_p1; 
       end  
   end  
endtask

task UtoD_10;
  for(k=0 ;k<=10; k=k+1)
   begin 
     if(k<=10)
       begin
        if(player==255 || player==216)
          begin
             player = 216;
             usestone_task;
             deposit_task;
             save_p1;
          end
        else 
          begin
             player = player+1;
             usestone_task;
             deposit_task;
         save_p1;
          end     
       end  
   end  
endtask

task BtoD_10_1;
  for(k=0 ;k<=5; k=k+1)
   begin 
     if(k<=5)
       begin
         buy_poke_task;
         deposit_alot;
         save_p1;
         player = player+1;     
       end  
   end  
endtask


task BtoD_10_2;
  for(k=0 ;k<=5; k=k+1)
   begin 
     if(k<=5)
       begin
         buy_poke_tasknoID;
         save_p1; 
         player = player+1;
         deposit_alot;     
       end  
   end  
endtask

//====================================================================================================================================================================================
//                   Pass Task
//====================================================================================================================================================================================
task pass_task; begin
    $display("                                                             \033[33m`-                                                                            ");        
    $display("                                                             /NN.                                                                           ");        
    $display("                                                            sMMM+                                                                           ");        
    $display(" .``                                                       sMMMMy                                                                           ");        
    $display(" oNNmhs+:-`                                               oMMMMMh                                                                           ");        
    $display("  /mMMMMMNNd/:-`                                         :+smMMMh                                                                           ");        
    $display("   .sNMMMMMN::://:-`                                    .o--:sNMy                                                                           ");        
    $display("     -yNMMMM:----::/:-.                                 o:----/mo                                                                           ");        
    $display("       -yNMMo--------://:.                             -+------+/                                                                           ");        
    $display("         .omd/::--------://:`                          o-------o.                                                                           ");        
    $display("           `/+o+//::-------:+:`                       .+-------y                                                                            ");        
    $display("              .:+++//::------:+/.---------.`          +:------/+                                                                            ");        
    $display("                 `-/+++/::----:/:::::::::::://:-.     o------:s.          \033[37m:::::----.           -::::.          `-:////:-`     `.:////:-.    \033[33m");        
    $display("                    `.:///+/------------------:::/:- `o-----:/o          \033[37m.NNNNNNNNNNds-       -NNNNNd`       -smNMMMMMMNy   .smNNMMMMMNh    \033[33m");        
    $display("                         :+:----------------------::/:s-----/s.          \033[37m.MMMMo++sdMMMN-     `mMMmMMMs      -NMMMh+///oys  `mMMMdo///oyy    \033[33m");        
    $display("                        :/---------------------------:++:--/++           \033[37m.MMMM.   `mMMMy     yMMM:dMMM/     +MMMM:      `  :MMMM+`     `    \033[33m");        
    $display("                       :/---///:-----------------------::-/+o`           \033[37m.MMMM.   -NMMMo    +MMMs -NMMm.    .mMMMNdo:.     `dMMMNds/-`      \033[33m");        
    $display("                      -+--/dNs-o/------------------------:+o`            \033[37m.MMMMyyyhNMMNy`   -NMMm`  sMMMh     .odNMMMMNd+`   `+dNMMMMNdo.    \033[33m");        
    $display("                     .o---yMMdsdo------------------------:s`             \033[37m.MMMMNmmmdho-    `dMMMdooosMMMM+      `./sdNMMMd.    `.:ohNMMMm-   \033[33m");        
    $display("                    -yo:--/hmmds:----------------//:------o              \033[37m.MMMM:...`       sMMMMMMMMMMMMMN-  ``     `:MMMM+ ``      -NMMMs   \033[33m");        
    $display("                   /yssy----:::-------o+-------/h/-hy:---:+              \033[37m.MMMM.          /MMMN:------hMMMd` +dy+:::/yMMMN- :my+:::/sMMMM/   \033[33m");        
    $display("                  :ysssh:------//////++/-------sMdyNMo---o.              \033[37m.MMMM.         .mMMMs       .NMMMs /NMMMMMMMMmh:  -NMMMMMMMMNh/    \033[33m");        
    $display("                  ossssh:-------ddddmmmds/:----:hmNNh:---o               \033[37m`::::`         .::::`        -:::: `-:/++++/-.     .:/++++/-.      \033[33m");        
    $display("                  /yssyo--------dhhyyhhdmmhy+:---://----+-                                                                                  ");        
    $display("                  `yss+---------hoo++oosydms----------::s    `.....-.                                                                       ");        
    $display("                   :+-----------y+++++++oho--------:+sssy.://:::://+o.                                                                      ");        
    $display("                    //----------y++++++os/--------+yssssy/:--------:/s-                                                                     ");        
    $display("             `..:::::s+//:::----+s+++ooo:--------+yssssy:-----------++                                                                      ");        
    $display("           `://::------::///+/:--+soo+:----------ssssys/---------:o+s.``                                                                    ");        
    $display("          .+:----------------/++/:---------------:sys+----------:o/////////::::-...`                                                        ");        
    $display("          o---------------------oo::----------::/+//---------::o+--------------:/ohdhyo/-.``                                                ");        
    $display("          o---------------------/s+////:----:://:---------::/+h/------------------:oNMMMMNmhs+:.`                                           ");        
    $display("          -+:::::--------------:s+-:::-----------------:://++:s--::------------::://sMMMMMMMMMMNds/`                                        ");        
    $display("           .+++/////////////+++s/:------------------:://+++- :+--////::------/ydmNNMMMMMMMMMMMMMMmo`                                        ");        
    $display("             ./+oo+++oooo++/:---------------------:///++/-   o--:///////::----sNMMMMMMMMMMMMMMMmo.                                          ");        
    $display("                o::::::--------------------------:/+++:`    .o--////////////:--+mMMMMMMMMMMMMmo`                                            ");        
    $display("               :+--------------------------------/so.       +:-:////+++++///++//+mMMMMMMMMMmo`                                              ");        
    $display("              .s----------------------------------+: ````` `s--////o:.-:/+syddmNMMMMMMMMMmo`                                                ");        
    $display("              o:----------------------------------s. :s+/////--//+o-       `-:+shmNNMMMNs.                                                  ");        
    $display("             //-----------------------------------s` .s///:---:/+o.               `-/+o.                                                    ");        
    $display("            .o------------------------------------o.  y///+//:/+o`                                                                          ");        
    $display("            o-------------------------------------:/  o+//s//+++`                                                                           ");        
    $display("           //--------------------------------------s+/o+//s`                                                                                ");        
    $display("          -+---------------------------------------:y++///s                                                                                 ");        
    $display("          o-----------------------------------------oo/+++o                                                                                 ");        
    $display("         `s-----------------------------------------:s   ``                                                                                 ");        
    $display("          o-:::::------------------:::::-------------o.                                                                                     ");        
    $display("          .+//////////::::::://///////////////:::----o`                                                                                     ");        
    $display("          `:soo+///////////+++oooooo+/////////////:-//                                                                                      ");        
    $display("       -/os/--:++/+ooo:::---..:://+ooooo++///////++so-`                                                                                     ");        
    $display("      syyooo+o++//::-                 ``-::/yoooo+/:::+s/.                                                                                  ");        
    $display("       `..``                                `-::::///:++sys:                                                                                ");        
    $display("                                                    `.:::/o+  \033[37m                                                                              ");	
    $display("********************************************************************");
    $display("                        \033[0;38;5;219mCongratulations!\033[m      ");
    $display("                 \033[0;38;5;219mYou have passed all patterns!\033[m");
    $display("********************************************************************");
    $finish;
    repeat (5) @(negedge clk);
    $finish;
    end 
    endtask
endprogram