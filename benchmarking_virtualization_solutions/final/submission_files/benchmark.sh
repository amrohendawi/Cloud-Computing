#!/bin/sh
# initiates new 1GB test_file for sysbench
sysbench fileio --file-num=1 --file-total-size=1G prepare --verbosity=0
TIME=60                          # TODO: before final submission set it back to 60 
HOST_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)  # if this doesnt work please add the host external IP manually

FORKBENCH_RANGE=400
# collect the measurements using sysbench
D=$(date '+%s')
S1=$(sysbench cpu --time=$TIME run | grep -oP 'events\sper\ssecond:\s*\K.*')
S2=$(sysbench memory --time=$TIME --memory-block-size=4K --memory-total-size=100T run | grep -oP 'MiB\stransferred\s\(\K[0-9.]*')
S3=$(sysbench fileio --time=$TIME --file-test-mode=rndrd --file-num=1 --file-total-size=1G --file-extra-flags=direct run | grep -oP 'read,\sMiB/s:\s*\K[0-9\.]*')
S4=$(sysbench fileio --time=$TIME --file-test-mode=seqrd --file-num=1 --file-total-size=1G --file-extra-flags=direct run | grep -oP 'read,\sMiB/s:\s*\K[0-9\.]*')

# suppress stderr prints in forkbench.c
exec 2> /dev/null
# -Wno-everything suppresses all clang warnings to keep echo clean. 400 is enough to run forkbench a few seconds
ignore=$(make CFLAGS="-Wno-everything" forkbench)
end_fb=$(($(date +%s) + $TIME ))
sum_fb=0
i=0
while [ $(date +%s) -lt $end_fb ]; do
    result=$(./forkbench 1 $FORKBENCH_RANGE)
    i=$((i+1))
    sum_fb=$(echo "$sum_fb + $result" | bc)     
done
avg_fb=$(echo "scale=2;$sum_fb / $i" | bc)  # Calculate forks-per-second average. scale=2 keeps 2 digit floating point in the result
uplink=$(iperf3 -c $HOST_IP --parallel 5 --version4 -f m --time $TIME | tail -n 3 | awk '/\[SUM\]/{print $6}')

# concatenate the measurements as time,cpu,mem,diskRand,diskSeq and add them to gcp_results.csv
echo "$D,$S1,$S2,$S3,$S4,$avg_fb,$uplink"
# cleaning up the 1GB created test_file
sysbench fileio cleanup --verbosity=0
