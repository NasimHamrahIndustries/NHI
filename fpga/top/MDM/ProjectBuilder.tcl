#
# Copyright 2020 Nasim Hamrah Industries
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#

# Microsemi Tcl Script
# libero

new_project -location {./Build_MDM} -name {Build_MDM} -project_description {In the Name of ALLAH
Noon, By the pen and by what they inscribe
Nasim Hamrah Industries NHI
MDM Board} -block_mode 0 -standalone_peripheral_initialization 0 -instantiate_in_smartdesign 1 -use_enhanced_constraint_flow 0 -hdl {VERILOG} -family {ProASIC3} -die {A3P125} -package {100 VQFP} -speed {-1} -die_voltage {1.5} -part_range {TGrade1} -adv_options {IO_DEFT_STD:LVCMOS 3.3V} -adv_options {RESTRICTPROBEPINS:1} -adv_options {RESTRICTSPIPINS:0} -adv_options {TEMPR:TGrade1} -adv_options {VCCI_1.5_VOLTR:COM} -adv_options {VCCI_1.8_VOLTR:COM} -adv_options {VCCI_2.5_VOLTR:COM} -adv_options {VCCI_3.3_VOLTR:COM} -adv_options {VOLTR:TGrade1}

set dir [pwd]

create_links \
   -convert_EDN_to_HDL 0 \
   -hdl_source_folder "$dir/../../../fpga/lib"
