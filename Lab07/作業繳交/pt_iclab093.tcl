# specify parameters
set DESIGN "CDC"

#Step 1 Read in the design data, which includes a gate-level netlist and associated logic libraries.
set search_path " ../02_SYN/Netlist \
			./ \
			~iclabta01/umc018/Synthesis/ \
			/usr/synthesis/libraries/syn/ " 

#set link_library { slow.db dw_foundation.sldb }
set link_path "* slow.db"
read_verilog Netlist/$DESIGN\_SYN.v
current_design $DESIGN
link_design -keep_sub_designs $DESIGN

#create_clock -period $CLK_period CLK
read_sdc Netlist/$DESIGN\_SYN.sdc

#Step 6 Specify case and mode analysis settings.
#Step 7 Back-annotate delay and parasitics.
read_sdf Netlist/$DESIGN\_SYN.sdf

# set_annotated_check 

# modify here
#three FIFO
#===================u3===============================================================================
foreach_in_collection x [get_cells u3_AFIFO_sync_r2w_m0_wq1_rptr_reg_4_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cell u3_AFIFO_sync_w2r_m0_rq1_wptr_reg_4_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}

foreach_in_collection x [get_cells u3_AFIFO_sync_r2w_m0_wq1_rptr_reg_3_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cell u3_AFIFO_sync_w2r_m0_rq1_wptr_reg_3_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}

foreach_in_collection x [get_cells u3_AFIFO_sync_r2w_m0_wq1_rptr_reg_2_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cell u3_AFIFO_sync_w2r_m0_rq1_wptr_reg_2_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}

foreach_in_collection x [get_cells u3_AFIFO_sync_r2w_m0_wq1_rptr_reg_1_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cell u3_AFIFO_sync_w2r_m0_rq1_wptr_reg_1_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}

foreach_in_collection x [get_cells u3_AFIFO_sync_r2w_m0_wq1_rptr_reg_0_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cell u3_AFIFO_sync_w2r_m0_rq1_wptr_reg_0_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
#============================u2=============================================
foreach_in_collection x [get_cells u2_AFIFO_sync_r2w_m0_wq1_rptr_reg_4_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cell u2_AFIFO_sync_w2r_m0_rq1_wptr_reg_4_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}

foreach_in_collection x [get_cells u2_AFIFO_sync_r2w_m0_wq1_rptr_reg_3_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cell u2_AFIFO_sync_w2r_m0_rq1_wptr_reg_3_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}

foreach_in_collection x [get_cells u2_AFIFO_sync_r2w_m0_wq1_rptr_reg_2_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cell u2_AFIFO_sync_w2r_m0_rq1_wptr_reg_2_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cells cnt_forout_reg_*] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cells u2_AFIFO_sync_r2w_m0_wq1_rptr_reg_1_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cell u2_AFIFO_sync_w2r_m0_rq1_wptr_reg_1_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cells u2_AFIFO_sync_r2w_m0_wq1_rptr_reg_0_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cell u2_AFIFO_sync_w2r_m0_rq1_wptr_reg_0_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
#==========u1===========================================================================
foreach_in_collection x [get_cells u1_AFIFO_sync_r2w_m0_wq1_rptr_reg_4_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cell u1_AFIFO_sync_w2r_m0_rq1_wptr_reg_4_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cells u1_AFIFO_sync_r2w_m0_wq1_rptr_reg_3_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cell u1_AFIFO_sync_w2r_m0_rq1_wptr_reg_3_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cells u1_AFIFO_sync_r2w_m0_wq1_rptr_reg_2_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cell u1_AFIFO_sync_w2r_m0_rq1_wptr_reg_2_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cells u1_AFIFO_sync_r2w_m0_wq1_rptr_reg_1_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cell u1_AFIFO_sync_w2r_m0_rq1_wptr_reg_1_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cells u1_AFIFO_sync_r2w_m0_wq1_rptr_reg_0_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cell u1_AFIFO_sync_w2r_m0_rq1_wptr_reg_0_] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
#FIFO output use clk2
foreach_in_collection x [get_cells ACT_1_reg_*] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cells ACT_2_reg_*] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cells ACT_3_reg_*] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cells ACT_4_reg_*] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cells ACT_5_reg_*] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cells perf_1_reg_*] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cells perf_2_reg_*] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cells perf_3_reg_*] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cells perf_4_reg_*] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}
foreach_in_collection x [get_cells perf_5_reg_*] {
  set_annotated_check -0 -setup -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
  set_annotated_check -0 -hold  -from [get_object_name $x]/CK -to [get_object_name $x]/D -clock rise
}


write_sdf Netlist/$DESIGN\_SYN_pt.sdf

#Step 8 (Optional) Apply variation.
#Step 9 Specify power information
#Step 10 (Optional) Specify options and data for signal integrity analysis.
#Step 11 (Optional) Apply options for specific design techniques.
#Step 12 Check the design data and analysis setup.
check_timing

#Step 13 Perform a full timing analysis and examine the results.
report_timing

#Step 14 (Optional) Perform ECO to fix timing violations and recover power.
#Step 15 Save the PrimeTime session.
#save_session
exit
