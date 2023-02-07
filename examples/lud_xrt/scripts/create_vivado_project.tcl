set path_to_packaged "./packaged_kernel"
set path_to_tmp_project "./tmp_kernel_pack"

create_project -force kernel_pack $path_to_tmp_project

glob ./proj/solution1/impl/verilog/*.tcl

add_files -norecurse [glob ./proj/solution1/impl/verilog/*.v]
#add_files -norecurse [glob ./proj/solution1/impl/ip/hdl/ip/*.v]
add_files -norecurse [glob /opt/xilinx/platforms/alveo-u50-xdc_20210505/*.xdc] -fileset constrs_1

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1


ipx::package_project -root_dir $path_to_packaged -vendor xilinx.com -library RTLKernel -taxonomy /KernelIP -import_files -set_current false
ipx::unload_core $path_to_packaged/component.xml
#./proj/solution1/impl/ip/component.xml
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory $path_to_packaged $path_to_packaged/component.xml
ipx::unload_core ./proj/solution1/impl/ip/component.xml
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory ./proj/solution1/impl/ip/ ./proj/solution1/impl/ip/component.xml
#./proj/solution1/impl/ip
#ipx::edit_ip_in_project -upgrade true -name tmp_edit_float -directory $path_to_floating_ip $path_to_floating_ip/component.xml
#create_ip -name floating_point -vendor xilinx.com -library ip -version 7.1 -module_name floating_point_v7_1_14
set_property sdx_kernel true [ipx::current_core]
set_property sdx_kernel_type rtl [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::associate_bus_interfaces -busif M_AXI_GMEM -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif M_AXI_GMEM1 -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif s_axi_control -clock ap_clk [ipx::current_core]
set_property xpm_libraries {XPM_CDC XPM_MEMORY XPM_FIFO} [ipx::current_core]
set_property supported_families { } [ipx::current_core]
set_property auto_family_support_level level_2 [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
close_project -delete
