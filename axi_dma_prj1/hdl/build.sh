#!/bin/bash
set -e
vivado -mode batch -source eprj_create.tcl
vivado -mode batch -source eprj_build.tcl

