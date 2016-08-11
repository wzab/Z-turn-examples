# Script prepared by Wojciech M. Zabolotny (wzab<at>ise.pw.edu.pl) to
# create a Vivado project from the hierarchical list of files
# (extended project files).
# This file is published as PUBLIC DOMAIN
# 
# Source the project settings
source proj_def.tcl
# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Check the Vivado version
set viv_version [ version -short ]
set ver_cmp_res [ string compare $viv_version $eprj_vivado_version ]
if { $eprj_vivado_version_allow_upgrade } {
    if [ expr $ver_cmp_res < 0 ] {
	error "Wrong Vivado version. Expected: $eprj_vivado_version or higher, found $viv_version"
    }
} else {
    if [ expr $ver_cmp_res != 0 ] {
	error "Wrong Vivado version. Expected: $eprj_vivado_version , found $viv_version"
    }
}
# Create project
create_project $eprj_proj_name ./$eprj_proj_name

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [get_projects $eprj_proj_name]
set_property "board_part" $eprj_board_part $obj
set_property "part" $eprj_part $obj
set_property "default_lib" $eprj_default_lib $obj
set_property "simulator_language" $eprj_simulator_language $obj
set_property "target_language" $eprj_target_language $obj

# Create the global variable which will keep the list of the OOC synthesis runs
global vextproj_ooc_synth_runs
set vextproj_ooc_synth_runs [list ]

# The procedure below changes the library "work" to "xil_defaultlib"
# to avoid problems with simulation in Vivado
# (see https://forums.xilinx.com/t5/Simulation-and-Verification/ERROR-XSIM-43-3225-Cannot-find-design-unit-xil-defaultlib-glbl/m-p/703641 )
proc fix_library { lib } {
    global eprj_default_lib
    if [ string match $eprj_default_lib "xil_defaultlib"] {
	if [ string match "work" $lib ] {
	    set lib "xil_defaultlib"
	}
    }
    return $lib
}

# The project reading procedure operates on objects storing the files
proc eprj_create_block {ablock mode setname } {
    upvar $ablock block    
    #Set the last file_obj initially to "none"
    set block(last_file_obj) "error"
    #Set the mode of the block
    #may be either IC - in context or OOC - out of context
    set block(mode) $mode
    if [string match -nocase $mode "IC"] {
	# Create 'sources_1' fileset (if not found)
	if {[string equal [get_filesets -quiet sources_1] ""]} {
	    create_fileset -srcset sources_1
	}
	set block(srcset) [get_filesets sources_1]
	# Create 'constrs_1' fileset (if not found)
	if {[string equal [get_filesets -quiet constrs_1] ""]} {
	    create_fileset -constrset constrs_1
	}
	set block(cnstrset) [get_filesets constrs_1]
    } elseif [string match -nocase $mode "OOC"] {
	# We create only a single blkset
	# Create 'setname' fileset (if not found)
	if {[string equal [get_filesets -quiet $setname] ""]} {
	    create_fileset -blockset $setname
	}
	# Both constraints and XDC should be added to the same set
	set block(srcset) [get_filesets $setname]
	set block(cnstrset) [get_filesets $setname]
    } else {
	eprj_error block "The block mode must be either IC - in context, or OOC - out of context. The $mode value is unacceptable"
    }
}

#Add file to the sources fileset
proc add_file_sources {ablock args pdir fname} {
    upvar $ablock block
    set nfile [file normalize "$pdir/$fname"]
    if {! [file exists $nfile]} {
	eprj_error block "Requested file $nfile is not available!"
    }
    add_files -norecurse -fileset $block(srcset) $nfile
    set file_obj [get_files -of_objects $block(srcset) $nfile]
    set block(last_file_obj) $file_obj
    #Check if the arguments contain "sim" and set the "simulation" properties if necessary
    if [expr [lsearch $args "sim"] >= 0] {
	set_property "used_in" "simulation" $file_obj
	set_property "used_in_synthesis" "0" $file_obj
    }
    return $file_obj
}

