FROM ubuntu:18.04
WORKDIR /usr/src
RUN apt-get update && apt-get -y install sysbench clang iperf3 bc make
COPY benchmark.sh /usr/src
COPY forkbench.c /usr/src
ENTRYPOINT ["sh", "benchmark.sh"]