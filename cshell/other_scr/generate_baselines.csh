#!/bin/csh

#-------------------------------------#
#-------------------------------------#
### Settings which may need to be changed frequently 
#-------------------------------------#
#-------------------------------------#

#For comparing to a baseline
set comp_base     = 1                                         #1=compare with baselines; 0= DO NOT compare with  baselines
set comp_base_id  = 'baselines_id01_f8c16cef46_03312015_nag531mpi19ncdf430'         #id or name of the baseline directory to compare against

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
set csmrun_old    = /dtemp/sing201/csmruns                     #csmrun directory mentioed in the config_machines.xml
set csmroot_new   = /dtemp/sing201/acme_testing/reg_tests/     #Directory where all files from this testing are stored
set base_dir      = /dtemp/sing201/acme_testing/acme_baselines #Baseline to compare against
set script_path   = ~sing201/trialProgs/cshell/bsingh_create_test_ver2.csh #script to invoke to run all the tests

#for generating baseline
set gen_base      = 1                                         #1=generate baselines; 0= DO NOT generate baselines

#xxxxxxxxxxxxxxxxxx  USER INPUT ENDS xxxxxxxxxxxxxxxxxxxxxx
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx





###WARNING:DO NOT modify the following code unless you are absolutely sure about it!!

set mach   = cascade                                    #machine name
set locdir = `pwd`

echo '->Clone fresh copy of the code...'
git clone $git_clone >& /dev/null
cd ACME
set src_code = `pwd`

echo '->Fetch and reset hard so that source code points to most recent copy of the master branch ...'
git fetch origin >& /dev/null
git reset --hard origin/master >& /dev/null


echo '->Get the hash to form file name ...'
set hsh      = `git rev-parse --short=10 --verify HEAD | head -n 1`
set date_str = `date +"%b_%d_%Y"`

#Now run the tests for each compiler 
#Run tests for acme integration as acme_developer is subset of acme_integration
set cat      = acme_integration

source $locdir/nag_acme.csh
source $locdir/intel_acme.csh


echo '->Finally delete the code...'
cd $locdir
/bin/rm -rf ACME

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
