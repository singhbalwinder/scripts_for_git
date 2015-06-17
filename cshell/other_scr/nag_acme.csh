echo '------------------------------------------'
echo 'Running '$cat' tests: NAG Compiler'
echo '------------------------------------------'
set comp = nag                                        #compiler name
set ver  = {$comp}531mpi19ncdf430

echo '->Form baseline id...' 
set id            = id01_{$hsh}_acme_master_{$cat}_{$date_str}_${ver}                #unique id for these tests
set csmroot       = $csmroot_new/$id

echo '->Launch tests for '$comp '...'
source $script_path
echo '->Clean up for '$comp '...'
unset comp
unset csmroot
unset id
unset ver
