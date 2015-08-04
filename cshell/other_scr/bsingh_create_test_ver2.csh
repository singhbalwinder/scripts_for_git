#!/bin/csh
echo ''
echo '**********************************************************'
echo '         RUNNING '$cat 'tests for compiler:'$comp 
echo '**********************************************************'
echo ''

echo 'Gather information about the code (hash etc.)...'
cd $src_code
#set hsh      = `git rev-parse --short=10 --verify HEAD | head -n 1`
set hsh      = `git rev-parse --verify HEAD | head -n 1`
echo ''
echo 'Hash of the code is:' $hsh
echo ''

#Generate branch info
git branch >& tmp.branch.info
set tmp_brnch_file_path = `pwd`/tmp.branch.info

cd $src_code/scripts

set gen_base_str       = ''
set comp_base_str      = ''
set gen_comp_in_dir_nm = ''
set clean_opt = OFF
if ( $clean_build_aft_run == 1 ) then
    set clean_opt = ON
endif
echo 'Cleaning up of the build obj files after tests are run is:'$clean_opt
set gen_comp_in_dir_nm = '.'
if ( $gen_base == 1 ) then
    set id_base_dir = 'baselines_'{$id}
    set gen_base_str =  '-generate '$id_base_dir
    set gen_comp_in_dir_nm = '.G.' #append G
    echo 'Generating baselines with id: '$id
else
    echo 'Not generating baselines...'
endif    


if ( $comp_base == 1 ) then
    set comp_base_str =  '-compare '$comp_base_id
    set gen_comp_in_dir_nm = '.C.' #append C
    echo 'Comparing with baselines: '$comp_base_id
    #see if the beaselines directory exists ********* FUTURE WORK ****
else
    echo 'Not comparing with baselines...'
endif    

if ( $gen_base == 1 && $comp_base == 1) then
    set gen_comp_in_dir_nm = '.GC.' #append GC
    echo 'Generating new baselines and comparing against old baselines...'
endif

#Go to the folder where manage_xml_entries script is and query it to get all test case names:
echo 'Obtaining test case names using manage_xml_entries ...'
ccsm_utils/Testlistxml/manage_xml_entries -query -outputlist -machine $mach -compiler $comp -category $cat >& tmp_test_names
echo 'Got the names from manage_xml_entries ...'


set tot_lines = `cat tmp_test_names| wc -l` 
@ tot_lnprnt  = $tot_lines - 2 # subtract 2 as first two lines in tmp_test_names are comments with '#'
set quit_scr = 0
if ( $tot_lnprnt == 0 ) then 
    echo ''
    echo '========================================================'
    echo 'ERROR: please check the test category name, you entered:' $cat
    echo $tot_lnprnt ' test case(s) found for this category'
    echo 'EXITING the script \!! ....'
    exit -1
endif
echo 'Total # of test cases in this category:'$tot_lnprnt

#Note: Do not build the test cases and of course do not run the test cases [-autosubmit off; -nobuild on]
echo ''
echo 'Calling create_test script...  ' `date`
./create_test -xml_mach $mach -xml_compiler $comp -xml_category $cat -testid $id -testroot $csmroot -baselineroot $base_dir $gen_base_str $comp_base_str  -autosubmit off -nobuild on -clean $clean_opt >& log_{$id}

#See if the script encountered any error
set err_cnt     = `grep -i error log_{$id}|wc -l`
set abort_cnt   = `grep -i abort log_{$id}|wc -l`
@ tot_err_cnt = $err_cnt + $abort_cnt

if ( $tot_err_cnt > 0 ) then
    echo 'Encountered '$tot_err_cnt ' error(s) while running create_test script'
    echo 'Please check the log file:' `pwd`/log_{$id}
    echo 'Exiting...'
    exit -1
endif

echo 'Calling create_test script...DONE\!!\!!  ' `date`
echo ''
#Loop through all the test cases to build them and submit the script
set iline = 1
echo 'Looping through testcases ...'
#set echo verbose
while ( $iline <= $tot_lines)
    #read each line in the file
    set line    = `awk -v ln=$iline '{if (NR==ln) print $0}' tmp_test_names` #extract each line in the file
    if( `echo $line | cut -c1` != '#' ) then #ignore first two line in the file with "#" in front of them
        set CASE = {$line}{$gen_comp_in_dir_nm}{$id}
	@ lnprnt = $iline - 2 # subtract 2 as first two lines in tmp_test_names are comments with '#'
	echo ''
	echo '['$lnprnt' of '$tot_lnprnt'] Processing testcase:'$CASE '--- [Test case #:'$lnprnt';Total testcases:'$tot_lnprnt']'
	#Delete if a case is created in the regular csmruns directory
	/bin/rm -rf $csmrun_old/$CASE
	/bin/rm -rf $csmrun_old/sharedlibroot.{$id}
	#Modify xml files now and build the model
	cd $csmroot
	cd $CASE
	#Modify xml files
	echo '      Modifying xml enteries for testcase:'$CASE
	./xmlchange -file env_build.xml -id CESMSCRATCHROOT  -val $csmroot/csmruns
	./xmlchange -file env_build.xml -id EXEROOT          -val $csmroot/csmruns/$CASE/bld
        ./xmlchange -file env_build.xml -id SHAREDLIBROOT    -val $csmroot/csmruns/sharedlibroot.{$id}
        ./xmlchange -file env_run.xml   -id RUNDIR           -val $csmroot/csmruns/$CASE/run
	./xmlchange -file env_run.xml   -id DOUT_S_ROOT      -val $csmroot/archive/$CASE
	./xmlchange -file env_run.xml   -id BFBFLAG          -val TRUE
	./xmlchange -file env_test.xml  -id CCSM_CPRNC       -val $cprnc_exe 
	echo '      Building testcase:'$CASE `date`
	#Build the model
	./$CASE.test_build >& log_bld

        echo '      Submitting testcase:'$CASE `date`
	#Submit the run
	./$CASE.submit >& /dev/null
	cd $src_code/scripts
	echo '      '$CASE 'DONE\!!\!!'
    endif
    @ iline  = $iline + 1
end
if ( $gen_base == 1 ) then
    echo 'Generate baseline code info file in baseline directory'
    /bin/cd $base_dir/$id_base_dir
    /bin/rm -rf $id.info
    echo 'Branch info [see * for the branch used]:'        >> $id.info
    cat $tmp_brnch_file_path                               >> $id.info
    echo ''                                                >> $id.info
    echo 'Hash:'                                           >> $id.info
    echo $hsh 
    #Remove temporary file
    /bin/rm -rf $tmp_brnch_file_path
endif
echo 'Removing temporary files...'
cd $src_code/scripts
/bin/rm tmp_test_names
/bin/mv log_{$id} $locdir/
echo 'ALL DONE\!!\!!'






