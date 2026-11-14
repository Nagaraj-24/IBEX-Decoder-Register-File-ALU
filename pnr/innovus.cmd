#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Sat Nov 14 13:54:26 2026                
#                                                     
#######################################################

#@(#)CDS: Innovus v20.14-s095_1 (64bit) 04/19/2021 14:41 (Linux 2.6.32-431.11.2.el6.x86_64)
#@(#)CDS: NanoRoute 20.14-s095_1 NR210411-1939/20_14-UB (database version 18.20.547) {superthreading v2.13}
#@(#)CDS: AAE 20.14-s018 (64bit) 04/19/2021 (Linux 2.6.32-431.11.2.el6.x86_64)
#@(#)CDS: CTE 20.14-s027_1 () Apr 13 2021 21:29:07 ( )
#@(#)CDS: SYNTECH 20.14-s017_1 () Mar 25 2021 13:07:27 ( )
#@(#)CDS: CPE v20.14-s080
#@(#)CDS: IQuantus/TQuantus 20.1.1-s460 (64bit) Fri Mar 5 18:46:16 PST 2021 (Linux 2.6.32-431.11.2.el6.x86_64)

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
getVersion
win
floorPlan -site CoreSite -r 1.0 0.7 10 10 10 10
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *
addRing -nets {VDD VSS} -type core_rings -layer {top M6 bottom M6 left M5 right M5} -width 2 -spacing 1 -offset 2
sroute -connect corePin -nets {VDD VSS}
place_opt_design
ccopt_design
routeDesign
zoomSelected -margin 50
fit
fit
fit
zoomSelected -margin 50
setDrawView fplan
setDrawView fplan
setDrawView fplan
set init_verilog ../synthesis/decoder_register_file_netlist.v
set init_top_cell decoder_register_file
set init_lef_file {/opt/sclpdkv3/scl180/stdcell/fs120/6M1L/lef/scl18fs120_tech.lef /opt/sclpdkv3/scl180/stdcell/fs120/6M1L/lef/scl18fs120_std.lef}
set init_pwr_net VDD
set init_gnd_net VSS
set init_mmmc_file mmmc.view
init_design
floorPlan -site CoreSite -r 1.0 0.7 10 10 10 10
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *
addRing -nets {VDD VSS} -type core_rings -layer {top M6 bottom M6 left M5 right M5} -width 2 -spacing 1 -offset 2
sroute -connect corePin -nets {VDD VSS}
place_opt_design
ccopt_design
routeDesign
setLayerPreference allM1 -isVisible 1
setLayerPreference allM2 -isVisible 1
setLayerPreference allM3 -isVisible 1
setLayerPreference allM4 -isVisible 1
setLayerPreference allM5 -isVisible 1
uiSetTool select
fit
streamOut decoder_register_file.gds -mapFile /opt/sclpdkv3/scl180/pdk/cdns/sclpdk_v3/HOTCODE/amslibs/cds_oa/cdsware/layout/bin/skill/rdsLayMapping.ile -libName DesignLib -units 1000 -mode ALL
zoomBox -22.45600 56.31700 471.57600 875.12900
zoomBox -22.45600 383.84100 471.57600 1202.65300
zoomBox 206.07500 592.05700 288.74900 729.08200
zoomBox 218.80000 603.64600 278.56500 702.70100
zoomSelected -margin 50
fit
zoomBox -22.45600 -107.44500 471.57600 711.36700
fit
zoomBox -274.84400 74.82800 723.96400 559.00400
selectInst CTS_ccl_a_buf_00029
deselectAll
setLayerPreference node_row -isVisible 1
setLayerPreference node_row -isVisible 0
setLayerPreference node_floorplan -isVisible 1
setLayerPreference node_floorplan -isVisible 0
setLayerPreference node_floorplan -isVisible 1
setDrawView ameba
setDrawView ameba
setDrawView fplan
setDrawView place
zoomBox -144.35200 126.25200 704.63600 537.80200
zoomBox -33.43300 169.96200 688.20700 519.78000
fit
verify_drc
verifyConnectivity
editPin -pin * -layer {M3 M4} -spreadType side -side {LEFT RIGHT TOP BOTTOM}
