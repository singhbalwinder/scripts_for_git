#!/bin/csh

#-------------------------------------#
#-------------------------------------#
### Settings which may need to be changed frequently 
#-------------------------------------#
#-------------------------------------#

#For comparing to a baseline
set comp_base        = 0                                         #1=compare with baselines; 0= DO NOT compare with  baselines
set comp_base_id     = ''         #id or name of the baseline directory to compare against

set unqid            = id02       #short unique id to append to these tests

set do_nag           = 1          #1=generate NAG baselines; 0=Do not generate NAG baselines 
set do_int           = 0          #1=generate Intel baselines; 0=Do not generate Intel baselines 

set clone_fresh_code = 0          #1-clone fresh copy of the code; 0=Use existing copy of the code

#NOTE: acme_developer is subset of acme_integration
#set cat        = acme_integration
#set cat_short  = acme_int #keep it short

#set cat        = acme_developer
#set cat_short  = acme_dev #keep it short

set cat        = acme_balli
set cat_short  = acme_bal #keep it short


#-------------------------------------#
#-------------------------------------#
### Settings which may need to be changed occasionally 
#-------------------------------------#
#-------------------------------------#

#Directory for storing scripts used for generating these baselines:
set dir_to_store  = baselines_by_date

#Settings common for both compilers
set git_clone     = 'git@github.com:ACME-Climate/ACME.git'

#paths
set csmrun_old     = /dtemp/sing201/csmruns                     #csmrun directory mentioed in the config_machines.xml
set csmroot_new    = /dtemp/sing201/acme_testing/reg_tests/     #Directory where all files from this testing are stored
set base_dir       = /dtemp/sing201/acme_testing/acme_baselines #Baseline to compare against
set script_path    = ~sing201/trialProgs/cshell/bsingh_create_test_ver2.csh #script to invoke to run all the tests
set intel_scr_path = ~/scripts_for_git/cshell/other_scr/intel_acme.csh
set nag_scr_path   = ~/scripts_for_git/cshell/other_scr/nag_acme.csh


#for generating baseline
set gen_base      = 1                                         #1=generate baselines; 0= DO NOT generate baselines

#xxxxxxxxxxxxxxxxxx  USER INPUT ENDS xxxxxxxxxxxxxxxxxxxxxx
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





###WARNING:DO NOT modify the following code unless you are absolutely sure about it!!

if($do_nag != 1 && $do_int != 1) then
    echo 'Please select atleast one compiler to run test with...'
    echo 'Exiting ....'
    exit
endif

set mach   = cascade                                    #machine name
set locdir = `pwd`

if ( $clone_fresh_code == 1 ) then
    echo '->Clone fresh copy of the code...'
    git clone $git_clone >& /dev/null
    echo '->Fetch and reset hard so that source code points to most recent copy of the master branch ...'
    git fetch origin >& /dev/null
    git reset --hard origin/master >& /dev/null
else
    echo '->Using existing code [DID NOT clone fresh copy]...'
endif
if ( !(-d ACME) ) then
    echo 'Code does not exists...enable option to download fesh copy of the code'
    echo 'exiting.....'
    exit
endif

cd ACME
set src_code = `pwd`


echo '->Get the hash of the code ...'
#set hsh      = `git rev-parse --short=10 --verify HEAD | head -n 1`
set hsh      = `git rev-parse --verify HEAD | head -n 1`

#generate branch info
git branch >& tmp.branch.info
set tmp_brnch_file_path = `pwd`/tmp.branch.info
set date_str = `date +"%m%d%Y"`

#Now run the tests for each compiler 
if ( $do_nag == 1 ) then
    source $nag_scr_path
endif
if ( $do_int == 1 ) then
    source $intel_scr_path
endif

/bin/rm -rf $tmp_brnch_file_path

if ( $clone_fresh_code == 1 ) then
    echo '->Finally delete the code...'
    cd $locdir
    /bin/rm -rf ACME
endif

echo '->Move files to a dated folder'
cd $locdir/$dir_to_store
/bin/mkdir -p $date_str

cd $locdir
/bin/mv $locdir/log* $locdir/$dir_to_store/$date_str/

#Get all the script files
set all_scr_files = `ls *.csh`
foreach file ($all_scr_files)
    echo '->Copying file:'$file' to '/$dir_to_store/$date_str/copy_of_{$file}
    /bin/cp $locdir/$file $locdir/$dir_to_store/$date_str/copy_of_{$file}
end
