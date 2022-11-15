d=$(iperf3 -s -f Mbits) & p=$pid
S6=$(iperf3 -c localhost --parallel 5 --version4 -f Mbits --time 10)
dump=$(trap "kill $p" SIGINT)

echo "bka bkas"