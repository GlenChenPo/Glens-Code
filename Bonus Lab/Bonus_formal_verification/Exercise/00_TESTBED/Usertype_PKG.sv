//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2020 ICLAB Fall Course
//   Lab09      : HF
//   Author     : Lien-Feng Hsu
//                
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : Usertype_PKG.sv
//   Module Name : usertype
//   Release version : v1.0 (Release Date: May-2020)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

`ifndef USERTYPE
`define USERTYPE

package usertype;

typedef enum logic  [3:0] { No_action  = 4'd0 ,   //0000
                            Seed       = 4'd1 ,   //0001
							Water      = 4'd3 ,   //0011
						    Reap       = 4'd2 ,   //0010 
							Steal      = 4'd4 ,   //0100
							Check_dep  = 4'd8     //1000
							}  Action ;
							
typedef enum logic  [3:0] { No_Err            = 4'd0 ,   //0000
                            Is_Empty          = 4'd1 ,   //0001
							Not_Empty         = 4'd2 ,   //0010
							Has_Grown         = 4'd3 ,   //0011
						    Not_Grown         = 4'd4 	 //0100
							}  Error_Msg ;

typedef enum logic  [3:0] { No_crop		 = 4'd0 ,
							Potato	     = 4'd1 ,
                            Corn	     = 4'd2 , 
							Tomato       = 4'd4 ,
						    Wheat        = 4'd8   
							}  Crop_cat ;

typedef logic [5:0]  Land;
typedef logic [11:0] Water_amnt;

typedef struct packed {
	Land  land_id, land_status;
	Crop_cat  crop_cat;
	Water_amnt water_amnt; 
} Land_Info; 

typedef union packed{ 
    Action       [2:0]d_act;
	Land         [1:0]d_id;
	Crop_cat     [2:0]d_cat;
	Water_amnt        d_amnt;
} DATA;

typedef enum logic [2:0] { AXI_IDLE =3'd0,
                           AXI_AW   =3'd1,
                           AXI_W    =3'd2,
                           AXI_B    =3'd3,
                           AXI_AR   =3'd4,
                           AXI_R    =3'd5
			 } AXI_STAGE;		


//##################################################

endpackage

import usertype::*; //import usertype into $unit

`endif