proc handle_xci {ablock args pdir line} {
    upvar $ablock block
    #Handle XCI file
    lassign $line lib fname
    set file_obj [add_file_sources block $args $pdir $fname]
    #set_property "synth_checkpoint_mode" "Singular" $file_obj
    set_property "library" [ fix_library $lib ] $file_obj
}

proc handle_xcix {ablock args pdir line} {
    upvar $ablock block
    #Handle XCIX file
    lassign $line lib fname
    set file_obj [add_file_sources block $args $pdir $fname]
    #set_property "synth_checkpoint_mode" "Singular" $file_obj
    set_property "library" [ fix_library $lib ] $file_obj
    export_ip_user_files -of_objects  $file_obj -force -quiet
}

proc handle_vhdl {ablock args pdir line} {
    upvar $ablock block
    #Handle VHDL file
    lassign $line lib fname
    set file_obj [add_file_sources block $args $pdir $fname]
    set_property "file_type" "VHDL" $file_obj
    set_property "library" [ fix_library $lib ] $file_obj
}

proc handle_verilog {ablock args pdir line} {
    upvar $ablock block
    #Handle Verilog file
    lassign $line fname
    set file_obj [add_file_sources block $args $pdir $fname]
    set_property "file_type" "Verilog" $file_obj
}

proc handle_sys_verilog {ablock args pdir line} {
    upvar $ablock block
    #Handle SystemVerilog file
    lassign $line fname
    set file_obj [add_file_sources block $args $pdir $fname]
    set_property "file_type" "SystemVerilog" $file_obj
}

proc handle_verilog_header {ablock args pdir line} {
    upvar $ablock block
    #Handle SystemVerilog file
    lassign $line fname
    set file_obj [add_file_sources block $args $pdir $fname]
    set_property "file_type" "Verilog Header" $file_obj
}

proc handle_global_verilog_header {ablock args pdir line} {
    upvar $ablock block
    #Handle Global Verilog Header file
    lassign $line fname
    set file_obj [add_file_sources block $args $pdir $fname]
    set_property "file_type" "Verilog Header" $file_obj
    set_property is_global_include true $file_obj
}

proc handle_bd {ablock args pdir line} {
    upvar $ablock block
    #Handle BD file
    lassign $line fname
    set file_obj [add_file_sources block $args $pdir $fname]
    if { ![get_property "is_locked" $file_obj] } {
	set_property "generate_synth_checkpoint" "0" $file_obj
    }
}

proc handle_mif {ablock args pdir line} {
    upvar $ablock block
    #Handle MIF file
    lassign $line lib fname
    set file_obj [add_file_sources block $args $pdir $fname]
    set_property "file_type" "Memory Initialization Files" $file_obj
    set_property "library" [ fix_library $lib ] $file_obj
    #set_property "synth_checkpoint_mode" "Singular" $file_obj
}

proc handle_xdc {ablock args pdir line} {
    upvar $ablock block
    #Handle XDC file
    lassign $line fname
    set nfile [file normalize "$pdir/$fname"]
    if {![file exists $nfile]} {
	eprj_error block "Requested file $nfile is not available!"
    }
    add_files -norecurse -fileset $block(cnstrset) $nfile
    set file_obj [get_files -of_objects $block(cnstrset) $nfile]
    set_property "file_type" "XDC" $file_obj
}	

proc handle_xdc_ooc {ablock args pdir line} {
    upvar $ablock block
    #Handle XDC_OOC file
    lassign $line fname
    set nfile [file normalize "$pdir/$fname"]
    if {![file exists $nfile]} {
	eprj_error block "Requested file $nfile is not available!"
    }
    if {![string match -nocase $block(mode) "OOC"]} {
	puts "Ignored file $nfile in IC mode"
	#Clear "last file object" in the block array
	set block(last_file_obj) "none"
    } else {
	add_files -norecurse -fileset $block(cnstrset) $nfile
	set file_obj [get_files -of_objects $block(cnstrset) $nfile]
	set_property "file_type" "XDC" $file_obj
	set_property USED_IN {out_of_context synthesis implementation} $file_obj
    }	
}

