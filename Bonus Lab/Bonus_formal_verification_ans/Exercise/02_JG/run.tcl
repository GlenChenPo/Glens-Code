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
assume {slave.awsize==5}               -name slave_awsize
assume {slave.awid==0}                 -name slave_awid
assume {slave.wid==0}                  -name slave_wid
assume {slave.wlast==1}                -name slave_wlast
assume {slave.arsize==5}               -name slave_arsize
assume {slave.arid==1}                 -name slave_arid
assume {slave.rlast==1}                -name slave_rlast
assume {slave.awburst==0}              -name slave_awburst_fixed
assume {slave.arburst==0}              -name slave_arburst_fixed
assume {&slave.wstrb==1}               -name slave_wstrb

# Good For TA
#get_needed_assumption -property {<embedded>::top.sc_w.genblk6.core.genblk7.COVER[1].data_in}
