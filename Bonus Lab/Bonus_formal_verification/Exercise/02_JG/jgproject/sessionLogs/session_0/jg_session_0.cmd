# ----------------------------------------
# JasperGold Version Info
# tool      : JasperGold 2021.03
# platform  : Linux 2.6.32-696.el6.x86_64
# version   : 2021.03 FCS 64 bits
# build date: 2021.03.23 02:50:43 UTC
# ----------------------------------------
# started   : 2022-05-15 10:28:24 CST
# hostname  : ee03.ed415
# pid       : 3992
# arguments : '-label' 'session_0' '-console' '//127.0.0.1:42305' '-style' 'windows' '-data' 'AAAAVHicY2RgYLCp////PwMYMFcBCQEGHwZfhiAGVyDpzxAGpOGA8QGUYcMI4gExH0MRQylDHoMeQwlDMkMOSA4AEIAKoQ==' '-proj' '/home/RAID2/COURSE/iclab/iclab093/Bonus_formal_verification/Exercise/02_JG/jgproject/sessionLogs/session_0' '-init' '-hidden' '/home/RAID2/COURSE/iclab/iclab093/Bonus_formal_verification/Exercise/02_JG/jgproject/.tmp/.initCmds.tcl' 'run.tcl'
clear -all

jasper_scoreboard_3 -init

set ABVIP_INST_DIR /home/RAID2/COURSE/iclab/iclabta01/cadence_vip/tools/abvip
#set ABVIP_INST_DIR /grid/avs/install/vipcat/11.3/latest/tools/abvip
abvip -set_location $ABVIP_INST_DIR
set_visualize_auto_load_debugging_tables on

analyze -sv09  -f jg.f
analyze -sv09  top.sv
elaborate -top top -no_precondition -extract_covergroups

clock SystemClock
reset ~inf.rst_n



# ------------------------ LAN Version ---------------------------
assert -disable *prot* *len* *user* *lock* *qos* *region* *cache* *last* *size* *burst* *awid* *arid*
assume {slave.awsize==4}               -name slave_awsize
assume {slave.awid==0}                 -name slave_awid
assume {slave.wid==0}                  -name slave_wid
assume {slave.wlast==1}                -name slave_wlast
assume {slave.arsize==4}               -name slave_arsize
assume {slave.arid==1}                 -name slave_arid
assume {slave.rlast==1}                -name slave_rlast
assume {slave.awburst==0}              -name slave_awburst_fixed
assume {slave.arburst==0}              -name slave_arburst_fixed
assume {&slave.wstrb==1}               -name slave_wstrb

# Good For TA
#get_needed_assumption -property {<embedded>::top.sc_w.genblk6.core.genblk7.COVER[1].data_in}
prove -bg -all
visualize -violation -property <embedded>::top.slave.genStableChks.genStableChksWRInf.master_aw_awaddr_stable -new_window
visualize -violation -property <embedded>::top.slave.genStableChks.genStableChksWRInf.master_aw_awaddr_stable -new_window
visualize -violation -property <embedded>::top.slave.genPropChksRDInf.genNoRdTblOverflow.master_ar_rd_tbl_no_overflow -new_window
prove -bg -all
include /home/RAID2/COURSE/iclab/iclab093/Bonus_formal_verification/Exercise/02_JG/run.tcl
prove -bg -all
visualize -violation -property <embedded>::top.assert_W_DATA -new_window
include /home/RAID2/COURSE/iclab/iclab093/Bonus_formal_verification/Exercise/02_JG/run.tcl
include /home/RAID2/COURSE/iclab/iclab093/Bonus_formal_verification/Exercise/02_JG/run.tcl
prove -bg -all
include /home/RAID2/COURSE/iclab/iclab093/Bonus_formal_verification/Exercise/02_JG/run.tcl
prove -bg -all
visualize -violation -property <embedded>::top.sc_AW.genblk6.core.genblk5.genblk1.data_integrity -new_window
visualize -violation -property <embedded>::top.slave.genPropChksWRInf.genNoWrTblOverflow.master_aw_wr_tbl_no_overflow -new_window
visualize -violation -property <embedded>::top.slave.genPropChksRDInf.genNoRdTblOverflow.master_ar_rd_tbl_no_overflow -new_window
visualize -violation -property <embedded>::top.slave.genStableChks.genStableChksWRInf.master_aw_awaddr_stable -new_window
visualize -violation -property <embedded>::top.slave.genStableChks.genStableChksWRInf.master_aw_awvalid_stable -new_window
visualize -violation -property <embedded>::top.slave.genStableChks.genStableChksRDInf.master_ar_araddr_stable -new_window
visualize -violation -property <embedded>::top.sc_AW.genblk6.core.genblk5.genblk1.data_integrity -new_window
visualize -violation -property <embedded>::top.sc_AW.genblk6.core.genblk5.genblk1.data_integrity -new_window
visualize -violation -property <embedded>::top.assert_W_DATA -new_window
