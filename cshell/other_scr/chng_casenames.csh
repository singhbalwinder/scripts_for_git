#!/bin/csh                                                                                                                                                                 
#set echo verbose                                                                                                                                                          
if ( $#argv == 2 ) then
    set string_old = $1
    set string_new = $2
else
    echo 'invalid # of arguments:' $#argv '  ...exiting...'
    echo 'Please supply only 2 arguments...'
    exit(1)
endif

#USER INPUT ENDS ###                                                                                                                                                       
echo ''
echo '-> Changing contents of the file...'
sed "s/$string_old/$string_new/g" $string_old>tmp1
echo '-> Changing file name ....'
cp tmp1 $string_new

rm -rf tmp1 $string_old
if ( -e mods_{$string_old} ) then
    set num_mods_dir = `ls -ld mods_*|wc -l`
    if ( $num_mods_dir == 1 ) then
	echo ''
	echo '-> Changing name of the mods directory...'
	mv mods_* mods_$string_new
	echo '-> Name of mods directory changed '
    else
	echo ''
	echo 'ERROR :: mods directory not found OR more than one mods dir...'
	echo 'Please check to see'
    endif
endif

#see if we need to modify _DUMMY script also                                                                                                                               
if ( -e {$string_old}_DUMMY ) then
    set num_file = `ls -l {$string_old}_DUMMY |wc -l` 
    if ( $num_file == 1 ) then
    echo '-> Changing name of the DUMMY script...'
    sed "s/$string_old/$string_new/g" {$string_old}_DUMMY>tmp1
    cp tmp1 {$string_new}_DUMMY
    rm -rf tmp1 {$string_old}_DUMMY
    echo '-> Name of DUMMY script changed '
    endif
endif



