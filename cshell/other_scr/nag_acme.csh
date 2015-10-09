#!/bin/csh
echo '------------------------------------------'
echo 'Running '$cat' tests: NAG Compiler'
echo '------------------------------------------'
set comp = nag                                        #compiler name
echo '->Form id...' 
#set id            = {$unqid}_{$hsh}_mstr_{$cat_short}_{$date_str}_${comp}                #unique id for these tests
set id            = {$date_str}_{$unqid}_{$cat_short}_${comp}                #unique id for these tests

echo '->Copy XML folder file to the case directory...'
cd $locdir
/bin/cp -rf $src_code/$scr_dir/ccsm_utils/Tools/perl5lib/XML $csmroot_new/$id/

set csmroot       = $csmroot_new/$id
set cprnc_exe     = /home/sing201/acme/tools/cprnc_nag/cprnc
echo '->Launch tests for '$comp '...'
source $script_path || echo 'Error runing test script' && exit -1
echo '->Clean up for '$comp '...'
unset comp
unset csmroot
unset ver
