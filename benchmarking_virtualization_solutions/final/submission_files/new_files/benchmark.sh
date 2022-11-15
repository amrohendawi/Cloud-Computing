#!/bin/sh
# initiates new 1GB test_file for sysbench
TIME=60                          # TODO: before final submission set it back to 60 
HOST_IP=iperf.scottlinux.com # if this doesnt work please add the host external IP manually

uplink=$(iperf3 -c $HOST_IP --parallel 5 --version4 -f m --time $TIME | tail -n 3 | awk '/\[SUM\]/{print $6}')

# concatenate the measurements as time,cpu,mem,diskRand,diskSeq and add them to gcp_results.csv
echo "$uplink"
