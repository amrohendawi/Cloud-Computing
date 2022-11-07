#!/bin/sh
# when called for the first time creates new file gcp_results.csv and adds the header to it
FILE=gcp_results.csv
if ! test -f "$FILE"; then
    echo ">>>>> initiating new file gcp_results for the first time.. <<<<<"
    echo "time,cpu,mem,diskRand,diskSeq" > gcp_results.csv
fi
# initiates new 1GB test_file for sysbench. does nothing if the file already exists
sysbench fileio --file-num=1 --file-total-size=1G prepare
# collect the measurements using sysbench
echo ">>>>> collecting timeseries.. this should take approx. 4 minutes to finish <<<<<"
D=$(date '+%s')
echo "minute 1: collecting cpu bench"
S1=$(sysbench cpu --time=60 run | grep -oP 'events\sper\ssecond:\s*\K.*')
echo "minute 2: collecting memory bench"
S2=$(sysbench memory --time=60 --memory-block-size=4K --memory-total-size=100T run | grep -oP 'MiB\stransferred\s\(\K[0-9.]*')
echo "minute 3: collecting random read bench"
S3=$(sysbench fileio --time=60 --file-test-mode=rndrd --file-num=1 --file-total-size=1G --file-extra-flags=direct run | grep -oP 'read,\sMiB/s:\s*\K[0-9\.]*')
echo "minute 4: collecting sequential read bench"
S4=$(sysbench fileio --time=60 --file-test-mode=seqrd --file-num=1 --file-total-size=1G --file-extra-flags=direct run | grep -oP 'read,\sMiB/s:\s*\K[0-9\.]*')
# concatenate the measurements as time,cpu,mem,diskRand,diskSeq and add them to gcp_results.csv
TIMESERIES="$D,$S1,$S2,$S3,$S4"
echo "adding ${TIMESERIES} and terminating"
echo "${TIMESERIES}" >> gcp_results.csv
# cleaning up the 1GB created test_file
sysbench fileio cleanup