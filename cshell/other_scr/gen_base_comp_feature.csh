#!/bin/csh
#xxxxxxxxxxxxxxxxxxxxxx STUB for wrapper script xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
##!/bin/csh
#set feat_brnch_name  = kaizhangpnl/atm/bugfix_MG1 #Name of the branch
#set feat_brnch_path  = mg1_bugfix_integ           #Path to feature branch [Assuming this script is at same dir level as the feat branch]

#set main_brnch_name  = master                     #Name of the branch from which feat branch was branched off
#set tmp_dir_path     = /dtemp/sing201/tmp-acme    #Temporary space clone code

#set unique_id        = mg1bug                     #A "short" unique id

#set cat              = acme_developer
#set cat_short        = acme_dev                   #Keep it short

#set mach             = cascade
#set csmrun_old       = /dtemp/sing201/csmruns     #csmrun directory mentioed in the config_machines.xml

#set script_path      = ~sing201/trialProgs/cshell/bsingh_create_test_ver2.csh #script to invoke to run all the tests
#set intel_scr_path   = ~/scripts_for_git/cshell/other_scr/intel_acme.csh
#set nag_scr_path     = ~/scripts_for_git/cshell/other_scr/nag_acme.csh

#various control options
#set clone_fresh_code = 0                          #0: Do not clone fresh copy of main branch, code already exist; 1:clone fresh copy of the main branch code

#set do_nag           = 0                          #1=Use NAG ; 0= Do not use NAG
#set do_int           = 1                          #1=Use INTEL ; 0= Do not use INTEL


##====================================================================================
###USER INPUT ENDS - Do not modify code below this line unless you are absolutely sure
##====================================================================================

#set locdir = `pwd`
#source ~/scripts_for_git/cshell/other_scr/gen_base_comp_feature.csh

#xxxxxxxxxxxxxxxxxxxxxx STUB for wrapper script ends xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

#====================================================================================
## Find the root of the branch on the main branch
#====================================================================================
echo '--> Get hash of the root of feature branch'
cd $feat_brnch_path
git rev-list --first-parent $feat_brnch_name >& tmp.feat_branch.hash
git rev-list --first-parent $main_brnch_name >& tmp.main_branch.hash

set hsh = `diff -u tmp.feat_branch.hash tmp.main_branch.hash |sed -ne 's/^ //p' | head -1`
echo '--> Hash of the root is: '$hsh
/bin/rm -rf tmp.feat_branch.hash tmp.main_branch.hash


#====================================================================================
## Clone the code and checkout the hash which is root of the feature
#====================================================================================
set date_str = `date +"%m%d%Y"`
cd $tmp_dir_path
/bin/mkdir -p {$date_str}_{$unique_id}
cd {$date_str}_{$unique_id}
if ( $clone_fresh_code == 1 ) then
    /bin/rm -rf ACME
    echo '--> Clone a fresh copy of the code'
    git clone git@github.com:ACME-Climate/ACME.git >& /dev/null
    cd ACME
    echo '--> Checkout hash of root [this is the point where feature branch branched off]'
    echo '--> ========= Output from git checkout ==========='
    git checkout $hsh    
    echo '--> ========= Output from git checkout ENDS==========='
else
    echo '--> Use an existing code as main branch code'
    cd ACME
endif
#generate branch info
git branch >& tmp.branch.info
set tmp_brnch_file_path = `pwd`/tmp.branch.info
set src_code = `pwd`
    
set comp_base        = 0                       #1=compare with baselines; 0= DO NOT compare with  baselines
set comp_base_id     = ''                      #id or name of the baseline directory to compare against
    
set unqid            = {$unique_id}_base       #short unique id to append to these tests
set csmroot_new      = $locdir                 #Directory where all files from this testing are stored
set base_dir         = $locdir/baselines       #Baseline to compare against
set gen_base         = 1                       #1=generate baselines; 0= DO NOT generate baselines
    
/bin/mkdir -p $base_dir
#Now run the tests for each compiler
if ( $do_nag == 1 ) then
    source $nag_scr_path   || echo "Error runing test cases for Nag" && exit -1
    set nag_id = $id
    unset id
endif
if ( $do_int == 1 ) then
    source $intel_scr_path || echo 'Error runing test cases for Intel' && exit -1
    set int_id = $id
    unset id
endif
/bin/rm -rf $tmp_brnch_file_path
unset tmp_brnch_file_path hsh unqid gen_base



#====================================================================================
## Run tests on feature branch and compare it against baselines generated above
#====================================================================================
echo '-------------------------------------------------------------------------------'
echo 'Run tests on feature branch to compare against baselines'
echo '-------------------------------------------------------------------------------'
cd $locdir
cd $feat_brnch_path
set hsh      = `git rev-parse --verify HEAD | head -n 1`
#generate branch info
git branch >& tmp.branch.info
set tmp_brnch_file_path = `pwd`/tmp.branch.info
set date_str = `date +"%m%d%Y"`
set src_code = `pwd`


set comp_base        = 1                       #1=compare with baselines; 0= DO NOT compare with  baselines
set unqid            = {$unique_id}_comp       #short unique id to append to these tests
set csmroot_new      = $locdir                 #Directory where all files from this testing are stored
set base_dir         = $locdir/baselines       #Baseline to compare against
set gen_base         = 0                       #1=generate baselines; 0= DO NOT generate baselines


#Now run the tests for each compiler
if ( $do_nag == 1 ) then
    set comp_base_id     = 'baselines_'{$nag_id}                      #id or name of the baseline directory to compare against
    source $nag_scr_path    
endif
if ( $do_int == 1 ) then
    set comp_base_id     = 'baselines_'{$int_id}                      #id or name of the baseline directory to compare against
    source $intel_scr_path
endif
/bin/rm -rf $tmp_brnch_file_path















