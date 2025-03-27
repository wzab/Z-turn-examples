# This script creates the project Tcl file.
# To keep it as similar as possible to the one created from GUI
# we change directory first
# Source the project settings
source proj_def.tcl
set old_dir [ pwd ]
cd ${eprj_proj_name}
open_project ./${eprj_proj_name}.xpr
write_project_tcl -force -no_copy_sources -use_bd_files {initial_state.tcl}
puts "INFO: Project $eprj_proj_name written to the initial_state.tcl file"
cd $old_dir