proc handle_prop {ablock args pdir line} {
    upvar $ablock block
    if [string match $block(last_file_obj) "error"] {
	eprj_error block "I don't know to which file apply the property $line" 
    } elseif [string match $block(last_file_obj) "none"] {
	puts "Property ignored $line" 
    } else {
	lassign $line property value
	set_property $property $value $block(last_file_obj)
    }    
}

proc handle_propadd {ablock args pdir line} {
    upvar $ablock block
    if [string match $block(last_file_obj) "error"] {
	eprj_error block "I don't know to which file apply the property $line" 
    } elseif [string match $block(last_file_obj) "none"] {
	puts "Property ignored $line" 
    } else {
	lassign $line property value
	set old_val [ get_property $property $block(last_file_obj) ]
	lappend old_val $value
	set_property $property $old_val $block(last_file_obj)
    }    
}

proc handle_exec {ablock args pdir line} {
    upvar $ablock block
    #Handle EXEC line
    lassign $line fname
    set nfile [file normalize "$pdir/$fname"]
    if {![file exists $nfile]} {
	eprj_error block "Requested file $nfile is not available!"
    }
    #Execute the program in its directory
    set old_dir [ pwd ]
    cd $pdir
    exec "./$fname"
    cd $old_dir
}	

# Handlers for VCS systems
proc handle_git_local {ablock args pdir line} {
    upvar $ablock block
    lassign $line clone_dir commit_or_tag_id exported_dir strip_num
    set old_dir [ pwd ]
    cd $pdir
    file delete -force -- "ext_src"
    file mkdir "ext_src"
    #Prepare the git command
    set strip_cmd ""
    if { $strip_num ne ""} {
	append strip_cmd " --strip-components=$strip_num"
    }
    set git_cmd "( cd $clone_dir ; git archive --format tar $commit_or_tag_id $exported_dir ) | ( cd ext_src ; tar -xf - $strip_cmd )"
    exec bash -c "$git_cmd"
    cd $old_dir
}

proc handle_git_remote {ablock args pdir line} {
    upvar $ablock block
    lassign $line repository_url tag_id exported_dir strip_num
    set old_dir [ pwd ]
    cd $pdir
    file delete -force -- "ext_src"
    file mkdir "ext_src"
    #Prepare the git command
    set strip_cmd ""
    if { $strip_num ne ""} {
	append strip_cmd " --strip-components=$strip_num"
    }
    set git_cmd "( git archive --format tar --remote $repository_url $tag_id $exported_dir ) | ( cd ext_src ; tar -xf - $strip_cmd )"
    exec bash -c "$git_cmd"
    cd $old_dir
}

proc handle_svn {ablock args pdir line} {
    upvar $ablock block
    lassign $line repository_with_path revision
    set old_dir [ pwd ]
    cd $pdir
    file delete -force -- "ext_src"
    file mkdir "ext_src"
    #Prepare the SVN command
    set rev_cmd ""
    if { $revision ne ""} {
	append rev_cmd " -r $revision"
    }
    set svn_cmd "( cd ext_src ; svn export $rev_cmd $repository_with_path )"
    exec bash -c "$svn_cmd"
    cd $old_dir
}

