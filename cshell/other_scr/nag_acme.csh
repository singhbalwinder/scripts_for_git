#!/bin/csh
echo '------------------------------------------'
echo 'Running '$cat' tests: NAG Compiler'
echo '------------------------------------------'
set comp = nag                                        #compiler name
echo '->Form baseline id...' 
#set id            = {$unqid}_{$hsh}_mstr_{$cat_short}_{$date_str}_${comp}                #unique id for these tests
set id            = {$date_str}_{$unqid}_{$cat_short}_${comp}                #unique id for these tests

echo '->Copy XML folder file to the Intel case directory...'
cd $locdir
/bin/cp -rf $src_code/scripts/ccsm_utils/Tools/perl5lib/XML $csmroot_new/$id/

/bin/rm -f $csmroot_new/$id/$id.info
echo 'Branch info [see * for the branch used]:'        >> $csmroot_new/$id/$id.info
cat $tmp_brnch_file_path                               >> $csmroot_new/$id/$id.info
echo ''                                                >> $csmroot_new/$id/$id.info
echo 'Hash:'                                           >> $csmroot_new/$id/$id.info
echo $hsh                                              >> $csmroot_new/$id/$id.info

set csmroot       = $csmroot_new/$id
set cprnc_exe     = /home/sing201/acme/tools/cprnc_nag/cprnc
echo '->Launch tests for '$comp '...'
source $script_path
echo '->Clean up for '$comp '...'
unset comp
unset csmroot
unset ver
