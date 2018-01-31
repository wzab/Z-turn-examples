#!/bin/bash
#Please note, that even though the Buildroot version
#is put into the environment variable, it may be also
#set in different configuration files or paths in 
#the zip archive. So if you want to change the Buildroot
#version, it may be difficult...
BRNAME=buildroot-2017.11.2
wget https://buildroot.org/downloads/$BRNAME.tar.bz2
#Unpack Buildroot
tar -xjf $BRNAME.tar.bz2
#Add our stuff (In the previous version we unpacked the
#archive, but keeping archive in GIT does not allow
#to track changes. Therefore now we copy contents from
#the directory, using "tar" to ensure that all directories
#and files, even hidden ones,  are copied/overwritten)
( cd example ; tar -cf - . ) | tar -xf -
#Modify the packages menu
#It is not the most elegant way, but the simplest 
#we just add new menu
cat >> $BRNAME/package/Config.in <<AddedMenu
menu "Additional example packages"
	source "package/axil2ipb-module/Config.in"
	source "package/axi4s2dmov-module/Config.in"
	source "package/axi4s2dmov-test/Config.in"
endmenu
AddedMenu
cd $BRNAME
make zynq_zturn_defconfig
make