#Procedure exctracting the args from the text: "type[arg1,arg2,arg3]"
#Returns the two-element list {type args}, where args is the list" {arg1 arg2 arg3}
proc type_parse_args { type_args } {
    regexp {([^\[]*)(\[(.*)\])*} $type_args whole_type type arg_part arg_list
    if [string match arg_list ""] {
	set args {}
    } else {
	set args [split $arg_list ","]
    }
    return [list $type $args]
}


# Array with line handlers, used by the line handling procedure
array set line_handlers {
    xci           handle_xci
    xcix          handle_xcix
    header        handle_verilog_header
    global_header handle_global_verilog_header 
    sys_verilog   handle_sys_verilog 
    verilog       handle_verilog 
    mif           handle_mif 
    bd            handle_bd
    vhdl          handle_vhdl
    
    prop          handle_prop
    propadd       handle_propadd
    ooc           handle_ooc
    xdc           handle_xdc
    xdc_ooc       handle_xdc_ooc
    exec          handle_exec
    git_local     handle_git_local
    git_remote    handle_git_remote
    svn           handle_svn 
}

#Line handling procedure
proc handle_line { ablock pdir line } {
    upvar $ablock block
    global line_handlers
    set rest [lassign $line type_args]
    #First we attempt to separate possible arguments from type
    lassign [type_parse_args $type_args] type args
    #Find the procedure to be called depending on the type of the line
    set ptc [lindex [array get line_handlers [string tolower $type]] 1] 
    if [ string equal $ptc "" ] {
	eprj_error block "Unknown line of type: $type"
    } else {
	$ptc block $args $pdir $rest	
    }
}

proc handle_ooc { ablock args pdir line } {
    global eprj_impl_strategy
    global eprj_impl_flow
    global eprj_synth_strategy
    global eprj_synth_flow
    global eprj_flow
    global eprj_part
    global vextproj_ooc_synth_runs

    upvar $ablock block
    #The OOC blocks can't be nested
    #detect the attempt to nest the block and return an error
    if {[string match -nocase $block(mode) "OOC"]} {
	eprj_error block "The OOC blocks can't be nested: $line"
    }    
    lassign $line stub fname blksetname
    #Create the new block of type OOC and continue parsing in it
    array set ooc_block {}
    eprj_create_block ooc_block "OOC" $blksetname
    if {[string match -nocase $stub "noauto"]} {
	set_property "use_blackbox_stub" "0" [get_filesets $blksetname]
    } elseif {![string match -nocase $stub "auto"]} {
	eprj_error block "OOC stub creation mode must be either 'auto' or 'noauto' not: $stub"
    }
    read_prj ooc_block $pdir/$fname
    set_property TOP $blksetname [get_filesets $blksetname]
    update_compile_order -fileset $blksetname
    #Create synthesis run for the blockset (if not found)
    set ooc_synth_run_name ${blksetname}_synth_1
    if {[string equal [get_runs -quiet ${ooc_synth_run_name}] ""]} {
	create_run -name ${ooc_synth_run_name} -part $eprj_part -flow {$eprj_flow} -strategy $eprj_synth_strategy -constrset $blksetname
    } else {
	set_property strategy $eprj_synth_strategy [get_runs ${ooc_synth_run_name}]
	set_property flow $eprj_synth_flow [get_runs ${ooc_synth_run_name}]
    }
    lappend vextproj_ooc_synth_runs ${ooc_synth_run_name}
    set_property constrset $blksetname [get_runs ${ooc_synth_run_name}]
    set_property part $eprj_part [get_runs ${ooc_synth_run_name}]
    # Create implementation run for the blockset (if not found)
    set ooc_impl_run_name ${blksetname}_impl_1
    if {[string equal [get_runs -quiet ${ooc_impl_run_name}] ""]} {
	create_run -name impl_1 -part $eprj_part -flow {$eprj_flow} -strategy $eprj_impl_strategy -constrset $blksetname -parent_run ${ooc_synth_run_name}
    } else {
	set_property strategy $eprj_impl_strategy [get_runs ${ooc_impl_run_name}]
	set_property flow $eprj_impl_flow [get_runs ${ooc_impl_run_name}]
    }
    set_property constrset $blksetname [get_runs ${ooc_impl_run_name}]
    set_property part $eprj_part [get_runs ${ooc_impl_run_name}]
    set_property include_in_archive "0" [get_runs ${ooc_impl_run_name}]
}

# Prepare the main block
array set main_block {}
eprj_create_block main_block "IC" ""

# Procedure reporting the errors
proc eprj_error { ablock message } {
    upvar $ablock block
    puts "ERROR in file: $block(file_name), line: $block(line_count)"
    error $message
}

# Procedure below reads the source files from PRJ files, extended with
# the "include file" statement
#Important thing - path to the source files should be given relatively
#to the location of the PRJ file.
proc read_prj { ablock prj } {
    upvar $ablock block
    #parray block
    #Clear information about the "last file_obj" to avoid wrong assignment of properties
    set block(last_file_obj) "error"
    #allow to use just the directory names. In this case add
    #the "/main.eprj" to it
    if {[file isdirectory $prj]} {
	append prj "/main.eprj"
	puts "Added default main.eprj to the directory name: $prj"
    }
    if {[file exists $prj]} {
	puts "\tReading PRJ file: $prj"
	set source [open $prj r]
	set source_data [read $source]
	close $source
	#Extract the directory of the PRJ file, as all paths to the
	#source files must be given relatively to that directory
	set prj_dir [ file dirname $prj ]
	regsub -all {\"} $source_data {} source_data
	set prj_lines [split $source_data "\n" ]
	#Set line counter and file name for error reporting function
	set block(line_count) 0
	set block(file_name) $prj
	foreach line $prj_lines {
	    incr block(line_count)
	    #Ignore empty and commented lines
	    if {[llength $line] > 0 && ![string match -nocase "#*" $line]} {
		#Detect the inlude line and ooc line
		lassign $line type fname
		if {[string match -nocase $type "include"]} {
                    puts "\tIncluding PRJ file: $prj_dir/$fname"
		    read_prj block $prj_dir/$fname
		    # Clear information about the last file_obj to avoid wrong assignment of properties
		    set block(last_file_obj) "error"
		} else {
		    handle_line block $prj_dir $line
		}
	    }
	}
    } else {
	eprj_error block "Requested file $prj is not available!"
    }
}


# Read project definitions
set main_block(file_name) ""
set main_block(line_count) 0
read_prj main_block $eprj_def_root

set_property "top" $eprj_top_entity  $main_block(srcset)
update_compile_order -fileset sources_1
# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
    create_run -name synth_1 -part $eprj_part -flow {$eprj_flow} -strategy $eprj_synth_strategy -constrset constrs_1
} else {
    set_property strategy $eprj_synth_strategy [get_runs synth_1]
    set_property flow $eprj_synth_flow [get_runs synth_1]
}
set obj [get_runs synth_1]

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
    create_run -name impl_1 -part $eprj_part -flow {$eprj_flow} -strategy $eprj_impl_strategy -constrset constrs_1 -parent_run synth_1
} else {
    set_property strategy $eprj_impl_strategy [get_runs impl_1]
    set_property flow $eprj_impl_flow [get_runs impl_1]
}
set obj [get_runs impl_1]

# set the current impl run
current_run -implementation [get_runs impl_1]

# Write the list of the OOC synthesis runs to the file
set file_ooc_runs [open "ooc_synth_runs.txt" "w"]
puts $file_ooc_runs $vextproj_ooc_synth_runs
close $file_ooc_runs

puts "INFO: Project created:$eprj_proj_name"

# Create the Tcl file with the initial state of the project
# In theory it should be enough to write it now:
#   write_project_tcl -force -no_copy_sources {initial_state.tcl}
# But unfortunately it will differ significantly from the Tcl file created after opening of the saved
# XPR file.
# Therefore we delegate it to the another script...

#launch_runs synth_1
#wait_on_run synth_1
#launch_runs impl_1
#wait_on_run impl_1
#launch_runs impl_1 -to_step write_bitstream
#wait_on_run impl_1

