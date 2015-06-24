#!/bin/csh
#set echo verbose
#set active_ln_num = `showq | grep -n 'active jobs-' | grep -o '^[0-9]*'`
set elig_ln_num   = `showq | grep -n 'eligible jobs-' | grep -o '^[0-9]*'`
set user_ln_num = `showq | grep -n $LOGNAME | grep -o '^[0-9]*'`

set i = 0
foreach job ($user_ln_num)
    @ i = $i + 1
    if ( $user_ln_num[$i] > $elig_ln_num ) then
	@ pos_in_q = ( $user_ln_num[$i] - $elig_ln_num ) - 2
	echo Rank: $pos_in_q
    else
	 echo 'Job is Running'
    endif
end
echo queue looks like:
showq |grep $LOGNAME
